function segmentedMRI = VolumeSegment(my_cfg)
% --> Segment the anatomical data into different tissue types (quite time consuming, ~ 7 mins) (binary / Boolean Map OR tissue probability maps (tpm)):
% --> Only the brain, scalp and skull segmentations are used for creating volume conduction models of the head by triangulation the outside surface of the three tissues

if exist(my_cfg.segMRIDir, 'file')
    choice = questdlg('The segmented MRI has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.segMRIDir, 'file')

if my_cfg.recompute % If 'true' segments, if 'false', loads precomputed segmented MRI
    load(my_cfg.MRIDir) % Loads computed pre-processed MRI
    
    cfg = [];
    cfg.output = {'brain', 'skull', 'scalp'}; % Tissue types
    segmentedMRIBrain = ft_volumesegment(cfg, mri);
    transformVox2SegmentedMRIBrain = segmentedMRIBrain.transform;
    
    cfg = [];
    cfg.output = {'gray', 'white', 'csf'}; % Tissue types
    segmentedMRIGrayWhiteCSF = ft_volumesegment(cfg, mri);
    
    fiducials.vox = [mri.fiducials.ijk.nas; mri.fiducials.ijk.lpa; mri.fiducials.ijk.rpa];
    fiducials.pnt = [mri.fiducials.xyz.nas; mri.fiducials.xyz.lpa; mri.fiducials.xyz.rpa];

    % --> Check and determine the coordinate-system of the segmented anatomical data (anatomical MRI):
    if ~isfield(segmentedMRIBrain, 'coordsys') || ~strcmp(segmentedMRIBrain.coordsys, my_cfg.coordSys) || ~isfield(segmentedMRIGrayWhiteCSF, 'coordsys') || ~strcmp(segmentedMRIGrayWhiteCSF.coordsys, my_cfg.coordSys)
        fiducials = IJKtransformXYZ(transformVox2SegmentedMRIBrain, 'voxel', fiducials.vox);
        
        segmentedMRIBrain = ft_determine_coordsys(segmentedMRIBrain);
        segmentedMRIGrayWhiteCSF.coordsys = segmentedMRIBrain.coordsys;
        
        T = segmentedMRIBrain.transform / transformVox2SegmentedMRIBrain; % ### FARDIN ###: To be verified
        fiducials = ft_transform_geometry(T, fiducials); % ### FARDIN ###: To be verified
        fiducials = IJKtransformXYZ(segmentedMRIBrain.transform, 'coordsys', fiducials.pnt); % ### FARDIN ###: To be verified
    end % if ~isfield(segmentedMRIBrain, 'coordsys') || ~strcmp(segmentedMRIBrain.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(segmentedMRIBrain, 'unit') || ~strcmp(segmentedMRIBrain.unit, my_cfg.unit) || ~isfield(segmentedMRIGrayWhiteCSF, 'unit') || ~strcmp(segmentedMRIGrayWhiteCSF.unit, my_cfg.unit)% True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        segmentedMRIBrain = ft_convert_units(segmentedMRIBrain, my_cfg.unit);
        segmentedMRIGrayWhiteCSF = ft_convert_units(segmentedMRIGrayWhiteCSF, my_cfg.unit);
        fiducials = ft_convert_units(fiducials, my_cfg.unit);
    end % if~isfield(segmentedMRIBrain, 'unit') || ~strcmp(segmentedMRIBrain.unit, my_cfg.unit)
    
    segmentedMRIBrain.fiducials.ijk.nas = fiducials.vox(1, :);
    segmentedMRIBrain.fiducials.ijk.lpa = fiducials.vox(2, :);
    segmentedMRIBrain.fiducials.ijk.rpa = fiducials.vox(3, :);
    segmentedMRIBrain.fiducials.xyz.nas = fiducials.pnt(1, :);
    segmentedMRIBrain.fiducials.xyz.lpa = fiducials.pnt(2, :);
    segmentedMRIBrain.fiducials.xyz.rpa = fiducials.pnt(3, :);
    segmentedMRI.segmentedMRIBrain = segmentedMRIBrain;
    
    segmentedMRIGrayWhiteCSF.fiducials = segmentedMRIBrain.fiducials;
    segmentedMRI.segmentedMRIGrayWhiteCSF = segmentedMRIGrayWhiteCSF;
    
    segmentedMRIAll = segmentedMRI.segmentedMRIBrain;
    segmentedMRIAll.white = segmentedMRI.segmentedMRIGrayWhiteCSF.white;
    segmentedMRIAll.gray = segmentedMRI.segmentedMRIGrayWhiteCSF.gray;
    segmentedMRIAll.csf = segmentedMRI.segmentedMRIGrayWhiteCSF.csf;
    segmentedMRI.segmentedMRIAllIndexed = ft_datatype_segmentation(segmentedMRIAll, 'segmentationstyle', 'indexed');
    
    save(my_cfg.segMRIDir, 'segmentedMRI') % Overwrites the new segmented MRI to the directory
else
    
    load(my_cfg.segMRIDir) % Loads the precomputed segmented MRI
end

% --> visualizing the segments of segmented MRI (Probabilistic / binary (boolean) representation):
if my_cfg.feedback.mriSeg
    output = {'brain', 'skull', 'scalp'};
    for i = 1 : length(output)
        cfg = [];
        cfg.funparameter = output{i};
        cfg.location = 'center';
        ft_sourceplot(cfg, segmentedMRI.segmentedMRIBrain);
    end % for i = 1 : length(output)
    
    output = {'gray', 'white', 'csf'};
    for i = 1 : length(output)
        cfg = [];
        cfg.funparameter = output{i};
        cfg.location = 'center';
        ft_sourceplot(cfg, segmentedMRI.segmentedMRIGrayWhiteCSF);
    end % for i = 1 : length(output)
    clear cfg i output
    
    % --> The indexed representation of segmented MRI
    % bss_i = segmentedmri;
    % bss_i.seg = double(segmentedmri.scalp);         % scalp is logical but seg will contain: 0,1,2,3
    % bss_i.seg(segmentedmri.skull) = 2;                         % skull is represented by index 2
    % bss_i.seg(segmentedmri.brain) = 3;                         % brain is represented by index 3
    % bss_i.seglabel = {'scalp', 'skull', 'brain'}; % label-order corresponds to index from 1 to 3
    % cfg = [];
    % cfg.funparameter = 'seg';
    % cfg.location  = 'center';
    % ft_sourceplot(cfg, bss_i);
    % map = [0 0 0; 1 0 0; 0 1 0; 0 0 1]; % change the colormap
    % colormap(map);
    % clear bss_i cfg map
    
end % if my_cfg.feedback.mriSeg