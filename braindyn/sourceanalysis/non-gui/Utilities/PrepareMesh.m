function bnd = PrepareMesh(my_cfg)

if exist(my_cfg.meshDir, 'file')
    choice = questdlg('The meshes have already been created. Would you like to recompute them and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.meshDir, 'file')

if my_cfg.recompute
    load(my_cfg.segMRIDir) % Loads the precomputed segmented MRI

    cfg = [];
    cfg.tissue = {'brain', 'skull', 'scalp'};
    cfg.numvertices = my_cfg.mesh.headNumVertices;
    head = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIBrain);
    
%     cfg = [];
% cfg.method = 'projectmesh';
% cfg.numvertices = 2000;
% cfg.tissue = 'brain';
% brain = ft_prepare_mesh(cfg, seg);
% cfg.tissue = 'skull';
% skull = ft_prepare_mesh(cfg, seg);
% cfg.tissue = 'scalp';
% scalp = ft_prepare_mesh(cfg, seg);

    % --> check and determine the coordinate-system of the meshes:
    if ~isfield(head, 'coordsys') || ~strcmp(head(1).coordsys, my_cfg.coordSys)
        head_(1) = ft_determine_coordsys(head(1));
        head_(2).coordsys = head_(1).coordsys;
        head_(3).coordsys = head_(1).coordsys;
        head = head_;
    end % if ~isfield(head(1), 'coordsys') ...
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(head(1), 'unit') || ... ~isfield(head(2), 'unit') || ~isfield(head(3), 'unit') || ...
            ~strcmp(head(1).unit, my_cfg.unit) %|| ~strcmp(head(2).unit, my_cfg.unit) || ~strcmp(head(3).unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        head(1) = ft_convert_units(head(1), my_cfg.unit);
        head(2) = ft_convert_units(head(2), my_cfg.unit);
        head(3) = ft_convert_units(head(3), my_cfg.unit);
    end % if ~isfield(head(1), 'unit') ...
    for i = 1 : length(head)
        head(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
    end
    bnd.head = head;
    
    %     elseif strcmp(my_cfg.name, 'MEG')
    %         cfg = [];
    %         cfg.tissue = 'brain';
    %         cfg.numvertices = my_cfg.numVertices(1);
    %         head = ft_prepare_mesh(cfg, my_cfg.segmentedmri.segmentedmriBrain);
    
    %         % --> MEG uses the same source space as EEG
    %         load(my_cfg.meshDir)
    %         head = head(1); % Because in 'singleshell' method for head model, no more than 1 shell at a time is allowed
    
    %         % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    %         if ~isfield(head, 'unit') || ~strcmp(head.unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
    %             head = ft_convert_units(head, my_cfg.unit);
    %         end % if ~isfield(head(1), 'unit') ...
    %     end % if strcmp(my_cfg.name, 'EEG')
    cfg = [];
    cfg.tissue = {'gray', 'white', 'csf'};
    cfg.numvertices = my_cfg.mesh.brainNumVertices;
    brain = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIGrayWhiteCSF);
    
    for i = 1 : length(brain)
        brain(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
    end
    bnd.brain = brain;
    
    save(my_cfg.meshDir, 'bnd');
else
    load(my_cfg.meshDir)
    %     if strcmp(my_cfg.name, 'MEG')
    %         bnd = bnd(1); % Because in 'singleshell' method for head model, no more than 1 shell at a time is allowed
    %
    %         % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    %         if ~isfield(bnd, 'unit') || ~strcmp(bnd.unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
    %             bnd = ft_convert_units(bnd, my_cfg.unit);
    %         end % if ~isfield(bnd(1), 'unit') ...
    %
    %     end
end

% --> Visualization of meshes:
if my_cfg.feedback.mesh
    fiducials = [bnd.head(1).fiducials.xyz.nas; bnd.head(1).fiducials.xyz.lpa; bnd.head(1).fiducials.xyz.rpa];
    
    %     if strcmp(my_cfg.name, 'EEG')
    %         % --> Visualization of meshes separately:
    tissue = {'brain', 'skull', 'scalp'};
    figure,
    %         subplot(141); ft_plot_mesh(bnd.white, 'vertexcolor', [0 0 0], 'edgecolor', [0 0 0]); view(0, 0); title('white matter mesh model'); drawnow
    subplot(131); ft_plot_mesh(bnd.head(1), 'vertexcolor', [0 0 1], 'edgecolor', [0 0 1]); hold on
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    text(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3) - 1, {'nas', 'lpa', 'rpa'})
    view(0, 0); title(tissue{1})
    subplot(132); ft_plot_mesh(bnd.head(2), 'vertexcolor', [0 1 0], 'edgecolor', [0 1 0]); hold on
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    view(0, 0); title({['Brain, skull, scalp mesh models (',my_cfg.name,' modality)'], tissue{2}})
    text(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3) - 1, {'nas', 'lpa', 'rpa'})
    subplot(133); ft_plot_mesh(bnd.head(3), 'vertexcolor', [1 0 0], 'edgecolor', [1 0 0]); hold on
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    view(0, 0); title(tissue{3}); drawnow
    text(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3) - 1, {'nas', 'lpa', 'rpa'})
    
    % --> Visualization of meshes together (Source model for brain mesh):
    figure
    %         ft_plot_mesh(bnd.white, 'vertexcolor', [0 0 0], 'edgecolor', [0 0 0], 'edgealpha', 0.25, 'facecolor', 'none'); hold on
    ft_plot_mesh(bnd.head(1), 'vertexcolor', [0 0 1], 'edgecolor', [0 0 1], 'edgealpha', 0.25, 'facecolor', 'none'); hold on
    ft_plot_mesh(bnd.head(2), 'vertexcolor', [0 1 0], 'edgecolor', [0 1 0], 'edgealpha', 0.15, 'facecolor', 'none');
    ft_plot_mesh(bnd.head(3), 'vertexcolor', [1 0 0], 'edgecolor', [1 0 0], 'edgealpha', 0.05, 'facecolor', 'none');
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
    text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
    text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
    view(0, 0); title(['Brain, skull, scalp mesh models (',my_cfg.name,' modality)']); camlight; drawnow
    
    %     elseif strcmp(my_cfg.name, 'MEG')
    %         % --> Visualization of mesh:
    %         figure
    %         subplot(111); ft_plot_mesh(bnd.head(1), 'vertexcolor', [0 0 0], 'edgecolor', [0 0 0]);
    %         view(0, 0); title('Brain mesh model (MEG modality)'); camlight; drawnow
    %         %         subplot(122); ft_plot_mesh(bnd.white, 'vertexcolor', [0 0 0], 'edgecolor', [0 0 0])
    %         %         view(0, 0), title('white matter mesh model (MEG modality)'); camlight; drawnow
    %     end % if length(bnd.head) == 3
end