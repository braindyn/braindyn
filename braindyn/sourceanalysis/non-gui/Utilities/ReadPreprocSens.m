function sens = ReadPreprocSens(my_cfg)

if exist(my_cfg.sensDir, 'file')
    choice = questdlg('The sensor model has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.sensDir, 'file')

load(my_cfg.volDir);
scalp = vol.head.bnd(3);
clear vol
load(my_cfg.MRIDir);
volHead = mri;
% clear vol

if my_cfg.recompute
    %     load(my_cfg.MRIDir) % Loads computed pre-processed MRI
    
    % --> Loading standard electrode/gradiometers layouts:
    sens = ft_read_sens(my_cfg.sensLoad, 'senstype', lower(my_cfg.name));
    % if ~isempty(SelSensInd) % In case of selecting at least 1 sensor
    % --> Electrodes alignment (necessary only for EEG)
    if strcmp(my_cfg.name, 'EEG') % ft_senstype(sens, 'eeg')
        % % %         sens = my_electrode_align(sens, mri.transform, mri.cfg.fiducial, volHead, my_cfg.feedback);
        %         sens = my_electrode_align(sens, mri.transform, mri.hdr.fiducial.mri, volHead, my_cfg.feedback); % Should be uncommented for non-standard setup
        
        
        
        % --> Automatic alignment (to the anatomical landmarks of the anatomical mri):
        % nas = ft_warp_apply(volHead.transform , volHead.fiducials.ijk.nas , 'homogenous');
        % lpa = ft_warp_apply(volHead.transform , volHead.fiducials.ijk.lpa , 'homogenous');
        % rpa = ft_warp_apply(volHead.transform , volHead.fiducials.ijk.rpa , 'homogenous');
        
        nas = volHead.fiducials.xyz.nas;
        lpa = volHead.fiducials.xyz.lpa;
        rpa = volHead.fiducials.xyz.rpa;
        
        Shift = [15 0 0];
        % --> create a structure similar to a template set of electrodes:
        fid.elecpos = [nas + Shift; lpa + Shift; rpa + Shift];
        % % % fid.elecpos = [nas; lpa; rpa];% ctf-coordinates of fiducials in MRI
        fid.label = {'Nz' , 'LPA' , 'RPA'};    % same labels as in elec
        fid.unit  = 'mm';                  % same units as mri
        % % --> alignment:
        cfg = [];
        cfg.method = 'fiducial';
        % cfg.template = fid;                   % see above
        cfg.target = fid;                   % see above
        cfg.elec = sens;
        cfg.fiducial = fid.label;  % labels of fiducials in fid and in elec
        sens = ft_electroderealign(cfg); % both electrodes and anatomical MRI are expressed in the same head-coordinate system (same fiducials)
        % clear cfg fid
        
        % cfg.method = 'fiducial';
        %         % cfg.template = fid;
        % %         cfg.feedback = 'yes';%my_cfg.feedback;
        %         cfg.elec = sens;
        %         cfg.target.pnt(1,:) = nas;     % location of the nose
        %         cfg.target.pnt(2,:) = lpa;     % location of the left ear
        %         cfg.target.pnt(3,:) = rpa;     % location of the right ear
        %         cfg.target.label = {'nz', 'lpa', 'rpa'};
        %         % cfg.fiducial = {'Nz', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
        %         sens_aligned = ft_electroderealign(cfg); % both electrodes and anatomical MRI are expressed in the same head-coordinate system (same fiducials)
        
        
        % % if Feedback
        % % % --> check the alignment visually:
        % figure;
        % ft_plot_sens(sens_aligned , 'style' , 'k', 'label','label'); hold on;
        % ft_plot_mesh(scalp , 'facealpha', 0.85 , 'edgecolor' , 'none' , 'facecolor' , 'skin'); %scalp
        % view(0 , 0)
        % % end
        
        % % % cfg = [];
        % % % cfg.method    = 'interactive';
        % % % cfg.elec      = sens;
        % % % cfg.headshape = scalp;
        % % % sens = ft_electroderealign(cfg);
        
        % --> Shifting the electrodes (based on visual inspection):
        % Shift = [0 12 0];
        % fid.chanpos = [nas + Shift ; lpa + Shift ; rpa + Shift];       % ctf-coordinates of fiducials
        % fid.label = {'Nz' , 'LPA' , 'RPA'};    % same labels as in elec
        % fid.unit  = 'mm';                  % same units as mri
        % % --> alignment:
        % cfg = [];
        % cfg.method = 'fiducial';
        % cfg.template = fid;                   % see above
        % cfg.elec = sens;
        % cfg.fiducial = {'Nz', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
        % sens_aligned = ft_electroderealign(cfg); % both electrodes and anatomical MRI are expressed in the same head-coordinate system (same fiducials)
        % clear fid cfg Shift
        
        % cfg = [];
        % cfg.method = 'fiducial';
        %         % cfg.template = fid;
        % %         cfg.feedback = 'yes';%my_cfg.feedback;
        %         cfg.elec = sens;
        %         cfg.target.pnt(1,:) = nas + Shift;     % location of the nose
        %         cfg.target.pnt(2,:) = lpa + Shift;     % location of the left ear
        %         cfg.target.pnt(3,:) = rpa + Shift;     % location of the right ear
        %         cfg.target.label = {'nz', 'lpa', 'rpa'};
        %         % cfg.fiducial = {'Nz', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
        %         sens_aligned = ft_electroderealign(cfg); % both electrodes and anatomical MRI are expressed in the same head-coordinate system (same fiducials)
        
        % figure;
        % ft_plot_sens(sens_aligned , 'style' , 'k'); hold on;
        % ft_plot_mesh(scalp , 'facealpha', 0.85 , 'edgecolor' , 'none' , 'facecolor' , 'skin'); %scalp
        % view(0 , 0)
        %
        % cfg.method = 'fiducial';
        %         % cfg.template = fid;
        %         cfg.feedback = 'yes';%my_cfg.feedback;
        %         cfg.elec = sens;
        %         cfg.target.pnt(1,:) = volHead.fiducials.xyz.nas;     % location of the nose
        %         cfg.target.pnt(2,:) = volHead.fiducials.xyz.lpa;     % location of the left ear
        %         cfg.target.pnt(3,:) = volHead.fiducials.xyz.rpa;     % location of the right ear
        %         cfg.target.label = {'nz', 'lpa', 'rpa'};
        %         % cfg.fiducial = {'Nz', 'LPA', 'RPA'};  % labels of fiducials in fid and in elec
        %         sens = ft_electroderealign(cfg); % both electrodes and anatomical MRI are expressed in the same head-coordinate system (same fiducials)
        
%         [sens.EEG.chanpos, ind, ~] = unique(sens.EEG.chanpos, 'rows'); % Remove repetitive electrodes
%         sens.EEG.elecpos = sens.EEG.elecpos(ind, :);
%         tmp1 = cell(length(ind), 1);
%         tmp2 = cell(length(ind), 1);
%         tmp3 = cell(length(ind), 1);
%         for i = 1 : length(ind)
%             tmp1{i} = sens.EEG.chantype{ind(i)};
%             tmp2{i} = sens.EEG.chanunit{ind(i)};
%             tmp3{i} = sens.EEG.label{ind(i)};
%         end
%         sens.EEG.chantype = tmp1;
%         sens.EEG.chanunit = tmp2;
%         sens.EEG.label = tmp3;
%             [~, ~, ib] = unique(sens.EEG.chanpos, 'rows', 'stable');
% indDoubleElec = find(hist(ib, unique(ib)) > 1);
% desiredChan = cell(1, length(indDoubleElec) + 1);
% desiredChan{1} = 'all';
% for i = 1 : length(indDoubleElec)
%     desiredChan{i + 1} = sprintf('-%s', sens.EEG.label{indDoubleElec(i)});
% end
% [sens.EEG2] = ft_channelselection(desiredChan, sens.EEG, 'eeg');


    elseif strcmp(my_cfg.name, 'MEG') % ft_senstype(sens, 'meg')
        % Do nothing
        %     sens = my_sensor_align(sens, mri.transform, mri.hdr.fiducial.mri, volHead, my_cfg.feedback); % Should be uncommented for non-standard setup
    end % if ft_senstype(sens, 'eeg')
    
    % --> Check and determine the coordinate-system of the electrodes:
    if ~isfield(sens, 'coordsys') || ~strcmp(sens.coordsys, my_cfg.coordSys)
        %         sens = ft_determine_coordsys(sens);
        sens.coordsys = 'ctf';
    end % if ~isfield(sens, 'coordsys') || ~strcmp(sens.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(sens, 'unit') || ~strcmp(sens.unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        sens = ft_convert_units(sens, my_cfg.unit);
    end % if ~isfield(sens, 'unit') || ~strcmp(sens.unit, my_cfg.unit)
    
    sens.fiducials = volHead.fiducials;
    
    save(my_cfg.sensDir, 'sens');
else
    load(my_cfg.sensDir);
end

% ---> Sensor spatial arrangement visualization
if my_cfg.feedback.sens
    
    fiducials = [volHead.fiducials.xyz.nas; volHead.fiducials.xyz.lpa; volHead.fiducials.xyz.rpa];
    
    figure
    %     ft_plot_sens(sens, 'style', my_cfg.channelsSymb(end), 'label', 'label'); hold on
    plot3(sens.chanpos(:, 1), sens.chanpos(:, 2), sens.chanpos(:, 3), 'ko', 'MarkerSize', 10), hold on % , 'MarkerFaceColor', 'k'
    text(sens.chanpos(:, 1), sens.chanpos(:, 2), sens.chanpos(:, 3), sens.label)
    plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
    text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
    text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
    title(['',my_cfg.name,' sensors']), axis off
end
% else % In case of NOT selecting at least 1 sensor
%     msgbox('No sensor location is selected! Please select.', 'Warning', 'error');
% end % if ~isempty(SelSensInd)

clear SelSensInd Ok

