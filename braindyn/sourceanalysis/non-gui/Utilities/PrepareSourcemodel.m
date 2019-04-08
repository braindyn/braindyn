function grid = PrepareSourcemodel(my_cfg)
% --> Produces the source model:

if exist(my_cfg.sourceModelDir, 'file')
    choice = questdlg('The source model has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.sourceModelDir, 'file')

if my_cfg.recompute
    load(my_cfg.volDir); % This should be thought over again (loading vol)
    volBrain = vol.brain;
    %         volHead = vol.brain; % Order: {'brain', 'skull', 'scalp'}
    clear vol
    
    load(my_cfg.meshDir)
    bndBrain = bnd.brain; % Order: {'gray', 'white', 'csf'}
    clear bnd
    
    %     cfg = [];
    %     cfg.grid.unit = bndBrain.unit;
    %     cfg.grid.pos = bndBrain.pos;
    %     cfg.grid.tri = bndBrain.tri;
    % %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
    % %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
    %     grid = ft_prepare_sourcemodel(cfg, volBrain); % ft_inside_vol
    cfg = [];
    cfg.grid.unit = bndBrain.unit;
    cfg.grid.pos = bndBrain(2).pos;
    cfg.grid.tri = bndBrain(2).tri;
    %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
    %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
    
    grid = [];
    grid.white = ft_prepare_sourcemodel(cfg, volBrain);
    %     temp.pos = temp.pos(temp.inside, :); % Select only the dipole positions which are inside
    %     temp.inside = temp.inside(temp.inside, :); % Select only the dipole positions which are inside
    %     grid.white = temp;
    Outliers = find(~grid.white.inside);
    grid.white.tri(ismember(grid.white.tri, Outliers)) = nan;
    grid.white.pos(Outliers, :) = nan;
    
    cfg = [];
    cfg.grid.unit = bndBrain.unit;
    cfg.grid.pos = bndBrain(1).pos;
    cfg.grid.tri = bndBrain(1).tri;
    %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
    %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
    grid.pial = ft_prepare_sourcemodel(cfg, volBrain);
    %     temp.pos = temp.pos(temp.inside, :); % Select only the dipole positions which are inside
    %     temp.inside = temp.inside(temp.inside, :); % Select only the dipole positions which are inside
    %     grid.pial = temp;
    Outliers = find(~grid.pial.inside);
    grid.pial.tri(ismember(grid.pial.tri, Outliers)) = nan;
    grid.pial.pos(Outliers, :) = nan;
    
    cfg = [];
    cfg.grid.unit = bndBrain.unit;
    cfg.grid.pos = (bndBrain(1).pos + bndBrain(2).pos) / 2;
    cfg.grid.tri = bndBrain(2).tri; % or bndBrain(1).tri
    %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
    %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
    grid.between = ft_prepare_sourcemodel(cfg, volBrain);
    %     temp.pos = temp.pos(temp.inside, :); % Select only the dipole positions which are inside
    %     temp.inside = temp.inside(temp.inside, :); % Select only the dipole positions which are inside
    %     grid.between = temp;
    Outliers = find(~grid.between.inside);
    grid.between.tri(ismember(grid.between.tri, Outliers)) = nan;
    grid.between.pos(Outliers, :) = nan;
    
    cfg = [];
    cfg.grid.unit = bndBrain.unit;
    cfg.grid.pos = [bndBrain(2).pos; bndBrain(1).pos];
    cfg.grid.tri = [bndBrain(2).tri; bndBrain(1).tri+size(bndBrain(2).pos, 1)];
    grid.whitePial = ft_prepare_sourcemodel(cfg, volBrain);
    Outliers = find(~grid.whitePial.inside);
    grid.whitePial.tri(ismember(grid.whitePial.tri, Outliers)) = nan;
    grid.whitePial.pos(Outliers, :) = nan;
    
    cfg = [];
    cfg.grid.unit = bndBrain.unit;
    cfg.grid.pos = [bndBrain(2).pos; (bndBrain(1).pos + bndBrain(2).pos) / 2; bndBrain(1).pos];
    cfg.grid.tri = [bndBrain(2).tri; bndBrain(2).tri+size(bndBrain(2).pos, 1); bndBrain(1).tri+2*size(bndBrain(2).pos, 1)];
    grid.whiteBetweenPial = ft_prepare_sourcemodel(cfg, volBrain);
    Outliers = find(~grid.whiteBetweenPial.inside);
    grid.whiteBetweenPial.tri(ismember(grid.whiteBetweenPial.tri, Outliers)) = nan;
    grid.whiteBetweenPial.pos(Outliers, :) = nan;
    
    % --> check and determine the coordinate-system of the volume conduction model of the head:
    if ~isfield(grid, 'coordsys') || ~strcmp(grid.coordsys, my_cfg.coordSys)
        %         grid = ft_determine_coordsys(grid);
        grid.white = ft_determine_coordsys(grid.white);
        grid.between = ft_determine_coordsys(grid.between);
        grid.pial = ft_determine_coordsys(grid.pial);
        grid.whitePial = ft_determine_coordsys(grid.whitePial);  
        grid.whiteBetweenPial = ft_determine_coordsys(grid.whiteBetweenPial); 
    end % if ~isfield(grid, 'coordsys') || ~strcmp(grid.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(grid, 'unit') || ~strcmp(grid.unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        %         grid = ft_convert_units(grid, my_cfg.unit);
        grid.white = ft_convert_units(grid.white, my_cfg.unit);
        grid.pial = ft_convert_units(grid.pial, my_cfg.unit);
        grid.between = ft_convert_units(grid.between, my_cfg.unit);
        grid.whitePial = ft_convert_units(grid.whitePial, my_cfg.unit); 
        grid.whiteBetweenPial = ft_convert_units(grid.whiteBetweenPial, my_cfg.unit); 
    end % if ~isfield(bnd, 'unit') || ~strcmp(bnd(1).unit, my_cfg.unit)
    
    grid.white.fiducials = bndBrain(1).fiducials;
    grid.pial.fiducials = bndBrain(1).fiducials;
    grid.between.fiducials = bndBrain(1).fiducials;
    grid.whitePial.fiducials = bndBrain(1).fiducials; 
    grid.whiteBetweenPial.fiducials = bndBrain(1).fiducials; 
    
    save(my_cfg.sourceModelDir, 'grid');
else
    load(my_cfg.sourceModelDir);
end

% --> Visualization of source model:
if my_cfg.feedback.src
    fiducials = [grid.pial.fiducials.xyz.nas; grid.pial.fiducials.xyz.lpa; grid.pial.fiducials.xyz.rpa];
    
    figure
    subplot(131)
    ft_plot_mesh(grid.white, 'surfaceonly', 'yes', 'vertexcolor', 'b', 'edgecolor', 'b'); hold on %,'face alpha',0.7, 'facecolor', 'white'
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'm*', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
    text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
    text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
    text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
    title('White matter source model'); %alpha 0.25; view(0, 0); camlight; drawnow
    subplot(132)
    ft_plot_mesh(grid.between, 'surfaceonly', 'yes', 'vertexcolor', 'b', 'edgecolor', 'b'); hold on %,'face alpha',0.7, 'facecolor', 'white'
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'm*', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
    text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
    text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
    text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
    title('In-between source model'); %alpha 0.25; view(0, 0); camlight; drawnow
    subplot(133)
    ft_plot_mesh(grid.pial, 'surfaceonly', 'yes', 'vertexcolor', 'b', 'edgecolor', 'b'); hold on %,'face alpha',0.7, 'facecolor', 'white'
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'm*', 'MarkerFaceColor', 'm', 'MarkerSize', 10)
    text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
    text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
    text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
    title('Pial source model'); %alpha 0.25; view(0, 0); camlight; drawnow
end



