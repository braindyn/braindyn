function convert_mne_to_spm(orig_res4_file, mne_file, epoched)

[filepath,name,ext] = fileparts(mne_file);
spm_filename=fullfile(filepath, sprintf('spm_%s.mat',name));

clear jobs
matlabbatch={};
        
matlabbatch{1}.spm.meeg.convert.dataset = {mne_file};
if epoched
    matlabbatch{1}.spm.meeg.convert.mode.epoched.usetrials = 1;
else
    matlabbatch{1}.spm.meeg.convert.mode.continuous.readall = 1;
end
matlabbatch{1}.spm.meeg.convert.channels{1}.all = 'all';
matlabbatch{1}.spm.meeg.convert.outfile = spm_filename;
matlabbatch{1}.spm.meeg.convert.eventpadding = 0;
matlabbatch{1}.spm.meeg.convert.blocksize = 3276800;
matlabbatch{1}.spm.meeg.convert.checkboundary = 1;
matlabbatch{1}.spm.meeg.convert.saveorigheader = 0;
matlabbatch{1}.spm.meeg.convert.inputformat = 'autodetect';

spm_jobman('run',matlabbatch);

load(spm_filename);

elec = ft_read_sens(orig_res4_file);
D.sensors=[];
D.sensors.meg = elec;
for i=1:length(D.channels)
    label=D.channels(i).label;
    D.channels(i).label=label(1:end-5);
end
D.fiducials = ft_convert_units(ft_read_headshape(orig_res4_file), 'mm');
save(spm_filename,'D');

D1=spm_eeg_load(spm_filename);
hdr = ft_read_header(orig_res4_file);
origchantypes = ft_chantype(hdr);
[sel1, sel2] = spm_match_str(D1.chanlabels, hdr.label);
origchantypes = origchantypes(sel2);
if length(strmatch('unknown', origchantypes, 'exact')) ~= numel(origchantypes)
    D1.origchantypes = struct([]);
    D1.origchantypes(1).label = hdr.label(sel2);
    D1.origchantypes(1).type = origchantypes;
end

S1 = [];
S1.task = 'defaulttype';
S1.D = D1;
S1.updatehistory = 0;
D1 = spm_eeg_prep(S1);
save(D1);

D1=spm_eeg_load(spm_filename);
S1 = [];
S1.task = 'project3D';
S1.modality = 'MEG';
S1.updatehistory = 0;
S1.D = D1;

D1 = spm_eeg_prep(S1);

save(D1);