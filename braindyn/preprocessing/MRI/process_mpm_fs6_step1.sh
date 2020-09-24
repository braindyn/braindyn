#!/bin/bash
#==============================================================================
# Created by James Bonaiuto on 4th November 2019
# Based on NSPN_mpm_bet_mask.sh created by Kirstie Whitaker on 13th April 2016
# and scripts created by Fred Dick, Marty Sereno, and Bruce Fischl
#
# DESCRIPTION:
#    This code conducts a brain and head extraction of the PDw image.
#      It then uses the head mask to set all voxels outside of the head to
#      zero for the quantitative MPM images and uses the brain mask to create
#      brain extracted versions of the MPM images (where all voxels outside of
#      the brain have been set to zero.
#    It then creates a synthetic MPRAGE volume from the MPMs for use with
#    freesurfer and runs recon-all
#
# USAGE:
#    process_mpm_fs6_step1.sh <subject_id> <data_directory>
#
# INPUTS:
#    subject_id : ID of the subject
#    data_directory: path to the PDw and MPM images
#
# EXPECTS:
#    The following files should be in the data directory:
#
#        R1.nii         MT.nii
#        R2s.nii        A.nii
#        PDw.nii
#====================================================================

## grab input args
sub=$1
datadir=$2
r1vol=R1.nii
pdvol=A.nii
pdwvol=PDw.nii

#====================================================================
# Check the input files are there
#====================================================================

if [[ ! -f $datadir/${r1vol} ]]; then
    echo "R1 file does not exist"
fi

if [[ ! -f $datadir/${pdvol} ]]; then
    echo "PDw file does not exist"
fi


if [[ ! -f $datadir/${pdwvol} ]]; then
    echo "PDw file does not exist"
fi

## check if mgh freesurfer setup
if [ -z "$FREESURFER_HOME" ]; then
 	echo "You need to setup freesurfer environment and run again"
	exit
fi

## check freesurfer dir exists!
if [[ ! -d $FREESURFER_HOME ]]; then
 	echo "I can't find MGH freesurfer, please make sure it exists"
 	exit
fi

source $FREESURFER_HOME/FreeSurferEnv.sh

## check if SUBJECTS_DIR exists
if [[ ! -d $SUBJECTS_DIR ]]; then
 	echo "I can't find SUBJECTS_DIR!"
 	exit
fi

## check if datadir exists
if [[ ! -d $datadir ]]; then
 	echo "$datadir does not exist, please make sure datadir is correct"
 	exit
fi

## confirm name assignment
echo "Subject is $sub, DataDir is $datadir"
echo  "R1-Vol is $r1vol, PD-Vol is $pdvol"

#====================================================================
# Set a couple of variables
#====================================================================
bet_dir=${datadir}/PDw_BrainExtractionOutput/

orig_filename_list=(PDw)
calc_filename_list=(A MT R1 R2s)

#====================================================================
# Do the brain extraction on the PDw file
#====================================================================
mkdir -p ${bet_dir}

echo "  Conducting brain and head extraction"

# Run brain extraction with the -A flag to get skull and
# scalp images too
if [[ ! -f ${datadir}/PDw_brain.nii.gz ]]; then
    bet $datadir/${pdwvol} ${bet_dir}/PDw_brain.nii.gz -A
fi

# Erode the brain mask by 3mm
if [[ ! -f ${datadir}/PDw_brain_ero3.nii.gz ]]; then
    fslmaths ${bet_dir}/PDw_brain.nii.gz -ero ${bet_dir}/PDw_brain_ero3.nii.gz
fi

#====================================================================
# Now make the brain and head files for each of the
# calculated MPM files
#====================================================================
echo -n "  Applying masks"
for f_name in ${calc_filename_list[@]}; do

    # Don't run if it's already complete!
    if [[ ! -f ${datadir}/${f_name}_head.nii.gz ]]; then
        echo -n " - ${f_name}"
        fslmaths ${bet_dir}/PDw_brain_ero3.nii.gz \
                    -bin \
                    -mul ${datadir}/${f_name}.nii.gz \
                    ${datadir}/${f_name}_brain.nii.gz

        fslmaths ${bet_dir}/PDw_brain_outskin_mask.nii.gz \
                    -bin \
                    -mul ${datadir}/${f_name}.nii.gz \
                    ${datadir}/${f_name}_head.nii.gz
    fi
done # Close the mpm calculated file loop
echo ""

# Scale R1
3dcalc -a $datadir/$r1vol -prefix $datadir/$sub-R1-vol-scale.nii -expr 'a*1000'

