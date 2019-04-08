function GeometricalElements(my_cfg)
if my_cfg.feedback.geometrics
    % if ft_senstype(my_cfg.Sens, 'eeg')
    load(my_cfg.MRIDir); % Processed MRI file directory (CTF, cm, aligned)
    load(my_cfg.segMRIDir); % Segmented MRI file directory
    %     load(my_cfg.meshDir); % Source model file directory
    load(my_cfg.volDir); % Head model file directory
    grid = load(my_cfg.sourceModelDir); % Source model
    %     cfg = [];
    %     cfg.method = 'slice';
    %     ft_sourceplot(cfg, mri)
    figure
    ft_plot_ortho(mri.anatomy, 'style', 'intersect', 'transform', segmentedMRI.segmentedMRIBrain.transform); hold on
    % ft_plot_mesh(grid.pos(grid.inside,:), 'surfaceonly', 'yes', 'vertexcolor', 'c', 'edgecolor', 'c'); hold on %,'face alpha',0.7, 'facecolor', 'white'
    ft_plot_mesh(grid.grid.white, 'vertexcolor', 'b', 'edgecolor', 'b', 'edgealpha', 0.5, 'facecolor', 'b', 'facealpha', 0.35); %,'face alpha',0.7, 'facecolor', 'white'
    ft_plot_mesh(grid.grid.between, 'vertexcolor', 'c', 'edgecolor', 'c', 'edgealpha', 0.5, 'facecolor', 'c', 'facealpha', 0.35);
    ft_plot_mesh(grid.grid.pial, 'vertexcolor', 'r', 'edgecolor', 'r', 'edgealpha', 0.5, 'facecolor', 'r', 'facealpha', 0.35);
    ft_plot_mesh(vol.head.bnd(1), 'vertexcolor', [0 0 1], 'edgecolor', [0 0 1], 'edgealpha', 0.5, 'facecolor', [0 0 1], 'facealpha', 0.25); hold on
    ft_plot_mesh(vol.head.bnd(2), 'vertexcolor', [0 1 0], 'edgecolor', [0 1 0], 'edgealpha', 0.5, 'facecolor', [0 1 0], 'facealpha', 0.15);
    ft_plot_mesh(vol.head.bnd(3), 'vertexcolor', [1 0 0], 'edgecolor', [1 0 0], 'edgealpha', 0.5, 'facecolor', [1 0 0], 'facealpha', 0.05);
    view([65 27])
    %   if strcmp(my_cfg.name, 'EEG')
    %     MEGSensAddress = fullfile(my_options.Address.load, filesep, 'Data', filesep, 'Subject01.ds'); % sensor file directory
    %     MEGSens = ft_read_sens(MEGSensAddress); % read MEG sensors
    %     MEGSensInd = my_find_MEG_equivTo_EEG(my_cfg.Modality.SensDir, MEGSensAddress, my_cfg.Modality.ChannelsInd, my_cfg.Modality.ChannelsSymb, 'og', my_cfg.Modality.MRIDir, false, my_options);
    %     MEGSens = my_sensor_sel(MEGSens, MEGSensInd); % Select desired sensors
    
    %     % --> Check and determine the coordinate-system of the electrodes:
    %     if ~isfield(MEGSens, 'coordsys') || ~strcmp(MEGSens.coordsys, my_cfg.Modality.CoordSys)
    %         MEGSens = my_determine_coordsys(MEGSens);
    %     end % if ~isfield(MEGSens, 'coordsys') || ~strcmp(MEGSens.coordsys, my_cfg.Modality.CoordSys)
    %
    %     % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    %     if ~isfield(MEGSens, 'unit') || ~strcmp(MEGSens.unit, my_cfg.Modality.Unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
    %         MEGSens = ft_convert_units(MEGSens, my_cfg.Modality.Unit);
    %     end % if ~isfield(sens, 'unit') || ~strcmp(sens.unit, my_cfg.Modality.Unit)
    
    % elseif ft_senstype(my_cfg.Sens, 'meg')
    %   elseif strcmp(my_cfg.name, 'MEG')
    
    %     It isn't needed
    % end
    
    
    
    % % --> Visualization of Source space together with volume conduction head model:
    % figure
    % ft_plot_sens(my_cfg.Sens, 'style', my_cfg.Modality.ChannelsSymb, 'label', 'label'); hold on
    % if ft_senstype(my_cfg.Sens, 'eeg')
    %     ft_plot_sens(MEGSens, 'style', 'og', 'label', 'label');
    %     for i = 1 : size(my_cfg.Sens.chanpos, 1)
    %         plot3(linspace(my_cfg.Sens.chanpos(i, 1), MEGSens.chanpos(i, 1)), linspace(my_cfg.Sens.chanpos(i, 2), MEGSens.chanpos(i, 2)), linspace(my_cfg.Sens.chanpos(i, 3), MEGSens.chanpos(i, 3)), 'r')
    %     end % for i = 1 : size(EEGSens.chanpos, 1)
    %     legend('EEG', 'MEG', 'Corresponding')
    % end
    % ft_plot_vol(my_cfg.Vol, 'facecolor', 'skin', 'edgecolor', 'none'), alpha 0.25
    % ft_plot_mesh(my_cfg.Bnd(1), 'facecolor', 'none', 'edgecolor', 'none', 'edgealpha', 0.25, 'vertexcolor', [0 0 1])
    %
    % if ft_senstype(my_cfg.Sens, 'eeg')
    %     title({['Source model (',num2str(size(my_cfg.Bnd(1).pnt, 1)),' dipoles)'], 'head model (brain, skull and scalp),', ['and sensor layout (',num2str(size(my_cfg.Sens.chanpos, 1)),' ',my_cfg.Modality.Name,' Channels)']})
    % elseif ft_senstype(my_cfg.Sens, 'meg')
    %     title({['Source model (',num2str(size(my_cfg.Bnd(1).pnt, 1)),' dipoles)'], 'head model (brain),', ['and sensor layout (',num2str(size(my_cfg.Sens.chanpos, 1)),' ',my_cfg.Modality.Name,' Channels)']})
    % end
    % view(0, 0), camlight, drawnow
    %
    % % --> Check for the consistency of unit and coordinate system of all geometrical elements
    % if ft_senstype(my_cfg.Sens, 'eeg')
    % if isequal(my_cfg.Vol.unit, my_cfg.Bnd(1).unit, my_cfg.Bnd(2).unit, my_cfg.Bnd(3).unit, my_cfg.Sens.unit, my_cfg.Mri.unit, my_cfg.Segmentedmri.unit) && ...
    %         isequal(my_cfg.Vol.coordsys, my_cfg.Bnd(1).coordsys, my_cfg.Bnd(2).coordsys, my_cfg.Bnd(3).coordsys, my_cfg.Sens.coordsys, my_cfg.Mri.coordsys, my_cfg.Segmentedmri.coordsys)
    %     msgbox('All the geometrical elements including MRI, segmented MRI, source model, sensor layout, and head model are in the same physical measurement unit and coordinate system', 'Confirmation');
    % else
    %     msgbox('The geometrical elements are not in the same physical measurement unit and coordinate system', 'Warning', 'error');
    % end
    % elseif ft_senstype(my_cfg.Sens, 'meg')
    % if isequal(my_cfg.Vol.unit, my_cfg.Bnd(1).unit, my_cfg.Sens.unit, my_cfg.Mri.unit, my_cfg.Segmentedmri.unit) && ...
    %         isequal(my_cfg.Vol.coordsys, my_cfg.Bnd(1).coordsys, my_cfg.Sens.coordsys, my_cfg.Mri.coordsys, my_cfg.Segmentedmri.coordsys)
    %     msgbox('All the geometrical elements including MRI, segmented MRI, source model, sensor layout, and head model are in the same physical measurement unit and in the same coordinate system', 'Confirmation');
    % else
    %     msgbox('The geometrical elements are not in the same physical measurement unit and coordinate system', 'Warning', 'error');
    % end
    % end
end

