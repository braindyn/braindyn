function EMEG_pipeline_ver2
clc
close all
restoredefaultpath

h = figure('tag', 'figure', 'toolbar', 'none', 'menubar', 'none', 'position', [50 50 1000 650], 'name','EEG/MEG source reconstruction pipeline', 'NumberTitle', 'off'); % , 'windowbuttondownfcn', @cb_getposition
hWH = get(h, 'Position'); %hWH = hWH(3) / hWH(4);

panelPath = uipanel(h, 'Title', 'Paths', 'Units', 'normalized', 'Position', [.2 .4 .6 .2]);
% panelPathWH = get(panelPath, 'Position'); panelPathWH = (panelPathWH(3) * hWH(3)) / (panelPathWH(4)* hWH(4));
txtFT = uicontrol(panelPath, 'Style', 'text', 'String', 'FieldTrip', 'Units', 'normalized' , 'Position',[.01 .7 .1 .2], 'horizontalalignment', 'left');
edtFT = uicontrol(panelPath, 'Style', 'edit', 'String', '', 'Units', 'normalized', 'Position', [.11 .7 .64 .2]); % E:\Ph.D\Related works\FT\Toolbox\fieldtrip-20180603
pbFT = uicontrol(panelPath, 'Style', 'pushbutton', 'String', 'Browse ...', 'Units', 'normalized', 'Position', [.75 .7 .2 .2], 'FontSize', 8, 'callback', @BrowseFT);
% txtTB = uicontrol(panelPath, 'Style', 'text', 'String', 'ToolBox', 'Units', 'normalized', 'Position', [0 .37 .25 .3], 'horizontalalignment', 'left'); %
% edtTB = uicontrol(panelPath, 'Style', 'edit', 'String', 'E:\pipeline', 'Units', 'normalized', 'Position', [.5 .37 .2 .3]); %
% pbTB = uicontrol(panelPath, 'Style', 'pushbutton', 'String', 'Browse ...', 'Units', 'normalized', 'Position', [.70 .37 .25 .30], 'FontSize', 7); %
txtSub = uicontrol(panelPath, 'Style', 'text', 'String', 'MRI', 'Units', 'normalized', 'Position', [.01 .45 .1 .2], 'horizontalalignment', 'left'); % [.1 .05 .3 .3] .1/panelPathWH
edtSub = uicontrol(panelPath, 'Style', 'edit', 'String', '', 'Units', 'normalized', 'Position', [.11 .45 .64 .2]); % E:\Ph.D\Related works\FT\Toolbox\tutorial\Subject01
pbSub = uicontrol(panelPath, 'Style', 'pushbutton', 'String', 'Browse ...', 'Units', 'normalized', 'Position', [.75 .45 .2 .2], 'FontSize', 8, 'callback', @BrowseSub); %
pbAddpath = uicontrol(panelPath, 'Style', 'pushbutton', 'String', 'Add path', 'Units', 'normalized', 'Position', [.75 .1 .2 .2], 'FontSize', 8, 'callback', @AddPath);

panelPipeline = uipanel(h, 'Title', 'Pipeline', 'Units', 'normalized', 'Position', [.02 .02 .96 .96], 'Visible', 'off'); %
panelPipelineWH = get(panelPipeline, 'Position'); panelPipelineWH = (panelPipelineWH(3) * hWH(3)) / (panelPipelineWH(4)* hWH(4));
% pbMRI = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'MRI', 'Units', 'normalized', 'Position', [.03 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off', 'callback', @MRI);
% pbSegMRI = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'Segmented MRI', 'Units', 'normalized', 'Position', [.055 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off', 'callback', @SegMRI);
% pbMesh = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'Mesh', 'Units', 'normalized', 'Position', [.06 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off', 'callback', @Mesh);
% pbVol = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'Head model', 'Units', 'normalized', 'Position', [.07 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off', 'callback', @HeadModel);
% pbSrc = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'Source model', 'Units', 'normalized', 'Position', [.08 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off', 'callback', @SourceModel);
% % pbSns = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'Sensor model', 'Units', 'normalized', 'Position', [.09 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off', 'callback', @SensorModel);
% pbLF = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'Lead-field', 'Units', 'normalized', 'Position', [.1 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off', 'callback', @LeadField);
% pbFS = uicontrol(panelPipeline, 'Style', 'pushbutton', 'String', 'Forward solution', 'Units', 'normalized', 'Position', [.85 .85 .12 .06], 'FontWeight', 'bold', 'Enable', 'off');
% align([pbMRI pbSegMRI pbMesh pbVol pbSrc pbSns pbLF pbFS], 'Distribute', 'Center');

% AxeEEGSensor = axes(panelPipeline, 'position', [0.05 0.08 0.4/panelPipelineWH 0.4], 'tag', 'AxeEEGSensor'); % , 'Box', 'off'
% axis off equal
% axis equal

% AxeEEGSource = axes(panelPipeline, 'position', [0.05 0.5 0.4/panelPipelineWH 0.4], 'tag', 'AxeEEGSource'); % , 'Box', 'off'
% AxeEEGSource = axes(h, 'position', [.35 .5 .3 .3], 'tag', 'AxeEEGSource'); % , 'Box', 'off'

% % align([AxeEEGSource h], 'Center', 'Middle');
% axis off
% box off
% logo = imread('CRNL-logo.jpg');
% logo(logo >= 250) = 0.94 * 255;
% imshow(logo)
% % axis equal

% AxeMEGSensor = axes(panelPipeline, 'position', [0.4/panelPipelineWH + 0.08 0.08 0.4/panelPipelineWH 0.4], 'tag', 'AxeMEGSensor'); % , 'Box', 'off'
% axis off equal
% axis equal
% AxeMEGSource = axes(panelPipeline, 'position', [0.4/panelPipelineWH + 0.08 0.5 0.4/panelPipelineWH 0.4], 'tag', 'AxeMEGSource'); % , 'Box', 'off'
% axis off equal
% % axis equal

sEEGSourceUp = uicontrol(panelPipeline, 'Style', 'slider', 'Min', 1, 'Max', 256, 'Value', 128, 'SliderStep', [1/256 5/256], 'Units', 'normalized', 'Position', [0.1 0.925 0.4 .05], 'Visible', 'off', 'callback', @MRI_slider);
txtEEGSourceUp = uicontrol(panelPipeline, 'Style', 'text', 'String', 'Coronal (128/256)', 'Units', 'normalized' , 'Position', [.25 .975 .1 0.025], 'horizontalalignment', 'center', 'Visible', 'off');
sEEGSourceLeft = uicontrol(panelPipeline, 'Style', 'slider', 'Min', 1, 'Max', 256, 'Value', 128, 'SliderStep', [1/256 5/256], 'Units', 'normalized', 'Position', [0.01 (1-0.4*panelPipelineWH)/2 .05/panelPipelineWH 0.4*panelPipelineWH], 'Visible', 'off', 'callback', @MRI_slider);% [0.05 0.3 0.05*panelPipelineWH 0.4*panelPipelineWH]
mls = sprintf('%s\n%s',' Axial','128/256');
txtEEGSourceLeft = uicontrol(panelPipeline, 'Style', 'text', 'String', mls, 'Units', 'normalized' , 'Position', [0.005 (1-0.4*panelPipelineWH)/2-.05 0.045 0.05], 'horizontalalignment', 'center', 'Visible', 'off'); % [0 (0.3 + 0.2*panelPipelineWH) 0.05 0.05]
sEEGSourceBottom = uicontrol(panelPipeline, 'Style', 'slider', 'Min', 1, 'Max', 256, 'Value', 128, 'SliderStep', [1/256 5/256], 'Units', 'normalized', 'Position', [0.1 0.025 0.4 0.05], 'Visible', 'off', 'callback', @MRI_slider);
txtEEGSourceBottom = uicontrol(panelPipeline, 'Style', 'text', 'String', 'Sagittal (128/256)', 'Units', 'normalized' , 'Position', [.25 0 .1 0.025], 'horizontalalignment', 'center', 'Visible', 'off');

% sMEGSourceUp = uicontrol(panelPipeline, 'Style', 'slider', 'Min', 1, 'Max', 256, 'Value', 128, 'SliderStep', [1 1], 'Units', 'normalized', 'Position', [0.4/panelPipelineWH + 0.08 0.9 0.4/panelPipelineWH 0.05], 'Enable', 'off', 'callback', @MEGMRI_slider);
% sMEGSourceLeft = uicontrol(panelPipeline, 'Style', 'slider', 'Min', 1, 'Max', 256, 'Value', 128, 'SliderStep', [1 1], 'Units', 'normalized', 'Position', [0.4/panelPipelineWH + 0.08 0.5 0.05 0.4], 'Enable', 'off', 'callback', @MEGMRI_slider);
% sMEGSourceBottom = uicontrol(panelPipeline, 'Style', 'slider', 'Min', 1, 'Max', 256, 'Value', 128, 'SliderStep', [1 1], 'Units', 'normalized', 'Position', [0.4/panelPipelineWH + 0.08 0.45 0.4/panelPipelineWH 0.05], 'Enable', 'off', 'callback', @MEGMRI_slider);

B = 0.02; % Bottom
H = (.95 - .05)/9; %0.05; % Height
L = 0.59; % Left
W = 0.4; % Width
Lin = linspace(.33, .9, 4); % Left inside panel
Win = Lin(2)-Lin(1);% Width inside panel
Bin = [.1 .55];% Bottom inside panel
Hin = [.95 .45];% Bottom inside panel
PB = [.005 .2 .255 .65];
% Lin = [0.05 linspace(0.1, 0.95, 5)]; % Left inside panel
% Bin = [0.05 linspace(0.1, 0.95, 5)]; % Left inside panel

panelIP = uipanel(panelPipeline, 'Title', ' 9- Inverse problem', 'Units', 'normalized', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]); %
pbIP = uicontrol(panelIP, 'Style', 'pushbutton', 'String', 'Inverse problem', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @InverseProblem, 'FontSize', 8);
cbIPDICSPowEEG = uicontrol(panelIP, 'Style', 'checkbox', 'String', 'Power', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(1) Bin(1)-.1 Win Hin(2)], 'Enable', 'off', 'callback', @InverseProblem_checkBox);
% cbIPDICSMom = uicontrol(panelIP, 'Style', 'checkbox', 'String', 'Moment (DICS)', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(2) Bin(1) Win Hin(2)], 'Enable', 'off');
cbIPDICSPowMEG = uicontrol(panelIP, 'Style', 'checkbox', 'String', 'Power', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(3) Bin(1)-.1 Win Hin(2)], 'Enable', 'off', 'callback', @InverseProblem_checkBox);
cbIPLCMVPowEEG = uicontrol(panelIP, 'Style', 'checkbox', 'String', 'Power', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(1) Bin(2)-.1 Win Hin(2)], 'Enable', 'off', 'callback', @InverseProblem_checkBox);
cbIPLCMVMomEEG = uicontrol(panelIP, 'Style', 'checkbox', 'String', 'Moment', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(2)-.05 Bin(2)-.1 Win Hin(2)], 'Enable', 'off', 'callback', @InverseProblem_checkBox);
cbIPLCMVPowMEG = uicontrol(panelIP, 'Style', 'checkbox', 'String', 'Power', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(3) Bin(2)-.1 Win Hin(2)], 'Enable', 'off', 'callback', @InverseProblem_checkBox);
cbIPLCMVMomMEG = uicontrol(panelIP, 'Style', 'checkbox', 'String', 'Moment', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(4)-.05 Bin(2)-.1 Win Hin(2)], 'Enable', 'off', 'callback', @InverseProblem_checkBox);
txtLCMVLabel = uicontrol(panelIP, 'Style', 'text', 'String', 'LCMV', 'Units', 'normalized' , 'Position', [.261 Bin(2) Lin(1)-.001-.261 .2], 'horizontalalignment', 'center', 'Enable', 'off', 'FontSize', 6, 'BackgroundColor', 0.8*ones(1, 3));
txtDICSLabel = uicontrol(panelIP, 'Style', 'text', 'String', 'DICS', 'Units', 'normalized' , 'Position', [.261 Bin(1) Lin(1)-.001-.261 .2], 'horizontalalignment', 'center', 'Enable', 'off', 'FontSize', 6, 'BackgroundColor', 0.8*ones(1, 3));
txtEEGLabel = uicontrol(panelIP, 'Style', 'text', 'String', 'EEG', 'Units', 'normalized' , 'Position', [Lin(1) .8 Lin(2)+Win-Lin(1)-.09 .2], 'horizontalalignment', 'center', 'Enable', 'off', 'FontSize', 6, 'BackgroundColor', 0.8*ones(1, 3));
txtMEGLabel = uicontrol(panelIP, 'Style', 'text', 'String', 'MEG', 'Units', 'normalized' , 'Position', [Lin(3) .8 Lin(4)+Win-Lin(3)-.09 .2], 'horizontalalignment', 'center', 'Enable', 'off', 'FontSize', 6, 'BackgroundColor', 0.8*ones(1, 3));

B = B + 1.1 * H;
panelFP = uipanel(panelPipeline, 'Title', ' 8- Forward problem', 'Units', 'normalized', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]); %
pbFP = uicontrol(panelFP, 'Style', 'pushbutton', 'String', 'Forward problem', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @ForwardProblem, 'FontSize', 8);
cbFPSource = uicontrol(panelFP, 'Style', 'checkbox', 'String', 'Source', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(1) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @ForwardProblem_checkBox);
cbFPEEG = uicontrol(panelFP, 'Style', 'checkbox', 'String', 'EEG', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(2) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @ForwardProblem_checkBox);
cbFPMEG = uicontrol(panelFP, 'Style', 'checkbox', 'String', 'MEG', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(3) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @ForwardProblem_checkBox);

B = B + 1.1 * H;
panelLF = uipanel(panelPipeline, 'Title', ' 7- Lead-field', 'Units', 'normalized', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]); %
pbLF = uicontrol(panelLF, 'Style', 'pushbutton', 'String', 'Lead-field', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @LeadField, 'FontSize', 8);
% cbLF = uicontrol(panelLF, 'Style', 'checkbox', 'String', 'Forward solution', 'Value', 0, 'Units', 'normalized', 'Position', [L B .15 H], 'Enable', 'off');

