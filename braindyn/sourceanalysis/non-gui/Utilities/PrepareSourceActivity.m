function forwardProblem = PrepareSourceActivity(my_cfg)

if exist(my_cfg.FPDir, 'file')
    choice = questdlg('The source activity has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch choice % Handle response
        case 'No'
            my_cfg.recompute = false; % If 'true' segments, if 'false', loads precomputed segmented MRI
        case 'Yes'
            my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
    end % switch choice
else
    my_cfg.recompute = true; % If 'true' segments, if 'false', loads precomputed segmented MRI
end % if exist(my_cfg.FPDir, 'file')

if my_cfg.recompute
    %     source = my_cfg.source;
    %
    %             patchCenter = my_cfg.grid.pos(my_cfg.source.pos, :);
    %     patchCenterAllDist = sqrt(sum((my_cfg.grid.pos - repmat(patchCenter, size(my_cfg.grid.pos, 1), 1)).^2, 2));
    %     [~, ind] = sort(patchCenterAllDist);
    %     source.activePatch = ind(1 : my_cfg.source.width);
    %
    %     source.Fs = 1000;
    %     source.t = 0 : 1 / source.Fs : 1 / my_cfg.source.freq; % Time of source activity
    %     source.waveForm = sin(2 * pi * my_cfg.source.freq * source.t); % Source activity waveform over time
    %     source.sphCoord = nan(length(source.t), 3); % Spherical coordinates (rho-theta-phi) of the source activity
    %     source.cartCoord = nan(length(source.t), 3); % Cartesian coordinates (x-y-z) of the source activity
    %     source.pow = zeros(size(my_cfg.grid.pos, 1), length(source.cartCoord));
    %     for i = 1 : length(source.cartCoord)
    %         [source.cartCoord(i, 1) , source.cartCoord(i, 2) , source.cartCoord(i, 3)] = sph2cart(my_cfg.source.ori(1) * pi / 180, my_cfg.source.ori(2) * pi / 180, my_cfg.source.amp * source.waveForm(i)); % Transform spherical coordinates of the dipole to Cartesian
    %         [source.sphCoord(i, 1) , source.sphCoord(i, 2) , source.sphCoord(i, 3)] = deal(my_cfg.source.amp * source.waveForm(i), my_cfg.source.ori(1) * pi / 180, my_cfg.source.ori(2) * pi / 180); % Transform spherical coordinates of the dipole to Cartesian
    %         source.pow(source.activePatch, i) = abs(source.sphCoord(i, 1));
    %     end % for i = 1 : length(source.cartCoord)
    % clc
    % clear
    % cfg = Configuration(cfg);
    load(my_cfg.sourceModelDir)
    load(my_cfg.LFDir)
    load(my_cfg.sensDir)
    load(my_cfg.volDir)
    
    %     sourceModel = grid.white;
    fig = figure;
    % subplot(121)
    %     vertexColor = nan(size(sourceModel.pos, 1), 3);
    %     vertexColor(sourceModel.inside, :) = repmat([0 0 1], length(find(sourceModel.inside)), 1);
    ft_plot_mesh(grid.white, 'vertexcolor', 'b', 'colormap', 'jet'); %, 'surfaceonly', 'yes' % , 'edgecolor', 'none' , 'vertexindex', sourceModel.inside , 'facecolor', 'w'  % MODIFIED
    hold on
    drawnow
    dcm_obj = datacursormode(fig);
    set(dcm_obj, 'SnapToDataVertex', 'on', 'DisplayStyle', 'window', 'Enable' , 'on') %
    while isempty(getCursorInfo(dcm_obj))
        waitfor(dcm_obj, 'Enable' , 'on');
        while strcmp(get(dcm_obj, 'Enable'), 'on')
            drawnow
            if ~isempty(getCursorInfo(dcm_obj))
                temp = getCursorInfo(dcm_obj);
                [~, AllSourceCenterInd] = min(sum(abs(grid.white.pos - temp.Position) , 2)); % MODIFIED
                break
            end
        end
        if strcmp(get(dcm_obj, 'Enable'), 'on')
            %             subplot(121)
            %             cla
            break
        end
    end
    close(fig)
    % SourceCenter = [-26.5 33.5 95.5; -23.5 -27.5 96.5; 66.5 -26.5 81.5; 67.5 32.5 86.5];
    % SourceCenter = [17.5 1.5 118.5; -8.5 -28.5 105.5; -38.5 1.5 92.5; -9.5 39.5 101.5; ...
    %     17.5 1.5 118.5; 51.5 -26.5 95.5; 69.5 -10.5 97.5; 76.5 3.5 90.5; 47.5 38.5 97.5; 17.5 1.5 118.5];
    % SourceCenter = [1.75 .15 11.85; -1.75 -2.75 10.45; -3.55 0.15 9.55; -1.95 3.95 10.15; ...
    %     1.75 .15 11.85; 5.15 -2.65 9.55; 7.65 .35 9.05; 5.05 3.45 9.75; 1.75 .15 11.85];
    % inds = nan(1, size(SourceCenter, 1));
    % for i = 1 : size(SourceCenter, 1)
    %     [~, inds(i)] = min(sum(abs(sourceModel.pos - repmat(SourceCenter(i, :), size(sourceModel.pos, 1), 1)), 2));
    % end % for i = 1 : size(SourceCenter, 1)
    
    SourceModels = {'white', 'pial', 'between', 'whitePial', 'whiteBetweenPial'};
    for j = 1 : length(SourceModels)
        sourceModel = grid.(SourceModels{j});
        if ismember(SourceModels{j}, {'white', 'pial', 'between'}) 
            nodes = [(1 : size(sourceModel.pos, 1))' sourceModel.pos];
            sel = nchoosek(1:size(sourceModel.tri, 2), 2); % Indices of different edges of the polygone (triangle)
            edges = nan(3*size(sourceModel.tri, 1), 2); % Initialisation
            for i = 1 : size(sel, 1) % All edges
                edges(size(sourceModel.tri, 1)*(i - 1) + 1 : size(sourceModel.tri, 1)*i, :) = sourceModel.tri(:, sel(i, :));
            end % for i = 1 : size(sel, 1)
            segments = [(1 : size(edges, 1))' edges];
            % =========================== Moving source activity
            % AllSourceCenterInd = [];
            % for i = 1 : length(inds) - 1
            %     [~, path] = dijkstra(nodes, segments, inds(i), inds(i + 1));
            %     AllSourceCenterInd = [AllSourceCenterInd path];
            % end
            % AllSourceCenterInd(diff(AllSourceCenterInd) == 0) = [];
            % % figure
            % % ft_plot_mesh(sourceModel, 'surfaceonly', 'yes', 'vertexcolor', 'b', 'edgecolor', 'b'); hold on
            % % ft_plot_mesh(sourceModel.pos(AllSourceCenterInd, :), 'surfaceonly', 'yes', 'vertexcolor', 'r', 'edgecolor', 'r');
            % ===========================
            Freq_FP = 10;
            time_FP = linspace(0, 1/Freq_FP, 10); % Time vector specific for fprward problem 1/Freq_FP
            Oscil_FP =  abs(sin(2 * pi * Freq_FP * time_FP)); % ones(1, length(time_FP));%
            % patchWidth = 100; % # of neighbours
            % activePatchInd = nan(length(AllSourceCenterInd), patchWidth);
            % activePatchAmp = nan(length(AllSourceCenterInd), patchWidth);
            activePatchAmp = nan(length(AllSourceCenterInd), size(sourceModel.pos, 1));
            sourceActivity = cell(length(AllSourceCenterInd), length(time_FP)); %zeros(size(grid.pos));
            sourceActivityPow = cell(1, length(AllSourceCenterInd));
            Field = cell(1, length(AllSourceCenterInd)); %nan(size(LF.LF_cat, 1), length(AllSourceCenterInd));
            sigma2 = my_cfg.sourceActivity.sigma2; % Maximum: 10000
            % figure
            for i = 1 : length(AllSourceCenterInd)
                [patchCenterAllDist, ~] = dijkstra(nodes, segments, AllSourceCenterInd(i));
                %         patchCenter = sourceModel.pos(AllSourceCenterInd(i), :);
                %         patchCenterAllDist = sqrt(sum((sourceModel.pos - repmat(patchCenter, size(sourceModel.pos, 1), 1)).^2, 2));
                %         [~, ind] = sort(patchCenterAllDist);
                %         activePatchInd(i, :) = ind(1 : patchWidth);
                
                %         activePatchAmp(i, :) = exp(-(((sourceModel.pos(activePatchInd(i, :), 1) - sourceModel.pos(AllSourceCenterInd(i), 1)).^2 / (2 * sigma2)) + ...
                %             ((sourceModel.pos(activePatchInd(i, :), 2) - sourceModel.pos(AllSourceCenterInd(i), 2)).^2 / (2 * sigma2)) + ...
                %             ((sourceModel.pos(activePatchInd(i, :), 3) - sourceModel.pos(AllSourceCenterInd(i), 3)).^2 / (2 * sigma2))));
                activePatchAmp(i, :) = exp(-((patchCenterAllDist.^2) / (2 * sigma2) ));
                
                sourceActivityPow{i} = nan(size(activePatchAmp, 2), length(time_FP));
                %          temp = rand(1, 3);
                for ii = 1 : length(time_FP)
                    
                    
                    sourceActivity{i, ii} = zeros(size(sourceModel.pos));
                    %             for j = 1 : size(activePatchAmp, 2)
                    %                 temp = rand(1, 3);
                    %                 %             sourceActivity{i, ii}(activePatchInd(i, j), :) = Oscil_FP(ii) * activePatchAmp(i, j) * temp./norm(temp);
                    %                 sourceActivity{i, ii}(j, :) = Oscil_FP(ii) * activePatchAmp(i, j) * temp./norm(temp);
                    %             end
                    if strcmp(SourceModels{j}, 'white')
                        dipMom = rand(1, 3);
                    else
                        dipMom = forwardProblem.white.dipMom;
                    end
                    %                 temp = rand(1, 3);
                    maxMom = repmat(activePatchAmp(i, :)', 1, 3) .* repmat(dipMom./norm(dipMom), size(activePatchAmp(i, :), 2), 1);
                    maxPow = sqrt(sum(maxMom.^ 2, 2));
                    sourceActivity{i, ii} = Oscil_FP(ii) * maxMom;
                    sourceActivityPow{i}(:, ii) = sqrt(sum(sourceActivity{i, ii}.^ 2, 2));
                    % -> representation
                    %                 subplot(121)
                    % figure
                    % subplot(121)
                    %                 ft_plot_mesh(sourceModel, 'vertexcolor', sourceActivityPow{i}(:, ii), 'edgecolor', 'k', 'colormap', 'jet'); % , 'surfaceonly', 'yes'
                    %                 lighting gouraud; material dull
                    
                    temp2 = sourceActivity{i, ii}(LeadField.(SourceModels{j}).inside, :)'; % MODIFIED
                    Field{i}(:, ii) = LeadField.(SourceModels{j}).LF_cat * temp2(:); % MODIFIED
                    
                    % -> representation
                    %                 subplot(122)
                    %                 %         ft_plot_topo(sens.chanpos(:, 1, :), y, val, ...)
                    % %                 if ft_senstype(sens, 'meg')
                    % %                     channel = ft_channelselection('m*', sens.label);
                    % %                 elseif ft_senstype(sens, 'eeg')
                    % %                     channel = ft_channelselection('all', sens.label);
                    % %                 end
                    % %                 ft_plot_topo3d(sens.chanpos(ismember(sens.label, channel), :), Field, 'colormap', 'jet')
                    % ft_plot_topo3d(sens.chanpos(ismember(sens.label, LF.label), :), Field, 'colormap', 'jet')
                    %                 pause(.01)
                    % drawnow
                end
            end % for i = 1 : length(AllSourceCenterInd)
            
            forwardProblem.(SourceModels{j}) = [];
            forwardProblem.(SourceModels{j}).maxMom = maxMom;
            forwardProblem.(SourceModels{j}).dipMom = dipMom;
            forwardProblem.(SourceModels{j}).maxPow = maxPow;
            forwardProblem.(SourceModels{j}).sourceModel = sourceModel;
            forwardProblem.(SourceModels{j}).sourceActivity = sourceActivity;
            forwardProblem.(SourceModels{j}).sourceActivityWidth = sigma2;
            forwardProblem.(SourceModels{j}).sourceActivityPow = sourceActivityPow;
            forwardProblem.(SourceModels{j}).Field = Field;
            forwardProblem.(SourceModels{j}).activePatchAmp = activePatchAmp;
            forwardProblem.(SourceModels{j}).Msc.segments = segments;
            forwardProblem.(SourceModels{j}).Msc.AllSourceCenterInd = AllSourceCenterInd;
            %             forwardProblem.(SourceModels{j}).Msc.nodes = nodes;
            forwardProblem.(SourceModels{j}).Msc.time_FP = time_FP;
            forwardProblem.(SourceModels{j}).Msc.Oscil_FP = Oscil_FP;
            forwardProblem.(SourceModels{j}).Msc.LeadField = LeadField.(SourceModels{j});
        elseif strcmp(SourceModels{j}, 'whitePial')
            forwardProblem.(SourceModels{j}) = [];
            forwardProblem.(SourceModels{j}).maxMom = [forwardProblem.white.maxMom; forwardProblem.pial.maxMom];
            forwardProblem.(SourceModels{j}).dipMom = dipMom;
            forwardProblem.(SourceModels{j}).maxPow = [forwardProblem.white.maxPow; forwardProblem.pial.maxPow];
            forwardProblem.(SourceModels{j}).sourceModel = sourceModel;
            for i = 1 : length(forwardProblem.white.Msc.time_FP)
                forwardProblem.(SourceModels{j}).sourceActivity{1, i} = [forwardProblem.white.sourceActivity{1, i}; forwardProblem.pial.sourceActivity{1, i}];
                temp2 = forwardProblem.(SourceModels{j}).sourceActivity{1, i}(LeadField.(SourceModels{j}).inside, :)';
                forwardProblem.(SourceModels{j}).Field{1}(:, i) = LeadField.(SourceModels{j}).LF_cat * temp2(:);
            end
            forwardProblem.(SourceModels{j}).sourceActivityWidth = sigma2;
            forwardProblem.(SourceModels{j}).sourceActivityPow{1} = [forwardProblem.white.sourceActivityPow{1}; forwardProblem.pial.sourceActivityPow{1}];
            %             forwardProblem.(SourceModels{j}).Field = [forwardProblem.white.Field{1}; forwardProblem.pial.Field{1}];
            forwardProblem.(SourceModels{j}).activePatchAmp = [forwardProblem.white.activePatchAmp forwardProblem.pial.activePatchAmp];
            forwardProblem.(SourceModels{j}).Msc.segments = [forwardProblem.white.Msc.segments; forwardProblem.pial.Msc.segments + repmat([size(forwardProblem.white.Msc.segments, 1) size(forwardProblem.white.sourceModel.pos, 1)*ones(1, 2)], size(forwardProblem.pial.Msc.segments, 1), 1)];
            forwardProblem.(SourceModels{j}).Msc.AllSourceCenterInd = [forwardProblem.white.Msc.AllSourceCenterInd forwardProblem.pial.Msc.AllSourceCenterInd + size(forwardProblem.white.sourceModel.pos, 1)];
            %             forwardProblem.(SourceModels{j}).Msc.nodes = nodes;
            forwardProblem.(SourceModels{j}).Msc.time_FP = time_FP;
            forwardProblem.(SourceModels{j}).Msc.Oscil_FP = Oscil_FP;
            forwardProblem.(SourceModels{j}).Msc.LeadField = LeadField.(SourceModels{j});
        elseif strcmp(SourceModels{j}, 'whiteBetweenPial')
            forwardProblem.(SourceModels{j}) = [];
            forwardProblem.(SourceModels{j}).maxMom = [forwardProblem.white.maxMom; forwardProblem.between.maxMom; forwardProblem.pial.maxMom];
            forwardProblem.(SourceModels{j}).dipMom = dipMom;
            forwardProblem.(SourceModels{j}).maxPow = [forwardProblem.white.maxPow; forwardProblem.between.maxPow; forwardProblem.pial.maxPow];
            forwardProblem.(SourceModels{j}).sourceModel = sourceModel;
            for i = 1 : length(forwardProblem.white.Msc.time_FP)
                forwardProblem.(SourceModels{j}).sourceActivity{1, i} = [forwardProblem.white.sourceActivity{1, i}; forwardProblem.between.sourceActivity{1, i}; forwardProblem.pial.sourceActivity{1, i}];
                temp2 = forwardProblem.(SourceModels{j}).sourceActivity{1, i}(LeadField.(SourceModels{j}).inside, :)';
                forwardProblem.(SourceModels{j}).Field{1}(:, i) = LeadField.(SourceModels{j}).LF_cat * temp2(:);
            end
            forwardProblem.(SourceModels{j}).sourceActivityWidth = sigma2;
            forwardProblem.(SourceModels{j}).sourceActivityPow{1} = [forwardProblem.white.sourceActivityPow{1}; forwardProblem.between.sourceActivityPow{1}; forwardProblem.pial.sourceActivityPow{1}];
            %             forwardProblem.(SourceModels{j}).Field = [forwardProblem.white.Field{1}; forwardProblem.pial.Field{1}];
            forwardProblem.(SourceModels{j}).activePatchAmp = [forwardProblem.white.activePatchAmp forwardProblem.between.activePatchAmp forwardProblem.pial.activePatchAmp];
            forwardProblem.(SourceModels{j}).Msc.segments = [forwardProblem.white.Msc.segments; ...
                forwardProblem.between.Msc.segments + repmat([size(forwardProblem.white.Msc.segments, 1) size(forwardProblem.white.sourceModel.pos, 1)*ones(1, 2)], size(forwardProblem.between.Msc.segments, 1), 1); ...
                forwardProblem.pial.Msc.segments + repmat([size(forwardProblem.white.Msc.segments, 1)+size(forwardProblem.between.Msc.segments, 1) (size(forwardProblem.white.sourceModel.pos, 1) + size(forwardProblem.between.sourceModel.pos, 1))*ones(1, 2)], size(forwardProblem.pial.Msc.segments, 1), 1)];
            forwardProblem.(SourceModels{j}).Msc.AllSourceCenterInd = [forwardProblem.white.Msc.AllSourceCenterInd forwardProblem.between.Msc.AllSourceCenterInd+size(forwardProblem.white.sourceModel.pos, 1) forwardProblem.pial.Msc.AllSourceCenterInd+size(forwardProblem.white.sourceModel.pos, 1)+size(forwardProblem.between.sourceModel.pos, 1)];
            %             forwardProblem.(SourceModels{j}).Msc.nodes = nodes;
            forwardProblem.(SourceModels{j}).Msc.time_FP = time_FP;
            forwardProblem.(SourceModels{j}).Msc.Oscil_FP = Oscil_FP;
            forwardProblem.(SourceModels{j}).Msc.LeadField = LeadField.(SourceModels{j});
        end % if ismember(SourceModels{j}, {'white', 'pial', 'between'})
    end % for j = 1 : length(SourceModels)
    
    save(my_cfg.FPDir, 'forwardProblem');
else
    load(my_cfg.FPDir);
    load(my_cfg.LFDir)
    load(my_cfg.sensDir)
end % if my_cfg.recompute

% --> Visualization of source activity:
if my_cfg.feedback.srcActivity
    %     fiducials = [my_cfg.grid.fiducials.xyz.nas; my_cfg.grid.fiducials.xyz.lpa; my_cfg.grid.fiducials.xyz.rpa];
    
    %     cfg = [];
    % cfg.funparameter = 'pow';
    % ft_sourcemovie(cfg, source);
    %     figure
    %     for i = 1 : size(source.cartCoord, 1)
    % %                     hh = quiver3(my_cfg.grid.pos(source.activePatch, 1), my_cfg.grid.pos(source.activePatch, 2), my_cfg.grid.pos(source.activePatch, 3), ...
    % %             my_cfg.grid.pos(source.activePatch, 1) + source.cartCoord(i, 1), ...
    % %             my_cfg.grid.pos(source.activePatch, 2) + source.cartCoord(i, 2), ...
    % %             my_cfg.grid.pos(source.activePatch, 3) + source.cartCoord(i, 3), 'color', 'r');
    %
    % %         ft_plot_mesh(my_cfg.grid.pos, 'surfaceonly', 'yes', 'vertexcolor', 'b', 'edgecolor', 'b'); hold on %,'face alpha',0.7, 'facecolor', 'white'
    %
    %         ft_plot_mesh(my_cfg.grid, 'vertexcolor', source.pow(:, i), 'edgecolor', 'none'); hold on %,'face alpha',0.7, 'facecolor', 'white',  'surfaceonly', 'yes'
    %         plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 10)
    %         text(fiducials(1, 1) + 1, fiducials(1, 2), fiducials(1, 3) - 1, 'nas')
    %         text(fiducials(2, 1), fiducials(2, 2) + 1, fiducials(2, 3) - 1, 'lpa')
    %         text(fiducials(3, 1), fiducials(3, 2) - 1, fiducials(3, 3) - 1, 'rpa')
    %         title('Source activity');
    %         alpha 0.25;
    %         view([0 90]);
    % %         camlight; drawnow
    %
    % % data = my_cfg.grid;
    % % data.avg.pow = source.pow;
    % % data.dimord = 'pos_time';
    % % data.dim = [256 256 256];
    % cfg = [];
    % cfg.method          = 'surface';
    % cfg.funparameter    = 'pow';
    % cfg.funcolormap     = 'jet';
    % %
    % % % cfg.latency         = .060;     % The time-point to plot
    % % % cfg.colorbar        = 'no';
    % % ft_plot_mesh(my_cfg.grid, 'vertexcolor', data.avg.pow(:,2))
    % ft_sourceplot(cfg, source, my_cfg.grid)
    % lighting gouraud; material dull
    %
    %                 drawnow
    %         pause(0.004)
    % %         delete(hh)
    %     end % for i = 1 : size(source.cartCoord, 1)
    SourceModels = {'white', 'between', 'pial', 'whitePial', 'whiteBetweenPial'}; % ADDED
    
    %     figure
    %     while 1
    %     for j = 1 : 1 % Repetition
    for jj = 1 : length(SourceModels)
        figure('Name', SourceModels{jj}, 'NumberTitle', 'off')
        for i = 1 : length(forwardProblem.(SourceModels{jj}).sourceActivityPow)
            for ii = 1 : size(forwardProblem.(SourceModels{jj}).sourceActivity, 2)
                subplot(121)
                ft_plot_mesh(forwardProblem.(SourceModels{jj}).sourceModel, 'vertexcolor', forwardProblem.(SourceModels{jj}).sourceActivityPow{i}(:, ii), 'edgecolor', 'k', 'colormap', 'jet');
                subplot(122)
                ft_plot_topo3d(sens.chanpos(ismember(sens.label, LeadField.(SourceModels{jj}).label), :), forwardProblem.(SourceModels{jj}).Field{i}(:, ii), 'colormap', 'jet')
                drawnow
                pause(0.01)
            end
        end
    end % for jj = 1 : length(SourceModels)
    %     end % for j = 1 : 1 % Repetition
    
end

