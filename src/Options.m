SAVE_FIG=true;
DIR_SIM='C:\Users\Edo\Desktop\Results';
DIR_KERNEL='C:\Users\Edo\OneDrive - Politecnico di Milano\LabWorks\Solus GitHub\src\DOT_core.m';
SIM_TITLE = '7 simulation - L1';
SIM_TEST = true; % will save and overwrite results in DIR_SIM\Test
HIDE_FIG = false;
DIARY = false;
SIM_TYPE = 'Standard'; %'Standard' 'StandardMuaMus' 'USprior' 'USprior_MuaMus' 'Fit4Param'
[~,OptionsFileName] = fileparts([mfilename('fullpath'),'.m']);