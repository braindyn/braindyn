function mri = ReadPreprocMRI(my_cfg)

% --> Using anatomical data (anatomical MRI):
% --> Segmentation works properly when the voxels of the anatomical images are homogenous (using 'ft_volumereslice').
% --> check the coordinate-system of the MRI, align the anatomical MRI (before the segmentation) into the same coordinate
% ... system in which the electrodes will be expressed.

if exist(my_cfg.MRIDir, 'file')
    choice = questdlg('The pre-processed MRI has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(my_cfg.MRIDir, 'file')

if my_cfg.recompute
    % --> read anatomical data (anatomical MRI) (it is the same file for all modalities):
    mri = ft_read_mri(my_cfg.MRILoad); % Read the anatomical data
    
    % --> align the anatomical data (MRI) into the the same electrodes (head) coordinate system (before the segmentation):
    if ~isfield(mri, 'hdr') % If the position of the anatomical landmarks (fiducials, e.g. LPA, RPA, NASion) are not specified in the volume,
        cfg = [];
        cfg.method = 'interactive';
        mri = ft_volumerealign(cfg, mri); % Creates a 4×4 homogenous affine transformation matrix from fiducials/landmarks using a right-handed convention
        fiducials.vox = [mri.cfg.fiducial.nas; mri.cfg.fiducial.lpa; mri.cfg.fiducial.rpa];
    else % If all the fiducials exist
        cfg = [];
        cfg.method = 'fiducial'; % The coordinate system is updated according to the defined fiducial points
        cfg.fiducial.nas = mri.hdr.fiducial.mri.nas; % Position of nasion
        cfg.fiducial.lpa = mri.hdr.fiducial.mri.lpa; % Position of LPA
        cfg.fiducial.rpa = mri.hdr.fiducial.mri.rpa; % Position of RPA
        mri = ft_volumerealign(cfg, mri); % Creates a 4×4 homogenous affine transformation matrix from fiducials/landmarks using a right-handed convention
        fiducials.vox = [mri.hdr.fiducial.mri.nas; mri.hdr.fiducial.mri.lpa; mri.hdr.fiducial.mri.rpa];
    end % if ~all(isfield(mri.hdr.fiducial.mri, {'nas', 'lpa', 'rpa'}))
    fiducials = IJKtransformXYZ(mri.transform, 'voxel', fiducials.vox);
    
    % --> Segmentation works properly when the voxels of the anatomical images are homogenous isotropic (have a uniform thickness for each slice)
    %     used it here to obtain a nicer orientation of the MRI images for visualization with ft_sourceplot.
    cfg = [];
    cfg.resolution = 1; % using 1 mm/cm thick slices
    cfg.dim = 256 * ones(1, 3); % This is the format which FreeSurfer works with
    mri = ft_volumereslice(cfg, mri);
    transformVox2MRIReslice = mri.transform;
    
    fiducials = IJKtransformXYZ(transformVox2MRIReslice, 'coordsys', fiducials.pnt);
    
    % --> Check and determine the coordinate-system of the anatomical data (anatomical MRI):
    if ~isfield(mri, 'coordsys') || ~strcmp(mri.coordsys, my_cfg.coordSys)
        mri = ft_determine_coordsys(mri);
        T = mri.transform / transformVox2MRIReslice; % ### FARDIN ###: To be verified
        fiducials = ft_transform_geometry(T, fiducials); % ### FARDIN ###: To be verified
        fiducials = IJKtransformXYZ(transformVox2MRIReslice, 'coordsys', fiducials.pnt); % ### FARDIN ###: To be verified
    end % if ~isfield(mri, 'coordsys') || ~strcmp(mri.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(mri, 'unit') || ~strcmp(mri.unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        mri = ft_convert_units(mri, my_cfg.unit);
        fiducials = ft_convert_units(fiducials, my_cfg.unit);
    end % if ~isfield(mri, 'unit') || ~strcmp(mri.unit, my_cfg.unit)
    
    mri.fiducials.ijk.nas = fiducials.vox(1, :);
    mri.fiducials.ijk.lpa = fiducials.vox(2, :);
    mri.fiducials.ijk.rpa = fiducials.vox(3, :);
    
    mri.fiducials.xyz.nas = fiducials.pnt(1, :);
    mri.fiducials.xyz.lpa = fiducials.pnt(2, :);
    mri.fiducials.xyz.rpa = fiducials.pnt(3, :);
    
    save(my_cfg.MRIDir, 'mri')
    fprintf('Pre-processed MRI was recomputed and saved.\n')
else
    load(my_cfg.MRIDir)
    fprintf('Pre-processed MRI was loaded.\n')
end

% --> visualizing the MRI:
if my_cfg.feedback.mri
    cfg = [];
    ft_sourceplot(cfg, mri);
end % if my_cfg.Feedback
