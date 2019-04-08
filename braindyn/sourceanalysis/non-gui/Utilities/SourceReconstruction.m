function sourceReconst = SourceReconstruction(my_cfg)

if exist(my_cfg.IPDir, 'file')
    choice = questdlg('The reconstructed source has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.IPDir, 'file')

if my_cfg.recompute
    %% ----
    load(my_cfg.FPDir)
    %     load(cfg.sourceModelDir)
    load(my_cfg.LFDir)
    load(my_cfg.sensDir)
    load(my_cfg.volDir)
    %% Timelock data simulation
    % create a dipole simulation with one dipole and a 10Hz sine wave
    
    SourceModels = {'white', 'pial', 'between', 'whitePial', 'whiteBetweenPial'}; % ADDED
    for j = 1 : length(SourceModels)  % ADDED
        
        cfg = [];
        if ft_senstype(sens, 'eeg')
            cfg.senstype = 'eeg';
            cfg.headmodel = vol.head; % volume conduction model (headmodel)
            cfg.elec = sens;
        elseif ft_senstype(sens, 'meg')
            cfg.senstype = 'meg';
            cfg.headmodel = vol.brain; % volume conduction model (headmodel)
            cfg.grad = sens;
        end
        cfg.channel = LeadField.(SourceModels{j}).label;  % ADDED
        cfg.dip.pos = forwardProblem.(SourceModels{j}).sourceModel.pos(forwardProblem.(SourceModels{j}).sourceModel.inside, :); % MODIFIED
        temp = forwardProblem.(SourceModels{j}).maxMom(LeadField.(SourceModels{j}).inside, :)';  % ADDED
        cfg.dip.mom = temp(:);
        %     figure % Plot real source activity
        %     temp = forwardProblem.(SourceModels{j}).maxMom(:, :)'; %sourceActivity{1}(:, :)';
        %     ft_plot_mesh(forwardProblem.(SourceModels{j}).sourceModel, 'vertexcolor', sqrt(sum(temp'.^ 2, 2)), 'edgecolor', 'k', 'colormap', 'jet'); % , 'surfaceonly', 'yes'
        %     lighting gouraud; material dull
        % note, it should be transposed
        % cfg.dip.frequency = 10;
        % cfg.dip.amplitude = 1; % per dipole
        % cfg.dip.phase = pi/6; % In radians
        % cfg.ntrials = 3;
        % cfg.triallength = 1; % seconds
        cfg.fsample = 250;
        time = (-0.5*cfg.fsample : 1 *cfg.fsample)/cfg.fsample; % manually create a time axis
        freq = my_cfg.sourceReconst.sinFreq; % Source activity oscillation frequency
        signal = zeros(1, length(time));
        signal(time >= 0) = sin(2 * pi * freq * time(time >= 0)); % manually create a signal (sine wave)
        % signal(time >= 0) = 1; % manually create a signal (step signal)
        cfg.dip.signal = cell(1, my_cfg.sourceReconst.trialNum);
        for i = 1 : my_cfg.sourceReconst.trialNum
            cfg.dip.signal{i} = signal;  % # of trials
        end % for i = 1 : my_cfg.sourceReconst.trialNum
        cfg.relnoise = my_cfg.sourceReconst.relnoise;
        rawData = ft_dipolesimulation(cfg);
        for i = 1 : length(rawData.time) % Correct the time course
            rawData.time{i} = time;
        end
        % figure; % Plot raw data
        % plot(rawData.time{1}, rawData.trial{1})
        
        for i = 1 : length(rawData.trial) % Demeaning the raw data
            %         mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) %[mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) mean(rawData.trial{i}(1,find(rawData.time{i} >= 0, 1):end))]
            rawData.trial{i} = ft_preproc_polyremoval(rawData.trial{i}, 0, 1, find(rawData.time{i} >= 0, 1) - 1); % this will also demean and detrend
            %         mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) %[mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) mean(rawData.trial{i}(1,find(rawData.time{i} >= 0, 1):end))]
        end % for i = 1 : length(rawData.trial)
        
        cfg = [];
        cfg.toilim = [-inf 0-1./rawData.fsample];
        rawDataPre = ft_redefinetrial(cfg, rawData);
        cfg.toilim = [0 inf];
        rawDataPost = ft_redefinetrial(cfg, rawData);
        
        
        cfg = [];
        cfg.covariance = 'yes';
        cfg.covariancewindow = [-inf 0-1./rawData.fsample];
        timeLock = ft_timelockanalysis(cfg, rawData);
        % timeLock.fsample = rawData.fsample;
        
        cfg = [];
        cfg.covariance = 'yes';
        timeLockPre = ft_timelockanalysis(cfg, rawDataPre);
        timeLockPost = ft_timelockanalysis(cfg, rawDataPost);
        % figure; plot(timeLock.time, timeLock.avg(:, :));
        %% LCMV
        switch my_cfg.sourceReconst.method
            case 'LCMV'
                cfg = [];
                cfg.method = 'lcmv';
                % cfg.grid = leadfield;
                cfg.grid = forwardProblem.(SourceModels{j}).sourceModel; % MODIFIED
                cfg.grid.leadfield = LeadField.(SourceModels{j}).leadfield; % leadfield  % ADDED
                if ft_senstype(sens, 'eeg')
                    cfg.senstype = 'eeg';
                    cfg.headmodel = vol.head; % volume conduction model (headmodel)
                    cfg.elec = sens;
                elseif ft_senstype(sens, 'meg')
                    cfg.senstype = 'meg';
                    cfg.headmodel = vol.brain; % volume conduction model (headmodel)
                    cfg.grad = sens;
                end
                cfg.channel = timeLock.label;
                cfg.lcmv.keepfilter = 'yes';
                cfg.lcmv.fixedori = 'no'; % project on axis of most variance using SVD
                cfg.lcmv.projectnoise = 'yes';
                % cfg.lcmv.weightnorm = 'nai';
                cfg.lcmv.lambda = my_cfg.sourceReconst.lambda;
                sourceLCMV = ft_sourceanalysis(cfg, timeLock);
                % sourceLCMV.avg.pow = abs(sourceLCMV.avg.pow);
                sourceLCMV.avg.NAI = abs(sourceLCMV.avg.pow) ./ sourceLCMV.avg.noise; % Neural Activity Index (NAI)
                
                
                % Instantpow = zeros(size(cfg.grid.pos, 1), length(sourceLCMV.time));
                % h = waitbar(0, 'Please wait...');
                % for i = 1 : length(timeLock.time)
                %     cfgInst = [];
                %     cfgInst.latency = [timeLock.time(1) timeLock.time(i)];
                %     timelockInst = ft_selectdata(cfgInst, timeLock);
                %     temp = ft_sourceanalysis(cfg, timelockInst);
                %     Instantpow(:, i) = abs(temp.avg.pow) ./ temp.avg.noise;
                %     waitbar(i / length(sourceLCMV.time))
                % end
                % close(h)
                % sourceLCMV.avg.Instantpow = abs(Instantpow);
                
                %     source2NAI = source2;
                %     source2NAI.avg.pow = abs(source2NAI.avg.pow) ./ source2NAI.avg.noise; % Neural Activity Index (NAI)
                
                % second and third call to ft_sourceanalysis now applying the precomputed filters to pre and %post intervals
                cfg.grid.filter = sourceLCMV.avg.filter; % Same cfg as the previous LCMV
                cfg = rmfield(cfg, 'lcmv');
                cfg.lcmv.projectnoise = 'yes';
                sourceLCMVPre = ft_sourceanalysis(cfg, timeLockPre);
                sourceLCMVPost = ft_sourceanalysis(cfg, timeLockPost);
                
                sourceLCMV.avg.relPow = (abs(sourceLCMVPost.avg.pow) - abs(sourceLCMVPre.avg.pow)) ./ abs(sourceLCMVPre.avg.pow);
                
                %     % contrast post stimulus onset activity with respect to baseline
                %     sourceLCMVPre.time = 0; % FT_MATH requires the time axis needs to be the same
                %     sourceLCMVPost.time = 0; % FT_MATH requires the time axis needs to be the same
                %     cfg = [];
                %     cfg.operation = '(abs(x2)-abs(x1))./abs(x1)';
                %     cfg.parameter = 'avg.pow';
                %     RelPow = ft_math(cfg, sourceLCMVPre, sourceLCMVPost);
                
                %
                % sourcePreNAI = sourceLCMVPre;
                % sourcePreNAI.avg.pow = sourcePreNAI.avg.pow ./ sourcePreNAI.avg.noise; % Neural Activity Index (NAI)
                %
                % sourcePostNAI = sourceLCMVPost;
                % sourcePostNAI.avg.pow = sourcePostNAI.avg.pow ./ sourcePostNAI.avg.noise; % Neural Activity Index (NAI)
                %
                % RelPowNAI = sourcePostNAI;
                % RelPowNAI.avg.pow = (abs(sourcePostNAI.avg.pow) - abs(sourcePreNAI.avg.pow))./abs(sourcePreNAI.avg.pow);
                
                % figure
                % ft_plot_mesh(grid, 'vertexcolor', source2.avg.pow, 'edgecolor', 'none', 'colormap', 'jet'); % , 'surfaceonly', 'yes'
                % lighting gouraud; material dull
                
                %     cfg = [];
                %     cfg.method = 'surface';
                %     cfg.funparameter = 'avg.pow';  %avg.pow
                %     cfg.maskparameter = cfg.funparameter;
                %     % cfg.funcolorlim    = [0.0 1.2];
                %     cfg.funcolormap    = 'jet';
                %     % cfg.ancolormap    = 'jet';
                %     % cfg.opacitylim     = [0.0 1.2];
                %     % cfg.opacitymap     = 'rampup';
                %     cfg.projmethod     = 'nearest';
                %     % cfg.surffile       = 'surface_white_both.mat';
                %     % cfg.surfdownsample = 10;
                %     ft_sourceplot(cfg, RelPow);
                %     view ([0 90])
                % figure
                % ft_plot_mesh(forwardProblem.(SourceModels{j}).sourceModel, 'vertexcolor', sourceLCMV.avg.relPow, 'edgecolor', 'none', 'colormap', 'jet');
                %     lighting gouraud; material dull
                
                % ind = source2.time >= 0;
                % momPowAvgTim = nan(size(source2.avg.mom, 1), 1);
                momPow = nan(size(sourceLCMV.avg.mom, 1), length(sourceLCMV.time));
                for i = 1 : size(momPow, 1)
                    if sourceLCMV.inside(i)
                        momPow(i, :) = sqrt(sum(abs(sourceLCMV.avg.mom{i}).^2, 1));
                        % momPowNAI(i, :) = sqrt(sum(abs(sourceLCMV.avg.mom{i}).^2, 1)) / sourceLCMV.avg.noise(i);
                        % momPowNAI(i, :) = mean(sqrt(sum(abs(sourceLCMV.avg.mom{i}).^2, 1))) / sourceLCMV.avg.noise(i);
                        %         momPowAvgTim(i) = mean(abs(momPow(i, ind)));
                    end % if sourceLCMV.inside(i)
                end % for i = 1 : size(momPow, 1)
                % sourceLCMV.avg.momPowAvgTim = momPowAvgTim;
                sourceLCMV.avg.momPow = momPow;
                
                % % ind = find(source2.time >= 0);
                % % momPowAvgTim = nan(size(source2.avg.mom, 1), 1);
                % momPow = nan(size(RelPow.avg.mom, 1), length(RelPow.time));
                % for i=1:size(momPow, 1)
                %     if RelPow.inside(i)
                %         momPow(i, :) = (sqrt(sum(abs(sourceLCMVPost.avg.mom{i}).^2, 1)) - sqrt(sum(abs(sourceLCMVPre.avg.mom{i}).^2, 1))) ./ sqrt(sum(abs(sourceLCMVPre.avg.mom{i}).^2, 1));
                % %         momPow(i, :) = sqrt(sum(abs((sourceLCMVPost.avg.mom{i} - sourceLCMVPre.avg.mom{i}) ./ sourceLCMVPre.avg.mom{i}).^2, 1));
                %
                %         %     momPowAvgTim(i) = mean(abs(momPow(i, ind)));
                % %         momPowAvgTim(i) = mean(abs(momPow(i, ind)));
                %     end
                % end
                % % source2.avg.momPowAvgTim = momPowAvgTim;
                % RelPow.avg.momPow = momPow;
                %
                
                % momPow = nan(size(source2.avg.mom, 1), size(source2.avg.mom{i, 1}, 2));
                % for i = 1 : size(source2.avg.mom, 1)
                % momPow(i, :) = sqrt(sum((source2.avg.mom{i, 1}).^2));
                % end
                % source2.avg.momPow = momPow;
                
                % figure
                % plot(source2.time, source2.avg.mom{1})
                
                % source is the result from a beamformer source estimation.
                % cfg = [];
                % cfg.projectmom = 'yes';
                % sdSource2 = ft_sourcedescriptives(cfg, source2);
                % % figure
                % %         ft_plot_mesh(grid, 'vertexcolor', sdSource2.avg.pow, 'edgecolor', 'k', 'colormap', 'jet'); % , 'surfaceonly', 'yes'
                % %         lighting gouraud; material dull
                %
                % momPow = nan(size(sdSource2.avg.mom, 1), size(sdSource2.avg.mom{i, 1}, 2));
                %   for i=1:size(momPow, 1)
                %     momPow(i,:) = sqrt(sum(abs(sdSource2.avg.mom{i}).^2, 1));
                %   end
                % sdSource2.avg.momPow = momPow;
                
                %     cfg = [];
                %     cfg.funparameter = 'momPow'; % 'momPow', 'pow'
                %     ft_sourcemovie(cfg, sourceLCMV)
                sourceReconst.(SourceModels{j}) = sourceLCMV;
                %     sourceReconst.sourceModel =
                %     forwardProblem.(SourceModels{j}).sourceModel; % MODIFIED
                
                %% DICS
            case 'DICS'
                % this chunk of code creates a 'dummy' reference channel to be used for
                % the coherence analysis
                refdata = [];
                trial = cell(size(rawData.trial));
                for k = 1 : numel(trial)
                    trial{k} = sin(2 * pi * freq * rawData.time{k});
                end
                refdata.trial = trial;
                refdata.time = rawData.time;
                refdata.label = {'refchan'};
                rawDataAppend = ft_appenddata([], rawData, refdata);
                rawDataAppend.fsample = rawData.fsample;
                
                % re-segment the data into pre and post stimulus onset intervals
                cfg = [];
                cfg.toilim = [-inf 0-1/rawDataAppend.fsample];
                rawDataAppendPre = ft_redefinetrial(cfg, rawDataAppend);
                cfg.toilim = [0 inf];
                rawDataAppendPost = ft_redefinetrial(cfg, rawDataAppend);
                
                % append data to facilitate the computation of a 'common' spatial filter
                rawDataAppendAll = ft_appenddata([], rawDataAppendPre, rawDataAppendPost);
                
                % calculate the cross-spectral density matrics
                cfg = [];
                cfg.method = 'mtmfft';
                cfg.output = 'fourier'; % powandcsd, fourier
                cfg.taper = 'hanning';
                cfg.foilim = [freq freq];
                freqPre = ft_freqanalysis(cfg, rawDataAppendPre);
                freqPost = ft_freqanalysis(cfg, rawDataAppendPost);
                freqAll = ft_freqanalysis(cfg, rawDataAppendAll);
                
                % perform source reconstruction using the dics method
                cfg = [];
                cfg.method = 'dics';
                cfg.frequency = freq;
                %     cfg.latency   = [0 0.160];
                cfg.channel = rawDataAppend.label;
                if ft_senstype(sens, 'eeg')
                    cfg.senstype = 'eeg';
                    cfg.headmodel = vol.head; % volume conduction model (headmodel)
                    cfg.elec = sens;
                elseif ft_senstype(sens, 'meg')
                    cfg.senstype = 'meg';
                    cfg.headmodel = vol.brain; % volume conduction model (headmodel)
                    cfg.grad = sens;
                end % if ft_senstype(sens, 'eeg')
                %     cfg.grid = LeadField.(SourceModels{j});  % ADDED
                cfg.grid = forwardProblem.(SourceModels{j}).sourceModel; % MODIFIED
                cfg.grid.leadfield = LeadField.(SourceModels{j}).leadfield; % leadfield  % ADDED
                cfg.dics.keepfilter = 'yes';
                cfg.dics.fixedori = 'no'; % To be generalised
                cfg.dics.projectnoise = 'yes';
                cfg.dics.lambda = my_cfg.sourceReconst.lambda;
                cfg.dics.realfilter = 'yes';
                %     cfg.dics.keepcsd = 'yes';
                cfg.refchan = {'refchan'};
                sourceDICS = ft_sourceanalysis(cfg, freqAll);
                sourceDICS.avg.NAI = abs(sourceDICS.avg.pow) ./ sourceDICS.avg.noise; % Neural Activity Index (NAI)
                
                %         sourceallNAI = sourceDICS;
                %     sourceallNAI.avg.pow = abs(sourceallNAI.avg.pow) ./ sourceallNAI.avg.noise; % Neural Activity Index (NAI)
                
                
                % apply common filters to pre and post stimulus data
                cfg.grid.filter = sourceDICS.avg.filter;
                % now we need to extract the dipole pairs' full csd matrix with respect
                % to the reference channel, which is not possible in the traditional
                % DICS implementation, but can be achieved with pcc
                %     cfg.method   = 'pcc';
                cfg = rmfield(cfg, 'dics');
                sourceDICSPre = ft_sourceanalysis(cfg, freqPre);
                sourceDICSPost = ft_sourceanalysis(cfg, freqPost);
                
                sourceDICS.avg.relPow = (abs(sourceDICSPost.avg.pow) - abs(sourceDICSPre.avg.pow)) ./ abs(sourceDICSPre.avg.pow);
                
                %         % contrast post stimulus onset activity with respect to baseline
                %     sourceDICSPre.time = 0; % FT_MATH requires the time axis needs to be the same
                %     sourceDICSPost.time = 0; % FT_MATH requires the time axis needs to be the same
                %     cfg = [];
                %     cfg.operation = '(abs(x2)-abs(x1))./abs(x1)';
                %     cfg.parameter = 'avg.pow';
                %     RelPow   = ft_math(cfg, sourceDICSPre, sourceDICSPost);
                
                %     RelPow = sourceDICSPost;
                % RelPow.avg.pow = (abs(sourceDICSPost.avg.coh) - abs(sourceDICSPre.avg.coh))./abs(sourceDICSPre.avg.coh);
                % % RelPow.avg.pow = ((sourceDICSPost.avg.pow) - (sourceDICSPre.avg.pow))./(sourceDICSPre.avg.pow);
                
                %     cfg = [];
                %     cfg.method = 'surface';
                %     cfg.funparameter = 'pow';  %avg.pow
                %     cfg.maskparameter = cfg.funparameter;
                %     % cfg.funcolorlim    = [0.0 1.2];
                %     cfg.funcolormap    = 'jet';
                %     % cfg.ancolormap    = 'jet';
                %     % cfg.opacitylim     = [0.0 1.2];
                %     % cfg.opacitymap     = 'rampup';
                %     cfg.projmethod     = 'nearest';
                %     % cfg.surffile       = 'surface_white_both.mat';
                %     % cfg.surfdownsample = 10;
                %     ft_sourceplot(cfg, sourceallNAI);
                %     view ([0 90])
                
                
                % % ind = source2.time >= 0;
                % % momPowAvgTim = nan(size(source2.avg.mom, 1), 1);
                % momPow = nan(size(sourceall.avg.mom, 1), length(sourceall.time));
                % for i=1:size(momPow, 1)
                %     if sourceall.inside(i)
                %         momPow(i, :) = sqrt(sum(abs(sourceall.avg.mom{i}).^2, 1));
                % % momPowNAI(i, :) = sqrt(sum(abs(sourceall.avg.mom{i}).^2, 1)) / sourceall.avg.noise(i);
                % % momPowNAI(i, :) = mean(sqrt(sum(abs(sourceall.avg.mom{i}).^2, 1))) / sourceall.avg.noise(i);
                % %         momPowAvgTim(i) = mean(abs(momPow(i, ind)));
                %     end
                % end
                % % sourceall.avg.momPowAvgTim = momPowAvgTim;
                % sourceall.avg.momPow = momPow;
                %
                % cfg = [];
                % cfg.funparameter = 'momPow'; % 'momPow', 'pow'
                % ft_sourcemovie(cfg, sourceall)
                sourceReconst.(SourceModels{j}) = sourceDICS;
        end % switch my_cfg.sourceReconst.method
        sourceReconst.(SourceModels{j}).forwardProblem = forwardProblem.(SourceModels{j}); % MODIFIED
    end % for j = 1 : length(SourceModels)  % ADDED
    save(my_cfg.IPDir, 'sourceReconst');
