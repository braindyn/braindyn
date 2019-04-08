% --> This script provides an example of how to compute an "EEG" and "MEG" leadfield in the Fieldtrip toolbox.
% --> The forward solution (leadfield) can be computed when the head model, the channel positions and the source model are given.
% --> A prerequisite of forward modeling is that the geometrical description of all elements (channel positions,
% head model, anatomical data and source model) is registered in the same coordination system with the same units.
%% 0-
clc; clear; close all;
%% 1- Parameters: Processing parameters
cfg = [];
cfg.user = 'Else'; % {'Office', 'Laptop', 'Else'}
cfg.mesh.headNumVertices = 1000 * [3 2 2]; % # of vertices for 'brain', 'skull', and 'scalp', respectively.
cfg.mesh.brainNumVertices = 1000 * [3 3 2]; % # of vertices for 'gray', 'white', and 'CSF', respectively.
cfg.sourceActivity.sigma2 = 200; % Extent of the brain source activity (max: 10000)
cfg.sourceReconst.method = 'LCMV'; % {'LCMV', 'DICS'}
cfg.sourceReconst.relnoise = 0.01; % Relative noise of the simulated raw data
cfg.sourceReconst.trialNum = 3; % # of simulated trials
cfg.sourceReconst.sinFreq = 10; % [Hz] Frequency of sine oscillation of brain activity
cfg.sourceReconst.lambda = '5%';
cfg.feedback.mri = true; % MRI feedback (step 3)
cfg.feedback.mriSeg = true; % Segmented MRI feedback (step 4)
cfg.feedback.mesh = true; % Meshes feedback (step 5)
cfg.feedback.vol = true; % Volume conduction head model feedback (step 6)
cfg.feedback.src = true; % Source model feedback (step 7)
cfg.feedback.sens = true; % Sensor model feedback (step 8)
cfg.feedback.geometrics = true; % All geometrical elements feedback (step 9)
cfg.feedback.srcActivity = true; % Source activity feedback (step 11)
cfg.feedback.srcReconst = true; % Source activity feedback (step 11)

clear FTDir subjectDir toolboxDir RESTOREDEFAULTPATH_EXECUTED
%% 2- Configuration: Specifications of each of the modalities:
cfg = Configuration(cfg);
%% 3- MRI preparation: Conditional MRI reading, alignment, reslicing, coordinate system checking, unit checking, conditional feedback
ReadPreprocMRI(cfg);
%% 4- MRI segmentation: Conditional MRI segmenting, coordinate system checking, unit checking, conditional feedback
VolumeSegment(cfg); 
%% 5- Mesh preparation: Conditional mesh preparing, coordinate system checking, unit checking, same sources for all modalities, conditional feedback
PrepareMesh(cfg);
%% 6- Head model preparation: Conditional head model preparing, coordinate system checking, unit checking, conditional feedback
PrepareHeadmodel(cfg);
%% 7- Source model preparation: Conditional source model preparing, coordinate system checking, unit checking, conditional feedback
PrepareSourcemodel(cfg);
%% 8- Sensor model preparation: Sensors reading, alignment, coordinate system checking, unit checking, conditional feedback
ReadPreprocSens(cfg);
%% 9- Representation: Consistency checking of all geometrical elements
GeometricalElements(cfg)
%% 10- Forward Problem I: Lead-field matrix
PrepareLeadfield(cfg);
%% 11- Forward Problem II: Source activity preparation
PrepareSourceActivity(cfg);
%% 12- Inverse Problem: LCMV & DICS
SourceReconstruction(cfg);