## To create the appropriate PD for input to mri_synthesize
##  remove all of the negative values and scale
## Here, $pdvol is the quantitative PD calculated by VBQ Toolbox
3dcalc -a $datadir/$pdvol -prefix $datadir/$sub-PD-vol-noneg-scale.nii -expr '(a*step(a))*100'

## R1 volume ($r1vol) is created by VBQ toolbox,
## needs to be  T1 (e.g., 1/R1) and also truncated,
## with no negative values, and scaled
3dcalc -a $datadir/$sub-R1-vol-scale.nii -prefix $datadir/$sub-T1.nii -expr '1000/(a/1000)'
3dcalc -a $datadir/$sub-T1.nii -prefix $datadir/$sub-T1-mask.nii -expr 'within(a,0,8000)'
3dcalc -a $datadir/$sub-T1-mask.nii -b $datadir/$sub-T1.nii -prefix $datadir/$sub-T1-trunc.nii -expr 'a*b'

## Output of mri_synthesize help is:
## usage: mri_synthesize [options] <TR> <alpha (deg)>
## <TE> <T1 volume> <PD volume> <output volume>
## The -w switch will use a fixed weighting in order
## to generate an output volume with optimal gray/white contrast
## It seems to need those three parameters, but
## ignores them....
mri_synthesize -w 20 30 2.5 $datadir/$sub-T1-trunc.nii $datadir/$sub-PD-vol-noneg-scale.nii $datadir/$sub-synth.nii

## Then make *another* copy with more normal mprage-like weighting
## for the talairaching *only*
mri_synthesize 20 30 2.5 $datadir/$sub-T1-trunc.nii $datadir/$sub-PD-vol-noneg-scale.nii $datadir/$sub-tal.nii

## Finally eliminate extreme values and scale
## This should get signal values into correct ballpark (80 < wm < 120)
## NOTE - the scaling factor may have to be a variable
## I am setting it so that it is easy to find.
## NOTE - larger scale number means lower vals as is denominator
scale=4
3dcalc -a $datadir/$sub-synth.nii -prefix $datadir/$sub-synth-trunc-scale.nii.gz -expr '(a*(within(a,0,700))/'$scale')'
3dcalc -a $datadir/$sub-tal.nii -prefix $datadir/$sub-tal-trunc-scale.nii.gz -expr '(a*(within(a,0,700))/'$scale')'

## Make a conformed mgz volume for csurf
mri_convert --conform --no_scale 1 $datadir/$sub-synth-trunc-scale.nii.gz $datadir/$sub-synth-trunc-conform.mgz
mri_convert --conform --no_scale 1 $datadir/$sub-tal-trunc-scale.nii.gz $datadir/$sub-tal-trunc-scale.mgz

# Apply brain mask
fslmaths $datadir/PDw_BrainExtractionOutput/PDw_brain_ero3.nii.gz -bin -mul $datadir/$sub-synth-trunc-scale.nii.gz $datadir/$sub-synth-trunc-scale_brain.nii.gz
mri_convert --conform --no_scale 1 $datadir/$sub-synth-trunc-scale_brain.nii.gz $datadir/brain.mgz

recon-all -subjid $sub-synth -motioncor -i $datadir/brain.mgz -openmp 3

mri_normalize -g 1 $SUBJECTS_DIR/$sub-synth/mri/orig.mgz $SUBJECTS_DIR/$sub-synth/mri/T1.mgz
cp $SUBJECTS_DIR/$sub-synth/mri/T1.mgz $SUBJECTS_DIR/$sub-synth/mri/nu.mgz
cp $SUBJECTS_DIR/$sub-synth/mri/orig.mgz $SUBJECTS_DIR/$sub-synth/mri/brainmask.mgz
cp $SUBJECTS_DIR/$sub-synth/mri/orig.mgz $SUBJECTS_DIR/$sub-synth/mri/rawavg.mgz

mri_em_register -mask $SUBJECTS_DIR/$sub-synth/mri/brainmask.mgz $datadir/$sub-tal-trunc-scale.mgz $FREESURFER_HOME/average/RB_all_2016-05-10.vc700.gca $SUBJECTS_DIR/$sub-synth/mri/transforms/talairach.lta
recon-all -subjid $sub-synth -canorm -careg -careginv

# Check registration to fsaverage
tkmedit $sub-synth T1.mgz -main-transform talairach.lta -aux $SUBJECTS_DIR/fsaverage3/mri/T1.mgz