B = B + 1.1 * H;
% H = 0.15;
panelSns = uipanel(panelPipeline, 'Title', ' 6- Sensor model', 'Units', 'normalized', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]); %
pbSns = uicontrol(panelSns, 'Style', 'pushbutton', 'String', 'Sensor model', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @SensorModel, 'FontSize', 8);
cbSnsEEG = uicontrol(panelSns, 'Style', 'checkbox', 'String', 'EEG', 'Units', 'normalized', 'Position',[Lin(1) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @SensorModel_checkBox);
cbSnsMEG = uicontrol(panelSns, 'Style', 'checkbox', 'String', 'MEG', 'Units', 'normalized', 'Position',[Lin(2) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @SensorModel_checkBox);

B = B + 1.1 * H;
% H = 0.1;
panelSrc = uipanel(panelPipeline, 'Title', ' 5- Source model', 'Units', 'normalized', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]); %
pbSrc = uicontrol(panelSrc, 'Style', 'pushbutton', 'String', 'Source model', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @SourceModel, 'FontSize', 8);
cbSrcWhite = uicontrol(panelSrc, 'Style', 'checkbox', 'String', 'White matter', 'Units', 'normalized', 'Position', [Lin(1) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @SourceModel_checkBox);
cbSrcPial = uicontrol(panelSrc, 'Style', 'checkbox', 'String', 'Pial', 'Units', 'normalized', 'Position', [Lin(2) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @SourceModel_checkBox);
cbSrcBetween = uicontrol(panelSrc, 'Style', 'checkbox', 'String', 'In-between', 'Units', 'normalized', 'Position', [Lin(3) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @SourceModel_checkBox);

B = B + 1.1 * H;
% H = 0.1;
panelVol = uipanel(panelPipeline, 'Title', ' 4- Head model', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]);
pbVol = uicontrol(panelVol, 'Style', 'pushbutton', 'String', 'Head model', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @HeadModel, 'FontSize', 8);
cbVolEEG = uicontrol(panelVol, 'Style', 'checkbox', 'String', 'EEG', 'Units', 'normalized', 'Position',[Lin(1) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @HeadModel_checkBox);
cbVolMEG = uicontrol(panelVol, 'Style', 'checkbox', 'String', 'MEG', 'Units', 'normalized', 'Position',[Lin(2) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @HeadModel_checkBox);

B = B + 1.1 * H;
% H = 0.15;
panelMesh = uipanel(panelPipeline, 'Title', ' 3- Mesh', 'Units', 'normalized', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]); %
pbMesh = uicontrol(panelMesh, 'Style', 'pushbutton', 'String', 'Mesh', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @Mesh, 'FontSize', 8);
cbMeshBrain = uicontrol(panelMesh, 'Style', 'checkbox', 'String', 'Brain', 'Units', 'normalized', 'Position',[Lin(1) Bin(2) Win Hin(2)], 'Enable', 'off', 'callback', @Mesh_checkBox);
cbMeshSkull = uicontrol(panelMesh, 'Style', 'checkbox', 'String', 'Skull', 'Units', 'normalized', 'Position',[Lin(2) Bin(2) Win Hin(2)], 'Enable', 'off', 'callback', @Mesh_checkBox);
cbMeshScalp = uicontrol(panelMesh, 'Style', 'checkbox', 'String', 'Scalp', 'Units', 'normalized', 'Position',[Lin(3) Bin(2) Win Hin(2)], 'Enable', 'off', 'callback', @Mesh_checkBox);
cbMeshWhite = uicontrol(panelMesh, 'Style', 'checkbox', 'String', 'White matter', 'Units', 'normalized', 'Position',[Lin(1) Bin(1) Win Hin(2)], 'Enable', 'off', 'callback', @Mesh_checkBox);
cbMeshGray = uicontrol(panelMesh, 'Style', 'checkbox', 'String', 'Pial', 'Units', 'normalized', 'Position',[Lin(2) Bin(1) Win Hin(2)], 'Enable', 'off', 'callback', @Mesh_checkBox);
cbMeshCSF = uicontrol(panelMesh, 'Style', 'checkbox', 'String', 'CSF', 'Units', 'normalized', 'Position',[Lin(3) Bin(1) Win Hin(2)], 'Enable', 'off', 'callback', @Mesh_checkBox);

B = B + 1.1 * H;
% H = 0.15;
panelSegMRI = uipanel(panelPipeline, 'Title', ' 2- Segmented MRI', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]);
pbSegMRI = uicontrol(panelSegMRI, 'Style', 'pushbutton', 'String', 'Segmented MRI', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @SegMRI, 'FontSize', 8);
cbSegBrain = uicontrol(panelSegMRI, 'Style', 'checkbox', 'String', 'Brain', 'Units', 'normalized', 'Position',[Lin(1) Bin(2) Win Hin(2)], 'Enable', 'off', 'callback', @SegMRI_checkBox);
cbSegSkull = uicontrol(panelSegMRI, 'Style', 'checkbox', 'String', 'Skull', 'Units', 'normalized', 'Position',[Lin(2) Bin(2) Win Hin(2)], 'Enable', 'off', 'callback', @SegMRI_checkBox);
cbSegScalp = uicontrol(panelSegMRI, 'Style', 'checkbox', 'String', 'Scalp', 'Units', 'normalized', 'Position',[Lin(3) Bin(2) Win Hin(2)], 'Enable', 'off', 'callback', @SegMRI_checkBox);
cbSegWhite = uicontrol(panelSegMRI, 'Style', 'checkbox', 'String', 'White matter', 'Units', 'normalized', 'Position',[Lin(1) Bin(1) Win Hin(2)], 'Enable', 'off', 'callback', @SegMRI_checkBox);
cbSegGray = uicontrol(panelSegMRI, 'Style', 'checkbox', 'String', 'Gray matter', 'Units', 'normalized', 'Position',[Lin(2) Bin(1) Win Hin(2)], 'Enable', 'off', 'callback', @SegMRI_checkBox);
cbSegCSF = uicontrol(panelSegMRI, 'Style', 'checkbox', 'String', 'CSF', 'Units', 'normalized', 'Position',[Lin(3) Bin(1) Win Hin(2)], 'Enable', 'off', 'callback', @SegMRI_checkBox);
cbSegAll = uicontrol(panelSegMRI, 'Style', 'checkbox', 'String', 'All', 'Units', 'normalized', 'Position',[Lin(4) .33 .1 Hin(2)], 'Enable', 'off', 'callback', @SegMRI_checkBox);

B = B + 1.1 * H;
% H = 0.1;
panelMRI = uipanel(panelPipeline, 'Title', ' 1- MRI', 'Units', 'normalized', 'Position', [L B W H], 'ForegroundColor', 0.4*[1 1 1]); %
pbMRI = uicontrol(panelMRI, 'Style', 'pushbutton', 'String', 'MRI', 'Units', 'normalized', 'Position', PB, 'Enable', 'off', 'callback', @MRI, 'FontSize', 8);
cbMRI = uicontrol(panelMRI, 'Style', 'checkbox', 'String', 'MRI', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(1) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @MRI_checkBox);
cbFiducl = uicontrol(panelMRI, 'Style', 'checkbox', 'String', 'Fiducials', 'Value', 0, 'Units', 'normalized', 'Position', [Lin(2) Bin(1) Win Hin(1)], 'Enable', 'off', 'callback', @Fid_checkBox);

panelMessage = uipanel(panelPipeline, 'Title', '', 'Units', 'normalized', 'Position', [.01 .02 .96 .1], 'BackgroundColor', [250, 128, 114] / 255, 'ShadowColor', [250, 128, 114] / 255, 'HighlightColor', [250, 128, 114] / 255, 'Visible', 'off');
txtMesg = uicontrol(panelMessage, 'Style', 'text', 'String', 'String', 'Units', 'normalized', 'Position', [.02 .02 .83 .75], 'horizontalalignment', 'left', 'Visible', 'off', 'FontSize', 10, 'FontWeight', 'bold');
pbYes = uicontrol(panelMessage, 'Style', 'pushbutton', 'String', 'Yes', 'Units', 'normalized', 'Position', [.85 .25 .07 .5], 'FontWeight', 'bold', 'Visible', 'off', 'callback', @YES);
pbNo = uicontrol(panelMessage, 'Style', 'pushbutton', 'String', 'No', 'Units', 'normalized', 'Position', [.92 .25 .07 .5], 'FontWeight', 'bold', 'Visible', 'off', 'callback', @NO);

A = 0.72;
B = 0.06;
C = 0.02;
edtBrainNod = uicontrol(panelMessage, 'Style', 'edit', 'String', '3000', 'Units', 'normalized', 'Position', [A .5 B .25], 'Visible', 'off'); %
txtBrainNod = uicontrol(panelMessage, 'Style', 'text', 'String', 'Brain', 'Units', 'normalized' , 'Position', [A 0.75+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off');
edtWhiteNod = uicontrol(panelMessage, 'Style', 'edit', 'String', '3000', 'Units', 'normalized', 'Position', [A .05 B .25], 'Visible', 'off'); %
txtWhiteNod = uicontrol(panelMessage, 'Style', 'text', 'String', 'White', 'Units', 'normalized' , 'Position', [A 0.3+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off');
A = A + B;
edtSkullNod = uicontrol(panelMessage, 'Style', 'edit', 'String', '2000', 'Units', 'normalized', 'Position', [A .5 B .25], 'Visible', 'off'); %
txtSkullNod = uicontrol(panelMessage, 'Style', 'text', 'String', 'Skull', 'Units', 'normalized' , 'Position', [A 0.75+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off');
edtPialNod = uicontrol(panelMessage, 'Style', 'edit', 'String', '3000', 'Units', 'normalized', 'Position', [A .05 B .25], 'Visible', 'off'); %
txtPialNod = uicontrol(panelMessage, 'Style', 'text', 'String', 'Pial', 'Units', 'normalized' , 'Position', [A 0.3+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off');
A = A + B;
edtScalpNod = uicontrol(panelMessage, 'Style', 'edit', 'String', '2000', 'Units', 'normalized', 'Position', [A .5 B .25], 'Visible', 'off'); %
txtScalpNod = uicontrol(panelMessage, 'Style', 'text', 'String', 'Scalp', 'Units', 'normalized' , 'Position', [A 0.75+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off');
edtCSFNod = uicontrol(panelMessage, 'Style', 'edit', 'String', '2000', 'Units', 'normalized', 'Position', [A .05 B .25], 'Visible', 'off'); %
txtCSFNod = uicontrol(panelMessage, 'Style', 'text', 'String', 'CSF', 'Units', 'normalized' , 'Position', [A 0.3+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off');

A = 0.72+0.06;
B = 0.06;
C = 0.02;
edtRelNoise = uicontrol(panelMessage, 'Style', 'edit', 'String', '0.01', 'Units', 'normalized', 'Position', [A .5 B .25], 'Visible', 'off'); %
txtRelNoise = uicontrol(panelMessage, 'Style', 'text', 'String', 'Noise', 'Units', 'normalized' , 'Position', [A 0.75+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off', 'FontSize', 6);
edtFreq = uicontrol(panelMessage, 'Style', 'edit', 'String', '10', 'Units', 'normalized', 'Position', [A .05 B .25], 'Visible', 'off'); %
txtFreq = uicontrol(panelMessage, 'Style', 'text', 'String', 'f [Hz]', 'Units', 'normalized' , 'Position', [A 0.3+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off', 'FontSize', 6);
A = A + B;
edtTrialsNum = uicontrol(panelMessage, 'Style', 'edit', 'String', '3', 'Units', 'normalized', 'Position', [A .5 B .25], 'Visible', 'off'); %
txtTrialsNum = uicontrol(panelMessage, 'Style', 'text', 'String', 'Trials', 'Units', 'normalized' , 'Position', [A 0.75+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off', 'FontSize', 6);
edtLambda = uicontrol(panelMessage, 'Style', 'edit', 'String', '5%', 'Units', 'normalized', 'Position', [A .05 B .25], 'Visible', 'off'); %
txtLambda = uicontrol(panelMessage, 'Style', 'text', 'String', 'lambda', 'Units', 'normalized' , 'Position', [A 0.3+C B 0.2], 'horizontalalignment', 'center', 'Visible', 'off', 'FontSize', 6);

temp = get(panelPath, 'Position');
panelMessagePath = uipanel(h, 'Title', '', 'Units', 'normalized', 'Position', [temp(1) temp(2)+temp(4) temp(3) .1], 'BackgroundColor', [250, 128, 114] / 255, 'ShadowColor', [250, 128, 114] / 255, 'HighlightColor', [250, 128, 114] / 255, 'Visible', 'off');
txtMesgPath = uicontrol(panelMessagePath, 'Style', 'text', 'String', 'String', 'Units', 'normalized', 'Position', [.02 .02 .83 .75], 'horizontalalignment', 'left', 'Visible', 'off', 'FontSize', 8, 'FontWeight', 'bold', 'BackgroundColor', [250, 128, 114] / 255);
pbOk = uicontrol(panelMessagePath, 'Style', 'pushbutton', 'String', 'Ok', 'Units', 'normalized', 'Position', [.92 .25 .07 .5], 'FontWeight', 'bold', 'Visible', 'on', 'callback', @OK);

% align([pbMRI edtFT pbFT], 'Distribute', 'Center');

% remember the various handles
opt.h = h;  % handle to the figure

opt.edtFT = edtFT;
opt.edtSub = edtSub;
opt.edtBrainNod = edtBrainNod;
opt.edtWhiteNod = edtWhiteNod;
opt.edtSkullNod = edtSkullNod;
opt.edtPialNod = edtPialNod;
opt.edtScalpNod = edtScalpNod;
opt.edtCSFNod = edtCSFNod;
opt.edtRelNoise = edtRelNoise;
opt.edtFreq = edtFreq;
opt.edtTrialsNum = edtTrialsNum;
opt.edtLambda = edtLambda;

opt.panelPipeline = panelPipeline;
opt.panelPath = panelPath;
opt.panelMessage = panelMessage;
opt.panelMRI = panelMRI;
opt.panelSegMRI = panelSegMRI;
opt.panelMesh = panelMesh;
opt.panelVol = panelVol;
opt.panelSrc = panelSrc;
opt.panelSns = panelSns;
opt.panelLF = panelLF;
opt.panelFP = panelFP;
opt.panelIP = panelIP;
opt.panelMessagePath = panelMessagePath;

opt.pbAddpath = pbAddpath;
opt.pbMRI = pbMRI;
opt.pbSegMRI = pbSegMRI;
opt.pbMesh = pbMesh;
opt.pbVol = pbVol;
opt.pbSrc = pbSrc;
opt.pbSns = pbSns;
opt.pbLF = pbLF;
opt.pbFP = pbFP;
opt.pbYes = pbYes;
opt.pbNo = pbNo;
% opt.pbFPIsSel = pbFPIsSel;
% opt.pbFPRotate = pbFPRotate;
% opt.pbFPDataSel = pbFPDataSel;
opt.pbIP = pbIP;
opt.pbOk = pbOk;
opt.pbFT = pbFT;
opt.pbSub = pbSub;

opt.cbMRI = cbMRI;
opt.cbMeshBrain = cbMeshBrain;
opt.cbMeshSkull = cbMeshSkull;
opt.cbMeshScalp = cbMeshScalp;
opt.cbMeshWhite = cbMeshWhite;
opt.cbMeshGray = cbMeshGray;
opt.cbMeshCSF = cbMeshCSF;
opt.cbSrcWhite = cbSrcWhite;
opt.cbSrcPial = cbSrcPial;
opt.cbSrcBetween = cbSrcBetween;
opt.cbSnsEEG = cbSnsEEG;
opt.cbSnsMEG = cbSnsMEG;
opt.cbSegBrain = cbSegBrain;
opt.cbSegSkull = cbSegSkull;
opt.cbSegScalp = cbSegScalp;
opt.cbSegWhite = cbSegWhite;
opt.cbSegGray = cbSegGray;
opt.cbSegCSF = cbSegCSF;
opt.cbSegAll = cbSegAll;
opt.cbFiducl = cbFiducl;
opt.cbVolEEG = cbVolEEG;
opt.cbVolMEG = cbVolMEG;
opt.cbFPSource = cbFPSource;
opt.cbFPEEG = cbFPEEG;
opt.cbFPMEG = cbFPMEG;
opt.cbIPDICSPowEEG = cbIPDICSPowEEG;
opt.cbIPDICSPowMEG = cbIPDICSPowMEG;
opt.cbIPLCMVPowEEG = cbIPLCMVPowEEG;
opt.cbIPLCMVMomEEG = cbIPLCMVMomEEG;
opt.cbIPLCMVPowMEG = cbIPLCMVPowMEG;
opt.cbIPLCMVMomMEG = cbIPLCMVMomMEG;

opt.sEEGSourceUp = sEEGSourceUp;
opt.sEEGSourceLeft = sEEGSourceLeft;
opt.sEEGSourceBottom = sEEGSourceBottom;
% opt.sMEGSourceUp = sMEGSourceUp;
% opt.sMEGSourceLeft = sMEGSourceLeft;
% opt.sMEGSourceBottom = sMEGSourceBottom;
% opt.sFPSigma2 = sFPSigma2;

% opt.AxeEEGSensor = AxeEEGSensor;
% opt.AxeEEGSource = AxeEEGSource;
% opt.AxeFPSourceActivity = AxeFPSourceActivity;
% opt.AxeMEGSensor = AxeMEGSensor;
% opt.AxeMEGSource = AxeMEGSource;

opt.txtMesg = txtMesg;
opt.txtEEGSourceUp = txtEEGSourceUp;
opt.txtEEGSourceLeft = txtEEGSourceLeft;
opt.txtEEGSourceBottom = txtEEGSourceBottom;
opt.txtBrainNod = txtBrainNod;
opt.txtWhiteNod = txtWhiteNod;
opt.txtSkullNod = txtSkullNod;
opt.txtPialNod = txtPialNod;
opt.txtScalpNod = txtScalpNod;
opt.txtCSFNod = txtCSFNod;
opt.txtLCMVLabel = txtLCMVLabel;
opt.txtDICSLabel = txtDICSLabel;
opt.txtEEGLabel = txtEEGLabel;
opt.txtMEGLabel = txtMEGLabel;
opt.txtRelNoise = txtRelNoise;
opt.txtFreq = txtFreq;
opt.txtTrialsNum = txtTrialsNum;
opt.txtLambda = txtLambda;
opt.txtMesgPath = txtMesgPath;

opt.txtFT = txtFT;
opt.txtSub = txtSub;

% opt.txtFPSigma2 = txtFPSigma2;

opt.cfg.address.subject = [];

opt.rotate3d = rotate3d;
opt.view = [40 25];

setappdata(h, 'opt', opt);

function BrowseFT(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

folder_name = uigetdir('C:\', 'Please select the FieldTrip home directory ...');
if folder_name == 0
    if isempty(get(opt.edtFT, 'String'))
        set(opt.panelMessagePath, 'Visible', 'on');
        set(opt.txtMesgPath, 'Visible', 'on', 'String', 'Error: A correct path addresse should be entered.'); % , 'HorizontalAlignment', 'center'
        set(opt.txtFT, 'Enable', 'off')
        set(opt.edtFT, 'Enable', 'off')
        set(opt.pbFT, 'Enable', 'off')
        set(opt.txtSub, 'Enable', 'off')
        set(opt.edtSub, 'Enable', 'off')
        set(opt.pbSub, 'Enable', 'off')
        set(opt.pbAddpath, 'Enable', 'off')
        
        while ~isfield(opt, 'choice')
            uiwait
            h = getparent(h);
            opt = getappdata(h, 'opt');
        end % while ~isfield(opt, 'choice')
        opt = rmfield(opt, 'choice');
        set(opt.panelMessagePath, 'Visible', 'off')
        set(opt.txtFT, 'Enable', 'on')
        set(opt.edtFT, 'Enable', 'on')
        set(opt.pbFT, 'Enable', 'on')
        set(opt.txtSub, 'Enable', 'on')
        set(opt.edtSub, 'Enable', 'on')
        set(opt.pbSub, 'Enable', 'on')
        set(opt.pbAddpath, 'Enable', 'on')
    end % if isempty(get(opt.edtFT, 'String'))
else
    set(opt.panelMessage, 'Visible', 'off');
    opt.cfg.EEG.EEGsensLoad = fullfile(folder_name, filesep, 'template', filesep, 'electrode', filesep, 'standard_1020.elc'); % sensor file directory
    
    addpath(folder_name)
    ft_defaults;
    set(opt.edtFT, 'String', folder_name);
end
setappdata(h, 'opt', opt);

function BrowseSub(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

folder_name = uigetdir('C:\', 'Please select subject''s home directory ...');
if folder_name == 0
    if isempty(get(opt.edtSub, 'String'))
        set(opt.panelMessagePath, 'Visible', 'on');
        set(opt.txtMesgPath, 'Visible', 'on', 'String', 'Error: A correct path addresse should be entered.'); % , 'HorizontalAlignment', 'center'
        
        set(opt.txtFT, 'Enable', 'off')
        set(opt.edtFT, 'Enable', 'off')
        set(opt.pbFT, 'Enable', 'off')
        set(opt.txtSub, 'Enable', 'off')
        set(opt.edtSub, 'Enable', 'off')
        set(opt.pbSub, 'Enable', 'off')
        set(opt.pbAddpath, 'Enable', 'off')
        
        while ~isfield(opt, 'choice')
            uiwait
            h = getparent(h);
            opt = getappdata(h, 'opt');
        end % while ~isfield(opt, 'choice')
        opt = rmfield(opt, 'choice');
        set(opt.panelMessagePath, 'Visible', 'off')
        set(opt.txtFT, 'Enable', 'on')
        set(opt.edtFT, 'Enable', 'on')
        set(opt.pbFT, 'Enable', 'on')
        set(opt.txtSub, 'Enable', 'on')
        set(opt.edtSub, 'Enable', 'on')
        set(opt.pbSub, 'Enable', 'on')
        set(opt.pbAddpath, 'Enable', 'on')
    end % if isempty(get(opt.edtSub, 'String'))
else
    set(opt.panelMessage, 'Visible', 'off');
    opt.cfg.address.subject = folder_name;
    addressLoad = [folder_name filesep 'Pipeline Results'];
    if exist(addressLoad, 'dir') ~= 7 % If the directory does not exist, creates the directory
        mkdir(addressLoad)
    end % if exist(addressLoad, 'dir') ~= 7
    
    opt.cfg.EEG.unit = 'mm'; % Unit of the coordinate system
    opt.cfg.EEG.coordSys = 'ctf'; % The coordinate system
    opt.cfg.EEG.MRILoad = fullfile(folder_name, filesep, 'Subject01.mri');
    opt.cfg.EEG.MRIDir = fullfile(addressLoad, filesep, 'EEGMRI.mat'); % Processed MRI file directory (CTF, cm, aligned)
    opt.cfg.EEG.segMRIDir = fullfile(addressLoad, filesep, 'EEGSegmentedmri.mat'); % Segmented MRI file directory
    opt.cfg.EEG.meshDir = fullfile(addressLoad, filesep, 'EEGMesh.mat'); % Source model file directory
    opt.cfg.EEG.volDir = fullfile(addressLoad, filesep, 'EEGHeadModel.mat'); % Head model file directory
    opt.cfg.EEG.sourceModelDir = fullfile(addressLoad, filesep, 'EEGSourceModel.mat'); % Source model
    opt.cfg.EEG.MEGsensLoad = fullfile(folder_name, filesep, 'Subject01.ds'); % sensor file directory
    opt.cfg.EEG.sensDir = fullfile(addressLoad, filesep, 'EEGSensorModel.mat'); % Sensor model
    opt.cfg.EEG.channelsSymb = 'sb'; % Symbol for sensor representation
    opt.cfg.EEG.LFDir = fullfile(addressLoad, filesep, 'EEGLeadField.mat'); % Lead-field matrix
    opt.cfg.EEG.FPDir = fullfile(addressLoad, filesep, 'EEGSourceActivity.mat'); % Forward problem (Source activity)
    opt.cfg.EEG.IPDir = fullfile(addressLoad, filesep, 'EEGSourceReconst.mat'); % Inverse problem
    
    opt.cfg.address.subject = folder_name;
    set(opt.edtSub, 'String', folder_name);
end
setappdata(h, 'opt', opt);

function AddPath(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
% % --------------------------------- Temporary
% % folder_name = 'D:\Related tools\FieldTrip\fieldtrip-master\fieldtrip-master'; % Office
% folder_name = 'D:\Andrea\Utilities\FT\fieldtrip-20171218'; % Office
% % folder_name = 'E:\Ph.D\Related works\FT\Toolbox\fieldtrip-20180603'; % Laptop
% opt.cfg.EEG.EEGsensLoad = fullfile(folder_name, filesep, 'template', filesep, 'electrode', filesep, 'standard_1020.elc'); % sensor file directory
% addpath(folder_name)
% ft_defaults;
% folder_name = 'D:\Related tools\FieldTrip\tutorial\Dataset\Subject01'; % Office
% % folder_name = 'E:\Ph.D\Related works\FT\Toolbox\tutorial\Subject01'; % Laptop
% opt.cfg.address.subject = folder_name;
% addressLoad = [folder_name filesep 'Pipeline Results'];
% if exist(addressLoad, 'dir') ~= 7 % If the directory does not exist, creates the directory
%     mkdir(addressLoad)
% end % if exist(addressLoad, 'dir') ~= 7
% opt.cfg.EEG.unit = 'mm'; % Unit of the coordinate system
% opt.cfg.EEG.coordSys = 'ctf'; % The coordinate system
% opt.cfg.EEG.MRILoad = fullfile(folder_name, filesep, 'Subject01.mri');
% opt.cfg.EEG.MRIDir = fullfile(addressLoad, filesep, 'EEGMRI.mat'); % Processed MRI file directory (CTF, cm, aligned)
% opt.cfg.EEG.segMRIDir = fullfile(addressLoad, filesep, 'EEGSegmentedmri.mat'); % Segmented MRI file directory
% opt.cfg.EEG.meshDir = fullfile(addressLoad, filesep, 'EEGMesh.mat'); % Source model file directory
% opt.cfg.EEG.volDir = fullfile(addressLoad, filesep, 'EEGHeadModel.mat'); % Head model file directory
% opt.cfg.EEG.sourceModelDir = fullfile(addressLoad, filesep, 'EEGSourceModel.mat'); % Source model
% opt.cfg.EEG.MEGsensLoad = fullfile(folder_name, filesep, 'Subject01.ds'); % sensor file directory
% opt.cfg.EEG.sensDir = fullfile(addressLoad, filesep, 'EEGSensorModel.mat'); % Sensor model
% opt.cfg.EEG.channelsSymb = 'sb'; % Symbol for sensor representation
% opt.cfg.EEG.LFDir = fullfile(addressLoad, filesep, 'EEGLeadField.mat'); % Lead-field matrix
% opt.cfg.EEG.FPDir = fullfile(addressLoad, filesep, 'EEGSourceActivity.mat'); % Source activity
% opt.cfg.EEG.IPDir = fullfile(addressLoad, filesep, 'EEGSourceReconst.mat'); % Source activity
% 
% % opt.cfg.MEG.unit = 'cm'; % Unit of the coordinate system
% % opt.cfg.MEG.coordSys = 'ctf'; % The coordinate system
% % opt.cfg.MEG.MRILoad = fullfile(folder_name, filesep, 'Subject01.mri');
% % % opt.cfg.MEG.MRIDir = fullfile(addressLoad, filesep, 'MEGMRI.mat'); % Processed MRI file directory (CTF, cm, aligned)
% % opt.cfg.MEG.segMRIDir = fullfile(addressLoad, filesep, 'MEGSegmentedmri.mat'); % Segmented MRI file directory
% % opt.cfg.MEG.meshDir = fullfile(addressLoad, filesep, 'MEGMesh.mat'); % Source model file directory
% % opt.cfg.MEG.volDir = fullfile(addressLoad, filesep, 'MEGHeadModel.mat'); % Head model file directory
% % opt.cfg.MEG.sourceModelDir = fullfile(addressLoad, filesep, 'MEGSourceModel.mat'); % Source model
% % opt.cfg.MEG.sensLoad = fullfile(folder_name, filesep, 'Subject01.ds'); % sensor file directory
% % opt.cfg.MEG.sensDir = fullfile(addressLoad, filesep, 'MEGSensorModel.mat'); % Sensor model
% % opt.cfg.MEG.channelsSymb = 'og'; % Symbol for sensor representation
% % opt.cfg.MEG.LFDir = fullfile(addressLoad, filesep, 'MEGLeadField.mat'); % Lead-field matrix
% % opt.cfg.MEG.FPDir = fullfile(addressLoad, filesep, 'MEGSourceActivity.mat'); % Source activity
% 
% opt.cfg.address.subject = folder_name;
% % --------------------------------- Temporary
if isempty(get(opt.edtFT, 'String')) || isempty(get(opt.edtSub, 'String'))
        set(opt.panelMessagePath, 'Visible', 'on');
    set(opt.txtMesgPath, 'Visible', 'on', 'String', 'Error: Both Matlab path addresses should be entered.'); % , 'HorizontalAlignment', 'center'

        set(opt.txtFT, 'Enable', 'off')
set(opt.edtFT, 'Enable', 'off')
set(opt.pbFT, 'Enable', 'off')
set(opt.txtSub, 'Enable', 'off')
set(opt.edtSub, 'Enable', 'off')
set(opt.pbSub, 'Enable', 'off')
set(opt.pbAddpath, 'Enable', 'off')

        while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
        end % while ~isfield(opt, 'choice')
opt = rmfield(opt, 'choice');
set(opt.panelMessagePath, 'Visible', 'off')
    set(opt.txtFT, 'Enable', 'on')
set(opt.edtFT, 'Enable', 'on')
set(opt.pbFT, 'Enable', 'on')
set(opt.txtSub, 'Enable', 'on')
set(opt.edtSub, 'Enable', 'on')
set(opt.pbSub, 'Enable', 'on')
set(opt.pbAddpath, 'Enable', 'on')

else
set(opt.panelMessage, 'Visible', 'off');
set(opt.panelPipeline, 'Visible', 'on');
opt.AxeEEGSource = axes(opt.panelPipeline, 'position', [0.1 0.2 0.4 .6], 'tag', 'AxeEEGSource'); % Redefine AxeEEGSource on panelPipeline (instead of h)
% set(gca,'Color','k') [0.1 0.1 0.4 .8]
axis off equal
opt.txtAxe = uipanel(opt.panelPipeline, 'Title', '', 'Units', 'normalized', 'Position', [0.01 0.01 0.56 .98], 'BackgroundColor', 0.94*ones(1, 3), 'ShadowColor', 0.94*ones(1, 3), 'HighlightColor', 0.94*ones(1, 3), 'Visible', 'off');
% opt.txtAxe = uicontrol(opt.panelPipeline, 'Style', 'text', 'String', '', 'Units', 'normalized' , 'Position', [0.01 0.01 0.56 .98], 'Visible', 'off');
opt.sFPSigma2 = uicontrol(opt.txtAxe, 'Style', 'slider', 'Min', 1, 'Max', 10000, 'Value', 100, 'SliderStep', [50/10000 100/10000], 'Units', 'normalized', 'Position', [0.1 0.025 0.8 0.05], 'Visible', 'off', 'Enable', 'off', 'callback', @FPSigma2_slider);
opt.txtFPSigma2 = uicontrol(opt.txtAxe, 'Style', 'text', 'String', 'Source activity extent', 'Units', 'normalized' , 'Position', [0.35 0 .3 .025], 'horizontalalignment', 'center', 'Visible', 'off', 'Enable', 'off');
opt.pbFPIsSel = uicontrol(opt.txtAxe, 'Style', 'pushbutton', 'String', 'Accept', 'Units', 'normalized', 'Position', [0.7 0.09 .2 .05], 'Visible', 'off', 'Enable', 'off', 'callback', @FPIsSel);
opt.pbFPRotate = uicontrol(opt.txtAxe, 'Style', 'pushbutton', 'String', 'Rotate', 'Units', 'normalized', 'Position', [0.1 0.09 .2 .05], 'Visible', 'off', 'Enable', 'on', 'callback', @FPRotate);
opt.pbFPDataSel = uicontrol(opt.txtAxe, 'Style', 'pushbutton', 'String', 'Center-of-activity selection', 'Units', 'normalized', 'Position', [0.35 0.09 .3 .05], 'Visible', 'off', 'Enable', 'on', 'callback', @FPDataSel);

opt.AxeFPSourceActivity = axes(opt.txtAxe, 'position', [0.15 0.2 0.7 .6], 'Color', 0.94*ones(1, 3), 'Visible', 'off', 'XColor', 'none', 'YColor', 'none', 'ZColor', 'none'); % , 'Box', 'off'
axis equal % off
set(opt.panelPath, 'Visible', 'off');
set(opt.pbMRI, 'Enable', 'on', 'FontWeight', 'bold');
set(opt.panelMRI, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
end % if isempty(get(opt.edtFT, 'String')) || isempty(get(opt.edtSub, 'String'))
setappdata(h, 'opt', opt);

function MRI(h, eventdata)
% --> Using anatomical data (anatomical MRI):
% --> Segmentation works properly when the voxels of the anatomical images are homogenous (using 'ft_volumereslice').
% --> check the coordinate-system of the MRI, align the anatomical MRI (before the segmentation) into the same coordinate
% ... system in which the electrodes will be expressed.
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.MRIDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelMRI, 'Position'); % , 'Position', [0.03, temp(2), temp(1)-.04, temp(4)-0.01]
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    %     Positions = align([opt.panelMRI, opt.panelMessage], 'None', 'Center');
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The pre-processed MRI has already been created. Would you like to recompute it and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    %     choice = questdlg('The pre-processed MRI has already been created. Would you like to recompute it and overwrite the existing file?', 'Recompute', 'No', 'Yes', 'No');
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            if isfield(opt.cfg.EEG, 'Fiducials')
                set(opt.cbFiducl, 'Value', 0)
                delete(opt.cfg.EEG.Fidh);
                opt.cfg.EEG = rmfield(opt.cfg.EEG, 'Fidh');
                opt.cfg.EEG = rmfield(opt.cfg.EEG, 'Fiducials');
            end
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 1 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 1 : length(pushButtons)
                if i > 1
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 1
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 1 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(1 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(2 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
            if strcmp(get(opt.txtLCMVLabel, 'Enable'), 'on')
                set(opt.txtLCMVLabel, 'Enable', 'off')
                set(opt.txtDICSLabel, 'Enable', 'off')
                set(opt.txtEEGLabel, 'Enable', 'off')
                set(opt.txtMEGLabel, 'Enable', 'off')
            end
            
    end % switch choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.MRIDir, 'file')

if recompute
    set(opt.pbYes, 'Visible', 'off')
    set(opt.pbNo, 'Visible', 'off')
    %     set(opt.pbMRI, 'BackgroundColor', 0.94*[1 1 1])
    temp = get(opt.panelMRI, 'Position'); % , 'Position', [0.03, temp(2), temp(1)-.04, temp(4)-0.01]
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    %     set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'MRI preparation: MRI reading, alignment, reslicing, coordinate system checking, unit checking (please wait ...)'); % , 'HorizontalAlignment', 'center'
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'MRI preparation (please wait ...)'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    % --> read anatomical data (anatomical MRI) (it is the same file for all modalities):
    mri = ft_read_mri(opt.cfg.EEG.MRILoad); % Read the anatomical data
    
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
    if ~isfield(mri, 'coordsys') || ~strcmp(mri.coordsys, opt.cfg.EEG.coordSys)
        mri = ft_determine_coordsys(mri);
        T = mri.transform / transformVox2MRIReslice; % ### FARDIN ###: To be verified
        fiducials = ft_transform_geometry(T, fiducials); % ### FARDIN ###: To be verified
        fiducials = IJKtransformXYZ(transformVox2MRIReslice, 'coordsys', fiducials.pnt); % ### FARDIN ###: To be verified
    end % if ~isfield(mri, 'coordsys') || ~strcmp(mri.coordsys, opt.cfg.EEG.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(mri, 'unit') || ~strcmp(mri.unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        mri = ft_convert_units(mri, opt.cfg.EEG.unit);
        fiducials = ft_convert_units(fiducials, opt.cfg.EEG.unit);
    end % if ~isfield(mri, 'unit') || ~strcmp(mri.unit, opt.cfg.EEG.unit)
    
    mri.fiducials.ijk.nas = fiducials.vox(1, :);
    mri.fiducials.ijk.lpa = fiducials.vox(2, :);
    mri.fiducials.ijk.rpa = fiducials.vox(3, :);
    
    mri.fiducials.xyz.nas = fiducials.pnt(1, :);
    mri.fiducials.xyz.lpa = fiducials.pnt(2, :);
    mri.fiducials.xyz.rpa = fiducials.pnt(3, :);
    
    save(opt.cfg.EEG.MRIDir, 'mri')
    %     save(opt.cfg.MEG.MRIDir, 'mri')
    Recover(h, CurrentState);
end
set(opt.panelMessage, 'Visible', 'off')
set(opt.pbMRI, 'BackgroundColor', [152 251 152] / 255)
set(opt.pbSegMRI, 'Enable', 'on', 'FontWeight', 'bold')
set(opt.panelSegMRI, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
set(opt.cbMRI, 'Enable', 'on')
set(opt.cbFiducl, 'Enable', 'on')
setappdata(h, 'opt', opt);

function MRI_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbMRI, 'Value') == 0
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MRI');
    %     opt.cfg.MEG = rmfield(opt.cfg.MEG, 'MRI');
    
    allHandle = {'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}; % Delete previous slices
    if all(~isfield(opt.cfg.EEG, allHandle))
        set(opt.sEEGSourceUp, 'Visible', 'off')
        set(opt.sEEGSourceLeft, 'Visible', 'off')
        set(opt.sEEGSourceBottom, 'Visible', 'off')
        
        %         set(opt.rotate3d, 'Enable', 'off');
        
        set(opt.txtEEGSourceUp, 'Visible', 'off')
        set(opt.txtEEGSourceLeft, 'Visible', 'off')
        set(opt.txtEEGSourceBottom, 'Visible', 'off')
    end
    %     set(opt.sMEGSourceUp, 'Enable', 'off')
    %     set(opt.sMEGSourceLeft, 'Enable', 'off')
    %     set(opt.sMEGSourceBottom, 'Enable', 'off')
    %     axes(opt.AxeEEGSource)
    %     axis off
    %     axes(opt.AxeMEGSource)
    %     axis off
    delete(opt.cfg.EEG.MRIhx)
    delete(opt.cfg.EEG.MRIhy)
    delete(opt.cfg.EEG.MRIhz)
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MRIhx');
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MRIhy');
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MRIhz');
    %     delete(opt.cfg.MEG.MRIhx)
    %     delete(opt.cfg.MEG.MRIhy)
    %     delete(opt.cfg.MEG.MRIhz)
    
else
    
    %     if ~isfield(opt.cfg.EEG, 'MRI')
    load(opt.cfg.EEG.MRIDir)
    opt.cfg.EEG.MRI = mri;
    %     load(opt.cfg.MEG.MRIDir)
    %     opt.cfg.MEG.MRI = mri;
    %     end % if ~isfield(opt.cfg.EEG, 'MRI')
    
    if strcmp(get(opt.sEEGSourceUp, 'Visible'), 'off')
        set(opt.sEEGSourceUp, 'Visible', 'on')
        set(opt.sEEGSourceLeft, 'Visible', 'on')
        set(opt.sEEGSourceBottom, 'Visible', 'on')
        set(opt.txtEEGSourceUp, 'Visible', 'on')
        set(opt.txtEEGSourceLeft, 'Visible', 'on')
        set(opt.txtEEGSourceBottom, 'Visible', 'on')
    end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    S1 = round(get(opt.sEEGSourceUp, 'Value'));
    S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    pos = IJKtransformXYZ(opt.cfg.EEG.MRI.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    
    axes(opt.AxeEEGSource)
    %     if isfield(opt.cfg.EEG, 'MRIhx')
    %         delete(opt.cfg.EEG.MRIhx)
    %         delete(opt.cfg.EEG.MRIhy)
    %         delete(opt.cfg.EEG.MRIhz)
    %         %         delete(opt.cfg.MEG.MRIhx)
    %         %         delete(opt.cfg.MEG.MRIhy)
    %         %         delete(opt.cfg.MEG.MRIhz)
    %     end
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %any(isfield(opt.cfg.EEG, {'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}))
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end
    [opt.cfg.EEG.MRIhx, opt.cfg.EEG.MRIhy, opt.cfg.EEG.MRIhz] = ft_plot_ortho(opt.cfg.EEG.MRI.anatomy, 'style', 'intersect', 'transform', opt.cfg.EEG.MRI.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.MRI.unit);
    %     if exist('az', 'var')
    %         view([az, el])
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    
    %     % MEG
    %     load(opt.cfg.MEG.MRIDir)
    %     set(opt.sMEGSourceUp, 'Enable', 'on')
    %     set(opt.sMEGSourceLeft, 'Enable', 'on')
    %     set(opt.sMEGSourceBottom, 'Enable', 'on')
    %
    %     S1 = get(opt.sMEGSourceUp, 'Value');
    %     S2 = get(opt.sMEGSourceLeft, 'Value');
    %     S3 = get(opt.sMEGSourceBottom, 'Value');
    %     pos = IJKtransformXYZ(opt.cfg.MEG.MRI.transform, 'voxel', [S1, S3, S2]);
    %
    %     axes(opt.AxeMEGSource)
    %     [opt.cfg.MEG.MRIhx, opt.cfg.MEG.MRIhy, opt.cfg.MEG.MRIhz] = ft_plot_ortho(opt.cfg.MEG.MRI.anatomy, 'style', 'intersect', 'transform', opt.cfg.MEG.MRI.transform, 'location', pos.pnt);
    %     rotate3d on
end
setappdata(h, 'opt', opt);

function MRI_slider(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
S1 = round(get(opt.sEEGSourceUp, 'Value'));
S2 = round(get(opt.sEEGSourceLeft, 'Value'));
S3 = round(get(opt.sEEGSourceBottom, 'Value'));
if isfield(opt.cfg.EEG, 'MRI')
    pos = IJKtransformXYZ(opt.cfg.EEG.MRI.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
elseif isfield(opt.cfg.EEG, 'segMRI')
    pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
end
axes(opt.AxeEEGSource)

% [az, el] = view;
[opt.view(1), opt.view(2)] = view;

if isfield(opt.cfg.EEG, 'MRIhx') % Delete previous slices
    delete(opt.cfg.EEG.MRIhx)
    delete(opt.cfg.EEG.MRIhy)
    delete(opt.cfg.EEG.MRIhz)
    [opt.cfg.EEG.MRIhx, opt.cfg.EEG.MRIhy, opt.cfg.EEG.MRIhz] = ft_plot_ortho(opt.cfg.EEG.MRI.anatomy, 'style', 'intersect', 'transform', opt.cfg.EEG.MRI.transform, 'location', pos.pnt);
end
allHandle = {'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}; % Delete previous slices
if any(isfield(opt.cfg.EEG, allHandle))
    temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
    %     eval(['delete(opt.cfg.EEG.',temp,')'])
    delete(opt.cfg.EEG.(temp))
    temp = [temp(1:end - 1) 'y'];
    %     eval(['delete(opt.cfg.EEG.',temp,')'])
    delete(opt.cfg.EEG.(temp))
    temp = [temp(1:end - 1) 'z'];
    %     eval(['delete(opt.cfg.EEG.',temp,')'])
    delete(opt.cfg.EEG.(temp))
    
    if get(opt.cbSegBrain, 'Value') == 1 % Brain
        [opt.cfg.EEG.SegBrainhx, opt.cfg.EEG.SegBrainhy, opt.cfg.EEG.SegBrainhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.brain, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt);
    elseif get(opt.cbSegSkull, 'Value') == 1 % Skull
        [opt.cfg.EEG.SegSkullhx, opt.cfg.EEG.SegSkullhy, opt.cfg.EEG.SegSkullhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.skull, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt);
    elseif get(opt.cbSegScalp, 'Value') == 1 % Scalp
        [opt.cfg.EEG.SegScalphx, opt.cfg.EEG.SegScalphy, opt.cfg.EEG.SegScalphz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.scalp, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt);
    elseif get(opt.cbSegWhite, 'Value') == 1 % White matter
        [opt.cfg.EEG.SegWhitehx, opt.cfg.EEG.SegWhitehy, opt.cfg.EEG.SegWhitehz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.white, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt);
    elseif get(opt.cbSegGray, 'Value') == 1 % Gray matter
        [opt.cfg.EEG.SegGrayhx, opt.cfg.EEG.SegGrayhy, opt.cfg.EEG.SegGrayhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.gray, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt);
    elseif get(opt.cbSegCSF, 'Value') == 1 % CSF
        [opt.cfg.EEG.SegCSFhx, opt.cfg.EEG.SegCSFhy, opt.cfg.EEG.SegCSFhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.csf, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt);
    elseif get(opt.cbSegAll, 'Value') == 1 % CSF
        [opt.cfg.EEG.SegAllhx, opt.cfg.EEG.SegAllhy, opt.cfg.EEG.SegAllhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.seg, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.unit, 'colormap', 'jet');
    end % if get(opt.cbSegBrain, 'Value') == 1
end % if any(isfield(opt.cfg.EEG, allHandle))

% view([az, el])
view(opt.view);
% rotate3d on

set(opt.txtEEGSourceUp, 'String', ['Coronal (',num2str(S1),'/256)'])
mls = sprintf(' Axial\n%d/256', S2);
set(opt.txtEEGSourceLeft, 'String', mls)
set(opt.txtEEGSourceBottom, 'String', ['Sagittal (',num2str(S3),'/256)'])
setappdata(h, 'opt', opt);

function Fid_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if get(opt.cbFiducl, 'Value') == 0
    delete(opt.cfg.EEG.Fidh);
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'Fidh');
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'Fiducials');
elseif get(opt.cbFiducl, 'Value') == 1
    if isfield(opt.cfg.EEG, 'MRI')
        opt.cfg.EEG.Fiducials = opt.cfg.EEG.MRI.fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'segMRI')
        opt.cfg.EEG.Fiducials = opt.cfg.EEG.segMRI.segmentedMRIBrain.fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'Mesh')
        opt.cfg.EEG.Fiducials = opt.cfg.EEG.Mesh.head(1).fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'HeadModel')
        opt.cfg.EEG.Fiducials = opt.cfg.EEG.HeadModel.head.fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'SourceModel')
        opt.cfg.EEG.Fiducials = opt.cfg.EEG.SourceModel.white.fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'SensorModel')
        opt.cfg.EEG.Fiducials = opt.cfg.EEG.SensorModel.EEG.fiducials;
    else
        load(opt.cfg.EEG.MRIDir)
        opt.cfg.EEG.Fiducials = mri.fiducials.xyz;
        clear mri
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    axes(opt.AxeEEGSource)
    
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx') || isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    
    fiducials = [opt.cfg.EEG.Fiducials.nas; opt.cfg.EEG.Fiducials.lpa; opt.cfg.EEG.Fiducials.rpa];
    hold on
    opt.cfg.EEG.Fidh = plot3(fiducials(:, 1), fiducials(:, 2), fiducials(:, 3), 'm*', 'MarkerFaceColor', 'm', 'MarkerSize', 8);
    htxt1 = text(fiducials(1, 1) + eps, fiducials(1, 2), fiducials(1, 3) - eps, 'nas');
    htxt2 = text(fiducials(2, 1), fiducials(2, 2) + eps, fiducials(2, 3) - eps, 'lpa');
    htxt3 = text(fiducials(3, 1), fiducials(3, 2) - eps, fiducials(3, 3) - eps, 'rpa');
    opt.cfg.EEG.Fidh = [opt.cfg.EEG.Fidh; htxt1; htxt2; htxt3];
    
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
end
setappdata(h, 'opt', opt);

function SegMRI(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.segMRIDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelSegMRI, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The segmented MRI has already been created. Would you like to recompute it and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 2 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 2 : length(pushButtons)
                if i > 2
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 2
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 3 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(4 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(2 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
            if strcmp(get(opt.txtLCMVLabel, 'Enable'), 'on')
                set(opt.txtLCMVLabel, 'Enable', 'off')
                set(opt.txtDICSLabel, 'Enable', 'off')
                set(opt.txtEEGLabel, 'Enable', 'off')
                set(opt.txtMEGLabel, 'Enable', 'off')
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    set(opt.pbYes, 'Visible', 'off')
    set(opt.pbNo, 'Visible', 'off')
    %     set(opt.pbSegMRI, 'BackgroundColor', 0.94*[1 1 1])
    temp = get(opt.panelSegMRI, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    %     set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'MRI segmentation: MRI segmenting, coordinate system checking, unit checking (please wait ...)'); % , 'HorizontalAlignment', 'center'
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'MRI segmentation (please wait ...)'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    load(opt.cfg.EEG.MRIDir) % Loads computed pre-processed MRI
    
    cfg = [];
    cfg.output = {'brain', 'skull', 'scalp'}; % Tissue types
    % cfg.output = {'white', 'gray', 'csf', 'brain', 'skull', 'scalp'}; % Tissue types
    segmentedMRIBrain = ft_volumesegment(cfg, mri);
    %     segmentedMRI = ft_volumesegment(cfg, mri);
    transformVox2SegmentedMRIBrain = segmentedMRIBrain.transform;
    % transformVox2SegmentedMRI = segmentedMRI.transform;
    
    cfg = [];
    cfg.output = {'gray', 'white', 'csf'}; % Tissue types
    segmentedMRIGrayWhiteCSF = ft_volumesegment(cfg, mri);
    
    fiducials.vox = [mri.fiducials.ijk.nas; mri.fiducials.ijk.lpa; mri.fiducials.ijk.rpa];
    fiducials.pnt = [mri.fiducials.xyz.nas; mri.fiducials.xyz.lpa; mri.fiducials.xyz.rpa];
    
    % --> Check and determine the coordinate-system of the segmented anatomical data (anatomical MRI):
    if ~isfield(segmentedMRIBrain, 'coordsys') || ~strcmp(segmentedMRIBrain.coordsys, opt.cfg.EEG.coordSys) || ~isfield(segmentedMRIGrayWhiteCSF, 'coordsys') || ~strcmp(segmentedMRIGrayWhiteCSF.coordsys, opt.cfg.EEG.coordSys)
        % if ~isfield(segmentedMRI, 'coordsys') || ~strcmp(segmentedMRI.coordsys, opt.cfg.EEG.coordSys)
        fiducials = IJKtransformXYZ(transformVox2SegmentedMRIBrain, 'voxel', fiducials.vox);
        %         fiducials = IJKtransformXYZ(transformVox2SegmentedMRI, 'voxel', fiducials.vox);
        
        segmentedMRIBrain = ft_determine_coordsys(segmentedMRIBrain);
        segmentedMRIGrayWhiteCSF.coordsys = segmentedMRIBrain.coordsys;
        % segmentedMRI = ft_determine_coordsys(segmentedMRI);
        T = segmentedMRIBrain.transform / transformVox2SegmentedMRIBrain; % ### FARDIN ###: To be verified
        %         T = segmentedMRI.transform / transformVox2SegmentedMRI; % ### FARDIN ###: To be verified
        fiducials = ft_transform_geometry(T, fiducials); % ### FARDIN ###: To be verified
        fiducials = IJKtransformXYZ(segmentedMRIBrain.transform, 'coordsys', fiducials.pnt); % ### FARDIN ###: To be verified
        % fiducials = IJKtransformXYZ(segmentedMRI.transform, 'coordsys', fiducials.pnt); % ### FARDIN ###: To be verified
    end % if ~isfield(segmentedMRI, 'coordsys') || ~strcmp(segmentedMRI.coordsys, opt.cfg.EEG.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(segmentedMRIBrain, 'unit') || ~strcmp(segmentedMRIBrain.unit, opt.cfg.EEG.unit) || ~isfield(segmentedMRIGrayWhiteCSF, 'unit') || ~strcmp(segmentedMRIGrayWhiteCSF.unit, opt.cfg.EEG.unit)% True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        %     if ~isfield(segmentedMRI, 'unit') || ~strcmp(segmentedMRI.unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        segmentedMRIBrain = ft_convert_units(segmentedMRIBrain, opt.cfg.EEG.unit);
        %         segmentedMRI = ft_convert_units(segmentedMRI, opt.cfg.EEG.unit);
        segmentedMRIGrayWhiteCSF = ft_convert_units(segmentedMRIGrayWhiteCSF, opt.cfg.EEG.unit);
        fiducials = ft_convert_units(fiducials, opt.cfg.EEG.unit);
    end % if ~isfield(segmentedMRI, 'unit') || ~strcmp(segmentedMRI.unit, opt.cfg.EEG.unit)
    
    segmentedMRIBrain.fiducials.ijk.nas = fiducials.vox(1, :);
    segmentedMRIBrain.fiducials.ijk.lpa = fiducials.vox(2, :);
    segmentedMRIBrain.fiducials.ijk.rpa = fiducials.vox(3, :);
    segmentedMRIBrain.fiducials.xyz.nas = fiducials.pnt(1, :);
    segmentedMRIBrain.fiducials.xyz.lpa = fiducials.pnt(2, :);
    segmentedMRIBrain.fiducials.xyz.rpa = fiducials.pnt(3, :);
    %         segmentedMRI.fiducials.ijk.nas = fiducials.vox(1, :);
    %     segmentedMRI.fiducials.ijk.lpa = fiducials.vox(2, :);
    %     segmentedMRI.fiducials.ijk.rpa = fiducials.vox(3, :);
    %     segmentedMRI.fiducials.xyz.nas = fiducials.pnt(1, :);
    %     segmentedMRI.fiducials.xyz.lpa = fiducials.pnt(2, :);
    %     segmentedMRI.fiducials.xyz.rpa = fiducials.pnt(3, :);
    segmentedMRI.segmentedMRIBrain = segmentedMRIBrain;
    
    segmentedMRIGrayWhiteCSF.fiducials = segmentedMRIBrain.fiducials;
    segmentedMRI.segmentedMRIGrayWhiteCSF = segmentedMRIGrayWhiteCSF;
    
    segmentedMRIAll = segmentedMRI.segmentedMRIBrain;
    segmentedMRIAll.white = segmentedMRI.segmentedMRIGrayWhiteCSF.white;
    segmentedMRIAll.gray = segmentedMRI.segmentedMRIGrayWhiteCSF.gray;
    segmentedMRIAll.csf = segmentedMRI.segmentedMRIGrayWhiteCSF.csf;
    segmentedMRI.segmentedMRIAllIndexed = ft_datatype_segmentation(segmentedMRIAll, 'segmentationstyle', 'indexed');
    
    save(opt.cfg.EEG.segMRIDir, 'segmentedMRI')
    %     save(opt.cfg.MEG.segMRIDir, 'segmentedMRI')
    Recover(h, CurrentState);
end
set(opt.panelMessage, 'Visible', 'off')
set(opt.pbSegMRI, 'BackgroundColor', [152 251 152] / 255)
set(opt.pbMesh, 'Enable', 'on', 'FontWeight', 'bold')
set(opt.panelMesh, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
set(opt.cbSegBrain, 'Enable', 'on')
set(opt.cbSegSkull, 'Enable', 'on')
set(opt.cbSegScalp, 'Enable', 'on')
set(opt.cbSegWhite, 'Enable', 'on')
set(opt.cbSegGray, 'Enable', 'on')
set(opt.cbSegCSF, 'Enable', 'on')
set(opt.cbSegAll, 'Enable', 'on')

setappdata(h, 'opt', opt);

function SegMRI_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbSegBrain, 'Value') == 0 && get(opt.cbSegSkull, 'Value') == 0 && get(opt.cbSegScalp, 'Value') == 0 && ...
        get(opt.cbSegWhite, 'Value') == 0 && get(opt.cbSegGray, 'Value') == 0 && get(opt.cbSegCSF, 'Value') == 0 && ...
        get(opt.cbSegAll, 'Value') == 0
    
    allHandle = {'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}; % Delete previous slices
    if any(isfield(opt.cfg.EEG, allHandle))
        temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
        %         eval(['delete(opt.cfg.EEG.',temp,')'])
        delete(opt.cfg.EEG.(temp))
        opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
        temp = [temp(1:end - 1) 'y'];
        %         eval(['delete(opt.cfg.EEG.',temp,')'])
        delete(opt.cfg.EEG.(temp))
        opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
        temp = [temp(1:end - 1) 'z'];
        %         eval(['delete(opt.cfg.EEG.',temp,')'])
        delete(opt.cfg.EEG.(temp))
        opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    end % if any(isfield(opt.cfg.EEG, allHandle))
    
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'segMRI');
    
    allHandle = {'MRIhx'}; % Delete previous slices
    if all(~isfield(opt.cfg.EEG, allHandle))
        set(opt.sEEGSourceUp, 'Visible', 'off')
        set(opt.sEEGSourceLeft, 'Visible', 'off')
        set(opt.sEEGSourceBottom, 'Visible', 'off')
        
        %         set(opt.rotate3d, 'Enable', 'off');
        
        set(opt.txtEEGSourceUp, 'Visible', 'off')
        set(opt.txtEEGSourceLeft, 'Visible', 'off')
        set(opt.txtEEGSourceBottom, 'Visible', 'off')
    end
else
    if isfield(opt.cfg.EEG, 'segMRI') % One of the checkboxes in panel has been already selected
        
        if isfield(opt.cfg.EEG, 'SegBrainhx') % Brain
            ToBeDeleted = 'SegBrainh';
            %             delete(opt.cfg.EEG.SegBrainhx)
            %             delete(opt.cfg.EEG.SegBrainhy)
            %             delete(opt.cfg.EEG.SegBrainhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegBrainhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegBrainhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegBrainhz');
            set(opt.cbSegBrain, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'SegSkullhx') % Skull
            ToBeDeleted = 'SegSkullh';
            %             delete(opt.cfg.EEG.SegSkullhx)
            %             delete(opt.cfg.EEG.SegSkullhy)
            %             delete(opt.cfg.EEG.SegSkullhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegSkullhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegSkullhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegSkullhz');
            set(opt.cbSegSkull, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'SegScalphx') % Scalp
            ToBeDeleted = 'SegScalph';
            %             delete(opt.cfg.EEG.SegScalphx)
            %             delete(opt.cfg.EEG.SegScalphy)
            %             delete(opt.cfg.EEG.SegScalphz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegScalphx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegScalphy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegScalphz');
            set(opt.cbSegScalp, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'SegWhitehx') % White matter
            ToBeDeleted = 'SegWhiteh';
            %             delete(opt.cfg.EEG.SegWhitehx)
            %             delete(opt.cfg.EEG.SegWhitehy)
            %             delete(opt.cfg.EEG.SegWhitehz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegWhitehx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegWhitehy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegWhitehz');
            set(opt.cbSegWhite, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'SegGrayhx') % Gray matter
            ToBeDeleted = 'SegGrayh';
            %             delete(opt.cfg.EEG.SegGrayhx)
            %             delete(opt.cfg.EEG.SegGrayhy)
            %             delete(opt.cfg.EEG.SegGrayhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegGrayhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegGrayhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegGrayhz');
            set(opt.cbSegGray, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'SegCSFhx') % CSF
            ToBeDeleted = 'SegCSFh';
            %             delete(opt.cfg.EEG.SegCSFhx)
            %             delete(opt.cfg.EEG.SegCSFhy)
            %             delete(opt.cfg.EEG.SegCSFhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhz');
            set(opt.cbSegCSF, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'SegAllhx') % CSF
            ToBeDeleted = 'SegAllh';
            %             delete(opt.cfg.EEG.SegCSFhx)
            %             delete(opt.cfg.EEG.SegCSFhy)
            %             delete(opt.cfg.EEG.SegCSFhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhz');
            set(opt.cbSegAll, 'Value', 0)
        end % if isfield(opt.cfg.EEG, 'SegBrainhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    else
        load(opt.cfg.EEG.segMRIDir)
        opt.cfg.EEG.segMRI = segmentedMRI;
        clear segmentedMRI
    end % if isfield(opt.cfg.EEG, 'segMRI')
    %     setappdata(h, 'opt', opt);
    
    if strcmp(get(opt.sEEGSourceUp, 'Visible'), 'off')
        set(opt.sEEGSourceUp, 'Visible', 'on')
        set(opt.sEEGSourceLeft, 'Visible', 'on')
        set(opt.sEEGSourceBottom, 'Visible', 'on')
        set(opt.txtEEGSourceUp, 'Visible', 'on')
        set(opt.txtEEGSourceLeft, 'Visible', 'on')
        set(opt.txtEEGSourceBottom, 'Visible', 'on')
    end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    S1 = round(get(opt.sEEGSourceUp, 'Value'));
    S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    if get(opt.cbSegBrain, 'Value') == 1 || get(opt.cbSegSkull, 'Value') == 1 || get(opt.cbSegScalp, 'Value') == 1
        pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    elseif get(opt.cbSegWhite, 'Value') == 1 || get(opt.cbSegGray, 'Value') == 1 || get(opt.cbSegCSF, 'Value') == 1
        pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    elseif get(opt.cbSegAll, 'Value') == 1
        pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    end
    
    axes(opt.AxeEEGSource)
    %     if isfield(opt.cfg.EEG, 'MRIhx')
    %         delete(opt.cfg.EEG.MRIhx)
    %         delete(opt.cfg.EEG.MRIhy)
    %         delete(opt.cfg.EEG.MRIhz)
    %     end
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    
    if get(opt.cbSegBrain, 'Value') == 1 % Brain
        [opt.cfg.EEG.SegBrainhx, opt.cfg.EEG.SegBrainhy, opt.cfg.EEG.SegBrainhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.brain, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIBrain.unit);
    elseif get(opt.cbSegSkull, 'Value') == 1 % Skull
        [opt.cfg.EEG.SegSkullhx, opt.cfg.EEG.SegSkullhy, opt.cfg.EEG.SegSkullhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.skull, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIBrain.unit);
    elseif get(opt.cbSegScalp, 'Value') == 1 % Scalp
        [opt.cfg.EEG.SegScalphx, opt.cfg.EEG.SegScalphy, opt.cfg.EEG.SegScalphz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.scalp, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIBrain.unit);
    elseif get(opt.cbSegWhite, 'Value') == 1 % White matter
        [opt.cfg.EEG.SegWhitehx, opt.cfg.EEG.SegWhitehy, opt.cfg.EEG.SegWhitehz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.white, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.unit);
    elseif get(opt.cbSegGray, 'Value') == 1 % Gray matter
        [opt.cfg.EEG.SegGrayhx, opt.cfg.EEG.SegGrayhy, opt.cfg.EEG.SegGrayhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.gray, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.unit);
    elseif get(opt.cbSegCSF, 'Value') == 1 % CSF
        [opt.cfg.EEG.SegCSFhx, opt.cfg.EEG.SegCSFhy, opt.cfg.EEG.SegCSFhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.csf, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.unit);
    elseif get(opt.cbSegAll, 'Value') == 1 % All segments
        valNorm = opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.seg;
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        [opt.cfg.EEG.SegAllhx, opt.cfg.EEG.SegAllhy, opt.cfg.EEG.SegAllhz] = ft_plot_ortho(valNorm, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.unit, 'colormap', 'jet');
    end % if get(opt.cbSegBrain, 'Value') == 1
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    if exist('ToBeDeleted', 'var')
        eval(['delete(opt.cfg.EEG.',[ToBeDeleted 'x'],')'])
        eval(['delete(opt.cfg.EEG.',[ToBeDeleted 'y'],')'])
        eval(['delete(opt.cfg.EEG.',[ToBeDeleted 'z'],')'])
        opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'x']);
        opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'y']);
        opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'z']);
    end % if exist('ToBeDeleted', 'var')
end
setappdata(h, 'opt', opt);

function Mesh(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.meshDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelMesh, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The meshes have already been created. Would you like to recompute them and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 3 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 3 : length(pushButtons)
                if i > 3
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 3
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 10 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(25 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(3 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
            if strcmp(get(opt.txtLCMVLabel, 'Enable'), 'on')
                set(opt.txtLCMVLabel, 'Enable', 'off')
                set(opt.txtDICSLabel, 'Enable', 'off')
                set(opt.txtEEGLabel, 'Enable', 'off')
                set(opt.txtMEGLabel, 'Enable', 'off')
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    temp = get(opt.panelMesh, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    temp2 = get(opt.txtMesg, 'Position'); % [.02 .02 .83 .75]
    set(opt.txtMesg, 'Visible', 'on', 'Position', [temp2(1), temp2(2), temp2(3)-.1, temp2(4)], 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Parameters: Please enter the number of vertices for each mesh.'); % , 'HorizontalAlignment', 'center'
    set(opt.pbNo, 'String', 'Ok', 'Visible', 'on')
    set(opt.pbYes, 'Visible', 'off')
    set(opt.edtBrainNod, 'Visible', 'on')
    set(opt.txtBrainNod, 'Visible', 'on')
    set(opt.edtWhiteNod, 'Visible', 'on')
    set(opt.txtWhiteNod, 'Visible', 'on')
    set(opt.edtSkullNod, 'Visible', 'on')
    set(opt.txtSkullNod, 'Visible', 'on')
    set(opt.edtPialNod, 'Visible', 'on')
    set(opt.txtPialNod, 'Visible', 'on')
    set(opt.edtScalpNod, 'Visible', 'on')
    set(opt.txtScalpNod, 'Visible', 'on')
    set(opt.edtCSFNod, 'Visible', 'on')
    
    set(opt.txtCSFNod, 'Visible', 'on')
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
        opt.cfg.EEG.mesh.headNumVertices(1) = str2double(get(opt.edtBrainNod, 'String'));
        opt.cfg.EEG.mesh.brainNumVertices(2) = str2double(get(opt.edtWhiteNod, 'String'));
        opt.cfg.EEG.mesh.headNumVertices(2) = str2double(get(opt.edtSkullNod, 'String'));
        opt.cfg.EEG.mesh.brainNumVertices(1) = str2double(get(opt.edtPialNod, 'String'));
        opt.cfg.EEG.mesh.headNumVertices(3) = str2double(get(opt.edtScalpNod, 'String'));
        opt.cfg.EEG.mesh.brainNumVertices(3) = str2double(get(opt.edtCSFNod, 'String'));
    end
    Recover(h, CurrentState);
    
    if strcmp(opt.choice, 'No')
        set(opt.txtMesg, 'Position', temp2)
        opt = rmfield(opt, 'choice'); % Initialize 'choice' field
        set(opt.panelMessage, 'Visible', 'off')
        set(opt.pbNo, 'String', 'No', 'Visible', 'off')
        set(opt.edtBrainNod, 'Visible', 'off')
        set(opt.txtBrainNod, 'Visible', 'off')
        set(opt.edtWhiteNod, 'Visible', 'off')
        set(opt.txtWhiteNod, 'Visible', 'off')
        set(opt.edtSkullNod, 'Visible', 'off')
        set(opt.txtSkullNod, 'Visible', 'off')
        set(opt.edtPialNod, 'Visible', 'off')
        set(opt.txtPialNod, 'Visible', 'off')
        set(opt.edtScalpNod, 'Visible', 'off')
        set(opt.txtScalpNod, 'Visible', 'off')
        set(opt.edtCSFNod, 'Visible', 'off')
        set(opt.txtCSFNod, 'Visible', 'off')
        %         set(opt.pbMesh, 'BackgroundColor', 0.94*[1 1 1])
        set(opt.panelMessage, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
        %         set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Mesh preparation: Meshing, coordinate system checking, unit checking (please wait ...)'); % , 'HorizontalAlignment', 'center'
        set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Mesh preparation (please wait ...)'); % , 'HorizontalAlignment', 'center'
        setappdata(h, 'opt', opt);
        CurrentState = Freeze(h);
        pause(0.001)
        
        load(opt.cfg.EEG.segMRIDir) % Loads the precomputed segmented MRI
        cfg = [];
        cfg.tissue = {'brain', 'skull', 'scalp'};
        cfg.numvertices = opt.cfg.EEG.mesh.headNumVertices;
        head = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIBrain);
        
        % --> check and determine the coordinate-system of the meshes:
        if ~isfield(head, 'coordsys') || ~strcmp(head(1).coordsys, opt.cfg.EEG.coordSys)
            head_(1) = ft_determine_coordsys(head(1));
            head_(2).coordsys = head_(1).coordsys;
            head_(3).coordsys = head_(1).coordsys;
            head = head_;
        end % if ~isfield(head(1), 'coordsys') ...
        
        % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
        if ~isfield(head(1), 'unit') || ... ~isfield(head(2), 'unit') || ~isfield(head(3), 'unit') || ...
                ~strcmp(head(1).unit, opt.cfg.EEG.unit) %|| ~strcmp(head(2).unit, opt.cfg.EEG.unit) || ~strcmp(head(3).unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
            head(1) = ft_convert_units(head(1), opt.cfg.EEG.unit);
            head(2) = ft_convert_units(head(2), opt.cfg.EEG.unit);
            head(3) = ft_convert_units(head(3), opt.cfg.EEG.unit);
        end % if ~isfield(head(1), 'unit') ...
        for i = 1 : length(head)
            head(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
        end
        bnd.head = head;
        
        cfg = [];
        cfg.tissue = {'gray', 'white', 'csf'};
        cfg.numvertices = opt.cfg.EEG.mesh.brainNumVertices;
        brain = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIGrayWhiteCSF);
        
        for i = 1 : length(brain)
            brain(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
        end
        bnd.brain = brain;
        
        save(opt.cfg.EEG.meshDir, 'bnd');
        Recover(h, CurrentState);
    end % if strcmp(opt.choice, 'Yes')
end
set(opt.panelMessage, 'Visible', 'off')
set(opt.pbMesh, 'BackgroundColor', [152 251 152] / 255)
set(opt.pbVol, 'Enable', 'on', 'FontWeight', 'bold')
set(opt.panelVol, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
set(opt.cbMeshBrain, 'Enable', 'on')
set(opt.cbMeshSkull, 'Enable', 'on')
set(opt.cbMeshScalp, 'Enable', 'on')
set(opt.cbMeshWhite, 'Enable', 'on')
set(opt.cbMeshGray, 'Enable', 'on')
set(opt.cbMeshCSF, 'Enable', 'on')

setappdata(h, 'opt', opt);

function Mesh_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbMeshBrain, 'Value') == 0 && get(opt.cbMeshSkull, 'Value') == 0 && get(opt.cbMeshScalp, 'Value') == 0 && ...
        get(opt.cbMeshWhite, 'Value') == 0 && get(opt.cbMeshGray, 'Value') == 0 && get(opt.cbMeshCSF, 'Value') == 0
    
    allHandle = {'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh'}; % Delete previous slices
    %     ToBeDeleted = isfield(opt.cfg.EEG, allHandle);
    %     if any(ToBeDeleted)
    %         ToBeDeleted = find(ToBeDeleted);
    %         for i = 1 : length(ToBeDeleted)
    temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
    %             temp = allHandle{ToBeDeleted(i)};
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    
    delete(opt.cfg.EEG.(temp));
    opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         temp = [temp(1:end - 1) 'y'];
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         temp = [temp(1:end - 1) 'z'];
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         end % for i = 1 : length(ToBeDeleted)
    %     end % if any(ToBeDeleted)
    
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'Mesh');
    
    %         allHandle = {'MRIhx', 'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}; % Delete previous slices
    %     if all(~isfield(opt.cfg.EEG, allHandle))
    %         set(opt.sEEGSourceUp, 'Enable', 'off')
    %         set(opt.sEEGSourceLeft, 'Enable', 'off')
    %         set(opt.sEEGSourceBottom, 'Enable', 'off')
    %
    %         rotate3d off
    %
    %         set(opt.txtEEGSourceUp, 'Enable', 'off')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'off')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'off')
    %     end
else
    if isfield(opt.cfg.EEG, 'Mesh') % One of the checkboxes in panel has been already selected
        
        %         if isfield(opt.cfg.EEG, 'MeshBrainh') % Brain
        %             ToBeDeleted = 'MeshBrainh';
        %             set(opt.cbMeshBrain, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshSkullh') % Skull
        %             ToBeDeleted = 'MeshSkullh';
        %             set(opt.cbMeshSkull, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshScalph') % Scalp
        %             ToBeDeleted = 'MeshScalph';
        %             set(opt.cbMeshScalp, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshWhiteh') % White matter
        %             ToBeDeleted = 'MeshWhiteh';
        %             set(opt.cbMeshWhite, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshGrayh') % Gray matter
        %             ToBeDeleted = 'MeshGrayh';
        %             set(opt.cbMeshGray, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshCSFh') % CSF
        %             ToBeDeleted = 'MeshCSFh';
        %             set(opt.cbMeshCSF, 'Value', 0)
        %         end % if isfield(opt.cfg.EEG, 'MeshBrainh')
        %         [az, el] = view;
    else
        load(opt.cfg.EEG.meshDir)
        opt.cfg.EEG.Mesh = bnd;
        clear bnd
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    %     if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    %         set(opt.sEEGSourceUp, 'Enable', 'on')
    %         set(opt.sEEGSourceLeft, 'Enable', 'on')
    %         set(opt.sEEGSourceBottom, 'Enable', 'on')
    %         set(opt.txtEEGSourceUp, 'Enable', 'on')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'on')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'on')
    %     end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    %     S1 = round(get(opt.sEEGSourceUp, 'Value'));
    %     S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    %     S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    %     if get(opt.cbSegBrain, 'Value') == 1 || get(opt.cbSegSkull, 'Value') == 1 || get(opt.cbSegScalp, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegWhite, 'Value') == 1 || get(opt.cbSegGray, 'Value') == 1 || get(opt.cbSegCSF, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegAll, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     end
    
    axes(opt.AxeEEGSource)
    %     if isfield(opt.cfg.EEG, 'MRIhx')
    %         delete(opt.cfg.EEG.MRIhx)
    %         delete(opt.cfg.EEG.MRIhy)
    %         delete(opt.cfg.EEG.MRIhz)
    %     end
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx') || isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    
    C = colormap('jet');
    temp = round(linspace(1, size(C, 1), 6));
    
    if get(opt.cbMeshWhite, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'MeshWhiteh') % White matter
        opt.cfg.EEG.MeshWhiteh = ft_plot_mesh_mod(opt.cfg.EEG.Mesh.brain(2), 'vertexcolor', C(temp(1), :), 'edgecolor', C(temp(1), :), 'edgealpha', 0.95, 'facecolor', C(temp(1), :), 'facealpha', 0.95); hold on
    elseif get(opt.cbMeshWhite, 'Value') == 0 && isfield(opt.cfg.EEG, 'MeshWhiteh') % White matter
        delete(opt.cfg.EEG.MeshWhiteh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MeshWhiteh');
    elseif get(opt.cbMeshGray, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'MeshGrayh') % Gray matter
        opt.cfg.EEG.MeshGrayh = ft_plot_mesh_mod(opt.cfg.EEG.Mesh.brain(1), 'vertexcolor', C(temp(2), :), 'edgecolor', C(temp(2), :), 'edgealpha', 0.77, 'facecolor', C(temp(2), :), 'facealpha', 0.77); hold on
    elseif get(opt.cbMeshGray, 'Value') == 0 && isfield(opt.cfg.EEG, 'MeshGrayh') % White matter
        delete(opt.cfg.EEG.MeshGrayh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MeshGrayh');
    elseif get(opt.cbMeshCSF, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'MeshCSFh') % CSF
        opt.cfg.EEG.MeshCSFh = ft_plot_mesh_mod(opt.cfg.EEG.Mesh.brain(3), 'vertexcolor', C(temp(3), :), 'edgecolor', C(temp(3), :), 'edgealpha', 0.59, 'facecolor', C(temp(3), :), 'facealpha', 0.59); hold on
    elseif get(opt.cbMeshCSF, 'Value') == 0 && isfield(opt.cfg.EEG, 'MeshCSFh') % White matter
        delete(opt.cfg.EEG.MeshCSFh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MeshCSFh');
    elseif get(opt.cbMeshBrain, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'MeshBrainh') % Brain
        opt.cfg.EEG.MeshBrainh = ft_plot_mesh_mod(opt.cfg.EEG.Mesh.head(1), 'vertexcolor', C(temp(4), :), 'edgecolor', C(temp(4), :), 'edgealpha', 0.41, 'facecolor', C(temp(4), :), 'facealpha', 0.41); hold on
    elseif get(opt.cbMeshBrain, 'Value') == 0 && isfield(opt.cfg.EEG, 'MeshBrainh') % White matter
        delete(opt.cfg.EEG.MeshBrainh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MeshBrainh');
    elseif get(opt.cbMeshSkull, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'MeshSkullh') % Skull
        opt.cfg.EEG.MeshSkullh = ft_plot_mesh_mod(opt.cfg.EEG.Mesh.head(2), 'vertexcolor', C(temp(5), :), 'edgecolor', C(temp(5), :), 'edgealpha', 0.25, 'facecolor', C(temp(5), :), 'facealpha', 0.25); hold on
    elseif get(opt.cbMeshSkull, 'Value') == 0 && isfield(opt.cfg.EEG, 'MeshSkullh') % White matter
        delete(opt.cfg.EEG.MeshSkullh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MeshSkullh');
    elseif get(opt.cbMeshScalp, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'MeshScalph') % Scalp
        opt.cfg.EEG.MeshScalph = ft_plot_mesh_mod(opt.cfg.EEG.Mesh.head(3), 'vertexcolor', C(temp(6), :), 'edgecolor', C(temp(6), :), 'edgealpha', 0.05, 'facecolor', C(temp(6), :), 'facealpha', 0.05); hold on
    elseif get(opt.cbMeshScalp, 'Value') == 0 && isfield(opt.cfg.EEG, 'MeshScalph') % White matter
        delete(opt.cfg.EEG.MeshScalph)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'MeshScalph');
    end % if get(opt.cbSegBrain, 'Value') == 1
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    %     if exist('ToBeDeleted', 'var')
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'x'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'y'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'z'],'])'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'x']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'y']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'z']);
    %         delete(opt.cfg.EEG.(ToBeDeleted))
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, ToBeDeleted);
    %     end % if exist('ToBeDeleted', 'var')
end
setappdata(h, 'opt', opt);

function HeadModel(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.volDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelVol, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The head models have already been created. Would you like to recompute them and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 4 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 4 : length(pushButtons)
                if i > 4
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 4
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 16 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(32 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(4 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
            if strcmp(get(opt.txtLCMVLabel, 'Enable'), 'on')
                set(opt.txtLCMVLabel, 'Enable', 'off')
                set(opt.txtDICSLabel, 'Enable', 'off')
                set(opt.txtEEGLabel, 'Enable', 'off')
                set(opt.txtMEGLabel, 'Enable', 'off')
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    temp = get(opt.panelVol, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Head model preparation (please wait ...)'); % , 'HorizontalAlignment', 'center'
    set(opt.pbYes, 'Visible', 'off')
    set(opt.pbNo, 'Visible', 'off')
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    
    load(opt.cfg.EEG.meshDir)
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
    if ~isfield(vol.head, 'coordsys') || ~strcmp(vol.head.coordsys, opt.cfg.EEG.coordSys)
        vol.head = ft_determine_coordsys(vol.head);
        vol.brain.coordsys = vol.head.coordsys;
    end % if ~isfield(vol.head, 'coordsys') || ~strcmp(vol.head.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(vol.head, 'unit') || ~strcmp(vol.head.unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        vol.head = ft_convert_units(vol.head, opt.cfg.EEG.unit);
        vol.brain = ft_convert_units(vol.brain, opt.cfg.EEG.unit);
    end % if ~isfield(bnd, 'unit') || ~strcmp(bnd(1).unit, my_cfg.unit)
    
    vol.head.fiducials = bndHead(1).fiducials;
    vol.brain.fiducials = bndHead(1).fiducials;
    
    save(opt.cfg.EEG.volDir, 'vol');
    % else
    %     load(opt.cfg.EEG.volDir);
    Recover(h, CurrentState);
end


%     set(opt.edtBrainNod, 'Visible', 'on')
%     opt.cfg.EEG.mesh.headNumVertices(1) = str2double(get(opt.edtBrainNod, 'String'));
%     set(opt.txtBrainNod, 'Visible', 'on')
%     set(opt.edtWhiteNod, 'Visible', 'on')
%     opt.cfg.EEG.mesh.brainNumVertices(2) = str2double(get(opt.edtWhiteNod, 'String'));
%     set(opt.txtWhiteNod, 'Visible', 'on')
%     set(opt.edtSkullNod, 'Visible', 'on')
%     opt.cfg.EEG.mesh.headNumVertices(2) = str2double(get(opt.edtSkullNod, 'String'));
%     set(opt.txtSkullNod, 'Visible', 'on')
%     set(opt.edtPialNod, 'Visible', 'on')
%     opt.cfg.EEG.mesh.brainNumVertices(1) = str2double(get(opt.edtPialNod, 'String'));
%     set(opt.txtPialNod, 'Visible', 'on')
%     set(opt.edtScalpNod, 'Visible', 'on')
%     opt.cfg.EEG.mesh.headNumVertices(3) = str2double(get(opt.edtScalpNod, 'String'));
%     set(opt.txtScalpNod, 'Visible', 'on')
%     set(opt.edtCSFNod, 'Visible', 'on')
%     opt.cfg.EEG.mesh.brainNumVertices(3) = str2double(get(opt.edtCSFNod, 'String'));
%     set(opt.txtCSFNod, 'Visible', 'on')
%     setappdata(h, 'opt', opt);
%     uiwait

%     h = getparent(h);
%     opt = getappdata(h, 'opt');

%     if strcmp(opt.choice, 'Yes')
%         opt = rmfield(opt, 'choice'); % Initialize 'choice' field
%         set(opt.panelMessage, 'Visible', 'off')
%         set(opt.pbYes, 'String', 'Yes', 'Visible', 'off')
%         set(opt.edtBrainNod, 'Visible', 'off')
%         set(opt.txtBrainNod, 'Visible', 'off')
%         set(opt.edtWhiteNod, 'Visible', 'off')
%         set(opt.txtWhiteNod, 'Visible', 'off')
%         set(opt.edtSkullNod, 'Visible', 'off')
%         set(opt.txtSkullNod, 'Visible', 'off')
%         set(opt.edtPialNod, 'Visible', 'off')
%         set(opt.txtPialNod, 'Visible', 'off')
%         set(opt.edtScalpNod, 'Visible', 'off')
%         set(opt.txtScalpNod, 'Visible', 'off')
%         set(opt.edtCSFNod, 'Visible', 'off')
%         set(opt.txtCSFNod, 'Visible', 'off')
%         set(opt.pbMesh, 'BackgroundColor', 0.94*[1 1 1])
%         set(opt.panelMessage, 'Visible', 'on', 'BackgroundColor', 'y', 'ShadowColor', 'y', 'HighlightColor', 'y');
%         set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', 'y', 'String', 'Mesh preparation: Meshing, coordinate system checking, unit checking (please wait ...)'); % , 'HorizontalAlignment', 'center'
%         pause(0.001)
%         load(opt.cfg.EEG.segMRIDir) % Loads the precomputed segmented MRI
%         cfg = [];
%         cfg.tissue = {'brain', 'skull', 'scalp'};
%         cfg.numvertices = opt.cfg.EEG.mesh.headNumVertices;
%         head = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIBrain);
%
%         % --> check and determine the coordinate-system of the meshes:
%         if ~isfield(head, 'coordsys') || ~strcmp(head(1).coordsys, opt.cfg.EEG.coordSys)
%             head_(1) = ft_determine_coordsys(head(1));
%             head_(2).coordsys = head_(1).coordsys;
%             head_(3).coordsys = head_(1).coordsys;
%             head = head_;
%         end % if ~isfield(head(1), 'coordsys') ...
%
%         % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
%         if ~isfield(head(1), 'unit') || ... ~isfield(head(2), 'unit') || ~isfield(head(3), 'unit') || ...
%                 ~strcmp(head(1).unit, opt.cfg.EEG.unit) %|| ~strcmp(head(2).unit, opt.cfg.EEG.unit) || ~strcmp(head(3).unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
%             head(1) = ft_convert_units(head(1), opt.cfg.EEG.unit);
%             head(2) = ft_convert_units(head(2), opt.cfg.EEG.unit);
%             head(3) = ft_convert_units(head(3), opt.cfg.EEG.unit);
%         end % if ~isfield(head(1), 'unit') ...
%         for i = 1 : length(head)
%             head(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
%         end
%         bnd.head = head;
%
%         cfg = [];
%         cfg.tissue = {'gray', 'white', 'csf'};
%         cfg.numvertices = opt.cfg.EEG.mesh.brainNumVertices;
%         brain = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIGrayWhiteCSF);
%
%         for i = 1 : length(brain)
%             brain(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
%         end
%         bnd.brain = brain;
%
%         save(opt.cfg.EEG.meshDir, 'bnd');
%     end % if strcmp(opt.choice, 'Yes')
% end
set(opt.panelMessage, 'Visible', 'off')
set(opt.pbVol, 'BackgroundColor', [152 251 152] / 255)
set(opt.pbSrc, 'Enable', 'on', 'FontWeight', 'bold')
set(opt.panelSrc, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
set(opt.cbVolEEG, 'Enable', 'on')
set(opt.cbVolMEG, 'Enable', 'on')

setappdata(h, 'opt', opt);

function HeadModel_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbVolEEG, 'Value') == 0 && get(opt.cbVolMEG, 'Value') == 0
    
    allHandle = {'VolEEGh', 'VolMEGh'}; % Delete previous slices
    %     ToBeDeleted = isfield(opt.cfg.EEG, allHandle);
    %     if any(ToBeDeleted)
    %         ToBeDeleted = find(ToBeDeleted);
    %         for i = 1 : length(ToBeDeleted)
    temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    
    delete(opt.cfg.EEG.(temp));
    opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         temp = [temp(1:end - 1) 'y'];
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         temp = [temp(1:end - 1) 'z'];
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         end % for i = 1 : length(ToBeDeleted)
    %     end % if any(ToBeDeleted)
    
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'HeadModel');
    
    %         allHandle = {'MRIhx', 'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}; % Delete previous slices
    %     if all(~isfield(opt.cfg.EEG, allHandle))
    %         set(opt.sEEGSourceUp, 'Enable', 'off')
    %         set(opt.sEEGSourceLeft, 'Enable', 'off')
    %         set(opt.sEEGSourceBottom, 'Enable', 'off')
    %
    %         rotate3d off
    %
    %         set(opt.txtEEGSourceUp, 'Enable', 'off')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'off')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'off')
    %     end
else
    if isfield(opt.cfg.EEG, 'HeadModel') % One of the checkboxes in panel has been already selected
        
        %         if isfield(opt.cfg.EEG, 'MeshBrainh') % Brain
        %             ToBeDeleted = 'MeshBrainh';
        %             set(opt.cbMeshBrain, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshSkullh') % Skull
        %             ToBeDeleted = 'MeshSkullh';
        %             set(opt.cbMeshSkull, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshScalph') % Scalp
        %             ToBeDeleted = 'MeshScalph';
        %             set(opt.cbMeshScalp, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshWhiteh') % White matter
        %             ToBeDeleted = 'MeshWhiteh';
        %             set(opt.cbMeshWhite, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshGrayh') % Gray matter
        %             ToBeDeleted = 'MeshGrayh';
        %             set(opt.cbMeshGray, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshCSFh') % CSF
        %             ToBeDeleted = 'MeshCSFh';
        %             set(opt.cbMeshCSF, 'Value', 0)
        %         end % if isfield(opt.cfg.EEG, 'MeshBrainh')
        %         [az, el] = view;
    else
        load(opt.cfg.EEG.volDir)
        opt.cfg.EEG.HeadModel = vol;
        clear vol
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    %     if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    %         set(opt.sEEGSourceUp, 'Enable', 'on')
    %         set(opt.sEEGSourceLeft, 'Enable', 'on')
    %         set(opt.sEEGSourceBottom, 'Enable', 'on')
    %         set(opt.txtEEGSourceUp, 'Enable', 'on')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'on')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'on')
    %     end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    %     S1 = round(get(opt.sEEGSourceUp, 'Value'));
    %     S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    %     S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    %     if get(opt.cbSegBrain, 'Value') == 1 || get(opt.cbSegSkull, 'Value') == 1 || get(opt.cbSegScalp, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegWhite, 'Value') == 1 || get(opt.cbSegGray, 'Value') == 1 || get(opt.cbSegCSF, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegAll, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     end
    
    axes(opt.AxeEEGSource)
    hold on
    %     if isfield(opt.cfg.EEG, 'MRIhx')
    %         delete(opt.cfg.EEG.MRIhx)
    %         delete(opt.cfg.EEG.MRIhy)
    %         delete(opt.cfg.EEG.MRIhz)
    %     end
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx') || isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    
    %     C = colormap('jet');
    %     temp = round(linspace(1, size(C, 1), 6));
    
    if get(opt.cbVolEEG, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'VolEEGh') % White matter
        h1 = ft_plot_mesh_mod(opt.cfg.EEG.HeadModel.head.bnd(1), 'vertexcolor', 'none', 'edgecolor', 'none', 'facealpha', 0.8, 'facecolor', [0.7922 0.3922 0.3922]);
        h2 = ft_plot_mesh_mod(opt.cfg.EEG.HeadModel.head.bnd(2), 'vertexcolor', 'none', 'edgecolor', 'none', 'facealpha', 0.55, 'facecolor', [1.0000 0.8784 0.7412]);
        h3 = ft_plot_mesh_mod(opt.cfg.EEG.HeadModel.head.bnd(3), 'vertexcolor', 'none', 'edgecolor', 'none', 'facealpha', 0.3, 'facecolor', [1.0000 0.8784 0.7412]);
        opt.cfg.EEG.VolEEGh = [h1; h2; h3];
        %         opt.cfg.EEG.MeshWhiteh = ft_plot_mesh_mod(opt.cfg.EEG.Mesh.brain(1), 'vertexcolor', C(temp(1), :), 'edgecolor', C(temp(1), :), 'edgealpha', 0.95, 'facecolor', C(temp(1), :), 'facealpha', 0.95); hold on
    elseif get(opt.cbVolEEG, 'Value') == 0 && isfield(opt.cfg.EEG, 'VolEEGh') % White matter
        delete(opt.cfg.EEG.VolEEGh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'VolEEGh');
    elseif get(opt.cbVolMEG, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'VolMEGh') % Gray matter
        opt.cfg.EEG.VolMEGh = ft_plot_mesh_mod(opt.cfg.EEG.HeadModel.brain.bnd, 'vertexcolor', 'none', 'edgecolor', 'none', 'facealpha', 0.8, 'facecolor', [0.7922 0.3922 0.3922]);
    elseif get(opt.cbVolMEG, 'Value') == 0 && isfield(opt.cfg.EEG, 'VolMEGh') % White matter
        delete(opt.cfg.EEG.VolMEGh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'VolMEGh');
    end % if get(opt.cbSegBrain, 'Value') == 1
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    %     if exist('ToBeDeleted', 'var')
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'x'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'y'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'z'],'])'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'x']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'y']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'z']);
    %         delete(opt.cfg.EEG.(ToBeDeleted))
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, ToBeDeleted);
    %     end % if exist('ToBeDeleted', 'var')
end
setappdata(h, 'opt', opt);

function SourceModel(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.sourceModelDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelSrc, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The source model has already been created. Would you like to recompute it and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 5 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 5 : length(pushButtons)
                if i > 5
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 5
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 18 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(34 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(5 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
            if strcmp(get(opt.txtLCMVLabel, 'Enable'), 'on')
                set(opt.txtLCMVLabel, 'Enable', 'off')
                set(opt.txtDICSLabel, 'Enable', 'off')
                set(opt.txtEEGLabel, 'Enable', 'off')
                set(opt.txtMEGLabel, 'Enable', 'off')
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    temp = get(opt.panelSrc, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Source model preparation (please wait ...)'); % , 'HorizontalAlignment', 'center'
    set(opt.pbYes, 'Visible', 'off')
    set(opt.pbNo, 'Visible', 'off')
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    
    load(opt.cfg.EEG.volDir); % This should be thought over again (loading vol)
    volBrain = vol.brain;
    clear vol
    
    load(opt.cfg.EEG.meshDir)
    bndBrain = bnd.brain; % Order: {'gray', 'white', 'csf'}
    clear bnd
    
    cfg = [];
    cfg.grid.unit = opt.cfg.EEG.unit;
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
    cfg.grid.unit = opt.cfg.EEG.unit;
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
    cfg.grid.unit = opt.cfg.EEG.unit;
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
    
    
    % --> check and determine the coordinate-system of the volume conduction model of the head:
    if ~isfield(grid.white, 'coordsys') || ~strcmp(grid.white.coordsys, opt.cfg.EEG.coordSys)
        grid.white = ft_determine_coordsys(grid.white);
        grid.pial = ft_determine_coordsys(grid.pial);
        grid.between = ft_determine_coordsys(grid.between);
    end % if ~isfield(grid, 'coordsys') || ~strcmp(grid.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(grid.white, 'unit') || ~strcmp(grid.white.unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        grid.white = ft_convert_units(grid.white, my_cfg.unit);
        grid.pial = ft_convert_units(grid.pial, my_cfg.unit);
        grid.between = ft_convert_units(grid.between, my_cfg.unit);
    end % if ~isfield(bnd, 'unit') || ~strcmp(bnd(1).unit, my_cfg.unit)
    
    grid.white.fiducials = bndBrain(1).fiducials;
    grid.pial.fiducials = bndBrain(1).fiducials;
    grid.between.fiducials = bndBrain(1).fiducials;
    
    save(opt.cfg.EEG.sourceModelDir, 'grid');
    Recover(h, CurrentState);
end % if recompute

set(opt.panelMessage, 'Visible', 'off')
set(opt.pbSrc, 'BackgroundColor', [152 251 152] / 255)
set(opt.pbSns, 'Enable', 'on', 'FontWeight', 'bold')
set(opt.panelSns, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
set(opt.cbSrcWhite, 'Enable', 'on')
set(opt.cbSrcPial, 'Enable', 'on')
set(opt.cbSrcBetween, 'Enable', 'on')

setappdata(h, 'opt', opt);

function SourceModel_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbSrcWhite, 'Value') == 0 && get(opt.cbSrcPial, 'Value') == 0 && get(opt.cbSrcBetween, 'Value') == 0
    
    allHandle = {'SrcWhiteh', 'SrcPialh', 'SrcBetweenh'}; % Delete previous slices
    %     ToBeDeleted = isfield(opt.cfg.EEG, allHandle);
    %     if any(ToBeDeleted)
    %         ToBeDeleted = find(ToBeDeleted);
    %         for i = 1 : length(ToBeDeleted)
    temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    
    delete(opt.cfg.EEG.(temp));
    opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         temp = [temp(1:end - 1) 'y'];
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         temp = [temp(1:end - 1) 'z'];
    %         eval(['delete(opt.cfg.EEG.',temp,')'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    %         end % for i = 1 : length(ToBeDeleted)
    %     end % if any(ToBeDeleted)
    
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SourceModel');
    
    %         allHandle = {'MRIhx', 'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}; % Delete previous slices
    %     if all(~isfield(opt.cfg.EEG, allHandle))
    %         set(opt.sEEGSourceUp, 'Enable', 'off')
    %         set(opt.sEEGSourceLeft, 'Enable', 'off')
    %         set(opt.sEEGSourceBottom, 'Enable', 'off')
    %
    %         rotate3d off
    %
    %         set(opt.txtEEGSourceUp, 'Enable', 'off')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'off')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'off')
    %     end
else
    if isfield(opt.cfg.EEG, 'SourceModel') % One of the checkboxes in panel has been already selected
        
        %         if isfield(opt.cfg.EEG, 'MeshBrainh') % Brain
        %             ToBeDeleted = 'MeshBrainh';
        %             set(opt.cbMeshBrain, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshSkullh') % Skull
        %             ToBeDeleted = 'MeshSkullh';
        %             set(opt.cbMeshSkull, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshScalph') % Scalp
        %             ToBeDeleted = 'MeshScalph';
        %             set(opt.cbMeshScalp, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshWhiteh') % White matter
        %             ToBeDeleted = 'MeshWhiteh';
        %             set(opt.cbMeshWhite, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshGrayh') % Gray matter
        %             ToBeDeleted = 'MeshGrayh';
        %             set(opt.cbMeshGray, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshCSFh') % CSF
        %             ToBeDeleted = 'MeshCSFh';
        %             set(opt.cbMeshCSF, 'Value', 0)
        %         end % if isfield(opt.cfg.EEG, 'MeshBrainh')
        %         [az, el] = view;
    else
        grid = load(opt.cfg.EEG.sourceModelDir);
        opt.cfg.EEG.SourceModel = grid.grid;
        clear vol
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    %     if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    %         set(opt.sEEGSourceUp, 'Enable', 'on')
    %         set(opt.sEEGSourceLeft, 'Enable', 'on')
    %         set(opt.sEEGSourceBottom, 'Enable', 'on')
    %         set(opt.txtEEGSourceUp, 'Enable', 'on')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'on')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'on')
    %     end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    %     S1 = round(get(opt.sEEGSourceUp, 'Value'));
    %     S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    %     S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    %     if get(opt.cbSegBrain, 'Value') == 1 || get(opt.cbSegSkull, 'Value') == 1 || get(opt.cbSegScalp, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegWhite, 'Value') == 1 || get(opt.cbSegGray, 'Value') == 1 || get(opt.cbSegCSF, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegAll, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     end
    
    axes(opt.AxeEEGSource)
    hold on
    
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx') || isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    
    if get(opt.cbSrcWhite, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'SrcWhiteh') % White matter
        opt.cfg.EEG.SrcWhiteh = ft_plot_mesh_mod(opt.cfg.EEG.SourceModel.white, 'vertexcolor', 'b', 'edgecolor', 'b', 'facealpha', 0.75, 'facecolor', 'b');
    elseif get(opt.cbSrcWhite, 'Value') == 0 && isfield(opt.cfg.EEG, 'SrcWhiteh') % White matter
        delete(opt.cfg.EEG.SrcWhiteh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SrcWhiteh');
    elseif get(opt.cbSrcPial, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'SrcPialh') % Gray matter
        opt.cfg.EEG.SrcPialh = ft_plot_mesh_mod(opt.cfg.EEG.SourceModel.pial, 'vertexcolor', 'r', 'edgecolor', 'r', 'facealpha', 0.5, 'facecolor', 'r');
    elseif get(opt.cbSrcPial, 'Value') == 0 && isfield(opt.cfg.EEG, 'SrcPialh') % White matter
        delete(opt.cfg.EEG.SrcPialh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SrcPialh');
    elseif get(opt.cbSrcBetween, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'SrcBetweenh') % Gray matter
        opt.cfg.EEG.SrcBetweenh = ft_plot_mesh_mod(opt.cfg.EEG.SourceModel.between, 'vertexcolor', 'g', 'edgecolor', 'g', 'facealpha', 0.65, 'facecolor', 'g');
    elseif get(opt.cbSrcBetween, 'Value') == 0 && isfield(opt.cfg.EEG, 'SrcBetweenh') % White matter
        delete(opt.cfg.EEG.SrcBetweenh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SrcBetweenh');
    end % if get(opt.cbSegBrain, 'Value') == 1
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    %     if exist('ToBeDeleted', 'var')
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'x'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'y'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'z'],'])'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'x']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'y']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'z']);
    %         delete(opt.cfg.EEG.(ToBeDeleted))
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, ToBeDeleted);
    %     end % if exist('ToBeDeleted', 'var')
end
setappdata(h, 'opt', opt);

function SensorModel(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.sensDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelSns, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The sensor models have already been created. Would you like to recompute it and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 6 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 6 : length(pushButtons)
                if i > 6
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 6
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 21 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(37 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(6 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
            if strcmp(get(opt.txtLCMVLabel, 'Enable'), 'on')
                set(opt.txtLCMVLabel, 'Enable', 'off')
                set(opt.txtDICSLabel, 'Enable', 'off')
                set(opt.txtEEGLabel, 'Enable', 'off')
                set(opt.txtMEGLabel, 'Enable', 'off')
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    temp = get(opt.panelSns, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Sensor models preparation (please wait ...)'); % , 'HorizontalAlignment', 'center'
    set(opt.pbYes, 'Visible', 'off')
    set(opt.pbNo, 'Visible', 'off')
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    
    if isfield(opt.cfg.EEG, 'MRI')
        Fiducials = opt.cfg.EEG.MRI.fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'segMRI')
        Fiducials = opt.cfg.EEG.segMRI.segmentedMRIBrain.fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'Mesh')
        Fiducials = opt.cfg.EEG.Mesh.head(1).fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'HeadModel')
        Fiducials = opt.cfg.EEG.HeadModel.head.fiducials.xyz;
    elseif isfield(opt.cfg.EEG, 'SourceModel')
        Fiducials = opt.cfg.EEG.SourceModel.white.fiducials.xyz;
        %     elseif isfield(opt.cfg.EEG, 'SensorModel')
        %         opt.cfg.EEG.Fiducials = opt.cfg.EEG.SensorModel.EEG.fiducials.xyz;
    else
        load(opt.cfg.EEG.MRIDir)
        Fiducials = mri.fiducials.xyz;
        clear mri
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    if isfield(opt.cfg.EEG, 'HeadModel')
        scalp = opt.cfg.EEG.HeadModel.head.bnd(3);
    else
        load(opt.cfg.EEG.volDir)
        scalp = vol.head.bnd(3);
        clear vol
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    % --> Loading standard electrode/gradiometers layouts:
    sens.EEG = ft_read_sens(opt.cfg.EEG.EEGsensLoad, 'senstype', 'eeg');
    
    nas = Fiducials.nas;
    lpa = Fiducials.lpa;
    rpa = Fiducials.rpa;
    
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
    cfg.elec = sens.EEG;
    cfg.fiducial = fid.label;  % labels of fiducials in fid and in elec
    sens.EEG = ft_electroderealign(cfg); % both electrodes and anatomical MRI are expressed in the same head-coordinate system (same fiducials)
    
    
    %     cfg = [];
    %     cfg.method = 'interactive';
    %     cfg.elec = sens.EEG;
    %     cfg.headshape = scalp;
    %     sens.EEG = ft_electroderealign(cfg);
    
    sens.MEG = ft_read_sens(opt.cfg.EEG.MEGsensLoad, 'senstype', 'meg');
    
    % --> check and determine the coordinate-system of the volume conduction model of the head:
    if ~isfield(sens.EEG, 'coordsys') || ~strcmp(sens.EEG.coordsys, opt.cfg.EEG.coordSys)
        sens.EEG = ft_determine_coordsys(sens.EEG);
        sens.MEG = ft_determine_coordsys(sens.MEG);
    end % if ~isfield(grid, 'coordsys') || ~strcmp(grid.coordsys, my_cfg.coordSys)
    
    % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
    if ~isfield(sens.EEG, 'unit') || ~strcmp(sens.EEG.unit, opt.cfg.EEG.unit) || ...
            ~isfield(sens.MEG, 'unit') || ~strcmp(sens.MEG.unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        sens.EEG = ft_convert_units(sens.EEG, opt.cfg.EEG.unit);
        sens.MEG = ft_convert_units(sens.MEG, opt.cfg.EEG.unit);
    end % if ~isfield(bnd, 'unit') || ~strcmp(bnd(1).unit, my_cfg.unit)
    
    sens.EEG.fiducials = Fiducials;
    sens.MEG.fiducials = Fiducials;
    
    save(opt.cfg.EEG.sensDir, 'sens');
    Recover(h, CurrentState);
end % if recompute

set(opt.panelMessage, 'Visible', 'off')
set(opt.pbSns, 'BackgroundColor', [152 251 152] / 255)
set(opt.pbLF, 'Enable', 'on', 'FontWeight', 'bold')
set(opt.panelLF, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
set(opt.cbSnsEEG, 'Enable', 'on')
set(opt.cbSnsMEG, 'Enable', 'on')

setappdata(h, 'opt', opt);

function SensorModel_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbSnsEEG, 'Value') == 0 && get(opt.cbSnsMEG, 'Value') == 0
    
    allHandle = {'SnsEEGh', 'SnsMEGh'}; % Delete previous slices
    temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
    delete(opt.cfg.EEG.(temp));
    opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SensorModel');
    
else
    if isfield(opt.cfg.EEG, 'SensorModel') % One of the checkboxes in panel has been already selected
        
        %         if isfield(opt.cfg.EEG, 'MeshBrainh') % Brain
        %             ToBeDeleted = 'MeshBrainh';
        %             set(opt.cbMeshBrain, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshSkullh') % Skull
        %             ToBeDeleted = 'MeshSkullh';
        %             set(opt.cbMeshSkull, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshScalph') % Scalp
        %             ToBeDeleted = 'MeshScalph';
        %             set(opt.cbMeshScalp, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshWhiteh') % White matter
        %             ToBeDeleted = 'MeshWhiteh';
        %             set(opt.cbMeshWhite, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshGrayh') % Gray matter
        %             ToBeDeleted = 'MeshGrayh';
        %             set(opt.cbMeshGray, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshCSFh') % CSF
        %             ToBeDeleted = 'MeshCSFh';
        %             set(opt.cbMeshCSF, 'Value', 0)
        %         end % if isfield(opt.cfg.EEG, 'MeshBrainh')
        %         [az, el] = view;
    else
        load(opt.cfg.EEG.sensDir);
        opt.cfg.EEG.SensorModel = sens;
        clear sens
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    %     if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    %         set(opt.sEEGSourceUp, 'Enable', 'on')
    %         set(opt.sEEGSourceLeft, 'Enable', 'on')
    %         set(opt.sEEGSourceBottom, 'Enable', 'on')
    %         set(opt.txtEEGSourceUp, 'Enable', 'on')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'on')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'on')
    %     end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    %     S1 = round(get(opt.sEEGSourceUp, 'Value'));
    %     S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    %     S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    %     if get(opt.cbSegBrain, 'Value') == 1 || get(opt.cbSegSkull, 'Value') == 1 || get(opt.cbSegScalp, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegWhite, 'Value') == 1 || get(opt.cbSegGray, 'Value') == 1 || get(opt.cbSegCSF, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegAll, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     end
    
    axes(opt.AxeEEGSource)
    hold on
    
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx') || isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    
    if get(opt.cbSnsEEG, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'SnsEEGh') % White matter
        opt.cfg.EEG.SnsEEGh = ft_plot_sens_mod(opt.cfg.EEG.SensorModel.EEG, 'style', opt.cfg.EEG.channelsSymb(end), 'label', 'label');
    elseif get(opt.cbSnsEEG, 'Value') == 0 && isfield(opt.cfg.EEG, 'SnsEEGh') % White matter
        delete(opt.cfg.EEG.SnsEEGh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SnsEEGh');
    elseif get(opt.cbSnsMEG, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'SnsMEGh') % Gray matter
        opt.cfg.EEG.SnsMEGh = ft_plot_sens_mod(opt.cfg.EEG.SensorModel.MEG, 'style', opt.cfg.EEG.channelsSymb(end), 'label', 'label');
    elseif get(opt.cbSnsMEG, 'Value') == 0 && isfield(opt.cfg.EEG, 'SnsMEGh') % White matter
        delete(opt.cfg.EEG.SnsMEGh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SnsMEGh');
    end % if get(opt.cbSegBrain, 'Value') == 1
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    %     if exist('ToBeDeleted', 'var')
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'x'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'y'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'z'],'])'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'x']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'y']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'z']);
    %         delete(opt.cfg.EEG.(ToBeDeleted))
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, ToBeDeleted);
    %     end % if exist('ToBeDeleted', 'var')
end
setappdata(h, 'opt', opt);

function LeadField(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.LFDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelLF, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The lead-field matrix has already been created. Would you like to recompute it and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 7 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 7 : length(pushButtons)
                if i > 7
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 7
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 23 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(39 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(7 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
            if strcmp(get(opt.txtLCMVLabel, 'Enable'), 'on')
                set(opt.txtLCMVLabel, 'Enable', 'off')
                set(opt.txtDICSLabel, 'Enable', 'off')
                set(opt.txtEEGLabel, 'Enable', 'off')
                set(opt.txtMEGLabel, 'Enable', 'off')
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    temp = get(opt.panelLF, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Parameter: Would you like to normalise the lead-field matrix?'); % , 'HorizontalAlignment', 'center'
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            normalize = 'no'; % normalize the leadfield (yes: removes depth bias (Q in eq. 27 of van Veen et al, 1997))
        case 'Yes'
            normalize = 'yes'; % normalize the leadfield (yes: removes depth bias (Q in eq. 27 of van Veen et al, 1997))
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
    
    set(opt.panelMessage, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Lead-field preparation (please wait ...)'); % , 'HorizontalAlignment', 'center'
    set(opt.pbYes, 'Visible', 'off')
    set(opt.pbNo, 'Visible', 'off')
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    
    load(opt.cfg.EEG.volDir)
    sourceModel = load(opt.cfg.EEG.sourceModelDir);
    load(opt.cfg.EEG.sensDir)
    
    cfg = [];
    cfg.grid = sourceModel.grid.white;
    cfg.normalize = normalize; % normalize the leadfield (yes: removes depth bias (Q in eq. 27 of van Veen et al, 1997))
    % cfg.vol = my_cfg.Vol; % Volume conduction head model
    % cfg.grid.pos = my_cfg.Bnd_pnt; % Source space
    % cfg.grid.inside = 1 : size(my_cfg.Bnd_pnt, 1);
    %     if strcmp(opt.cfg.EEG.name, 'EEG') % ft_senstype(opt.cfg.EEG.Sens, 'eeg')
    cfg.senstype = 'eeg';
    cfg.elec = sens.EEG; % Sensor model
    %     cfg.vol = vol.head; % Volume conduction head model
    cfg.headmodel = vol.head; % Volume conduction head model
    cfg.channel = {'all', '-Nz', '-LPA', '-RPA'}; % Should be generalised based on the different fiducial label conventions
    EEGLF = ft_prepare_leadfield(cfg); % Leadfield
    
    LF_cat = zeros(length(EEGLF.label), 3 * length(find(EEGLF.inside))); % Concatenated lead-field
    c = 1;
    for i = 1 : length(EEGLF.leadfield)
        if ~isempty(EEGLF.leadfield{i})
            LF_cat(:, (c - 1) * size(EEGLF.leadfield{i}, 2) + 1 : c * size(EEGLF.leadfield{i}, 2)) = EEGLF.leadfield{i};
            c = c + 1;
        end
    end % for i = 1 : length(EEGLF.leadfield)
    
    EEGLF.LF_cat = LF_cat; % Concatenated lead-field
    
    %     elseif strcmp(opt.cfg.EEG.name, 'MEG') % ft_senstype(opt.cfg.EEG.Sens, 'meg')
    cfg.senstype = 'meg';
    cfg.grad = sens.MEG; % Sensor model
    %     cfg.vol = vol.brain; % Volume conduction head model
    cfg.headmodel = vol.brain; % Volume conduction head model
    cfg.channel = {'MEG'};
    %     end % if strcmp(opt.cfg.EEG.name, 'EEG')
    MEGLF = ft_prepare_leadfield(cfg); % Leadfield
    
    LF_cat = zeros(length(MEGLF.label), 3 * length(find(MEGLF.inside))); % Concatenated lead-field
    c = 1;
    for i = 1 : length(MEGLF.leadfield)
        if ~isempty(MEGLF.leadfield{i})
            LF_cat(:, (c - 1) * size(MEGLF.leadfield{i}, 2) + 1 : c * size(MEGLF.leadfield{i}, 2)) = MEGLF.leadfield{i};
            c = c + 1;
        end
    end % for i = 1 : length(MEGLF.leadfield)
    
    MEGLF.LF_cat = LF_cat; % Concatenated lead-field
    
    LF = [];
    LF.EEGLF = EEGLF;
    LF.MEGLF = MEGLF;
    
    save(opt.cfg.EEG.LFDir, 'LF');
    Recover(h, CurrentState);
end % if recompute

set(opt.panelMessage, 'Visible', 'off')
set(opt.pbLF, 'BackgroundColor', [152 251 152] / 255)
set(opt.pbFP, 'Enable', 'on', 'FontWeight', 'bold')
set(opt.panelFP, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')

setappdata(h, 'opt', opt);

function ForwardProblem(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

axes(opt.AxeEEGSource)
[opt.view(1), opt.view(2)] = view;

allHandle = {'FPSrch', 'FPEEGh', 'FPMEGh'}; % Delete previous geometrical elements
for i = 1 : length(allHandle)
    if isfield(opt.cfg.EEG, allHandle{i})
        delete(opt.cfg.EEG.(allHandle{i}));
        opt.cfg.EEG = rmfield(opt.cfg.EEG, allHandle{i});
    end
end
if isfield(opt.cfg.EEG, 'ForwardProblem')
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'ForwardProblem');
end

set(opt.cbFPSource, 'Value', 0)
set(opt.cbFPEEG, 'Value', 0)
set(opt.cbFPMEG, 'Value', 0)

if exist(opt.cfg.EEG.FPDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelFP, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The forward problem has already been created. Would you like to recompute it and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            for i = 8 : length(panels)
                set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 8 : length(pushButtons)
                if i > 8
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 8
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 23 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(39 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(7 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    temp = get(opt.panelFP, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'To simulate the brain activity, select the center of brain activity and its width.'); % , 'HorizontalAlignment', 'center'
    set(opt.pbYes, 'Visible', 'off')
    set(opt.pbNo, 'Visible', 'on', 'String', 'Ok')
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    if strcmp(opt.choice, 'No')
        opt = rmfield(opt, 'choice'); % Initialize 'choice' field
        set(opt.panelMessage, 'Visible', 'off')
        set(opt.pbNo, 'String', 'No', 'Visible', 'off')
        setappdata(h, 'opt', opt);
        CurrentState = Freeze(h);
        pause(0.001)
        
        %         grid = load(opt.cfg.EEG.sourceModelDir);
        %         opt.cfg.EEG.SourceModel = grid.grid;
        %         clear vol
        
        load(opt.cfg.EEG.sourceModelDir)
        load(opt.cfg.EEG.LFDir)
        load(opt.cfg.EEG.sensDir)
        load(opt.cfg.EEG.volDir)
        
        sourceModel = grid.white;
        %     fig = figure;
        % subplot(121)
        nodes = [(1 : size(sourceModel.pos, 1))' sourceModel.pos];
        sel = nchoosek(1:size(sourceModel.tri, 2), 2); % Indices of different edges of the polygone (triangle)
        edges = nan(3*size(sourceModel.tri, 1), 2); % Initialisation
        for i = 1 : size(sel, 1) % All edges
            edges(size(sourceModel.tri, 1)*(i - 1) + 1 : size(sourceModel.tri, 1)*i, :) = sourceModel.tri(:, sel(i, :));
        end % for i = 1 : size(sel, 1)
        segments = [(1 : size(edges, 1))' edges];
        
        flag = 0;
        if strcmp(get(opt.sEEGSourceUp, 'Visible'), 'on')
            set(opt.sEEGSourceUp, 'Visible', 'off')
            set(opt.txtEEGSourceUp, 'Visible', 'off')
            set(opt.sEEGSourceLeft, 'Visible', 'off')
            set(opt.txtEEGSourceLeft, 'Visible', 'off')
            set(opt.sEEGSourceBottom, 'Visible', 'off')
            set(opt.txtEEGSourceBottom, 'Visible', 'off')
            flag = 1;
        end
        
        %         if strcmp(get(opt.sFPSigma2, 'Visible'), 'off')
        set(opt.sFPSigma2, 'Visible', 'on')
        set(opt.txtFPSigma2, 'Visible', 'on')
        set(opt.pbFPIsSel, 'Visible', 'on')
        set(opt.pbFPRotate, 'Visible', 'on')
        set(opt.pbFPDataSel, 'Visible', 'on')
        %         end
        
        axes(opt.AxeFPSourceActivity)
        set(opt.txtAxe, 'Visible', 'on')
        set(opt.AxeFPSourceActivity, 'Visible', 'on')
        hold on
        FPSourceActivityh = ft_plot_mesh_mod(sourceModel, 'vertexcolor', 'b', 'edgecolor', 'b', 'facecolor', 'w');
        view(opt.view)
        %         if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx') || isfield(opt.cfg.EEG, 'MRIhx')
        %             %             [az, el] = view;
        %             [opt.view(1), opt.view(2)] = view;
        %         end % if isfield(opt.cfg.EEG, 'MRIhx')
        
        %     get(sFPSigma2, 'Value')
        opt.dcm_obj = datacursormode(h);
        set(opt.dcm_obj, 'SnapToDataVertex', 'on', 'Enable' , 'on') % , 'DisplayStyle', 'window'
        
        Freq_FP = 10;
        time_FP = linspace(0, 1/Freq_FP, 10); % Time vector specific for fprward problem 1/Freq_FP
        %     Oscil_FP = abs(sin(2 * pi * Freq_FP * time_FP));
        Oscil_FP = ones(1, length(time_FP));
        % patchWidth = 100; % # of neighbours
        % activePatchInd = nan(length(AllSourceCenterInd), patchWidth);
        % activePatchAmp = nan(length(AllSourceCenterInd), patchWidth);
        activePatchAmp = nan(1, size(sourceModel.pos, 1)); % length(AllSourceCenterInd) ---> 1
        sourceActivity = cell(size(activePatchAmp, 1), length(time_FP)); %zeros(size(grid.pos));
        sourceActivityPow = cell(1, size(activePatchAmp, 1));
        EEGActivity = cell(1, size(activePatchAmp, 1)); %nan(size(LF.LF_cat, 1), length(AllSourceCenterInd));
        MEGActivity = cell(1, size(activePatchAmp, 1)); %nan(size(LF.LF_cat, 1), length(AllSourceCenterInd));
        
        opt.forwardProblem = [];
        opt.forwardProblem.Msc.isselected = false;
        setappdata(h, 'opt', opt);
        while ~opt.forwardProblem.Msc.isselected
            h = getparent(h);
            opt = getappdata(h, 'opt');
            %     ft_plot_mesh(sourceModel, 'surfaceonly', 'yes', 'vertexcolor', 'b', 'edgecolor', 'b');
            %     hold on
            drawnow
            %     dcm_obj = datacursormode(h);
            %     set(dcm_obj, 'SnapToDataVertex', 'on', 'Enable' , 'on') % , 'DisplayStyle', 'window'
            while ~opt.forwardProblem.Msc.isselected
                h = getparent(h);
                opt = getappdata(h, 'opt');
                %         waitfor(dcm_obj, 'Enable' , 'on');
                %         while strcmp(get(dcm_obj, 'Enable'), 'on')
                drawnow
                if ~isempty(getCursorInfo(opt.dcm_obj)) && ~opt.forwardProblem.Msc.isselected
                    temp = getCursorInfo(opt.dcm_obj);
                    [~, AllSourceCenterInd] = min(sum(abs(sourceModel.pos - temp.Position) , 2));
                    opt.dcm_obj.removeAllDataCursors()
                    break
                end
                %         end
                %         if strcmp(get(dcm_obj, 'Enable'), 'on')
                % %             subplot(121)
                % %             cla
                %             break
                %         end
            end
            %     delete(opt.cfg.EEG.FPSourceActivityh)
            % SourceCenter = [-26.5 33.5 95.5; -23.5 -27.5 96.5; 66.5 -26.5 81.5; 67.5 32.5 86.5];
            % SourceCenter = [17.5 1.5 118.5; -8.5 -28.5 105.5; -38.5 1.5 92.5; -9.5 39.5 101.5; ...
            %     17.5 1.5 118.5; 51.5 -26.5 95.5; 69.5 -10.5 97.5; 76.5 3.5 90.5; 47.5 38.5 97.5; 17.5 1.5 118.5];
            % SourceCenter = [1.75 .15 11.85; -1.75 -2.75 10.45; -3.55 0.15 9.55; -1.95 3.95 10.15; ...
            %     1.75 .15 11.85; 5.15 -2.65 9.55; 7.65 .35 9.05; 5.05 3.45 9.75; 1.75 .15 11.85];
            % inds = nan(1, size(SourceCenter, 1));
            % for i = 1 : size(SourceCenter, 1)
            %     [~, inds(i)] = min(sum(abs(sourceModel.pos - repmat(SourceCenter(i, :), size(sourceModel.pos, 1), 1)), 2));
            % end % for i = 1 : size(SourceCenter, 1)
            
            %     nodes = [(1 : size(sourceModel.pos, 1))' sourceModel.pos];
            %     sel = nchoosek(1:size(sourceModel.tri, 2), 2); % Indices of different edges of the polygone (triangle)
            %     edges = nan(3*size(sourceModel.tri, 1), 2); % Initialisation
            %     for i = 1 : size(sel, 1) % All edges
            %         edges(size(sourceModel.tri, 1)*(i - 1) + 1 : size(sourceModel.tri, 1)*i, :) = sourceModel.tri(:, sel(i, :));
            %     end % for i = 1 : size(sel, 1)
            %     segments = [(1 : size(edges, 1))' edges];
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
            %     Freq_FP = 10;
            %     time_FP = linspace(0, 1/Freq_FP, 10); % Time vector specific for fprward problem 1/Freq_FP
            % %     Oscil_FP = abs(sin(2 * pi * Freq_FP * time_FP));
            %     Oscil_FP = ones(1, length(time_FP));
            %     % patchWidth = 100; % # of neighbours
            %     % activePatchInd = nan(length(AllSourceCenterInd), patchWidth);
            %     % activePatchAmp = nan(length(AllSourceCenterInd), patchWidth);
            %     activePatchAmp = nan(length(AllSourceCenterInd), size(sourceModel.pos, 1));
            %     sourceActivity = cell(length(AllSourceCenterInd), length(time_FP)); %zeros(size(grid.pos));
            %     sourceActivityPow = cell(1, length(AllSourceCenterInd));
            %     EEGActivity = cell(1, length(AllSourceCenterInd)); %nan(size(LF.LF_cat, 1), length(AllSourceCenterInd));
            %         MEGActivity = cell(1, length(AllSourceCenterInd)); %nan(size(LF.LF_cat, 1), length(AllSourceCenterInd));
            %
            %     sigma2 = my_cfg.sourceActivity.sigma2; % Maximum: 10000
            if ~opt.forwardProblem.Msc.isselected
                if strcmp(get(opt.sFPSigma2, 'Enable'), 'off')
                    set(opt.sFPSigma2, 'Enable', 'on')
                    set(opt.txtFPSigma2, 'Enable', 'on')
                    set(opt.pbFPIsSel, 'Enable', 'on')
                end
                sigma2 = get(opt.sFPSigma2, 'Value'); % Maximum: 10000
                
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
                    for ii = 1 %: length(time_FP)
                        
                        
                        sourceActivity{i, ii} = zeros(size(sourceModel.pos));
                        %             for j = 1 : size(activePatchAmp, 2)
                        %                 temp = rand(1, 3);
                        %                 %             sourceActivity{i, ii}(activePatchInd(i, j), :) = Oscil_FP(ii) * activePatchAmp(i, j) * temp./norm(temp);
                        %                 sourceActivity{i, ii}(j, :) = Oscil_FP(ii) * activePatchAmp(i, j) * temp./norm(temp);
                        %             end
                        temp = rand(1, 3);
                        maxMom = repmat(activePatchAmp(i, :)', 1, 3) .* repmat(temp./norm(temp), size(activePatchAmp(i, :), 2), 1);
                        maxPow = sqrt(sum(maxMom.^ 2, 2));
                        sourceActivity{i, ii} = Oscil_FP(ii) * maxMom;
                        sourceActivityPow{i}(:, ii) = sqrt(sum(sourceActivity{i, ii}.^ 2, 2));
                        % -> representation
                        %                 subplot(121)
                        % figure
                        % subplot(121)
                        %                 ft_plot_mesh(sourceModel, 'vertexcolor', sourceActivityPow{i}(:, ii), 'edgecolor', 'k', 'colormap', 'jet'); % , 'surfaceonly', 'yes'
                        %                 lighting gouraud; material dull
                        
                        temp = sourceActivity{i, ii}(LF.EEGLF.inside, :)';
                        EEGActivity{i}(:, ii) = LF.EEGLF.LF_cat * temp(:);
                        
                        temp = sourceActivity{i, ii}(LF.MEGLF.inside, :)';
                        MEGActivity{i}(:, ii) = LF.MEGLF.LF_cat * temp(:);
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
                
                set(opt.txtAxe, 'Visible', 'on')
                axes(opt.AxeFPSourceActivity)
                %                 set(opt.AxeFPSourceActivity, 'Visible', 'on')
                
                tmp = ft_plot_mesh_mod(sourceModel, 'vertexcolor', sourceActivityPow{1}(:, 1), 'edgecolor', 'k', 'colormap', 'jet'); % , 'facecolor', 'w'
                if isfield(opt.cfg.EEG, 'FPSourceActivityh')
                    delete(opt.cfg.EEG.FPSourceActivityh)
                end
                opt.cfg.EEG.FPSourceActivityh = tmp;
                delete(FPSourceActivityh)
                pause(0.001)
                %                 if strcmp(get(opt.sFPSigma2, 'Visible'), 'off')
                %                     set(opt.sFPSigma2, 'Visible', 'on')
                %                     set(opt.txtFPSigma2, 'Visible', 'on')
                %                     set(opt.pbFPIsSel, 'Visible', 'on')
                %                 end
                %     forwardProblem = [];
                opt.forwardProblem.maxMom = maxMom;
                opt.forwardProblem.maxPow = maxPow;
                opt.forwardProblem.sourceModel = sourceModel;
                opt.forwardProblem.sourceActivity = sourceActivity;
                opt.forwardProblem.sourceActivityWidth = sigma2;
                opt.forwardProblem.sourceActivityPow = sourceActivityPow;
                opt.forwardProblem.EEGActivity = EEGActivity;
                opt.forwardProblem.MEGActivity = MEGActivity;
                opt.forwardProblem.activePatchAmp = activePatchAmp;
                opt.forwardProblem.Msc.segments = segments;
                opt.forwardProblem.Msc.AllSourceCenterInd = AllSourceCenterInd;
                opt.forwardProblem.Msc.nodes = nodes;
                opt.forwardProblem.Msc.time_FP = time_FP;
                opt.forwardProblem.Msc.Oscil_FP = Oscil_FP;
                opt.forwardProblem.Msc.LF = LF;
                %                 [opt.view(1), opt.view(2)] = view;
                %                 %         opt.forwardProblem = forwardProblem;
                %                 setappdata(h, 'opt', opt);
            end
            axes(opt.AxeFPSourceActivity)
            [opt.view(1), opt.view(2)] = view;
            setappdata(h, 'opt', opt);
        end % while ~opt.forwardProblem.Msc.isselected
        h = getparent(h);
        opt = getappdata(h, 'opt');
        set(opt.sFPSigma2, 'Visible', 'off', 'Enable', 'off')
        set(opt.txtFPSigma2, 'Visible', 'off', 'Enable', 'off')
        set(opt.pbFPIsSel, 'Visible', 'off', 'Enable', 'off')
        set(opt.pbFPRotate, 'Visible', 'off')
        set(opt.pbFPDataSel, 'Visible', 'off')
        delete(opt.cfg.EEG.FPSourceActivityh)
        %         set(opt.AxeFPSourceActivity, 'Visible', 'off')
        axes(opt.AxeEEGSource)
        view(opt.view)
        set(opt.txtAxe, 'Visible', 'off')
        pause(.001)
        
        forwardProblem = opt.forwardProblem;
        forwardProblem.sens = sens;
        save(opt.cfg.EEG.FPDir, 'forwardProblem');
        Recover(h, CurrentState);
    end % if strcmp(opt.choice, 'No')
end % if recompute
% opt.forwardProblem = forwardProblem;
set(opt.panelMessage, 'Visible', 'off')
set(opt.pbFP, 'BackgroundColor', [152 251 152] / 255)
set(opt.cbFPSource, 'Enable', 'on')
set(opt.cbFPEEG, 'Enable', 'on')
set(opt.cbFPMEG, 'Enable', 'on')
% set(opt.AxeFPSourceActivity, 'Visible', 'off')
if exist('flag', 'var') && flag
    set(opt.sEEGSourceUp, 'Visible', 'on')
    set(opt.txtEEGSourceUp, 'Visible', 'on')
    set(opt.sEEGSourceLeft, 'Visible', 'on')
    set(opt.txtEEGSourceLeft, 'Visible', 'on')
    set(opt.sEEGSourceBottom, 'Visible', 'on')
    set(opt.txtEEGSourceBottom, 'Visible', 'on')
end

set(opt.panelIP, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')
set(opt.pbIP, 'Enable', 'on', 'FontWeight', 'bold')

setappdata(h, 'opt', opt);

function FPSigma2_slider(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
% S = round(get(opt.sFPSigma2, 'Value'));
sigma2 = get(opt.sFPSigma2, 'Value'); % Maximum: 10000

% figure
for i = 1 : length(opt.forwardProblem.Msc.AllSourceCenterInd)
    [patchCenterAllDist, ~] = dijkstra(opt.forwardProblem.Msc.nodes, opt.forwardProblem.Msc.segments, opt.forwardProblem.Msc.AllSourceCenterInd(i));
    %         patchCenter = sourceModel.pos(AllSourceCenterInd(i), :);
    %         patchCenterAllDist = sqrt(sum((sourceModel.pos - repmat(patchCenter, size(sourceModel.pos, 1), 1)).^2, 2));
    %         [~, ind] = sort(patchCenterAllDist);
    %         activePatchInd(i, :) = ind(1 : patchWidth);
    
    %         activePatchAmp(i, :) = exp(-(((sourceModel.pos(activePatchInd(i, :), 1) - sourceModel.pos(AllSourceCenterInd(i), 1)).^2 / (2 * sigma2)) + ...
    %             ((sourceModel.pos(activePatchInd(i, :), 2) - sourceModel.pos(AllSourceCenterInd(i), 2)).^2 / (2 * sigma2)) + ...
    %             ((sourceModel.pos(activePatchInd(i, :), 3) - sourceModel.pos(AllSourceCenterInd(i), 3)).^2 / (2 * sigma2))));
    opt.forwardProblem.activePatchAmp(i, :) = exp(-((patchCenterAllDist.^2) / (2 * sigma2) ));
    
    opt.forwardProblem.sourceActivityPow{i} = nan(size(opt.forwardProblem.activePatchAmp, 2), length(opt.forwardProblem.Msc.time_FP));
    for ii = 1 %: length(time_FP)
        
        
        opt.forwardProblem.sourceActivity{i, ii} = zeros(size(opt.forwardProblem.sourceModel.pos));
        %             for j = 1 : size(activePatchAmp, 2)
        %                 temp = rand(1, 3);
        %                 %             opt.forwardProblem.sourceActivity{i, ii}(activePatchInd(i, j), :) = Oscil_FP(ii) * activePatchAmp(i, j) * temp./norm(temp);
        %                 opt.forwardProblem.sourceActivity{i, ii}(j, :) = Oscil_FP(ii) * activePatchAmp(i, j) * temp./norm(temp);
        %             end
        temp = rand(1, 3);
        opt.forwardProblem.maxMom = repmat(opt.forwardProblem.activePatchAmp(i, :)', 1, 3) .* repmat(temp./norm(temp), size(opt.forwardProblem.activePatchAmp(i, :), 2), 1);
        opt.forwardProblem.maxPow = sqrt(sum(opt.forwardProblem.maxMom.^ 2, 2));
        opt.forwardProblem.sourceActivity{i, ii} = opt.forwardProblem.Msc.Oscil_FP(ii) * opt.forwardProblem.maxMom;
        opt.forwardProblem.sourceActivityPow{i}(:, ii) = sqrt(sum(opt.forwardProblem.sourceActivity{i, ii}.^ 2, 2));
        % -> representation
        %                 subplot(121)
        % figure
        % subplot(121)
        %                 ft_plot_mesh(sourceModel, 'vertexcolor', opt.forwardProblem.sourceActivityPow{i}(:, ii), 'edgecolor', 'k', 'colormap', 'jet'); % , 'surfaceonly', 'yes'
        %                 lighting gouraud; material dull
        
        temp = opt.forwardProblem.sourceActivity{i, ii}(opt.forwardProblem.Msc.LF.EEGLF.inside, :)';
        opt.forwardProblem.EEGActivity{i}(:, ii) = opt.forwardProblem.Msc.LF.EEGLF.LF_cat * temp(:);
        
        temp = opt.forwardProblem.sourceActivity{i, ii}(opt.forwardProblem.Msc.LF.MEGLF.inside, :)';
        opt.forwardProblem.MEGActivity{i}(:, ii) = opt.forwardProblem.Msc.LF.MEGLF.LF_cat * temp(:);
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

axes(opt.AxeFPSourceActivity)

tmp = ft_plot_mesh_mod(opt.forwardProblem.sourceModel, 'vertexcolor', opt.forwardProblem.sourceActivityPow{1}(:, 1), 'edgecolor', 'k', 'colormap', 'jet'); % , 'facecolor', 'w'
delete(opt.cfg.EEG.FPSourceActivityh)
opt.cfg.EEG.FPSourceActivityh = tmp;
opt.forwardProblem.sourceActivityWidth = sigma2;


% S2 = round(get(opt.sEEGSourceLeft, 'Value'));
% S3 = round(get(opt.sEEGSourceBottom, 'Value'));
% if isfield(opt.cfg.EEG, 'MRI')
%     pos = IJKtransformXYZ(opt.cfg.EEG.MRI.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
% elseif isfield(opt.cfg.EEG, 'segMRI')
%     pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
% end
% axes(opt.AxeEEGSource)
% [az, el] = view;
%
% if isfield(opt.cfg.EEG, 'MRIhx') % Delete previous slices
%     delete(opt.cfg.EEG.MRIhx)
%     delete(opt.cfg.EEG.MRIhy)
%     delete(opt.cfg.EEG.MRIhz)
%     [opt.cfg.EEG.MRIhx, opt.cfg.EEG.MRIhy, opt.cfg.EEG.MRIhz] = ft_plot_ortho(opt.cfg.EEG.MRI.anatomy, 'style', 'intersect', 'transform', opt.cfg.EEG.MRI.transform, 'location', pos.pnt);
% end
% allHandle = {'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx'}; % Delete previous slices
% if any(isfield(opt.cfg.EEG, allHandle))
%     temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
%     %     eval(['delete(opt.cfg.EEG.',temp,')'])
%     delete(opt.cfg.EEG.(temp))
%     temp = [temp(1:end - 1) 'y'];
%     %     eval(['delete(opt.cfg.EEG.',temp,')'])
%     delete(opt.cfg.EEG.(temp))
%     temp = [temp(1:end - 1) 'z'];
%     %     eval(['delete(opt.cfg.EEG.',temp,')'])
%     delete(opt.cfg.EEG.(temp))
%
%     if get(opt.cbSegBrain, 'Value') == 1 % Brain
%         [opt.cfg.EEG.SegBrainhx, opt.cfg.EEG.SegBrainhy, opt.cfg.EEG.SegBrainhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.brain, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt);
%     elseif get(opt.cbSegSkull, 'Value') == 1 % Skull
%         [opt.cfg.EEG.SegSkullhx, opt.cfg.EEG.SegSkullhy, opt.cfg.EEG.SegSkullhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.skull, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt);
%     elseif get(opt.cbSegScalp, 'Value') == 1 % Scalp
%         [opt.cfg.EEG.SegScalphx, opt.cfg.EEG.SegScalphy, opt.cfg.EEG.SegScalphz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIBrain.scalp, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'location', pos.pnt);
%     elseif get(opt.cbSegWhite, 'Value') == 1 % White matter
%         [opt.cfg.EEG.SegWhitehx, opt.cfg.EEG.SegWhitehy, opt.cfg.EEG.SegWhitehz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.white, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt);
%     elseif get(opt.cbSegGray, 'Value') == 1 % Gray matter
%         [opt.cfg.EEG.SegGrayhx, opt.cfg.EEG.SegGrayhy, opt.cfg.EEG.SegGrayhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.gray, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt);
%     elseif get(opt.cbSegCSF, 'Value') == 1 % CSF
%         [opt.cfg.EEG.SegCSFhx, opt.cfg.EEG.SegCSFhy, opt.cfg.EEG.SegCSFhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.csf, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'location', pos.pnt);
%     elseif get(opt.cbSegAll, 'Value') == 1 % CSF
%         [opt.cfg.EEG.SegAllhx, opt.cfg.EEG.SegAllhy, opt.cfg.EEG.SegAllhz] = ft_plot_ortho(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.seg, 'style', 'intersect', 'transform', opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'location', pos.pnt, 'unit', opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.unit, 'colormap', 'jet');
%     end % if get(opt.cbSegBrain, 'Value') == 1
% end % if any(isfield(opt.cfg.EEG, allHandle))
%
% view([az, el])
% % rotate3d on
%
% set(opt.txtEEGSourceUp, 'String', ['Coronal (',num2str(S1),'/256)'])
% mls = sprintf(' Axial\n(%d/256)', S2);
% set(opt.txtEEGSourceLeft, 'String', mls)
% set(opt.txtEEGSourceBottom, 'String', ['Sagittal (',num2str(S3),'/256)'])
setappdata(h, 'opt', opt);

function FPIsSel(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
opt.forwardProblem.Msc.isselected = true;
axes(opt.AxeEEGSource)
rotate3d on
set(opt.rotate3d, 'Enable', 'on')
setappdata(h, 'opt', opt);

function ForwardProblem_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbFPSource, 'Value') == 0 && get(opt.cbFPEEG, 'Value') == 0 && get(opt.cbFPMEG, 'Value') == 0
    
    allHandle = {'FPSrch', 'FPEEGh', 'FPMEGh'}; % Delete previous geometrical elements
    temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
    delete(opt.cfg.EEG.(temp));
    opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'ForwardProblem');
    
else
    if isfield(opt.cfg.EEG, 'ForwardProblem') % One of the checkboxes in panel has been already selected
        
        %         if isfield(opt.cfg.EEG, 'MeshBrainh') % Brain
        %             ToBeDeleted = 'MeshBrainh';
        %             set(opt.cbMeshBrain, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshSkullh') % Skull
        %             ToBeDeleted = 'MeshSkullh';
        %             set(opt.cbMeshSkull, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshScalph') % Scalp
        %             ToBeDeleted = 'MeshScalph';
        %             set(opt.cbMeshScalp, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshWhiteh') % White matter
        %             ToBeDeleted = 'MeshWhiteh';
        %             set(opt.cbMeshWhite, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshGrayh') % Gray matter
        %             ToBeDeleted = 'MeshGrayh';
        %             set(opt.cbMeshGray, 'Value', 0)
        %         elseif isfield(opt.cfg.EEG, 'MeshCSFh') % CSF
        %             ToBeDeleted = 'MeshCSFh';
        %             set(opt.cbMeshCSF, 'Value', 0)
        %         end % if isfield(opt.cfg.EEG, 'MeshBrainh')
        %         [az, el] = view;
    else
        load(opt.cfg.EEG.FPDir);
        opt.cfg.EEG.ForwardProblem = forwardProblem;
        clear forwardProblem
    end % if isfield(opt.cfg.EEG, 'Mesh')
    
    %     if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    %         set(opt.sEEGSourceUp, 'Enable', 'on')
    %         set(opt.sEEGSourceLeft, 'Enable', 'on')
    %         set(opt.sEEGSourceBottom, 'Enable', 'on')
    %         set(opt.txtEEGSourceUp, 'Enable', 'on')
    %         set(opt.txtEEGSourceLeft, 'Enable', 'on')
    %         set(opt.txtEEGSourceBottom, 'Enable', 'on')
    %     end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    %     S1 = round(get(opt.sEEGSourceUp, 'Value'));
    %     S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    %     S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    %     if get(opt.cbSegBrain, 'Value') == 1 || get(opt.cbSegSkull, 'Value') == 1 || get(opt.cbSegScalp, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegWhite, 'Value') == 1 || get(opt.cbSegGray, 'Value') == 1 || get(opt.cbSegCSF, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegAll, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     end
    
    axes(opt.AxeEEGSource)
    hold on
    
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx') || isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    
    if get(opt.cbFPSource, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'FPSrch')
        valNorm = opt.cfg.EEG.ForwardProblem.sourceActivityPow{1}(:, 1);
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        opt.cfg.EEG.FPSrch = ft_plot_mesh_mod(opt.cfg.EEG.ForwardProblem.sourceModel, 'vertexcolor', valNorm, 'edgecolor', 'none', 'colormap', 'jet');
    elseif get(opt.cbFPSource, 'Value') == 0 && isfield(opt.cfg.EEG, 'FPSrch')
        delete(opt.cfg.EEG.FPSrch)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'FPSrch');
    elseif get(opt.cbFPEEG, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'FPEEGh')
        valNorm = opt.cfg.EEG.ForwardProblem.EEGActivity{1}(:, 1);
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        opt.cfg.EEG.FPEEGh = ft_plot_topo3d_mod(opt.cfg.EEG.ForwardProblem.sens.EEG.chanpos(ismember(opt.cfg.EEG.ForwardProblem.sens.EEG.label, opt.cfg.EEG.ForwardProblem.Msc.LF.EEGLF.label), :), valNorm, 'colormap', 'jet');
    elseif get(opt.cbFPEEG, 'Value') == 0 && isfield(opt.cfg.EEG, 'FPEEGh')
        delete(opt.cfg.EEG.FPEEGh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'FPEEGh');
    elseif get(opt.cbFPMEG, 'Value') == 1 && ~isfield(opt.cfg.EEG, 'FPMEGh')
        valNorm = opt.cfg.EEG.ForwardProblem.MEGActivity{1}(:, 1);
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        opt.cfg.EEG.FPMEGh = ft_plot_topo3d_mod(opt.cfg.EEG.ForwardProblem.sens.MEG.chanpos(ismember(opt.cfg.EEG.ForwardProblem.sens.MEG.label, opt.cfg.EEG.ForwardProblem.Msc.LF.MEGLF.label), :), valNorm, 'colormap', 'jet');
    elseif get(opt.cbFPMEG, 'Value') == 0 && isfield(opt.cfg.EEG, 'FPMEGh')
        delete(opt.cfg.EEG.FPMEGh)
        opt.cfg.EEG = rmfield(opt.cfg.EEG, 'FPMEGh');
    end % if get(opt.cbSegBrain, 'Value') == 1
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    %     if exist('ToBeDeleted', 'var')
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'x'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'y'],'])'])
    %         eval(['delete([opt.cfg.EEG.',[ToBeDeleted 'z'],'])'])
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'x']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'y']);
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'z']);
    %         delete(opt.cfg.EEG.(ToBeDeleted))
    %         opt.cfg.EEG = rmfield(opt.cfg.EEG, ToBeDeleted);
    %     end % if exist('ToBeDeleted', 'var')
end
setappdata(h, 'opt', opt);

function FPRotate(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
axes(opt.AxeFPSourceActivity)
rotate3d on
set(opt.rotate3d, 'Enable', 'on')
setappdata(h, 'opt', opt);

function FPDataSel(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
axes(opt.AxeFPSourceActivity)
% rotate3d off
set(opt.rotate3d, 'Enable', 'off')
set(opt.dcm_obj, 'Enable' , 'on')
setappdata(h, 'opt', opt);

function InverseProblem(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');

if exist(opt.cfg.EEG.IPDir, 'file')
    set(opt.pbYes, 'Visible', 'on')
    set(opt.pbNo, 'Visible', 'on')
    temp = get(opt.panelIP, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Warning: The reconstructed source has already been created. Would you like to recompute it and overwrite the existing file?'); % , 'HorizontalAlignment', 'center'
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
    end
    Recover(h, CurrentState);
    
    switch opt.choice % Handle response
        case 'No'
            recompute = false; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
        case 'Yes'
            recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
            
            % panels = {'panelSegMRI', 'panelMesh', 'panelVol', 'panelSrc', 'panelSns', 'panelLF', 'panelFP', 'panelIP'};
            % for i = 8 : length(panels)
            %     set(opt.(panels{i}), 'ForegroundColor', 0.4*[1 1 1], 'FontWeight', 'normal');
            % end % for i = 1 : length(checkBoxes)
            
            pushButtons = {'pbMRI', 'pbSegMRI', 'pbMesh', 'pbVol', 'pbSrc', 'pbSns', 'pbLF', 'pbFP', 'pbIP'};
            for i = 9 : length(pushButtons)
                if i > 9
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1], 'FontWeight', 'normal', 'Enable', 'off');
                elseif i == 9
                    set(opt.(pushButtons{i}), 'BackgroundColor', 0.94*[1 1 1]);
                end
            end
            
            checkBoxes = {'cbMRI', 'cbFiducl', ...
                'cbSegBrain', 'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
                'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', 'cbMeshGray', 'cbMeshCSF', ...
                'cbVolEEG', 'cbVolMEG', ...
                'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', ...
                'cbSnsEEG', 'cbSnsMEG', ...
                'cbFPSource', 'cbFPEEG', 'cbFPMEG', ...
                'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', 'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG'};
            for i = 26 : length(checkBoxes)
                set(opt.(checkBoxes{i}), 'Enable', 'off', 'Value', 0);
            end % for i = 1 : length(checkBoxes)
            
            plots = {'MRIhx', 'MRIhy', 'MRIhz', ...
                'SegBrainhx', 'SegSkullhx', 'SegScalphx', 'SegWhitehx', 'SegGrayhx', 'SegCSFhx', 'SegAllhx', ...
                'SegBrainhy', 'SegSkullhy', 'SegScalphy', 'SegWhitehy', 'SegGrayhy', 'SegCSFhy', 'SegAllhy', ...
                'SegBrainhz', 'SegSkullhz', 'SegScalphz', 'SegWhitehz', 'SegGrayhz', 'SegCSFhz', 'SegAllhz', ...
                'MeshBrainh', 'MeshSkullh', 'MeshScalph', 'MeshWhiteh', 'MeshGrayh', 'MeshCSFh', 'MeshAllh', ...
                'VolEEGh', 'VolMEGh', ...
                'SrcWhiteh', 'SrcPialh', 'SrcBetweenh', ...
                'SnsEEGh', 'SnsMEGh', ...
                'FPSrch', 'FPEEGh', 'FPMEGh', ...
                'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'};
            plots_sel = plots(42 : end);
            if any(isfield(opt.cfg.EEG, plots_sel))
                ind = find(isfield(opt.cfg.EEG, plots_sel));
                for i = 1 : length(ind)
                    delete(opt.cfg.EEG.(plots_sel{ind(i)}))
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, plots_sel{ind(i)});
                end
            end
            
            data = {'MRI', 'segMRI', 'Mesh', 'HeadModel', 'SourceModel', 'SensorModel', 'ForwardProblem', 'sourceReconst'};
            data_sel = data(8 : end);
            if any(isfield(opt.cfg.EEG, data_sel))
                ind = find(isfield(opt.cfg.EEG, data_sel));
                for i = 1 : length(ind)
                    opt.cfg.EEG = rmfield(opt.cfg.EEG, data_sel{ind(i)});
                end
            end
            
    end % switch opt.choice
    opt = rmfield(opt, 'choice'); % Initialize 'choice' field
else
    recompute = true; % If 'true' read & process MRI, if 'false', loads preprocessed MRI
end % if exist(opt.cfg.EEG.segMRIDir, 'file')

if recompute
    temp = get(opt.panelIP, 'Position');
    set(opt.panelMessage, 'Visible', 'on', 'Position', [0.01, temp(2), temp(1)-.02, temp(4)], 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
    %     temp2 = get(opt.panelIP, 'Position'); % [.02 .02 .83 .75]
    set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Parameters: Please enter the following required parameters.'); % , 'HorizontalAlignment', 'center', 'Position', [temp2(1), temp2(2), temp2(3)-.1, temp2(4)],
    set(opt.pbNo, 'String', 'Ok', 'Visible', 'on')
    set(opt.pbYes, 'Visible', 'off')
    set(opt.edtRelNoise, 'Visible', 'on')
    set(opt.txtRelNoise, 'Visible', 'on')
    set(opt.edtFreq, 'Visible', 'on')
    set(opt.txtFreq, 'Visible', 'on')
    set(opt.edtTrialsNum, 'Visible', 'on')
    set(opt.txtTrialsNum, 'Visible', 'on')
    set(opt.edtLambda, 'Visible', 'on')
    set(opt.txtLambda, 'Visible', 'on')
    setappdata(h, 'opt', opt);
    CurrentState = Freeze(h);
    pause(0.001)
    while ~isfield(opt, 'choice')
        uiwait
        h = getparent(h);
        opt = getappdata(h, 'opt');
        sourceReconst.relNoise = str2double(get(opt.edtRelNoise, 'String'));
        sourceReconst.freq = str2double(get(opt.edtFreq, 'String'));
        sourceReconst.trialsNum = str2double(get(opt.edtTrialsNum, 'String'));
        sourceReconst.lambda = get(opt.edtLambda, 'String');
        fprintf('The selected parameters for source reconstruction are:\n')
        fprintf('- Relative noise of the simulated signal: %1.2f\n', sourceReconst.relNoise)
        fprintf('- Oscillation frequency of source sinusoidal activity: %1.2f\n', sourceReconst.freq)
        fprintf('- Number of simulated trials: %d\n', sourceReconst.trialsNum)
        fprintf('- Lambda parameter: %s\n', sourceReconst.lambda)
    end
    Recover(h, CurrentState);
    
    if strcmp(opt.choice, 'No')
        %         set(opt.txtMesg, 'Position', temp2)
        opt = rmfield(opt, 'choice'); % Initialize 'choice' field
        set(opt.panelMessage, 'Visible', 'off')
        set(opt.pbNo, 'String', 'No', 'Visible', 'off')
        set(opt.edtRelNoise, 'Visible', 'off')
        set(opt.txtRelNoise, 'Visible', 'off')
        set(opt.edtFreq, 'Visible', 'off')
        set(opt.txtFreq, 'Visible', 'off')
        set(opt.edtTrialsNum, 'Visible', 'off')
        set(opt.txtTrialsNum, 'Visible', 'off')
        set(opt.edtLambda, 'Visible', 'off')
        set(opt.txtLambda, 'Visible', 'off')
        
        set(opt.panelMessage, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'ShadowColor', [238, 221, 130] / 255, 'HighlightColor', [238, 221, 130] / 255);
        %         set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Mesh preparation: Meshing, coordinate system checking, unit checking (please wait ...)'); % , 'HorizontalAlignment', 'center'
        set(opt.txtMesg, 'Visible', 'on', 'BackgroundColor', [238, 221, 130] / 255, 'String', 'Inverse solution preparation (please wait ...)'); % , 'HorizontalAlignment', 'center'
        setappdata(h, 'opt', opt);
        CurrentState = Freeze(h);
        pause(0.001)
        
        load(opt.cfg.EEG.FPDir)
        %     load(cfg.sourceModelDir)
        load(opt.cfg.EEG.LFDir)
        load(opt.cfg.EEG.sensDir)
        load(opt.cfg.EEG.volDir)
        %% Timelock data simulation
        % create a dipole simulation with one dipole and a 10Hz sine wave
        cfg = [];
        %     if ft_senstype(sens, 'eeg')
        cfg.senstype = 'eeg';
        cfg.headmodel = vol.head; % volume conduction model (headmodel)
        cfg.elec = sens.EEG;
        %     elseif ft_senstype(sens, 'meg')
        %         cfg.senstype = 'meg';
        %         cfg.headmodel = vol.brain; % volume conduction model (headmodel)
        %         cfg.grad = sens;
        %     end
        cfg.channel = LF.EEGLF.label;
        cfg.dip.pos = forwardProblem.sourceModel.pos(forwardProblem.sourceModel.inside, :);
        temp = forwardProblem.maxMom(LF.EEGLF.inside, :)';
        cfg.dip.mom = temp(:);
        %     figure % Plot real source activity
        %     temp = forwardProblem.maxMom(:, :)'; %sourceActivity{1}(:, :)';
        %     ft_plot_mesh(forwardProblem.sourceModel, 'vertexcolor', sqrt(sum(temp'.^ 2, 2)), 'edgecolor', 'k', 'colormap', 'jet'); % , 'surfaceonly', 'yes'
        %     lighting gouraud; material dull
        % note, it should be transposed
        % cfg.dip.frequency = 10;
        % cfg.dip.amplitude = 1; % per dipole
        % cfg.dip.phase = pi/6; % In radians
        % cfg.ntrials = 3;
        % cfg.triallength = 1; % seconds
        cfg.fsample = 250;
        time = (-0.5*cfg.fsample : 1 *cfg.fsample)/cfg.fsample; % manually create a time axis
        freq = sourceReconst.freq; % Source activity oscillation frequency
        signal = zeros(1, length(time));
        signal(time >= 0) = sin(2 * pi * freq * time(time >= 0)); % manually create a signal (sine wave)
        % signal(time >= 0) = 1; % manually create a signal (step signal)
        cfg.dip.signal = cell(1, sourceReconst.trialsNum);
        for i = 1 : sourceReconst.trialsNum
            cfg.dip.signal{i} = signal;  % # of trials
        end % for i = 1 : my_cfg.sourceReconst.trialNum
        cfg.relnoise = sourceReconst.relNoise;
        rawData = [];
        rawData.EEG = ft_dipolesimulation(cfg);
        for i = 1 : length(rawData.EEG.time) % Correct the time course
            rawData.EEG.time{i} = time;
        end
        
        cfg.senstype = 'meg';
        cfg.headmodel = vol.brain; % volume conduction model (headmodel)
        cfg.grad = sens.MEG;
        cfg.channel = LF.MEGLF.label;
        temp = forwardProblem.maxMom(LF.MEGLF.inside, :)';
        cfg.dip.mom = temp(:);
        rawData.MEG = ft_dipolesimulation(cfg);
        for i = 1 : length(rawData.MEG.time) % Correct the time course
            rawData.MEG.time{i} = time;
        end
        
        % figure; % Plot raw data
        % plot(rawData.time{1}, rawData.trial{1})
        
        for i = 1 : length(rawData.EEG.trial) % Demeaning the raw data
            %         mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) %[mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) mean(rawData.trial{i}(1,find(rawData.time{i} >= 0, 1):end))]
            rawData.EEG.trial{i} = ft_preproc_polyremoval(rawData.EEG.trial{i}, 0, 1, find(rawData.EEG.time{i} >= 0, 1) - 1); % this will also demean and detrend
            %         mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) %[mean(rawData.trial{i}(1,1:find(rawData.time{i} >= 0, 1) - 1)) mean(rawData.trial{i}(1,find(rawData.time{i} >= 0, 1):end))]
            rawData.MEG.trial{i} = ft_preproc_polyremoval(rawData.MEG.trial{i}, 0, 1, find(rawData.MEG.time{i} >= 0, 1) - 1); % this will also demean and detrend
        end % for i = 1 : length(rawData.trial)
        
        cfg = [];
        cfg.toilim = [-inf 0-1./rawData.EEG.fsample];
        rawDataPre.EEG = ft_redefinetrial(cfg, rawData.EEG);
        cfg.toilim = [0 inf];
        rawDataPost.EEG = ft_redefinetrial(cfg, rawData.EEG);
        
        cfg = [];
        cfg.toilim = [-inf 0-1./rawData.MEG.fsample];
        rawDataPre.MEG = ft_redefinetrial(cfg, rawData.MEG);
        cfg.toilim = [0 inf];
        rawDataPost.MEG = ft_redefinetrial(cfg, rawData.MEG);
        
        cfg = [];
        cfg.covariance = 'yes';
        cfg.covariancewindow = [-inf 0-1./rawData.EEG.fsample];
        timeLock.EEG = ft_timelockanalysis(cfg, rawData.EEG);
        % timeLock.fsample = rawData.fsample;
        
        cfg = [];
        cfg.covariance = 'yes';
        cfg.covariancewindow = [-inf 0-1./rawData.MEG.fsample];
        timeLock.MEG = ft_timelockanalysis(cfg, rawData.MEG);
        
        cfg = [];
        cfg.covariance = 'yes';
        timeLockPre.EEG = ft_timelockanalysis(cfg, rawDataPre.EEG);
        timeLockPost.EEG = ft_timelockanalysis(cfg, rawDataPost.EEG);
        % figure; plot(timeLock.time, timeLock.avg(:, :));
        cfg = [];
        cfg.covariance = 'yes';
        timeLockPre.MEG = ft_timelockanalysis(cfg, rawDataPre.MEG);
        timeLockPost.MEG = ft_timelockanalysis(cfg, rawDataPost.MEG);
        
        
        %% LCMV
        %     switch my_cfg.sourceReconst.method
        %         case 'LCMV'
        Modalities = {'EEG', 'MEG'};
        for i = 1 : length(Modalities)
            cfg = [];
            cfg.method = 'lcmv';
            % cfg.grid = leadfield;
            cfg.grid = forwardProblem.sourceModel;
            eval(['cfg.grid.leadfield = LF.',Modalities{i},'LF.leadfield;']) % leadfield
            if strcmp(Modalities{i}, 'EEG') %ft_senstype(sens, 'eeg')
                cfg.senstype = 'eeg';
                cfg.headmodel = vol.head; % volume conduction model (headmodel)
                cfg.elec = sens.(Modalities{i});
            elseif strcmp(Modalities{i}, 'MEG') %ft_senstype(sens, 'meg')
                cfg.senstype = 'meg';
                cfg.headmodel = vol.brain; % volume conduction model (headmodel)
                cfg.grad = sens.(Modalities{i});
            end
            cfg.channel = timeLock.(Modalities{i}).label;
            cfg.lcmv.keepfilter = 'yes';
            cfg.lcmv.fixedori = 'no'; % project on axis of most variance using SVD
            cfg.lcmv.projectnoise = 'yes';
            % cfg.lcmv.weightnorm = 'nai';
            cfg.lcmv.lambda = sourceReconst.lambda;
            sourceLCMV.(Modalities{i}) = ft_sourceanalysis(cfg, timeLock.(Modalities{i}));
            % sourceLCMV.avg.pow = abs(sourceLCMV.avg.pow);
            sourceLCMV.(Modalities{i}).avg.NAI = abs(sourceLCMV.(Modalities{i}).avg.pow) ./ sourceLCMV.(Modalities{i}).avg.noise; % Neural Activity Index (NAI)
            
            
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
            cfg.grid.filter = sourceLCMV.(Modalities{i}).avg.filter; % Same cfg as the previous LCMV
            cfg = rmfield(cfg, 'lcmv');
            cfg.lcmv.projectnoise = 'yes';
            sourceLCMVPre.(Modalities{i}) = ft_sourceanalysis(cfg, timeLockPre.(Modalities{i}));
            sourceLCMVPost.(Modalities{i}) = ft_sourceanalysis(cfg, timeLockPost.(Modalities{i}));
            
            sourceLCMV.(Modalities{i}).avg.relPow = (abs(sourceLCMVPost.(Modalities{i}).avg.pow) - abs(sourceLCMVPre.(Modalities{i}).avg.pow)) ./ abs(sourceLCMVPre.(Modalities{i}).avg.pow);
            
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
            % ft_plot_mesh(forwardProblem.sourceModel, 'vertexcolor', sourceLCMV.avg.relPow, 'edgecolor', 'none', 'colormap', 'jet');
            %     lighting gouraud; material dull
            
            % ind = source2.time >= 0;
            % momPowAvgTim = nan(size(source2.avg.mom, 1), 1);
            momPow = nan(size(sourceLCMV.(Modalities{i}).avg.mom, 1), length(sourceLCMV.(Modalities{i}).time));
            for ii = 1 : size(momPow, 1)
                if sourceLCMV.(Modalities{i}).inside(ii)
                    momPow(ii, :) = sqrt(sum(abs(sourceLCMV.(Modalities{i}).avg.mom{ii}).^2, 1));
                    % momPowNAI(i, :) = sqrt(sum(abs(sourceLCMV.avg.mom{i}).^2, 1)) / sourceLCMV.avg.noise(i);
                    % momPowNAI(i, :) = mean(sqrt(sum(abs(sourceLCMV.avg.mom{i}).^2, 1))) / sourceLCMV.avg.noise(i);
                    %         momPowAvgTim(i) = mean(abs(momPow(i, ind)));
                end % if sourceLCMV.inside(i)
            end % for i = 1 : size(momPow, 1)
            % sourceLCMV.avg.momPowAvgTim = momPowAvgTim;
            sourceLCMV.(Modalities{i}).avg.momPow = momPow;
        end % for i = 1 : length(Modalities)
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
        sourceReconst.LCMV = sourceLCMV;
        %     sourceReconst.sourceModel = forwardProblem.sourceModel;
        
        %% DICS
        %             case 'DICS'
        % this chunk of code creates a 'dummy' reference channel to be used for
        % the coherence analysis
        for i = 1 : length(Modalities)
            refdata = [];
            trial = cell(size(rawData.(Modalities{i}).trial));
            for k = 1 : numel(trial)
                trial{k} = sin(2 * pi * freq * rawData.(Modalities{i}).time{k});
            end
            refdata.trial = trial;
            refdata.time = rawData.(Modalities{i}).time;
            refdata.label = {'refchan'};
            rawDataAppend = ft_appenddata([], rawData.(Modalities{i}), refdata);
            rawDataAppend.fsample = rawData.(Modalities{i}).fsample;
            
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
            if strcmp(Modalities{i}, 'EEG') %ft_senstype(sens, 'eeg')
                cfg.senstype = 'eeg';
                cfg.headmodel = vol.head; % volume conduction model (headmodel)
                cfg.elec = sens.(Modalities{i});
            elseif strcmp(Modalities{i}, 'MEG') % ft_senstype(sens, 'meg')
                cfg.senstype = 'meg';
                cfg.headmodel = vol.brain; % volume conduction model (headmodel)
                cfg.grad = sens.(Modalities{i});
            end % if ft_senstype(sens, 'eeg')
            %     cfg.grid = LF;
            cfg.grid = forwardProblem.sourceModel;
            eval(['cfg.grid.leadfield = LF.',Modalities{i},'LF.leadfield;']) % leadfield
            cfg.dics.keepfilter = 'yes';
            cfg.dics.fixedori = 'no'; % To be generalised
            cfg.dics.projectnoise = 'yes';
            cfg.dics.lambda = sourceReconst.lambda;
            cfg.dics.realfilter = 'yes';
            %     cfg.dics.keepcsd = 'yes';
            cfg.refchan = {'refchan'};
            sourceDICS.(Modalities{i}) = ft_sourceanalysis(cfg, freqAll);
            sourceDICS.(Modalities{i}).avg.NAI = abs(sourceDICS.(Modalities{i}).avg.pow) ./ sourceDICS.(Modalities{i}).avg.noise; % Neural Activity Index (NAI)
            
            %         sourceallNAI = sourceDICS;
            %     sourceallNAI.avg.pow = abs(sourceallNAI.avg.pow) ./ sourceallNAI.avg.noise; % Neural Activity Index (NAI)
            
            
            % apply common filters to pre and post stimulus data
            cfg.grid.filter = sourceDICS.(Modalities{i}).avg.filter;
            % now we need to extract the dipole pairs' full csd matrix with respect
            % to the reference channel, which is not possible in the traditional
            % DICS implementation, but can be achieved with pcc
            %     cfg.method   = 'pcc';
            cfg = rmfield(cfg, 'dics');
            sourceDICSPre = ft_sourceanalysis(cfg, freqPre);
            sourceDICSPost = ft_sourceanalysis(cfg, freqPost);
            
            sourceDICS.(Modalities{i}).avg.relPow = (abs(sourceDICSPost.avg.pow) - abs(sourceDICSPre.avg.pow)) ./ abs(sourceDICSPre.avg.pow);
            
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
        end % for i = 1 : length(Modalities)
        sourceReconst.DICS = sourceDICS;
        %     end % switch my_cfg.sourceReconst.method
        sourceReconst.forwardProblem = forwardProblem;
        save(opt.cfg.EEG.IPDir, 'sourceReconst');
        
        
        
        
        
        
        
        
        %         load(opt.cfg.EEG.segMRIDir) % Loads the precomputed segmented MRI
        %         cfg = [];
        %         cfg.tissue = {'brain', 'skull', 'scalp'};
        %         cfg.numvertices = opt.cfg.EEG.mesh.headNumVertices;
        %         head = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIBrain);
        %
        %         % --> check and determine the coordinate-system of the meshes:
        %         if ~isfield(head, 'coordsys') || ~strcmp(head(1).coordsys, opt.cfg.EEG.coordSys)
        %             head_(1) = ft_determine_coordsys(head(1));
        %             head_(2).coordsys = head_(1).coordsys;
        %             head_(3).coordsys = head_(1).coordsys;
        %             head = head_;
        %         end % if ~isfield(head(1), 'coordsys') ...
        %
        %         % --> Check the unit (assuming that the common unit is mm for EEG and cm for MEG):
        %         if ~isfield(head(1), 'unit') || ... ~isfield(head(2), 'unit') || ~isfield(head(3), 'unit') || ...
        %                 ~strcmp(head(1).unit, opt.cfg.EEG.unit) %|| ~strcmp(head(2).unit, opt.cfg.EEG.unit) || ~strcmp(head(3).unit, opt.cfg.EEG.unit) % True, if there isn't 'unit' field or unit isn't desired one (mm/cm)
        %             head(1) = ft_convert_units(head(1), opt.cfg.EEG.unit);
        %             head(2) = ft_convert_units(head(2), opt.cfg.EEG.unit);
        %             head(3) = ft_convert_units(head(3), opt.cfg.EEG.unit);
        %         end % if ~isfield(head(1), 'unit') ...
        %         for i = 1 : length(head)
        %             head(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
        %         end
        %         bnd.head = head;
        %
        %         cfg = [];
        %         cfg.tissue = {'gray', 'white', 'csf'};
        %         cfg.numvertices = opt.cfg.EEG.mesh.brainNumVertices;
        %         brain = ft_prepare_mesh(cfg, segmentedMRI.segmentedMRIGrayWhiteCSF);
        %
        %         for i = 1 : length(brain)
        %             brain(i).fiducials = segmentedMRI.segmentedMRIBrain.fiducials;
        %         end
        %         bnd.brain = brain;
        %
        %         save(opt.cfg.EEG.meshDir, 'bnd');
        Recover(h, CurrentState);
    end % if strcmp(opt.choice, 'Yes')
end
set(opt.panelMessage, 'Visible', 'off')
set(opt.pbIP, 'BackgroundColor', [152 251 152] / 255)
% set(opt.pbVol, 'Enable', 'on', 'FontWeight', 'bold')
% set(opt.panelVol, 'ForegroundColor', [0 0 0], 'FontWeight', 'bold')

set(opt.cbIPDICSPowEEG, 'Enable', 'on')
set(opt.cbIPDICSPowMEG, 'Enable', 'on')
set(opt.cbIPLCMVPowEEG, 'Enable', 'on')
set(opt.cbIPLCMVMomEEG, 'Enable', 'on')
set(opt.cbIPLCMVPowMEG, 'Enable', 'on')
set(opt.cbIPLCMVMomMEG, 'Enable', 'on')
set(opt.txtLCMVLabel, 'Enable', 'on')
set(opt.txtDICSLabel, 'Enable', 'on')
set(opt.txtEEGLabel, 'Enable', 'on')
set(opt.txtMEGLabel, 'Enable', 'on')

setappdata(h, 'opt', opt);

function InverseProblem_checkBox(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
if get(opt.cbIPDICSPowEEG, 'Value') == 0 && get(opt.cbIPDICSPowMEG, 'Value') == 0 && get(opt.cbIPLCMVPowEEG, 'Value') == 0 && ...
        get(opt.cbIPLCMVMomEEG, 'Value') == 0 && get(opt.cbIPLCMVPowMEG, 'Value') == 0 && get(opt.cbIPLCMVMomMEG, 'Value') == 0
    
    allHandle = {'DICSPowEEGh', 'DICSPowMEGh', 'LCMVPowEEGh', 'LCMVMomEEGh', 'LCMVPowMEGh', 'LCMVMomMEGh'}; % Delete previous slices
    if any(isfield(opt.cfg.EEG, allHandle))
        temp = allHandle{isfield(opt.cfg.EEG, allHandle)};
        %         eval(['delete(opt.cfg.EEG.',temp,')'])
        delete(opt.cfg.EEG.(temp))
        opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
        %         temp = [temp(1:end - 1) 'y'];
        %         %         eval(['delete(opt.cfg.EEG.',temp,')'])
        %         delete(opt.cfg.EEG.(temp))
        %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
        %         temp = [temp(1:end - 1) 'z'];
        %         %         eval(['delete(opt.cfg.EEG.',temp,')'])
        %         delete(opt.cfg.EEG.(temp))
        %         opt.cfg.EEG = rmfield(opt.cfg.EEG, temp);
    end % if any(isfield(opt.cfg.EEG, allHandle))
    
    opt.cfg.EEG = rmfield(opt.cfg.EEG, 'sourceReconst');
    
    %     allHandle = {'MRIhx'}; % Delete previous slices
    %     if all(~isfield(opt.cfg.EEG, allHandle))
    %         set(opt.sEEGSourceUp, 'Visible', 'off')
    %         set(opt.sEEGSourceLeft, 'Visible', 'off')
    %         set(opt.sEEGSourceBottom, 'Visible', 'off')
    %
    %         %         set(opt.rotate3d, 'Enable', 'off');
    %
    %         set(opt.txtEEGSourceUp, 'Visible', 'off')
    %         set(opt.txtEEGSourceLeft, 'Visible', 'off')
    %         set(opt.txtEEGSourceBottom, 'Visible', 'off')
    %     end
else
    if isfield(opt.cfg.EEG, 'sourceReconst') % One of the checkboxes in panel has been already selected
        
        if isfield(opt.cfg.EEG, 'DICSPowEEGh') % Brain
            ToBeDeleted = 'DICSPowEEGh';
            %             delete(opt.cfg.EEG.SegBrainhx)
            %             delete(opt.cfg.EEG.SegBrainhy)
            %             delete(opt.cfg.EEG.SegBrainhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegBrainhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegBrainhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegBrainhz');
            set(opt.cbIPDICSPowEEG, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'DICSPowMEGh') % Skull
            ToBeDeleted = 'DICSPowMEGh';
            %             delete(opt.cfg.EEG.SegSkullhx)
            %             delete(opt.cfg.EEG.SegSkullhy)
            %             delete(opt.cfg.EEG.SegSkullhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegSkullhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegSkullhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegSkullhz');
            set(opt.cbIPDICSPowMEG, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'LCMVPowEEGh') % Scalp
            ToBeDeleted = 'LCMVPowEEGh';
            %             delete(opt.cfg.EEG.SegScalphx)
            %             delete(opt.cfg.EEG.SegScalphy)
            %             delete(opt.cfg.EEG.SegScalphz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegScalphx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegScalphy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegScalphz');
            set(opt.cbIPLCMVPowEEG, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'LCMVMomEEGh') % White matter
            ToBeDeleted = 'LCMVMomEEGh';
            %             delete(opt.cfg.EEG.SegWhitehx)
            %             delete(opt.cfg.EEG.SegWhitehy)
            %             delete(opt.cfg.EEG.SegWhitehz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegWhitehx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegWhitehy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegWhitehz');
            set(opt.cbIPLCMVMomEEG, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'LCMVPowMEGh') % Gray matter
            ToBeDeleted = 'LCMVPowMEGh';
            %             delete(opt.cfg.EEG.SegGrayhx)
            %             delete(opt.cfg.EEG.SegGrayhy)
            %             delete(opt.cfg.EEG.SegGrayhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegGrayhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegGrayhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegGrayhz');
            set(opt.cbIPLCMVPowMEG, 'Value', 0)
        elseif isfield(opt.cfg.EEG, 'LCMVMomMEGh') % CSF
            ToBeDeleted = 'LCMVMomMEGh';
            %             delete(opt.cfg.EEG.SegCSFhx)
            %             delete(opt.cfg.EEG.SegCSFhy)
            %             delete(opt.cfg.EEG.SegCSFhz)
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhx');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhy');
            %             opt.cfg.EEG = rmfield(opt.cfg.EEG, 'SegCSFhz');
            set(opt.cbIPLCMVMomMEG, 'Value', 0)
        end % if isfield(opt.cfg.EEG, 'SegBrainhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    else
        load(opt.cfg.EEG.IPDir)
        opt.cfg.EEG.sourceReconst = sourceReconst;
        clear sourceReconst
    end % if isfield(opt.cfg.EEG, 'segMRI')
    %     setappdata(h, 'opt', opt);
    
    %     if strcmp(get(opt.sEEGSourceUp, 'Visible'), 'off')
    %         set(opt.sEEGSourceUp, 'Visible', 'on')
    %         set(opt.sEEGSourceLeft, 'Visible', 'on')
    %         set(opt.sEEGSourceBottom, 'Visible', 'on')
    %         set(opt.txtEEGSourceUp, 'Visible', 'on')
    %         set(opt.txtEEGSourceLeft, 'Visible', 'on')
    %         set(opt.txtEEGSourceBottom, 'Visible', 'on')
    %     end % if strcmp(get(opt.sEEGSourceUp, 'Enable'), 'off')
    
    %     S1 = round(get(opt.sEEGSourceUp, 'Value'));
    %     S2 = round(get(opt.sEEGSourceLeft, 'Value'));
    %     S3 = round(get(opt.sEEGSourceBottom, 'Value'));
    %     if get(opt.cbSegBrain, 'Value') == 1 || get(opt.cbSegSkull, 'Value') == 1 || get(opt.cbSegScalp, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIBrain.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegWhite, 'Value') == 1 || get(opt.cbSegGray, 'Value') == 1 || get(opt.cbSegCSF, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIGrayWhiteCSF.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     elseif get(opt.cbSegAll, 'Value') == 1
    %         pos = IJKtransformXYZ(opt.cfg.EEG.segMRI.segmentedMRIAllIndexed.transform, 'voxel', [S1, S3, S2]); % [Coronal Sagittal Axial]
    %     end
    %
    
    axes(opt.AxeEEGSource)
    %     if isfield(opt.cfg.EEG, 'MRIhx')
    %         delete(opt.cfg.EEG.MRIhx)
    %         delete(opt.cfg.EEG.MRIhy)
    %         delete(opt.cfg.EEG.MRIhz)
    %     end
    if strcmp(get(opt.rotate3d, 'Enable'), 'on') %isfield(opt.cfg.EEG, 'MRIhx')
        %         [az, el] = view;
        [opt.view(1), opt.view(2)] = view;
    end % if isfield(opt.cfg.EEG, 'MRIhx')
    set(opt.rotate3d, 'Enable', 'on')
    setappdata(h, 'opt', opt);
    
    if get(opt.cbIPDICSPowEEG, 'Value') == 1 %
        valNorm = opt.cfg.EEG.sourceReconst.DICS.EEG.avg.relPow;
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        opt.cfg.EEG.DICSPowEEGh = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm, 'edgecolor', 'none', 'colormap', 'jet');
    elseif get(opt.cbIPDICSPowMEG, 'Value') == 1 %
        valNorm = opt.cfg.EEG.sourceReconst.DICS.MEG.avg.relPow;
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        opt.cfg.EEG.DICSPowMEGh = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm, 'edgecolor', 'none', 'colormap', 'jet');
    elseif get(opt.cbIPLCMVPowEEG, 'Value') == 1 %
        valNorm = opt.cfg.EEG.sourceReconst.LCMV.EEG.avg.relPow;
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        opt.cfg.EEG.LCMVPowEEGh = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm, 'edgecolor', 'none', 'colormap', 'jet');
    elseif get(opt.cbIPLCMVMomEEG, 'Value') == 1 %
        %         valNorm = opt.cfg.EEG.sourceReconst.LCMV.EEG.avg.momPow;
        %         valNorm = (valNorm - min(valNorm(:))) ./ (max(valNorm(:)) - min(valNorm(:)));
        % %         while (get(opt.cbIPDICSPowEEG, 'Value') == 0 && get(opt.cbIPDICSPowMEG, 'Value') == 0 && get(opt.cbIPLCMVPowEEG, 'Value') == 0 && ...
        % %                 get(opt.cbIPLCMVPowMEG, 'Value') == 0 && get(opt.cbIPLCMVMomMEG, 'Value') == 0) || get(opt.cbIPLCMVMomEEG, 'Value') == 1
        % temp = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm(:, 1), 'edgecolor', 'none', 'colormap', 'jet');
        % pause(0.05)
        %             for i = 2 : size(valNorm, 2)
        % %                 h = getparent(h);
        % %                 opt = getappdata(h, 'opt');
        %                 opt.cfg.EEG.LCMVMomEEGh = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm(:, i), 'edgecolor', 'none', 'colormap', 'jet');
        %                 delete(temp);
        %                 temp = opt.cfg.EEG.LCMVMomEEGh;
        %                 pause(0.05)
        % %                 delete(opt.cfg.EEG.LCMVMomEEGh);
        %
        % %                 if ~((get(opt.cbIPDICSPowEEG, 'Value') == 0 && get(opt.cbIPDICSPowMEG, 'Value') == 0 && get(opt.cbIPLCMVPowEEG, 'Value') == 0 && ...
        % %                         get(opt.cbIPLCMVPowMEG, 'Value') == 0 && get(opt.cbIPLCMVMomMEG, 'Value') == 0) || get(opt.cbIPLCMVMomEEG, 'Value') == 1)
        % %                     break
        % %                 end
        %             end % for i = 1 : size(valNorm, 2)
        % %         end
        % set(opt.cbIPLCMVMomEEG, 'Value', 0)
        % delete(temp);
        %         opt.cfg.EEG = rmfield(opt.cfg.EEG, 'LCMVMomEEGh');
        
        cfg = [];
        cfg.funparameter = 'momPow'; % 'momPow', 'pow'
        ft_sourcemovie(cfg, opt.cfg.EEG.sourceReconst.LCMV.EEG);
        % if exist('M', 'var')
        set(opt.cbIPLCMVMomEEG, 'Value', 0)
        % end
        
    elseif get(opt.cbIPLCMVPowMEG, 'Value') == 1 %
        valNorm = opt.cfg.EEG.sourceReconst.LCMV.MEG.avg.relPow;
        valNorm = (valNorm - min(valNorm(:))) / (max(valNorm(:)) - min(valNorm(:))); % Normalizing the values
        opt.cfg.EEG.LCMVPowMEGh = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm, 'edgecolor', 'none', 'colormap', 'jet');
    elseif get(opt.cbIPLCMVMomMEG, 'Value') == 1 %
        %         valNorm = opt.cfg.EEG.sourceReconst.LCMV.MEG.avg.momPow;
        %         valNorm = (valNorm - min(valNorm(:))) ./ (max(valNorm(:)) - min(valNorm(:)));
        % %         while (get(opt.cbIPDICSPowEEG, 'Value') == 0 && get(opt.cbIPDICSPowMEG, 'Value') == 0 && get(opt.cbIPLCMVPowEEG, 'Value') == 0 && ...
        % %                 get(opt.cbIPLCMVPowMEG, 'Value') == 0 && get(opt.cbIPLCMVMomMEG, 'Value') == 0) || get(opt.cbIPLCMVMomEEG, 'Value') == 1
        %                 temp = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm(:, 1), 'edgecolor', 'none', 'colormap', 'jet');
        %                 pause(0.05)
        %             for i = 2 : size(valNorm, 2)
        % %                 h = getparent(h);
        % %                 opt = getappdata(h, 'opt');
        %                 opt.cfg.EEG.LCMVMomMEGh = ft_plot_mesh_mod(opt.cfg.EEG.sourceReconst.forwardProblem.sourceModel, 'vertexcolor', valNorm(:, i), 'edgecolor', 'none', 'colormap', 'jet');
        %                  delete(temp);
        %                 temp = opt.cfg.EEG.LCMVMomMEGh;
        %                 pause(0.05)
        % %                 if ~((get(opt.cbIPDICSPowEEG, 'Value') == 0 && get(opt.cbIPDICSPowMEG, 'Value') == 0 && get(opt.cbIPLCMVPowEEG, 'Value') == 0 && ...
        % %                         get(opt.cbIPLCMVPowMEG, 'Value') == 0 && get(opt.cbIPLCMVMomMEG, 'Value') == 0) || get(opt.cbIPLCMVMomEEG, 'Value') == 1)
        % %                     break
        % %                 end
        %             end % for i = 1 : size(valNorm, 2)
        % %         end
        % set(opt.cbIPLCMVMomMEG, 'Value', 0)
        % delete(opt.cfg.EEG.LCMVMomMEGh);
        %         opt.cfg.EEG = rmfield(opt.cfg.EEG, 'LCMVMomMEGh');
        
        cfg = [];
        cfg.funparameter = 'momPow'; % 'momPow', 'pow'
        ft_sourcemovie(cfg, opt.cfg.EEG.sourceReconst.LCMV.MEG);
        % if exist('M', 'var')
        set(opt.cbIPLCMVMomMEG, 'Value', 0)
        % end
    end % if get(opt.cbSegBrain, 'Value') == 1
    setappdata(h, 'opt', opt);
    %     if exist('az', 'var')
    %         view([az, el]);
    %     else
    %         view([40 25])
    %         set(opt.rotate3d, 'Enable', 'on');
    %     end % if isfield(opt.cfg.EEG, 'MRIhx')
    view(opt.view)
    set(opt.rotate3d, 'Enable', 'on');
    if exist('ToBeDeleted', 'var')
        delete(opt.cfg.EEG.(ToBeDeleted));
        opt.cfg.EEG = rmfield(opt.cfg.EEG, ToBeDeleted);
        %         eval(['delete(opt.cfg.EEG.',[ToBeDeleted 'x'],')'])
        %         eval(['delete(opt.cfg.EEG.',[ToBeDeleted 'y'],')'])
        %         eval(['delete(opt.cfg.EEG.',[ToBeDeleted 'z'],')'])
        %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'x']);
        %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'y']);
        %         opt.cfg.EEG = rmfield(opt.cfg.EEG, [ToBeDeleted 'z']);
    end % if exist('ToBeDeleted', 'var')
end
setappdata(h, 'opt', opt);

function YES(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
opt.choice = 'Yes';
setappdata(h, 'opt', opt);
uiresume(h)

function NO(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
opt.choice = 'No';
setappdata(h, 'opt', opt);
uiresume(h)

function OK(h, eventdata)
h = getparent(h);
opt = getappdata(h, 'opt');
opt.choice = 'Ok';
setappdata(h, 'opt', opt);
uiresume(h)

function output = IJKtransformXYZ(transform_vox2coord, param, value)
switch param
    case 'voxel'
        vox = [value ones(size(value, 1), 1)]';
        pnt =  transform_vox2coord * vox;
    case 'coordsys'
        pnt = [value  ones(size(value, 1), 1)]';
        vox = round(inv(transform_vox2coord) * pnt);
end
output.vox = vox(1 : end - 1, :)';
output.pnt = pnt(1 : end - 1, :)';
output.transform = transform_vox2coord;

function h = getparent(h)
p = h;
while p~=0
    h = p;
    p = get(h, 'parent');
end

function [hs] = ft_plot_mesh_mod(mesh, varargin)

% FT_PLOT_MESH visualizes a surface or volumetric mesh, for example describing the
% realistic shape of the head. Surface meshes should be described by triangles and
% contain the fields "pos" and "tri". Volumetric meshes should be described with
% tetraheders or hexaheders and have the fields "pos" and "tet" or "hex".
%
% Use as
%   ft_plot_mesh(mesh, ...)
% or if you only want to plot the 3-D vertices
%   ft_plot_mesh(pos, ...)
%
% Optional arguments should come in key-value pairs and can include
%   'facecolor'    = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r', or an Nx3 or Nx1 array where N is the number of faces
%   'vertexcolor'  = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r', or an Nx3 or Nx1 array where N is the number of vertices
%   'edgecolor'    = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r'
%   'faceindex'    = true or false
%   'vertexindex'  = true or false
%   'facealpha'    = transparency, between 0 and 1 (default = 1)
%   'edgealpha'    = transparency, between 0 and 1 (default = 1)
%   'surfaceonly'  = true or false, plot only the outer surface of a hexahedral or tetrahedral mesh (default = false)
%   'vertexmarker' = character, e.g. '.', 'o' or 'x' (default = '.')
%   'vertexsize'   = scalar or vector with the size for each vertex (default = 10)
%   'unit'         = string, convert to the specified geometrical units (default = [])
%   'maskstyle',   = 'opacity' or 'colormix', if the latter is specified, opacity masked color values
%                    are converted (in combination with a background color) to rgb. This bypasses
%                    openGL functionality, which behaves unpredictably on some platforms (e.g. when
%                    using software opengl)
%
% If you don't want the faces, edges or vertices to be plotted, you should specify the color as 'none'.
%
% Example
%   [pos, tri] = icosahedron162;
%   mesh.pos = pos;
%   mesh.tri = tri;
%   ft_plot_mesh(mesh, 'facecolor', 'skin', 'edgecolor', 'none')
%   camlight
%
% See also FT_PLOT_HEADSHAPE, FT_PLOT_VOL, TRIMESH, PATCH

% Copyright (C) 2009, Cristiano Micheli
% Copyright (C) 2009-2015, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

ws = warning('on', 'MATLAB:divideByZero');

% rename pnt into pos
mesh = fixpos(mesh);

if ~isstruct(mesh) && isnumeric(mesh) && size(mesh,2)==3
    % the input seems like a list of points, convert into something that resembles a mesh
    mesh = struct('pos', mesh);
end

% the input is a structure, but might also be a struct-array
if numel(mesh)>1
    % plot each of the boundaries
    for i=1:numel(mesh)
        ft_plot_mesh(mesh(i), varargin{:})
    end
    return
end

% get the optional input arguments
vertexcolor  = ft_getopt(varargin, 'vertexcolor');
if isfield(mesh, 'tri') && size(mesh.tri,1)>10000
    facecolor    = ft_getopt(varargin, 'facecolor',   'cortex_light');
    edgecolor    = ft_getopt(varargin, 'edgecolor',   'none');
else
    facecolor    = ft_getopt(varargin, 'facecolor',   'white');
    edgecolor    = ft_getopt(varargin, 'edgecolor',   'k');
end
faceindex    = ft_getopt(varargin, 'faceindex',   false);
vertexindex  = ft_getopt(varargin, 'vertexindex', false);
vertexsize   = ft_getopt(varargin, 'vertexsize',  10);
vertexmarker = ft_getopt(varargin, 'vertexmarker', '.');
facealpha    = ft_getopt(varargin, 'facealpha',   1);
edgealpha    = ft_getopt(varargin, 'edgealpha',   1);
tag          = ft_getopt(varargin, 'tag',         '');
surfaceonly  = ft_getopt(varargin, 'surfaceonly');  % default is handled below
unit         = ft_getopt(varargin, 'unit');
clim         = ft_getopt(varargin, 'clim');
alphalim     = ft_getopt(varargin, 'alphalim');
alphamapping = ft_getopt(varargin, 'alphamap', 'rampup');
cmap         = ft_getopt(varargin, 'colormap');
maskstyle    = ft_getopt(varargin, 'maskstyle', 'opacity');

haspos   = isfield(mesh, 'pos');  % vertices
hastri   = isfield(mesh, 'tri');  % triangles   as a Mx3 matrix with vertex indices
hastet   = isfield(mesh, 'tet');  % tetraheders as a Mx4 matrix with vertex indices
hashex   = isfield(mesh, 'hex');  % hexaheders  as a Mx8 matrix with vertex indices
hasline  = isfield(mesh, 'line'); % line segments in 3-D
haspoly  = isfield(mesh, 'poly'); % polynomial surfaces in 3-D
hascolor = isfield(mesh, 'color'); % color code for vertices

if hastet && isempty(surfaceonly)
    ft_warning('only visualizing the outer surface of the tetrahedral mesh, see the "surfaceonly" option')
    surfaceonly = true;
elseif hashex && isempty(surfaceonly)
    ft_warning('only visualizing the outer surface of the hexahedral mesh, see the "surfaceonly" option')
    surfaceonly = true;
else
    surfaceonly = false;
end

if ~isempty(unit)
    mesh = ft_convert_units(mesh, unit);
end

if surfaceonly
    mesh = mesh2edge(mesh);
    % update the flags that indicate which surface/volume elements are present
    hastri   = isfield(mesh, 'tri');  % triangles   as a Mx3 matrix with vertex indices
    hastet   = isfield(mesh, 'tet');  % tetraheders as a Mx4 matrix with vertex indices
    hashex   = isfield(mesh, 'hex');  % hexaheders  as a Mx8 matrix with vertex indices
end

% convert string into boolean values
faceindex   = istrue(faceindex);   % yes=view the face number
vertexindex = istrue(vertexindex); % yes=view the vertex number

if isempty(vertexcolor)
    if haspos && hascolor && (hastri || hastet || hashex || hasline || haspoly)
        vertexcolor = mesh.color;
    elseif haspos && (hastri || hastet || hashex || hasline || haspoly)
        vertexcolor ='none';
    else
        vertexcolor ='k';
    end
end

% there are various ways of specifying that this should not be plotted
if isequal(vertexcolor, 'false') || isequal(vertexcolor, 'no') || isequal(vertexcolor, 'off') || isequal(vertexcolor, false)
    vertexcolor = 'none';
end
if isequal(facecolor, 'false') || isequal(facecolor, 'no') || isequal(facecolor, 'off') || isequal(facecolor, false)
    facecolor = 'none';
end
if isequal(edgecolor, 'false') || isequal(edgecolor, 'no') || isequal(edgecolor, 'off') || isequal(edgecolor, false)
    edgecolor = 'none';
end

% color management
if ischar(vertexcolor) && exist([vertexcolor '.m'], 'file')
    vertexcolor = eval(vertexcolor);
elseif ischar(vertexcolor) && isequal(vertexcolor, 'curv') % default of ft_sourceplot method surface
    if isfield(mesh, 'curv')
        cortex_light = eval('cortex_light');
        cortex_dark  = eval('cortex_dark');
        % the curvature determines the color of gyri and sulci
        vertexcolor = mesh.curv(:) * cortex_dark + (1-mesh.curv(:)) * cortex_light;
    else
        cortex_light = eval('cortex_light');
        vertexcolor = repmat(cortex_light, size(mesh.pos,1), 1);
        ft_warning('no curv field present in the mesh structure, using cortex_light as vertexcolor')
    end
end
if ischar(facecolor) && exist([facecolor '.m'], 'file')
    facecolor = eval(facecolor);
end
if ischar(edgecolor) && exist([edgecolor '.m'], 'file')
    edgecolor = eval(edgecolor);
end

% everything is added to the current figure
holdflag = ishold;
if ~holdflag
    hold on
end

if isfield(mesh, 'pos')
    % this is assumed to reflect 3-D vertices
    pos = mesh.pos;
elseif isfield(mesh, 'prj')
    % this happens sometimes if the 3-D vertices are projected to a 2-D plane
    pos = mesh.prj;
else
    ft_error('no vertices found');
end

if isempty(pos)
    hs=[];
    return
end

if hastri+hastet+hashex+hasline+haspoly>1
    ft_error('cannot deal with simultaneous triangles, tetraheders and/or hexaheders')
end

if hastri
    tri = mesh.tri;
elseif haspoly
    % these are treated just like triangles
    tri = mesh.poly;
elseif hastet
    % represent the tetraeders as the four triangles
    tri = [
        mesh.tet(:,[1 2 3]);
        mesh.tet(:,[2 3 4]);
        mesh.tet(:,[3 4 1]);
        mesh.tet(:,[4 1 2])];
    % or according to SimBio:  (1 2 3), (2 4 3), (4 1 3), (1 4 2)
    % there are shared triangles between neighbouring tetraeders, remove these
    tri = unique(tri, 'rows');
elseif hashex
    % represent the hexaheders as a collection of 6 patches
    tri = [
        mesh.hex(:,[1 2 3 4]);
        mesh.hex(:,[5 6 7 8]);
        mesh.hex(:,[1 2 6 5]);
        mesh.hex(:,[2 3 7 6]);
        mesh.hex(:,[3 4 8 7]);
        mesh.hex(:,[4 1 5 8]);
        ];
    % there are shared faces between neighbouring hexaheders, remove these
    tri = unique(tri, 'rows');
else
    tri = [];
end

if hasline
    line = mesh.line;
else
    line = [];
end

if haspos
    if ~isempty(tri)
        hs = patch('Vertices', pos, 'Faces', tri);
    elseif ~isempty(line)
        hs = patch('Vertices', pos, 'Faces', line);
    else
        hs = patch('Vertices', pos, 'Faces', []);
    end
    %set(hs, 'FaceColor', facecolor);
    set(hs, 'EdgeColor', edgecolor);
    set(hs, 'tag', tag);
end

% the vertexcolor can be specified either as a RGB color for each vertex, or as a single value at each vertex
% the facecolor can be specified either as a RGB color for each triangle, or as a single value at each triangle
% if there are triangles, the vertexcolor is used for linear interpolation over the patches
vertexpotential = ~isempty(tri) && ~ischar(vertexcolor) && (size(pos,1)==numel(vertexcolor) || size(pos,1)==size(vertexcolor,1) && (size(vertexcolor,2)==1 || size(vertexcolor,2)==3));
facepotential   = ~isempty(tri) && ~ischar(facecolor  ) && (size(tri,1)==numel(facecolor  ) || size(tri,1)==size(facecolor  ,1) && (size(facecolor  ,2)==1 || size(facecolor,  2)==3));

switch maskstyle
    case 'opacity'
        % if both vertexcolor and facecolor are numeric arrays, let the vertexcolor prevail
        if vertexpotential
            % vertexcolor is an array with number of elements equal to the number of vertices
            set(hs, 'FaceVertexCData', vertexcolor, 'FaceColor', 'interp');
            if numel(vertexcolor)==size(pos,1)
                if ~isempty(clim), set(gca, 'clim', clim); end
                if ~isempty(cmap), colormap(cmap); end
            end
        elseif facepotential
            set(hs, 'FaceVertexCData', facecolor, 'FaceColor', 'flat');
            if numel(facecolor)==size(tri,1)
                if ~isempty(clim), set(gca, 'clim', clim); end
                if ~isempty(cmap), colormap(cmap); end
            end
        else
            % the color is indicated as a single character or as a single RGB triplet
            set(hs, 'FaceColor', facecolor);
        end
        
        % facealpha is a scalar, or an vector matching the number of vertices
        if size(pos,1)==numel(facealpha)
            set(hs, 'FaceVertexAlphaData', facealpha);
            set(hs, 'FaceAlpha', 'interp');
        elseif ~isempty(pos) && numel(facealpha)==1 && facealpha~=1
            % the default is 1, so that does not have to be set
            set(hs, 'FaceAlpha', facealpha);
        end
        
        if edgealpha~=1
            % the default is 1, so that does not have to be set
            set(hs, 'EdgeAlpha', edgealpha);
        end
        
        if ~(all(facealpha==1) && edgealpha==1)
            if ~isempty(alphalim)
                alim(gca, alphalim);
            end
            alphamap(alphamapping);
        end
        
    case 'colormix'
        % ensure facecolor to be 1x3
        assert(isequal(size(facecolor),[1 3]), 'facecolor should be 1x3');
        
        % ensure facealpha to be nvertex x 1
        if numel(facealpha)==1
            facealpha = repmat(facealpha, size(pos,1), 1);
        end
        assert(isequal(numel(facealpha),size(pos,1)), 'facealpha should be %dx1', size(pos,1));
        
        bgcolor = repmat(facecolor, [numel(vertexcolor) 1]);
        rgb     = bg_rgba2rgb(bgcolor, vertexcolor, cmap, clim, facealpha, alphamapping, alphalim);
        set(hs, 'FaceVertexCData', rgb, 'facecolor', 'interp');
        if ~isempty(clim); caxis(clim); end % set colorbar scale to match [fcolmin fcolmax]
end

if faceindex
    % plot the triangle indices (numbers) at each face
    for face_indx=1:size(tri,1)
        str = sprintf('%d', face_indx);
        tri_x = (pos(tri(face_indx,1), 1) +  pos(tri(face_indx,2), 1) +  pos(tri(face_indx,3), 1))/3;
        tri_y = (pos(tri(face_indx,1), 2) +  pos(tri(face_indx,2), 2) +  pos(tri(face_indx,3), 2))/3;
        tri_z = (pos(tri(face_indx,1), 3) +  pos(tri(face_indx,2), 3) +  pos(tri(face_indx,3), 3))/3;
        h   = text(tri_x, tri_y, tri_z, str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        hs  = [hs; h];
    end
end

if ~isequal(vertexcolor, 'none') && ~vertexpotential
    % plot the vertices as points
    
    if isempty(vertexcolor)
        % use black for all points
        if isscalar(vertexsize)
            if size(pos,2)==2
                hnode = plot(pos(:,1), pos(:,2), ['k' vertexmarker]);
            else
                hnode = plot3(pos(:,1), pos(:,2), pos(:,3), ['k' vertexmarker]);
            end
            set(hnode, 'MarkerSize', vertexsize);
        else
            if size(pos,2)==2
                for i=1:size(pos,1)
                    hnode = plot(pos(i,1), pos(i,2), ['k' vertexmarker]);
                    set(hnode, 'MarkerSize', vertexsize(i));
                end
            else
                for i=1:size(pos,1)
                    hnode = plot3(pos(i,1), pos(i,2), pos(i,3), ['k' vertexmarker]);
                    set(hnode, 'MarkerSize', vertexsize(i));
                end
            end
        end
        
    elseif ischar(vertexcolor) && numel(vertexcolor)==1
        % one color for all points
        if isscalar(vertexsize)
            if size(pos,2)==2
                hnode = plot(pos(:,1), pos(:,2), [vertexcolor vertexmarker]);
            else
                hnode = plot3(pos(:,1), pos(:,2), pos(:,3), [vertexcolor vertexmarker]);
            end
            set(hnode, 'MarkerSize', vertexsize);
        else
            if size(pos,2)==2
                for i=1:size(pos,1)
                    hnode = plot(pos(i,1), pos(i,2), [vertexcolor vertexmarker]);
                    set(hnode, 'MarkerSize', vertexsize(i));
                end
            else
                for i=1:size(pos,1)
                    hnode = plot3(pos(i,1), pos(i,2), pos(i,3), [vertexcolor vertexmarker]);
                    set(hnode, 'MarkerSize', vertexsize(i));
                end
            end
        end
        
    elseif ischar(vertexcolor) && numel(vertexcolor)==size(pos,1)
        % one color for each point
        if size(pos,2)==2
            for i=1:size(pos,1)
                hnode = plot(pos(i,1), pos(i,2), [vertexcolor(i) vertexmarker]);
                if isscalar(vertexsize)
                    set(hnode, 'MarkerSize', vertexsize);
                else
                    set(hnode, 'MarkerSize', vertexsize(i));
                end
            end
        else
            for i=1:size(pos,1)
                hnode = plot3(pos(i,1), pos(i,2), pos(i,3), [vertexcolor(i) vertexmarker]);
                if isscalar(vertexsize)
                    set(hnode, 'MarkerSize', vertexsize);
                else
                    set(hnode, 'MarkerSize', vertexsize(i));
                end
            end
        end
        
    elseif ~ischar(vertexcolor) && size(vertexcolor,1)==1
        % one RGB color for all points
        if size(pos,2)==2
            hnode = plot(pos(:,1), pos(:,2), vertexmarker);
            set(hnode, 'MarkerSize', vertexsize, 'MarkerEdgeColor', vertexcolor);
        else
            hnode = plot3(pos(:,1), pos(:,2), pos(:,3), vertexmarker);
            set(hnode, 'MarkerSize', vertexsize, 'MarkerEdgeColor', vertexcolor);
        end
        
    elseif ~ischar(vertexcolor) && size(vertexcolor,1)==size(pos,1) && size(vertexcolor,2)==3
        % one RGB color for each point
        if size(pos,2)==2
            for i=1:size(pos,1)
                hnode = plot(pos(i,1), pos(i,2), vertexmarker);
                if isscalar(vertexsize)
                    set(hnode, 'MarkerSize', vertexsize, 'MarkerEdgeColor', vertexcolor(i,:));
                else
                    set(hnode, 'MarkerSize', vertexsize(i), 'MarkerEdgeColor', vertexcolor(i,:));
                end
            end
        else
            for i=1:size(pos,1)
                hnode = plot3(pos(i,1), pos(i,2), pos(i,3), vertexmarker);
                if isscalar(vertexsize)
                    set(hnode, 'MarkerSize', vertexsize, 'MarkerEdgeColor', vertexcolor(i,:));
                else
                    set(hnode, 'MarkerSize', vertexsize(i), 'MarkerEdgeColor', vertexcolor(i,:));
                end
            end
        end
        
    else
        ft_error('Unknown color specification for the vertices');
    end
    
end % plotting the vertices as points


if vertexindex
    % plot the vertex indices (numbers) at each node
    for node_indx=1:size(pos,1)
        str = sprintf('%d', node_indx);
        if size(pos, 2)==2
            h = text(pos(node_indx, 1), pos(node_indx, 2), str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        else
            h = text(pos(node_indx, 1), pos(node_indx, 2), pos(node_indx, 3), str, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
        end
        hnode = [hnode; h];
    end
end

if exist('hnode', 'var')
    hs = [hs; hnode];
end

% axis off % FARDIN ADDED
axis vis3d
axis equal

if ~nargout
    clear hs
end
if ~holdflag
    hold off
end

warning(ws); % revert to original state

function mesh = fixpos(mesh, recurse)

% FIXPOS helper function to ensure that meshes are described properly

if nargin==1
    recurse = 1;
end

if isa(mesh, 'delaunayTriangulation')
    % convert to structure, otherwise the code below won't work properly
    ws = warning('off', 'MATLAB:structOnObject');
    mesh = struct(mesh);
    ft_warning(ws);
end

if ~isa(mesh, 'struct')
    return;
end

if numel(mesh)>1
    % loop over all individual elements
    clear tmp
    for i=1:numel(mesh)
        % this is to prevent an "Subscripted assignment between dissimilar structures" error
        tmp(i) = fixpos(mesh(i));
    end
    mesh = tmp;
    clear tmp
    return
end

% convert from MATLAB delaunayTriangulation output to FieldTrip convention
if isfield(mesh, 'Points') && isfield(mesh, 'ConnectivityList')
    mesh.pos = mesh.Points;
    switch size(mesh.ConnectivityList,2)
        case 2
            mesh.edge = mesh.ConnectivityList;
        case 3
            mesh.tri = mesh.ConnectivityList;
        case 4
            mesh.tet = mesh.ConnectivityList;
        case 8
            mesh.hex = mesh.ConnectivityList;
        otherwise
            ft_error('unsupported ConnectivityList')
    end % switch
    mesh = removefields(mesh, {'Points', 'ConnectivityList', 'Constraints', 'UnderlyingObj'});
end

% convert from BrainStorm/MNE to FieldTrip convention
if isfield(mesh, 'vertices') && isfield(mesh, 'faces')
    mesh.pos = mesh.vertices;
    mesh.tri = mesh.faces;
    mesh = rmfield(mesh, {'faces', 'vertices'});
elseif isfield(mesh, 'Vertices') && isfield(mesh, 'Faces')
    mesh.pos = mesh.Vertices;
    mesh.tri = mesh.Faces;
    mesh = rmfield(mesh, {'Faces', 'Vertices'});
end

% replace pnt by pos
if isfield(mesh, 'pnt')
    mesh.pos = mesh.pnt;
    mesh = rmfield(mesh, 'pnt');
end

if recurse<3
    % recurse into substructures, not too deep
    fn = fieldnames(mesh);
    fn = setdiff(fn, {'cfg'}); % don't recurse into the cfg structure
    for i=1:length(fn)
        if isstruct(mesh.(fn{i}))
            mesh.(fn{i}) = fixpos(mesh.(fn{i}), recurse+1);
        end
    end
end

function hs = ft_plot_sens_mod(sens, varargin)

% FT_PLOT_SENS visualizes the EEG, MEG or NIRS sensor array.
%
% Use as
%   ft_plot_sens(sens, ...)
% where the first argument is the sensor array as returned by FT_READ_SENS or
% by FT_PREPARE_VOL_SENS.
%
% Optional input arguments should come in key-value pairs and can include
%   'label'           = show the label, can be 'off', 'label', 'number' (default = 'off')
%   'chantype'        = string or cell-array with strings, for example 'meg' (default = 'all')
%   'unit'            = string, convert the sensor array to the specified geometrical units (default = [])
%   'fontcolor'       = string, color specification (default = 'k')
%   'fontsize'        = number, sets the size of the text (default = 10)
%   'fontunits'       =
%   'fontname'        =
%   'fontweight'      =
%
% The following options apply to MEG magnetometers and/or gradiometers
%   'coil'            = true/false, plot each individual coil (default = false)
%   'orientation'     = true/false, plot a line for the orientation of each coil (default = false)
%   'coilshape'       = 'point', 'circle', 'square', or 'sphere' (default is automatic)
%   'coilsize'        = diameter or edge length of the coils (default is automatic)
% The following options apply to EEG electrodes
%   'elec'            = true/false, plot each individual electrode (default = false)
%   'elecshape'       = 'point', 'circle', 'square', or 'sphere' (default is automatic)
%   'elecsize'        = diameter of the electrodes (default is automatic)
% The following options apply to NIRS optodes
%   'opto'            = true/false, plot each individual optode (default = false)
%   'optoshape'       = 'point', 'circle', 'square', or 'sphere' (default is automatic)
%   'optosize'        = diameter of the optodes (default is automatic)
%
% The following options apply when electrodes/coils/optodes are NOT plotted individually
%   'style'           = plotting style for the points representing the channels, see plot3 (default = [])
%   'marker'          = marker type representing the channels, see plot3 (default = '.')
% The following options apply when electrodes/coils/optodes are plotted individually
%   'facecolor'       = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r', or an Nx3 or Nx1 array where N is the number of faces (default is automatic)
%   'edgecolor'       = [r g b] values or string, for example 'brain', 'cortex', 'skin', 'black', 'red', 'r', color of channels or coils (default is automatic)
%   'facealpha'       = transparency, between 0 and 1 (default = 1)
%   'edgealpha'       = transparency, between 0 and 1 (default = 1)
%
% Example
%   sens = ft_read_sens('Subject01.ds');
%   figure; ft_plot_sens(sens, 'coilshape', 'point', 'style', 'r*')
%   figure; ft_plot_sens(sens, 'coilshape', 'circle')
%   figure; ft_plot_sens(sens, 'coilshape', 'circle', 'coil', true, 'chantype', 'meggrad')
%   figure; ft_plot_sens(sens, 'coilshape', 'circle', 'coil', false, 'orientation', true)
%
% See also FT_READ_SENS, FT_PLOT_HEADSHAPE, FT_PLOT_VOL

% Copyright (C) 2009-2016, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

ws = warning('on', 'MATLAB:divideByZero');

% ensure that the sensor description is up-to-date
sens = ft_datatype_sens(sens);

% get the optional input arguments
label           = ft_getopt(varargin, 'label', 'off');
chantype        = ft_getopt(varargin, 'chantype');
unit            = ft_getopt(varargin, 'unit');
orientation     = ft_getopt(varargin, 'orientation', false);
% these have to do with the font
fontcolor       = ft_getopt(varargin, 'fontcolor', 'k'); % default is black
fontsize        = ft_getopt(varargin, 'fontsize',   get(0, 'defaulttextfontsize'));
fontname        = ft_getopt(varargin, 'fontname',   get(0, 'defaulttextfontname'));
fontweight      = ft_getopt(varargin, 'fontweight', get(0, 'defaulttextfontweight'));
fontunits       = ft_getopt(varargin, 'fontunits',  get(0, 'defaulttextfontunits'));

% this is for MEG magnetometer and/or gradiometer arrays
coil            = ft_getopt(varargin, 'coil', false);
coilshape       = ft_getopt(varargin, 'coilshape'); % default depends on the input, see below
coilsize        = ft_getopt(varargin, 'coilsize');  % default depends on the input, see below
% this is for EEG electrode arrays
elec            = ft_getopt(varargin, 'elec', false);
elecshape       = ft_getopt(varargin, 'elecshape'); % default depends on the input, see below
elecsize        = ft_getopt(varargin, 'elecsize');  % default depends on the input, see below
% this is for NIRS optode arrays
opto            = ft_getopt(varargin, 'opto', false);
optoshape       = ft_getopt(varargin, 'optoshape'); % default depends on the input, see below
optosize        = ft_getopt(varargin, 'optosize');  % default depends on the input, see below

% make sure that the options are consistent with the data
if     ft_senstype(sens, 'eeg')
    individual = elec;
    sensshape  = elecshape;
    sensize    = elecsize;
elseif ft_senstype(sens, 'meg')
    individual = coil;
    sensshape  = coilshape;
    sensize    = coilsize;
elseif ft_senstype(sens, 'nirs')
    % this has not been tested
    individual = opto;
    sensshape  = optoshape;
    sensize    = optosize;
else
    ft_warning('unknown sensor array description');
    individual = false;
    sensshape  = [];
    sensize    = [];
end

% this is simply passed to plot3
style           = ft_getopt(varargin, 'style');
marker          = ft_getopt(varargin, 'marker', '.');

% this is simply passed to ft_plot_mesh
if strcmp(sensshape, 'sphere')
    edgecolor     = ft_getopt(varargin, 'edgecolor', 'none');
else
    edgecolor     = ft_getopt(varargin, 'edgecolor', 'g'); % ft_getopt(varargin, 'edgecolor', 'k');
end
facecolor       = ft_getopt(varargin, 'facecolor');  % default depends on the input, see below
facealpha       = ft_getopt(varargin, 'facealpha',   1);
edgealpha       = ft_getopt(varargin, 'edgealpha',   1);

if ischar(chantype)
    % this should be a cell array
    chantype = {chantype};
end

if ~isempty(ft_getopt(varargin, 'coilorientation'))
    % for backward compatibility, added on 17 Aug 2016
    ft_warning('the coilorientation option is deprecated, please use "orientation" instead')
    orientation = ft_getopt(varargin, 'coilorientation');
end

if ~isempty(ft_getopt(varargin, 'coildiameter'))
    % for backward compatibility, added on 6 July 2016
    % the sensize is the diameter for a circle, or the edge length for a square
    ft_warning('the coildiameter option is deprecated, please use "coilsize" instead')
    sensize = ft_getopt(varargin, 'coildiameter');
end

if ~isempty(unit)
    % convert the sensor description to the specified units
    sens = ft_convert_units(sens, unit);
end

if isempty(sensshape)
    if ft_senstype(sens, 'neuromag')
        if strcmp(chantype, 'megmag')
            sensshape = 'point'; % these cannot be plotted as squares
        else
            sensshape = 'square';
        end
    elseif ft_senstype(sens, 'meg')
        sensshape = 'circle';
    else
        sensshape = 'point';
    end
end

if isempty(sensize)
    switch ft_senstype(sens)
        case 'neuromag306'
            sensize = 30; % FIXME this is only an estimate
        case 'neuromag122'
            sensize = 35; % FIXME this is only an estimate
        case 'ctf151'
            sensize = 15; % FIXME this is only an estimate
        case 'ctf275'
            sensize = 15; % FIXME this is only an estimate
        otherwise
            if strcmp(sensshape, 'sphere')
                sensize = 4; % assuming spheres are used for intracranial electrodes, diameter is about 4mm
            elseif strcmp(sensshape, 'point')
                sensize = 30;
            else
                sensize = 10;
            end
    end
    % convert from mm to the units of the sensor array
    sensize = sensize/ft_scalingfactor(sens.unit, 'mm');
end

% color management
if isempty(facecolor) % set default color depending on shape
    if strcmp(sensshape, 'point')
        facecolor = 'k';
    elseif strcmp(sensshape, 'circle') || strcmp(sensshape, 'square')
        facecolor = 'g'; %'none'; % MODIFIED
    elseif strcmp(sensshape, 'sphere')
        facecolor = 'b';
    end
end
if ischar(facecolor) && exist([facecolor '.m'], 'file')
    facecolor = eval(facecolor);
end
if ischar(edgecolor) && exist([edgecolor '.m'], 'file')
    edgecolor = eval(edgecolor);
end

% select a subset of channels and coils to be plotted
if ~isempty(chantype)
    % remove the balancing from the sensor definition, e.g. 3rd order gradients, PCA-cleaned data or ICA projections
    sens = undobalancing(sens);
    
    chansel = match_str(sens.chantype, chantype);
    
    % remove the channels that are not selected
    sens.label    = sens.label(chansel);
    sens.chanpos  = sens.chanpos(chansel,:);
    sens.chantype = sens.chantype(chansel);
    sens.chanunit = sens.chanunit(chansel);
    if isfield(sens, 'chanori')
        % this is only present for MEG sensor descriptions
        sens.chanori  = sens.chanori(chansel,:);
    end
    
    % remove the magnetometer and gradiometer coils that are not in one of the selected channels
    if isfield(sens, 'tra') && isfield(sens, 'coilpos')
        sens.tra     = sens.tra(chansel,:);
        coilsel      = any(sens.tra~=0,1);
        sens.coilpos = sens.coilpos(coilsel,:);
        sens.coilori = sens.coilori(coilsel,:);
        sens.tra     = sens.tra(:,coilsel);
    end
    
    % FIXME note that I have not tested this on any complicated electrode definitions
    % remove the electrodes that are not in one of the selected channels
    if isfield(sens, 'tra') && isfield(sens, 'elecpos')
        sens.tra     = sens.tra(chansel,:);
        elecsel      = any(sens.tra~=0,1);
        sens.elecpos = sens.elecpos(elecsel,:);
        sens.tra     = sens.tra(:,elecsel);
    end
    
end % selecting channels and coils

% everything is added to the current figure
holdflag = ishold;
if ~holdflag
    hold on
end

if istrue(orientation)
    if istrue(individual)
        if isfield(sens, 'coilori')
            pos = sens.coilpos;
            ori = sens.coilori;
        elseif isfield(sens, 'elecori')
            pos = sens.elecpos;
            ori = sens.elecori;
        else
            pos = [];
            ori = [];
        end
    else
        if isfield(sens, 'chanori')
            pos = sens.chanpos;
            ori = sens.chanori;
        else
            pos = [];
            ori = [];
        end
    end
    scale = ft_scalingfactor('mm', sens.unit)*20; % draw a line segment of 20 mm
    for i=1:size(pos,1)
        x = [pos(i,1) pos(i,1)+ori(i,1)*scale];
        y = [pos(i,2) pos(i,2)+ori(i,2)*scale];
        z = [pos(i,3) pos(i,3)+ori(i,3)*scale];
        line(x, y, z)
    end
end

if istrue(individual)
    % simply get the position of all individual coils or electrodes
    if isfield(sens, 'coilpos')
        pos = sens.coilpos;
    elseif isfield(sens, 'elecpos')
        pos = sens.elecpos;
    end
    if isfield(sens, 'coilori')
        ori = sens.coilori;
    elseif isfield(sens, 'elecori')
        ori = sens.elecori;
    else
        ori = [];
    end
    
else
    % determine the position of each channel, which is for example the mean of
    % two bipolar electrodes, or the bottom coil of a axial gradiometer, or
    % the center between two coils of a planar gradiometer
    if isfield(sens, 'chanpos')
        pos = sens.chanpos;
    else
        pos = [];
    end
    if isfield(sens, 'chanori')
        ori = sens.chanori;
    else
        ori = [];
    end
    
end % if istrue(individual)

switch sensshape
    case 'point'
        if ~isempty(style)
            % the style can include the color and/or the shape of the marker
            % check whether the marker shape is specified
            possible = {'+', 'o', '*', '.', 'x', 'v', '^', '>', '<', 'square', 'diamond', 'pentagram', 'hexagram'};
            specified = false(size(possible));
            for i=1:numel(possible)
                specified(i) = ~isempty(strfind(style, possible{i}));
            end
            if any(specified)
                % the marker shape is specified in the style option
                hs = plot3(pos(:,1), pos(:,2), pos(:,3), style, 'MarkerSize', sensize);
            else
                % the marker shape is not specified in the style option, use the marker option instead and assume that the style option represents the color
                hs = plot3(pos(:,1), pos(:,2), pos(:,3), 'Marker', marker, 'MarkerSize', sensize, 'Color', style, 'Linestyle', 'none');
            end
        else
            % the style is not specified, use facecolor for the marker
            hs = plot3(pos(:,1), pos(:,2), pos(:,3), 'Marker', marker, 'MarkerSize', sensize, 'Color', facecolor, 'Linestyle', 'none');
        end
        
    case 'circle'
        hcoil = plotcoil(pos, ori, [], sensize, sensshape, 'edgecolor', edgecolor, 'facecolor', facecolor, 'edgealpha', edgealpha, 'facealpha', facealpha); % hcoil WAS ADDED
        
    case 'square'
        % determine the rotation-around-the-axis of each sensor
        % only applicable for neuromag planar gradiometers
        if ft_senstype(sens, 'neuromag')
            [nchan, ncoil] = size(sens.tra);
            chandir = nan(nchan,3);
            for i=1:nchan
                poscoil = find(sens.tra(i,:)>0);
                negcoil = find(sens.tra(i,:)<0);
                if numel(poscoil)==1 && numel(negcoil)==1
                    % planar gradiometer
                    direction = sens.coilpos(poscoil,:)-sens.coilpos(negcoil,:);
                    direction = direction/norm(direction);
                    chandir(i,:) = direction;
                elseif (numel([poscoil negcoil]))==1
                    % magnetometer
                elseif numel(poscoil)>1 || numel(negcoil)>1
                    ft_error('cannot work with balanced gradiometer definition')
                end
            end
        else
            chandir = [];
        end
        
        plotcoil(pos, ori, chandir, sensize, sensshape, 'edgecolor', edgecolor, 'facecolor', facecolor, 'edgealpha', edgealpha, 'facealpha', facealpha);
        
    case 'sphere'
        [xsp, ysp, zsp] = sphere(100);
        rsp = sensize/2; % convert coilsensize from diameter to radius
        hold on
        for i=1:size(pos,1)
            hs = surf(rsp*xsp+pos(i,1), rsp*ysp+pos(i,2), rsp*zsp+pos(i,3));
            set(hs, 'EdgeColor', edgecolor, 'FaceColor', facecolor, 'EdgeAlpha', edgealpha, 'FaceAlpha', facealpha);
        end
        
    otherwise
        ft_error('incorrect shape');
end % switch

if ~isempty(label) && ~any(strcmp(label, {'off', 'no'}))
    htxt = []; % ADDED
    for i=1:length(sens.label)
        switch label
            case {'on', 'yes'}
                str = sens.label{i};
            case {'label' 'labels'}
                str = sens.label{i};
            case {'number' 'numbers'}
                str = num2str(i);
            otherwise
                ft_error('unsupported value for option ''label''');
        end % switch
        if isfield(sens, 'chanori')
            % shift the labels along the channel orientation, which is presumably orthogonal to the scalp
            ori = sens.chanori(i,:);
        else
            % shift the labels away from the origin of the coordinate system
            ori = sens.chanpos(i,:) / norm(sens.chanpos(i,:));
        end
        % shift the label 5 mm
        x = sens.chanpos(i,1) + 5 * ft_scalingfactor('mm', sens.unit) * ori(1);
        y = sens.chanpos(i,2) + 5 * ft_scalingfactor('mm', sens.unit) * ori(2);
        z = sens.chanpos(i,3) + 5 * ft_scalingfactor('mm', sens.unit) * ori(3);
        htxti = text(x, y, z, str, 'color', fontcolor, 'fontunits', fontunits, 'fontsize', fontsize, 'fontname', fontname, 'fontweight', fontweight, 'horizontalalignment', 'center', 'verticalalignment', 'middle'); % htxt WAS ADDED
        htxt = [htxt; htxti]; % ADDED
    end % for each channel
end % if label

axis vis3d
axis equal

if ~nargout
    clear hs
end
if ~holdflag
    hold off
end

if ft_senstype(sens, 'meg') % exist('hs', 'var') % ADDED
    hs = [hcoil; htxt]; % ADDED
elseif ft_senstype(sens, 'eeg')
    hs = [hs; htxt]; % ADDED
end   % ADDED

warning(ws); % revert to original state

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION all optional inputs are passed to ft_plot_mesh
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'%%%%%%%%%%%%%%%%%%
function h = plotcoil(coilpos, coilori, chandir, coilsize, coilshape, varargin) % h WAS ADDED

% start with a single template coil at [0 0 0], oriented towards [0 0 1]
switch coilshape
    case 'circle'
        pos = circle(24);
    case 'square'
        pos = square;
end
ncoil = size(coilpos,1);
npos  = size(pos,1);
mesh.pos  = nan(ncoil*npos,3);
mesh.poly = nan(ncoil, npos);

% determine the scaling of the coil as homogenous transformation matrix
s  = scale([coilsize coilsize coilsize]);

for i=1:ncoil
    x  = coilori(i,1);
    y  = coilori(i,2);
    z  = coilori(i,3);
    ph = atan2(y, x)*180/pi;
    th = atan2(sqrt(x^2+y^2), z)*180/pi;
    % determine the rotation and translation of the coil as homogenous transformation matrix
    r1 = rotate([0 th 0]);
    r2 = rotate([0 0 ph]);
    t  = translate(coilpos(i,:));
    
    % determine the initial rotation of the coil as homogenous transformation matrix
    if isempty(chandir)
        % none of the coils needs to be rotated around their axis, this applies to circular coils
        r0 = eye(4);
    elseif ~all(isfinite(chandir(i,:)))
        % the rotation around the axis of this coil is not known
        r0 = nan(4);
    else
        % express the direction of sensitivity of the planar channel relative to the orientation of the channel
        dir = ft_warp_apply(inv(r2*r1), chandir(i,:));
        x = dir(1);
        y = dir(2);
        % determine the rotation
        rh = atan2(y, x)*180/pi;
        r0 = rotate([0 0 rh]);
    end
    
    % construct a single mesh with separate polygons for all coils
    sel = ((i-1)*npos+1):(i*npos);
    mesh.pos(sel,:) = ft_warp_apply(t*r2*r1*r0*s, pos); % scale, rotate and translate the template coil vertices, skip the central vertex
    mesh.poly(i,:)  = sel;                              % this is a polygon connecting all edge points
    
end
% plot all polygons together
h = ft_plot_mesh(mesh, varargin{:}); % h WAS ADDED

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION return a circle with unit diameter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pos] = circle(n)
phi = linspace(0, 2*pi, n+1)';
x = cos(phi);
y = sin(phi);
z = zeros(size(phi));
pos = [x y z]/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SUBFUNCTION return a square with unit edges
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [pos] = square
pos = [
    0.5  0.5 0
    -0.5  0.5 0
    -0.5 -0.5 0
    0.5 -0.5 0
    0.5  0.5 0 % this closes the square
    ];

function [H] = scale(f)

% SCALE returns the homogenous coordinate transformation matrix
% corresponding to a scaling along the x, y and z-axis
%
% Use as
%   [H] = translate(S)
% where
%   S       [sx, sy, sz] scaling along each of the axes
%   H   corresponding homogenous transformation matrix

% Copyright (C) 2000-2005, Robert Oostenveld
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if numel(f)~=3
    ft_error('incorrect input vector');
end

H = [
    f(1) 0    0    0
    0    f(2) 0    0
    0    0    f(3) 0
    0    0    0    1
    ];

function [H] = rotate(f)

% ROTATE returns the homogenous coordinate transformation matrix
% corresponding to a rotation around the x, y and z-axis. The direction of
% the rotation is according to the right-hand rule.
%
% Use as
%   [H] = rotate(R)
% where
%   R       [rx, ry, rz] in degrees
%   H       corresponding homogenous transformation matrix
%
% Note that the order in which the rotations are performs matters. The
% rotation is first done around the z-axis, then the y-axis and finally the
% x-axis.

% Copyright (C) 2000-2005, Robert Oostenveld
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if numel(f)~=3
    ft_error('incorrect input vector');
end

% convert degrees to radians
f = f*pi/180;

% get the individual angles (in radians)
rx = f(1);
ry = f(2);
rz = f(3);

% precompute the sin/cos values of the angles
cX = cos(rx);
cY = cos(ry);
cZ = cos(rz);
sX = sin(rx);
sY = sin(ry);
sZ = sin(rz);

% according to Roger Woods' http://bishopw.loni.ucla.edu/AIR5/homogenous.html
% it should be this, but I cannot reproduce his rotation matrix
% H = eye(4,4);
% H(1,1) = cZ*cY + sZ*sX*sY;
% H(1,2) = sZ*cY - cZ*sX*sY;
% H(1,3) =            cX*sY;
% H(2,1) = -sZ*cX;
% H(2,2) =  cZ*cX;
% H(2,3) =     sX;
% H(3,1) =  sZ*sX*cY - cZ*sY;
% H(3,2) = -cZ*sX*cY - sZ*sY;
% H(3,3) =             cX*cY;

% instead, the following rotation matrix does work according my
% expectations. It rotates according to the right hand rule and first
% rotates around z, then y and then x axis
H = [
    cZ*cY,          -sZ*cY,              sY,               0
    cZ*sY*sX+sZ*cX, -sZ*sY*sX+cZ*cX,          -cY*sX,               0
    -cZ*sY*cX+sZ*sX,  sZ*sY*cX+cZ*sX,           cY*cX,               0
    0,               0,               0,               1
    ];

if 0
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % The following code can be used to construct the combined rotation matrix
    % for either xyz or zyx ordering (using the MATLAB symbolic math toolbox)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    syms sX sY sZ cX cY cZ
    % this is for only rotating around x
    Rx = [
        1   0    0   0
        0   cX  -sX  0
        0   sX   cX  0
        0   0    0   1
        ];
    % this is for only rotating around y
    Ry = [
        cY  0   sY  0
        0   1   0   0
        -sY  0   cY  0
        0   0   0   1
        ];
    % this is for only rotating around z
    Rz = [
        cZ -sZ  0   0
        sZ  cZ  0   0
        0   0   1   0
        0   0   0   1
        ];
    % combine them
    Rzyx = Rz * Ry * Rx  % rotate around x, y, then z
    Rxyz = Rx * Ry * Rz  % rotate around z, y, then x
end

function [H] = translate(f)

% TRANSLATE returns the homogenous coordinate transformation matrix
% corresponding to a translation along the x, y and z-axis
%
% Use as
%   [H] = translate(T)
% where
%   T   [tx, ty, tz] translation along each of the axes
%   H   corresponding homogenous transformation matrix

% Copyright (C) 2000-2005, Robert Oostenveld
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if numel(f)~=3
    ft_error('incorrect input vector');
end

H = [
    1 0 0 f(1)
    0 1 0 f(2)
    0 0 1 f(3)
    0 0 0 1
    ];

function CurrentState = Freeze(h)
h = getparent(h);
opt = getappdata(h, 'opt');

Elements = {'pbMRI', 'cbMRI', 'cbFiducl', 'pbSegMRI', 'cbSegBrain', ...
    'cbSegSkull', 'cbSegScalp', 'cbSegWhite', 'cbSegGray', 'cbSegCSF', 'cbSegAll', ...
    'pbMesh', 'cbMeshBrain', 'cbMeshSkull', 'cbMeshScalp', 'cbMeshWhite', ...
    'cbMeshGray', 'cbMeshCSF', 'pbVol', 'cbVolEEG', 'cbVolMEG', ...
    'pbSrc', 'cbSrcWhite', 'cbSrcPial', 'cbSrcBetween', 'pbSns', 'cbSnsEEG', ...
    'cbSnsMEG', 'pbLF', 'pbFP', 'sEEGSourceUp', 'sEEGSourceLeft', 'sEEGSourceBottom', ...
    'txtEEGSourceUp', 'txtEEGSourceLeft', 'txtEEGSourceBottom', 'cbFPSource', ...
    'cbFPEEG', 'cbFPMEG', 'pbIP', 'cbIPDICSPowEEG', 'cbIPDICSPowMEG', 'cbIPLCMVPowEEG', ...
    'cbIPLCMVMomEEG', 'cbIPLCMVPowMEG', 'cbIPLCMVMomMEG', 'txtLCMVLabel', 'txtDICSLabel', ...
    'txtEEGLabel', 'txtMEGLabel'};

CurrentState = [];
for i = 1 : length(Elements)
    CurrentState.(Elements{i}) = get(opt.(Elements{i}), 'Enable');
end % for i = 1 : length(Elements)

for i = 1 : length(Elements)
    set(opt.(Elements{i}), 'Enable', 'off');
end % for i = 1 : length(Elements)
% set(opt.AxeEEGSource, 'Visible', 'off')
CurrentState.Elements = Elements;
setappdata(h, 'opt', opt);

function Recover(h, CurrentState)
h = getparent(h);
opt = getappdata(h, 'opt');

for i = 1 : length(CurrentState.Elements)
    set(opt.(CurrentState.Elements{i}), 'Enable', CurrentState.(CurrentState.Elements{i}));
end % for i = 1 : length(Elements)

% axes(opt.AxeEEGSource)
% view(opt.view)
setappdata(h, 'opt', opt);

function [dist,path] = dijkstra(nodes,segments,start_id,finish_id)
%DIJKSTRA Calculates the shortest distance and path between points on a map
%   using Dijkstra's Shortest Path Algorithm
%
% [DIST, PATH] = DIJKSTRA(NODES, SEGMENTS, SID, FID)
%   Calculates the shortest distance and path between start and finish nodes SID and FID
%
% [DIST, PATH] = DIJKSTRA(NODES, SEGMENTS, SID)
%   Calculates the shortest distances and paths from the starting node SID to all
%     other nodes in the map
%
% Note:
%     DIJKSTRA is set up so that an example is created if no inputs are provided,
%       but ignores the example and just processes the inputs if they are given.
%
% Inputs:
%     NODES should be an Nx3 or Nx4 matrix with the format [ID X Y] or [ID X Y Z]
%       where ID is an integer, and X, Y, Z are cartesian position coordinates)
%     SEGMENTS should be an Mx3 matrix with the format [ID N1 N2]
%       where ID is an integer, and N1, N2 correspond to node IDs from NODES list
%       such that there is an [undirected] edge/segment between node N1 and node N2
%     SID should be an integer in the node ID list corresponding with the starting node
%     FID (optional) should be an integer in the node ID list corresponding with the finish
%
% Outputs:
%     DIST is the shortest Euclidean distance
%       If FID was specified, DIST will be a 1x1 double representing the shortest
%         Euclidean distance between SID and FID along the map segments. DIST will have
%         a value of INF if there are no segments connecting SID and FID.
%       If FID was not specified, DIST will be a 1xN vector representing the shortest
%         Euclidean distance between SID and all other nodes on the map. DIST will have
%         a value of INF for any nodes that cannot be reached along segments of the map.
%     PATH is a list of nodes containing the shortest route
%       If FID was specified, PATH will be a 1xP vector of node IDs from SID to FID.
%         NAN will be returned if there are no segments connecting SID to FID.
%       If FID was not specified, PATH will be a 1xN cell of vectors representing the
%         shortest route from SID to all other nodes on the map. PATH will have a value
%         of NAN for any nodes that cannot be reached along the segments of the map.
%
% Example:
%     dijkstra; % calculates shortest path and distance between two nodes
%               % on a map of randomly generated nodes and segments
%
% Example:
%     nodes = [(1:10); 100*rand(2,10)]';
%     segments = [(1:17); floor(1:0.5:9); ceil(2:0.5:10)]';
%     figure; plot(nodes(:,2), nodes(:,3),'k.');
%     hold on;
%     for s = 1:17
%         if (s <= 10) text(nodes(s,2),nodes(s,3),[' ' num2str(s)]); end
%         plot(nodes(segments(s,2:3)',2),nodes(segments(s,2:3)',3),'k');
%     end
%     [d, p] = dijkstra(nodes, segments, 1, 10)
%     for n = 2:length(p)
%         plot(nodes(p(n-1:n),2),nodes(p(n-1:n),3),'r-.','linewidth',2);
%     end
%     hold off;
%
% Author: Joseph Kirk
% Email: jdkirk630 at gmail dot com
% Release: 1.3
% Release Date: 5/18/07

if (nargin < 3) % SETUP
    % (GENERATE RANDOM EXAMPLE OF NODES AND SEGMENTS IF NOT GIVEN AS INPUTS)
    % Create a random set of nodes/vertices,and connect some of them with
    % edges/segments. Then graph the resulting map.
    num_nodes = 40; L = 100; max_seg_length = 30; ids = (1:num_nodes)';
    nodes = [ids L*rand(num_nodes,2)]; % create random nodes
    h = figure; plot(nodes(:,2),nodes(:,3),'k.') % plot the nodes
    text(nodes(num_nodes,2),nodes(num_nodes,3),...
        [' ' num2str(ids(num_nodes))],'Color','b','FontWeight','b')
    hold on
    num_segs = 0; segments = zeros(num_nodes*(num_nodes-1)/2,3);
    for i = 1:num_nodes-1 % create edges between some of the nodes
        text(nodes(i,2),nodes(i,3),[' ' num2str(ids(i))],'Color','b','FontWeight','b')
        for j = i+1:num_nodes
            d = sqrt(sum((nodes(i,2:3) - nodes(j,2:3)).^2));
            if and(d < max_seg_length,rand < 0.6)
                plot([nodes(i,2) nodes(j,2)],[nodes(i,3) nodes(j,3)],'k.-')
                % add this link to the segments list
                num_segs = num_segs + 1;
                segments(num_segs,:) = [num_segs nodes(i,1) nodes(j,1)];
            end
        end
    end
    segments(num_segs+1:num_nodes*(num_nodes-1)/2,:) = [];
    axis([0 L 0 L])
    % Calculate Shortest Path Using Dijkstra's Algorithm
    % Get random starting/ending nodes,compute the shortest distance and path.
    start_id = ceil(num_nodes*rand); disp(['start id = ' num2str(start_id)]);
    finish_id = ceil(num_nodes*rand); disp(['finish id = ' num2str(finish_id)]);
    [distance,path] = dijkstra(nodes,segments,start_id,finish_id);
    disp(['distance = ' num2str(distance)]); disp(['path = [' num2str(path) ']']);
    % If a Shortest Path exists,Plot it on the Map.
    figure(h)
    for k = 2:length(path)
        m = find(nodes(:,1) == path(k-1));
        n = find(nodes(:,1) == path(k));
        plot([nodes(m,2) nodes(n,2)],[nodes(m,3) nodes(n,3)],'ro-','LineWidth',2);
    end
    title(['Shortest Distance from ' num2str(start_id) ' to ' ...
        num2str(finish_id) ' = ' num2str(distance)])
    hold off
    
else %--------------------------------------------------------------------------
    % MAIN FUNCTION - DIJKSTRA'S ALGORITHM
    
    % initializations
    node_ids = nodes(:,1);
    [num_map_pts,cols] = size(nodes);
    table = sparse(num_map_pts,2);
    shortest_distance = Inf(num_map_pts,1);
    settled = zeros(num_map_pts,1);
    path = num2cell(NaN(num_map_pts,1));
    col = 2;
    pidx = find(start_id == node_ids);
    shortest_distance(pidx) = 0;
    table(pidx,col) = 0;
    settled(pidx) = 1;
    path(pidx) = {start_id};
    if (nargin < 4) % compute shortest path for all nodes
        while_cmd = 'sum(~settled) > 0';
    else % terminate algorithm early
        while_cmd = 'settled(zz) == 0';
        zz = find(finish_id == node_ids);
    end
    while eval(while_cmd)
        % update the table
        table(:,col-1) = table(:,col);
        table(pidx,col) = 0;
        % find neighboring nodes in the segments list
        neighbor_ids = [segments(node_ids(pidx) == segments(:,2),3);
            segments(node_ids(pidx) == segments(:,3),2)];
        % calculate the distances to the neighboring nodes and keep track of the paths
        for k = 1:length(neighbor_ids)
            cidx = find(neighbor_ids(k) == node_ids);
            if ~settled(cidx)
                d = sqrt(sum((nodes(pidx,2:cols) - nodes(cidx,2:cols)).^2));
                if (table(cidx,col-1) == 0) || ...
                        (table(cidx,col-1) > (table(pidx,col-1) + d))
                    table(cidx,col) = table(pidx,col-1) + d;
                    tmp_path = path(pidx);
                    path(cidx) = {[tmp_path{1} neighbor_ids(k)]};
                else
                    table(cidx,col) = table(cidx,col-1);
                end
            end
        end
        % find the minimum non-zero value in the table and save it
        nidx = find(table(:,col));
        ndx = find(table(nidx,col) == min(table(nidx,col)));
        if isempty(ndx)
            break
        else
            pidx = nidx(ndx(1));
            shortest_distance(pidx) = table(pidx,col);
            settled(pidx) = 1;
        end
    end
    if (nargin < 4) % return the distance and path arrays for all of the nodes
        dist = shortest_distance';
        path = path';
    else % return the distance and path for the ending node
        dist = shortest_distance(zz);
        path = path(zz);
        path = path{1};
    end
end

function hs = ft_plot_topo3d_mod(pos, val, varargin)

% FT_PLOT_TOPO3D makes a 3-D topographic representation of the electric
% potential or field at the sensor locations
%
% Use as
%   ft_plot_topo3d(pos, val, ...);
% where the channel positions are given as a Nx3 matrix and the values are
% given as Nx1 vector.
%
% Optional input arguments should be specified in key-value pairs and can include
%   'contourstyle' = string, 'none', 'black', 'color' (default = 'none')
%   'isolines'     = vector with values at which to draw isocontours, or 'auto' (default = 'auto')
%   'facealpha'    = scalar, between 0 and 1 (default = 1)
%   'refine'       = scalar, number of refinement steps for the triangulation, to get a smoother interpolation (default = 0)
%
% See also FT_PLOT_TOPO, FT_TOPOPLOTER, FT_TOPOPLOTTFR

% Copyright (C) 2009-2015, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

ws = warning('on', 'MATLAB:divideByZero');

% get the optional input arguments
contourstyle  = ft_getopt(varargin, 'contourstyle', 'none');
nrefine       = ft_getopt(varargin, 'refine', 0);
isolines      = ft_getopt(varargin, 'isolines', 'auto');
topostyle     = ft_getopt(varargin, 'topostyle', 'color');  % FIXME what is the purpose of this option?
facealpha     = ft_getopt(varargin, 'facealpha', 1);

if islogical(contourstyle) && contourstyle==false
    % false was supported up to 18 November 2013, 'none' is more consistent with other plotting options
    contourstyle = 'none';
end

% everything is added to the current figure
holdflag = ishold;
if ~holdflag
    hold on
end

if size(val,2)==size(pos,1)
    val = val';
end

% the interpolation requires a triangulation
tri = projecttri(pos, 'delaunay');

if nrefine>0,
    posorig = pos;
    triorig = tri;
    valorig = val;
    for k = 1:nrefine
        [pos,tri] = refine(pos, tri);
    end
    prjorig = elproj(posorig);
    prj     = elproj(pos);
    val     = griddata(prjorig(:,1),prjorig(:,2),valorig,prj(:,1),prj(:,2),'v4');
    if numel(facealpha)==size(posorig,1)
        facealpha = griddata(prjorig(:,1),prjorig(:,2),facealpha,prj(:,1),prj(:,2),'v4');
    end
end


if ~isequal(topostyle, false)
    switch topostyle
        case 'color'
            % plot a 2D or 3D triangulated surface with linear interpolation
            if length(val)==size(pos,1)
                hs = patch('Vertices', pos, 'Faces', tri, 'FaceVertexCData', val, 'FaceColor', 'interp');
            else
                hs = patch('Vertices', pos, 'Faces', tri, 'CData', val, 'FaceColor', 'flat');
            end
            set(hs, 'EdgeColor', 'none');
            set(hs, 'FaceLighting', 'none');
            
            % if facealpha is an array with number of elements equal to the number of vertices
            if size(pos,1)==numel(facealpha)
                set(hs, 'FaceVertexAlphaData', facealpha);
                set(hs, 'FaceAlpha', 'interp');
            elseif ~isempty(pos) && numel(facealpha)==1 && facealpha~=1
                % the default is 1, so that does not have to be set
                set(hs, 'FaceAlpha', facealpha);
            end
            
        otherwise
            ft_error('unsupported topostyle');
    end % switch contourstyle
end % plot the interpolated topography


if ~strcmp(contourstyle, 'none')
    
    if ischar(isolines)
        if isequal(isolines, 'auto')
            minval = min(val);
            maxval = max(val);
            scale = max(abs(minval), abs(maxval));
            scale = 10^(floor(log10(scale))-1);
            minval = floor(minval/scale)*scale;
            maxval = ceil(maxval/scale)*scale;
            isolines = minval:scale:maxval;
        else
            ft_error('unsupported isolines');
        end
    end % convert string to vector
    
    tri_val = val(tri);
    tri_min = min(tri_val, [], 2);
    tri_max = max(tri_val, [], 2);
    
    for cnt_indx=1:length(isolines)
        cnt = isolines(cnt_indx);
        use = cnt>=tri_min & cnt<=tri_max;
        counter = 0;
        intersect1 = [];
        intersect2 = [];
        
        for tri_indx=find(use)'
            tri_pos = pos(tri(tri_indx,:), :);
            v(1) = tri_val(tri_indx,1);
            v(2) = tri_val(tri_indx,2);
            v(3) = tri_val(tri_indx,3);
            la(1) = (cnt-v(1)) / (v(2)-v(1)); % abcissa between vertex 1 and 2
            la(2) = (cnt-v(2)) / (v(3)-v(2)); % abcissa between vertex 2 and 3
            la(3) = (cnt-v(3)) / (v(1)-v(3)); % abcissa between vertex 1 and 2
            abc(1,:) = tri_pos(1,:) + la(1) * (tri_pos(2,:) - tri_pos(1,:));
            abc(2,:) = tri_pos(2,:) + la(2) * (tri_pos(3,:) - tri_pos(2,:));
            abc(3,:) = tri_pos(3,:) + la(3) * (tri_pos(1,:) - tri_pos(3,:));
            counter = counter + 1;
            sel     = find(la>=0 & la<=1);
            intersect1(counter, :) = abc(sel(1),:);
            intersect2(counter, :) = abc(sel(2),:);
        end
        
        % remember the details for external reference
        contour(cnt_indx).level = cnt;
        contour(cnt_indx).n     = counter;
        contour(cnt_indx).intersect1 = intersect1;
        contour(cnt_indx).intersect2 = intersect2;
    end
    
    % collect all different contour isolines for plotting
    intersect1 = [];
    intersect2 = [];
    cntlevel   = [];
    for cnt_indx=1:length(isolines)
        intersect1 = [intersect1; contour(cnt_indx).intersect1];
        intersect2 = [intersect2; contour(cnt_indx).intersect2];
        cntlevel   = [cntlevel; ones(contour(cnt_indx).n,1) * isolines(cnt_indx)];
    end
    
    X = [intersect1(:,1) intersect2(:,1)]';
    Y = [intersect1(:,2) intersect2(:,2)]';
    C = [cntlevel(:)     cntlevel(:)]';
    
    if size(pos,2)>2
        Z = [intersect1(:,3) intersect2(:,3)]';
    else
        Z = zeros(2, length(cntlevel));
    end
    
    switch contourstyle
        case 'black'
            % make black-white contours
            hc = [];
            for i=1:length(cntlevel)
                if cntlevel(i)>0
                    linestyle = '-';
                    linewidth = 1;
                elseif cntlevel(i)<0
                    linestyle = '--';
                    linewidth = 1;
                else
                    linestyle = '-';
                    linewidth = 2;
                end
                h1 = patch('XData', X(:,i), 'Ydata', Y(:,i), ...
                    'ZData', Z(:,i), 'CData', C(:,i), ...
                    'facecolor','none','edgecolor','black', ...
                    'linestyle', linestyle, 'linewidth', linewidth, ...
                    'userdata',cntlevel(i));
                hc = [hc; h1];
            end
            
        case 'color'
            % make full-color contours
            hc = [];
            for i=1:length(cntlevel)
                h1 = patch('XData', X(:,i), 'Ydata', Y(:,i), ...
                    'ZData', Z(:,i), 'CData', C(:,i), ...
                    'facecolor','none','edgecolor','flat',...
                    'userdata',cntlevel(i));
                hc = [hc; h1];
            end
            
        otherwise
            ft_error('unsupported contourstyle');
    end % switch contourstyle
    
end % plot the contours

axis off
axis vis3d
axis equal

if ~holdflag
    hold off
end

warning(ws); % revert to original state

function [tri] = projecttri(pnt, method)

% PROJECTTRI makes a closed triangulation of a list of vertices by
% projecting them onto a unit sphere and subsequently by constructing
% a convex hull triangulation.
%
% Use as
%   [tri] = projecttri(pnt, method)
% The optional method argument can be 'convhull' (default) or 'delaunay'.

% Copyright (C) 2006, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

if nargin<2
    method = 'convhull';
end

switch method
    case 'convhull'
        ori = (min(pnt) + max(pnt))./2;
        pnt(:,1) = pnt(:,1) - ori(1);
        pnt(:,2) = pnt(:,2) - ori(2);
        pnt(:,3) = pnt(:,3) - ori(3);
        nrm = sqrt(sum(pnt.^2, 2));
        pnt(:,1) = pnt(:,1)./nrm;
        pnt(:,2) = pnt(:,2)./nrm;
        pnt(:,3) = pnt(:,3)./nrm;
        tri = convhulln(pnt);
    case 'delaunay'
        % make a 2d triangulation of the projected points using delaunay
        prj = elproj(pnt);
        tri = delaunay(prj(:,1), prj(:,2));
    otherwise
        ft_error('unsupported method');
end

function [proj] = elproj(pos, method)

% ELPROJ makes a azimuthal projection of a 3D electrode cloud
%  on a plane tangent to the sphere fitted through the electrodes
%  the projection is along the z-axis
%
%  [proj] = elproj([x, y, z], 'method');
%
% Method should be one of these:
%     'gnomic'
%     'stereographic'
%     'orthographic'
%     'inverse'
%     'polar'
%
% Imagine a plane being placed against (tangent to) a globe. If
% a light source inside the globe projects the graticule onto
% the plane the result would be a planar, or azimuthal, map
% projection. If the imaginary light is inside the globe a Gnomonic
% projection results, if the light is antipodal a Sterographic,
% and if at infinity, an Orthographic.
%
% The default projection is a polar projection (BESA like).
% An inverse projection is the opposite of the default polar projection.

% Copyright (C) 2000-2008, Robert Oostenveld
%
% This file is part of FieldTrip, see http://www.fieldtriptoolbox.org
% for the documentation and details.
%
%    FieldTrip is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    FieldTrip is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with FieldTrip. If not, see <http://www.gnu.org/licenses/>.
%
% $Id$

x = pos(:,1);
y = pos(:,2);
if size(pos, 2)==3
    z = pos(:,3);
end

if nargin<2
    method='polar';
end

if strcmp(method, 'orthographic')
    % this method compresses the lowest electrodes very much
    % electrodes on the bottom half of the sphere are folded inwards
    xp = x;
    yp = y;
    num = length(find(z<0));
    str = sprintf('%d electrodes may be folded inwards in orthographic projection\n', num);
    if num
        ft_warning(str);
    end
    proj = [xp yp];
    
elseif strcmp(method, 'gnomic')
    % the lightsource is in the middle of the sphere
    % electrodes on the equator are projected at infinity
    % electrodes below the equator are not projected at all
    rad = mean(sqrt(x.^2 + y.^2 + z.^2));
    phi = cart2pol(x, y);
    th  = atan(sqrt(x.^2 + y.^2) ./ z);
    xp  = cos(phi) .* tan(th) .* rad;
    yp  = sin(phi) .* tan(th) .* rad;
    num = length(find(th==pi/2 | z<0));
    str = sprintf('removing %d electrodes from gnomic projection\n', num);
    if num
        ft_warning(str);
    end
    xp(find(th==pi/2 | z<0)) = NaN;
    yp(find(th==pi/2 | z<0)) = NaN;
    proj = [xp yp];
    
elseif strcmp(method, 'stereographic')
    % the lightsource is antipodal (on the south-pole)
    rad = mean(sqrt(x.^2 + y.^2 + z.^2));
    z   = z + rad;
    phi = cart2pol(x, y);
    th  = atan(sqrt(x.^2 + y.^2) ./ z);
    xp  = cos(phi) .* tan(th) .* rad * 2;
    yp  = sin(phi) .* tan(th) .* rad * 2;
    num = length(find(th==pi/2 | z<0));
    str = sprintf('removing %d electrodes from stereographic projection\n', num);
    if num
        ft_warning(str);
    end
    xp(find(th==pi/2 | z<0)) = NaN;
    yp(find(th==pi/2 | z<0)) = NaN;
    proj = [xp yp];
    
elseif strcmp(method, 'inverse')
    % compute the inverse projection of the default angular projection
    [th, r] = cart2pol(x, y);
    [xi, yi, zi] = sph2cart(th, pi/2 - r, 1);
    proj = [xi, yi, zi];
    
elseif strcmp(method, 'polar')
    % use default angular projection
    [az, el, r] = cart2sph(x, y, z);
    [x, y] = pol2cart(az, pi/2 - el);
    proj = [x, y];
    
else
    ft_error('unsupported method (%s)', method);
end