else
    load(my_cfg.IPDir);
end % if my_cfg.recompute
%%
%     load(my_cfg.volDir); % This should be thought over again (loading vol)
%     volBrain = vol.brain;
% %         volHead = vol.brain; % Order: {'brain', 'skull', 'scalp'}
%     clear vol
%
%     load(my_cfg.meshDir)
%     bndBrain = bnd.brain; % Order: {'gray', 'white', 'csf'}
%     clear bnd
%
% %     cfg = [];
% %     cfg.grid.unit = bndBrain.unit;
% %     cfg.grid.pos = bndBrain.pos;
% %     cfg.grid.tri = bndBrain.tri;
% % %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
% % %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
% %     grid = ft_prepare_sourcemodel(cfg, volBrain); % ft_inside_vol
%         cfg = [];
%     cfg.grid.unit = bndBrain.unit;
%     cfg.grid.pos = bndBrain(2).pos;
%     cfg.grid.tri = bndBrain(2).tri;
%     %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
%     %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
%     grid = [];
%     grid.white = ft_prepare_sourcemodel(cfg, volBrain);
% %     temp.pos = temp.pos(temp.inside, :); % Select only the dipole positions which are inside
% %     temp.inside = temp.inside(temp.inside, :); % Select only the dipole positions which are inside
% %     grid.white = temp;
%
% cfg = [];
%     cfg.grid.unit = bndBrain.unit;
%     cfg.grid.pos = bndBrain(1).pos;
%     cfg.grid.tri = bndBrain(1).tri;
%     %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
%     %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
%     grid.pial = ft_prepare_sourcemodel(cfg, volBrain);
% %     temp.pos = temp.pos(temp.inside, :); % Select only the dipole positions which are inside
% %     temp.inside = temp.inside(temp.inside, :); % Select only the dipole positions which are inside
% %     grid.pial = temp;
%
% cfg = [];
%     cfg.grid.unit = bndBrain.unit;
%     cfg.grid.pos = (bndBrain(1).pos + bndBrain(2).pos) / 2;
%         cfg.grid.tri = bndBrain(2).tri; % or bndBrain(1).tri
%     %     cfg.grid.inside = (~or(any((bndBrain.pos < repmat(min(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))'), ...
%     %         any((bndBrain.pos > repmat(max(my_cfg.vol.bnd.pos), size(my_cfg.vol.bnd.pos, 1), 1))')))';
%     grid.between = ft_prepare_sourcemodel(cfg, volBrain);
% %     temp.pos = temp.pos(temp.inside, :); % Select only the dipole positions which are inside
% %     temp.inside = temp.inside(temp.inside, :); % Select only the dipole positions which are inside
% %     grid.between = temp;
%
%     % --> check and determine the coordinate-system of the volume conduction model of the head:
%     if ~isfield(grid, 'coordsys') || ~strcmp(grid.coordsys, my_cfg.coordSys)
% %         grid = ft_determine_coordsys(grid);
%         grid.white = ft_determine_coordsys(grid.white);
%         grid.pial = ft_determine_coordsys(grid.pial);
%         grid.between = ft_determine_coordsys(grid.between);
%     end % if ~isfield(grid, 'coordsys') || ~strcmp(grid.coordsys, my_cfg.coordSys)
%
%     % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
%     if ~isfield(grid, 'unit') || ~strcmp(grid.unit, my_cfg.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
% %         grid = ft_convert_units(grid, my_cfg.unit);
%         grid.white = ft_convert_units(grid.white, my_cfg.unit);
%         grid.pial = ft_convert_units(grid.pial, my_cfg.unit);
%         grid.between = ft_convert_units(grid.between, my_cfg.unit);
%     end % if ~isfield(bnd, 'unit') || ~strcmp(bnd(1).unit, my_cfg.unit)
%
%         grid.white.fiducials = bndBrain(1).fiducials;
%     grid.pial.fiducials = bndBrain(1).fiducials;
%     grid.between.fiducials = bndBrain(1).fiducials;
%
%     save(my_cfg.IPDir, 'grid');
% else
%     load(my_cfg.IPDir);
% end
%
% --> Visualization of source model:
if my_cfg.feedback.srcReconst
    %     fiducials = [grid.pial.fiducials.xyz.nas; grid.pial.fiducials.xyz.lpa; grid.pial.fiducials.xyz.rpa];
    SourceModels = {'white', 'pial', 'between', 'whitePial', 'whiteBetweenPial'}; % ADDED
    for j = 1 : length(SourceModels)  % ADDED
        
        figure('Name', SourceModels{j}, 'NumberTitle', 'off')
        subplot(131)
        temp = sourceReconst.(SourceModels{j}).forwardProblem.maxMom(:, :)'; % MODIFIED
        ft_plot_mesh(sourceReconst.(SourceModels{j}).forwardProblem.sourceModel, 'vertexcolor', sqrt(sum(temp'.^ 2, 2)), 'edgecolor', 'k', 'colormap', 'jet'); % , 'surfaceonly', 'yes' % MODIFIED
        title('Actual source');
        subplot(132)
        ft_plot_mesh(sourceReconst.(SourceModels{j}).forwardProblem.sourceModel, 'vertexcolor', sourceReconst.(SourceModels{j}).avg.relPow, 'edgecolor', 'none', 'colormap', 'jet'); % MODIFIED
        title('Reconstructed source (relative power)');
        subplot(133)
        ft_plot_mesh(sourceReconst.(SourceModels{j}).forwardProblem.sourceModel, 'vertexcolor', sourceReconst.(SourceModels{j}).avg.NAI, 'edgecolor', 'none', 'colormap', 'jet'); % MODIFIED
        title('Reconstructed source (NAI)');
        %     plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
        %     text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
        %     text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
        %     text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
        %     title('Reconstructed source'); %alpha 0.25; view(0, 0); camlight; drawnow
        
        if isfield(sourceReconst.(SourceModels{j}).avg, 'momPow')
            cfg = [];
            cfg.funparameter = 'momPow'; % 'momPow', 'pow'
            ft_sourcemovie(cfg, sourceReconst.(SourceModels{j}))
        end
    end % for j = 1 : length(SourceModels)
    
end % if my_cfg.feedback.srcReconst