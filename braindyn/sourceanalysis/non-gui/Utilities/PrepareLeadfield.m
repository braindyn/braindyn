function LF = PrepareLeadfield(my_cfg)
% Forward solution (expressed as the leadfield matrix)
% --> The lead field matrix (= channels X source points matrix) is calculated for
% ... each grid point (dipole) taking into account the head model and the channel positions.
% --> The leadfields should be averaged referenced.

if exist(my_cfg.LFDir, 'file')
    choice = questdlg('The lead-field matrix has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.LFDir, 'file')

if my_cfg.recompute
    choice = questdlg('Would you like to normalise the lead-field matrix?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            normalize = 'no'; % normalize the leadfield (yes: removes depth bias (Q in eq. 27 of van Veen et al, 1997))
        case 'Yes'
            normalize = 'yes'; % normalize the leadfield (yes: removes depth bias (Q in eq. 27 of van Veen et al, 1997))
    end % switch choice
    
    load(my_cfg.volDir)
    sourceModel = load(my_cfg.sourceModelDir);
    load(my_cfg.sensDir)
    
    LeadField = [];
    SourceModels = {'white', 'pial', 'between', 'whitePial', 'whiteBetweenPial'};
    for j = 1 : length(SourceModels)
        cfg = [];
        cfg.grid = sourceModel.grid.(SourceModels{j});
        cfg.normalize = normalize; % normalize the leadfield (yes: removes depth bias (Q in eq. 27 of van Veen et al, 1997))
        % cfg.vol = my_cfg.Vol; % Volume conduction head model
        % cfg.grid.pos = my_cfg.Bnd_pnt; % Source space
        % cfg.grid.inside = 1 : size(my_cfg.Bnd_pnt, 1);
        if strcmp(my_cfg.name, 'EEG') % ft_senstype(my_cfg.Sens, 'eeg')
            cfg.senstype = 'eeg';
            cfg.elec = sens; % Sensor model
            %     cfg.vol = vol.head; % Volume conduction head model
            cfg.headmodel = vol.head; % Volume conduction head model
            cfg.channel = {'all', '-Nz', '-LPA', '-RPA'}; % Should be generalised based on the different fiducial label conventions
        elseif strcmp(my_cfg.name, 'MEG') % ft_senstype(my_cfg.Sens, 'meg')
            cfg.senstype = 'meg';
            cfg.grad = sens; % Sensor model
            %     cfg.vol = vol.brain; % Volume conduction head model
            cfg.headmodel = vol.brain; % Volume conduction head model
            cfg.channel = {'MEG'};
        end % if strcmp(my_cfg.name, 'EEG')
        LF = ft_prepare_leadfield(cfg); % Leadfield
        
        LF_cat = zeros(length(LF.label), 3 * length(find(LF.inside))); % Concatenated lead-field
        
        c = 1;
        for i = 1 : length(LF.leadfield)
            if ~isempty(LF.leadfield{i})
                LF_cat(:, (c - 1) * size(LF.leadfield{i}, 2) + 1 : c * size(LF.leadfield{i}, 2)) = LF.leadfield{i};
                c = c + 1;
            end
        end % for i = 1 : length(LF.leadfield)
        
        LF.LF_cat = LF_cat; % Concatenated lead-field
        
        eval(['LeadField.(SourceModels{j}) = LF;'])
    end % for j = 1 : length(SourceModels)
    
    save(my_cfg.LFDir, 'LeadField');
else
    load(my_cfg.LFDir);
end % if my_cfg.recompute