function vol = PrepareHeadmodel(my_cfg)
% --> Produces the volume conduction head model (the geometrical and electrical (conductive)/magnetic properties of the head):

if exist(my_cfg.volDir, 'file')
    choice = questdlg('The head model has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.volDir, 'file')


if my_cfg.recompute
    load(my_cfg.meshDir)
    bndHead = bnd.head;
    clear bnd
    
    cfg = [];
    cfg.method = 'bemcp';
    vol.head = ft_prepare_headmodel(cfg, bndHead);
    
%     if strcmp(my_cfg.name, 'MEG')
        cfg = [];
        cfg.method = 'singleshell';
        vol.brain = ft_prepare_headmodel(cfg, bndHead(1));
%     end % if strcmp(my_cfg.name, 'MEG')
    %     vol = ft_prepare_headmodel(cfg, bndHead);
    
    % --> check and determine the coordinate-system of the volume conduction model of the head:
    if ~isfield(vol.head, 'coordsys') || ~strcmp(vol.head.coordsys, my_cfg.coordSys)
        vol.head = ft_determine_coordsys(vol.head);
        vol.brain.coordsys = vol.head.coordsys;
    end % if ~isfield(vol.head, 'coordsys') || ~strcmp(vol.head.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(vol.head, 'unit') || ~strcmp(vol.head.unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        vol.head = ft_convert_units(vol.head, my_cfg.unit);
        vol.brain = ft_convert_units(vol.brain, my_cfg.unit);
    end % if ~isfield(bnd, 'unit') || ~strcmp(bnd(1).unit, my_cfg.unit)
    
    vol.head.fiducials = bndHead(1).fiducials;
    vol.brain.fiducials = bndHead(1).fiducials;
    
    save(my_cfg.volDir, 'vol');
else
    load(my_cfg.volDir);
end

% --> Visualization of volume conduction head model (ft_plot_vol & ft_plot_mesh):
if my_cfg.feedback.vol
    fiducials = [vol.head.fiducials.xyz.nas; vol.head.fiducials.xyz.lpa; vol.head.fiducials.xyz.rpa];
    
    figure
    %     ft_plot_vol(vol.head.bnd, 'facecolor', 'skin', 'edgecolor', 'none');
    ft_plot_mesh(vol.head.bnd(1), 'vertexcolor', 'none', 'edgecolor', 'none', 'facealpha', 1, 'facecolor', 'brain'); hold on
    ft_plot_mesh(vol.head.bnd(2), 'vertexcolor', 'none', 'edgecolor', 'none', 'facealpha', 0.75, 'facecolor', 'skin');
    ft_plot_mesh(vol.head.bnd(3), 'vertexcolor', 'none', 'edgecolor', 'none', 'facealpha', 0.25, 'facecolor', 'skin');
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
    text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
    text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
    title('Volume conduction head model'); alpha 0.25; view(0, 0); camlight; drawnow
%     if strcmp(my_cfg.name, 'MEG')
%         figure
%         ft_plot_vol(vol.brain, 'facecolor', 'skin', 'edgecolor', 'none'); hold on
%         plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
%         text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
%         text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
%         text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
%         title('Volume conduction brain model'); alpha 0.25; view(0, 0); camlight; drawnow
%     end % if strcmp(my_cfg.name, 'MEG')
end % if my_cfg.feedback