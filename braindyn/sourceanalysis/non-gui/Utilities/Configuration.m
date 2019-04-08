function my_cfg = Configuration(my_cfg)
% modality = my_cfg;
% if ~isfield(my_cfg, 'modality')

restoredefaultpath
switch my_cfg.user
    case 'Office'
        FTDir = 'D:\Related tools\FieldTrip\fieldtrip-master\fieldtrip-master'; % Office
        subjectDir = 'D:\Related tools\FieldTrip\tutorial\Dataset\Subject01'; % Office
        toolboxDir = 'D:\Mathilde ERC\Pipeline'; % Office
    case 'Laptop'
        FTDir = 'E:\Ph.D\Related works\FT\Toolbox\fieldtrip-20180603'; % Laptop
        subjectDir = 'E:\Ph.D\Related works\FT\Toolbox\tutorial\Subject01'; % Laptop
        toolboxDir = 'E:\pipeline'; % Laptop
    case 'Else'
        FTDir = uigetdir('C:\', '1/3: Please select the FieldTrip home directory ...');
        subjectDir = uigetdir('C:\', '2/3: Please select the subject home directory ...');
        toolboxDir = uigetdir('C:\', '3/3: Please select the toolbox home directory ...');
end % switch user
addpath(genpath(toolboxDir))
addpath(FTDir)
ft_defaults

my_cfg.address.FieldTrip = FTDir;
my_cfg.address.load = fullfile(toolboxDir, filesep, 'Workspace'); % address for saving and loading the results
my_cfg.address.subject = subjectDir;

[modalityInd, Ok] = listdlg('PromptString', 'Please select a modality:', ...
    'ListString', {'EEG', 'MEG'}, 'SelectionMode', 'single', ...
    'ListSize', [140 40]);

my_cfg.MRILoad = fullfile(my_cfg.address.subject, filesep, 'Subject01.mri');

if Ok && modalityInd == 1
    my_cfg.name = 'EEG'; % Name of the modality
    my_cfg.unit = 'mm'; % Unit of the coordinate system
    my_cfg.coordSys = 'ctf'; % The coordinate system
    my_cfg.MRIDir = fullfile(my_cfg.address.load, filesep, 'EEGMRI.mat'); % Processed MRI file directory (CTF, cm, aligned)
    my_cfg.segMRIDir = fullfile(my_cfg.address.load, filesep, 'EEGSegmentedmri.mat'); % Segmented MRI file directory
    my_cfg.meshDir = fullfile(my_cfg.address.load, filesep, 'EEGMesh.mat'); % Source model file directory
    my_cfg.volDir = fullfile(my_cfg.address.load, filesep, 'EEGHeadModel.mat'); % Head model file directory
    my_cfg.sourceModelDir = fullfile(my_cfg.address.load, filesep, 'EEGSourceModel.mat'); % Source model
    my_cfg.sensLoad = fullfile(my_cfg.address.FieldTrip, filesep, 'template', filesep, 'electrode', filesep, 'standard_1020.elc'); % sensor file directory
    my_cfg.sensDir = fullfile(my_cfg.address.load, filesep, 'EEGSensorModel.mat'); % Sensor model
    my_cfg.channelsSymb = 'sb'; % Symbol for sensor representation
    my_cfg.LFDir = fullfile(my_cfg.address.load, filesep, 'EEGLeadField.mat'); % Lead-field matrix
    my_cfg.FPDir = fullfile(my_cfg.address.load, filesep, 'EEGSourceActivity.mat'); % Forward problem
    my_cfg.IPDir = fullfile(my_cfg.address.load, filesep, 'EEGInverseProblem.mat'); % Inverse problem
    %     modality.SensDir = 'D:\Related tools\FieldTrip\fieldtrip-master\fieldtrip-master\template\electrode\standard_1020.elc';
    %         modality.DefChannelsInd = [1 2 3 4 6 19 21 23 25 27 43 44 45 46 47 65 67 69 84 85 86 90 91 92 93 56 34 33 57 35 55 68 22 24 66 54 36 58 32]; %  Indices of channels that are selected among all
    %         if isfield(my_cfg, 'Channels_ind')
    %             modality.ChannelsInd = my_cfg.Channels_ind; % NOTE: if this field exist, GUI would not be shown
    %         end
    
    if exist(my_cfg.address.load, 'dir') ~= 7 % If the directory does not exist, creates the directory
        mkdir(my_cfg.address.load)
    end % if exist(my_cfg.address.load, 'dir') ~= 7
    
elseif Ok && modalityInd == 2
    my_cfg.name = 'MEG'; % Name of the modality
    my_cfg.unit = 'mm'; % Unit of the coordinate system
    my_cfg.coordSys = 'ctf'; % The coordinate system
    
    my_cfg.MRIDir = fullfile(my_cfg.address.load, filesep, 'MEGMRI.mat'); % Processed MRI file directory (CTF, cm, aligned)
    my_cfg.segMRIDir = fullfile(my_cfg.address.load, filesep, 'MEGSegmentedmri.mat'); % Segmented MRI file directory
    my_cfg.meshDir = fullfile(my_cfg.address.load, filesep, 'MEGMesh.mat'); % Source model file directory
    my_cfg.volDir = fullfile(my_cfg.address.load, filesep, 'MEGHeadModel.mat'); % Head model file directory
    my_cfg.sourceModelDir = fullfile(my_cfg.address.load, filesep, 'MEGSourceModel.mat'); % Source model
    my_cfg.sensLoad = fullfile(my_cfg.address.subject, filesep, 'Subject01.ds'); % sensor file directory
    my_cfg.sensDir = fullfile(my_cfg.address.load, filesep, 'MEGSensorModel.mat'); % Sensor model
    my_cfg.channelsSymb = 'og'; % Symbol for sensor representation
    my_cfg.LFDir = fullfile(my_cfg.address.load, filesep, 'MEGLeadField.mat'); % Lead-field matrix
    my_cfg.FPDir = fullfile(my_cfg.address.load, filesep, 'MEGSourceActivity.mat'); % Source activity
    my_cfg.IPDir = fullfile(my_cfg.address.load, filesep, 'MEGInverseProblem.mat'); % Inverse problem
    %     modality.SensDir = 'D:\Related tools\FieldTrip\tutorial\Dataset\Subject01\Subject01.ds';
    
    %         modality.DefChannelsInd = [1 2 3 4 6 19 21 23 25 27 43 44 45 46 47 65 67 69 84 85 86 90 91 92 93 56 34 33 57 35 55 68 22 24 66 54 36 58 32]; %  Indices of channels that are selected among all
    %         if isfield(my_cfg, 'Channels_ind')
    %             modality.ChannelsInd = my_find_MEG_equivTo_EEG(fullfile(my_cfg.address.load, filesep, 'fieldtrip-20150207', filesep, 'template', filesep, 'electrode', filesep, 'standard_1020.elc'), ...
    %                 modality.SensDir, my_cfg.Channels_ind, 'sb', modality.ChannelsSymb, ...
    %                 fullfile(my_cfg.address.load, filesep, 'mmMRI.mat'), false, my_cfg); % indices of channels that are selected among all
    %         end
    
    if exist(my_cfg.address.load, 'dir') ~= 7 % If the directory does not exist, creates the directory
        mkdir(my_cfg.address.load)
    end % if exist(my_cfg.address.load, 'dir') ~= 7
    
else
    msgbox('No modality is selected! Please select.', 'Warning', 'error');
end % if Ok && modalityInd == 1
% elseif isfield(my_cfg, 'modality')
%     if strcmp(my_cfg.modality, 'EEG')
%         modality.Name = 'EEG'; % Name of the modality
%         modality.ChannelsSymb = 'sb'; % Symbol for sensor representation
%         modality.SensDir = fullfile(my_cfg.address.load, filesep, 'fieldtrip-20150207', filesep, 'template', filesep, 'electrode', filesep, 'standard_1020.elc'); % sensor file directory
%         modality.DefChannelsInd = [1 2 3 4 6 19 21 23 25 27 43 44 45 46 47 65 67 69 84 85 86 90 91 92 93 56 34 33 57 35 55 68 22 24 66 54 36 58 32]; %  Indices of channels that are selected among all
%         if isfield(my_cfg, 'Channels_ind')
%             modality.ChannelsInd = my_cfg.Channels_ind; % NOTE: if this field exist, GUI would not be shown
%         end
%         modality.Unit = 'mm'; % Unit of the coordinate system
%         modality.CoordSys = 'ctf'; % The coordinate system
%         modality.SegMRIDir = fullfile(my_cfg.address.load, filesep, 'segmentedmri_B_S_S.mat'); % Segmented MRI file directory
%         modality.HeadModelDir = fullfile(my_cfg.address.load, filesep, 'EEGHeadModel.mat'); % Head model file directory
%         modality.meshDir = fullfile(my_cfg.address.load, filesep, 'Mesh.mat'); % Source model file directory
%         modality.MRIDir = fullfile(my_cfg.address.load, filesep, 'mmMRI.mat'); % Processed MRI file directory (CTF, cm, aligned)
%
%     elseif strcmp(my_cfg.modality, 'MEG')
%         modality.Name = 'MEG'; % Name of the modality
%         modality.ChannelsSymb = 'og'; % Symbol for sensor representation
%         modality.SensDir = fullfile(my_cfg.address.load, filesep, 'Subject01.ds'); % sensor file directory
%         modality.DefChannelsInd = [1 2 3 4 6 19 21 23 25 27 43 44 45 46 47 65 67 69 84 85 86 90 91 92 93 56 34 33 57 35 55 68 22 24 66 54 36 58 32]; %  Indices of channels that are selected among all
%         if isfield(my_cfg, 'Channels_ind')
%             modality.ChannelsInd = my_find_MEG_equivTo_EEG(fullfile(my_cfg.address.load, filesep, 'fieldtrip-20150207', filesep, 'template', filesep, 'electrode', filesep, 'standard_1020.elc'), ...
%                 modality.SensDir, my_cfg.Channels_ind, 'sb', modality.ChannelsSymb, ...
%                 fullfile(my_cfg.address.load, filesep, 'mmMRI.mat'), false, my_cfg); % indices of channels that are selected among all
%         end
%         modality.Unit = 'cm'; % Unit of the coordinate system
%         modality.CoordSys = 'ctf'; % The coordinate system
%         modality.SegMRIDir = fullfile(my_cfg.address.load, filesep, 'segmentedmri_B.mat'); % Segmented MRI file directory
%         modality.HeadModelDir = fullfile(my_cfg.address.load, filesep, 'MEGHeadModel.mat'); % Head model file directory
%         modality.MeshDir = fullfile(my_cfg.address.load, filesep, 'Mesh.mat'); % Source model file directory
%         modality.MRIDir = fullfile(my_cfg.address.load, filesep, 'cmMRI.mat'); % Processed MRI file directory (CTF, cm, aligned)
%     end
% end
