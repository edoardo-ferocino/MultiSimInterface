MMLINE=-10:1:10;
PERLINE=-1:0.1:1;
F=struct('Value',[],'Label',[],'Unit',[],'minV',[],'maxV',[],'Levels',[],'Treshold',[],'Help',[],'ID',[]);
for ih = 1:P(NUMBER_HETE).Default
    inctype = lower(P(eval(['INCTYPE' num2str(ih)])).Default);
    F=addF([inctype 'errXP'],[inctype 'errXP'],'mm',-10,10,MMLINE,0,'Absolute Error on Perturbation X',F); % Absolute Error on Perturbation X
    F=addF([inctype 'errYP'],[inctype 'errYP'],'mm',-10,10,MMLINE,0,'Absolute Error on Perturbation Y',F); % Absolute Error on Perturbation Y
    F=addF([inctype 'errZP'],[inctype 'errZP'],'mm',-10,10,MMLINE,0,'Absolute Error on Perturbation Z',F); % Absolute Error on Perturbation Z
    F=addF([inctype 'relP'],[inctype 'relP'],'%',-1,1,PERLINE,0,'Relative Error on DMua',F); % Relative Error on DMua
    F=addF([inctype 'relVOL'],[inctype 'relVOL'],'%',-1,1,PERLINE,0,'Relative Error on Volume',F); % Relative volume error
    %F=addF([inctype 'relVOLGauss'],[inctype 'relVOLGauss'],'%',-1,1,PERLINE,0,'Relative volume (gaussian fit) errore',F); % Relative volume (gaussian fit) error
end
[~,FspaceFileName] = fileparts([mfilename('fullpath'),'.m']);
clear inctype