P=struct('Order',[],'iP',[],'Default',[],'Range',[],'Label',[],'Unit',[],'Title',[],'Value',[],'Dim',[],'Help',[],'ID',[],'PlotPos',[]);
P=addP(0,'ROISTART',68,[0 1],'FirstChanRoi','',0,'FIrst channel of the ROI','',P);
P=addP(0,'ROISTOP',600,[200 250 300 350 400],'LastChanRoi','',0,'Last channel of the ROI','',P);
P=addP(0,'TW',20,[5 10 20 40],'TimeWindows','',0,'Number of Time Windows within the ROI','',P);
P=addP(0,'MUA0',0.01,0.05:0.05:0.3,'Mua0','mm-1',0,'Absorption','',P);
P=addP(0,'MUS0',1,6:2:18,'Mus0','mm-1',0,'Scattering','',P);
P=addP(0,'NB',1.4,[5 10 20],'RefIndex','',0,'Refractive index','',P);
P=addP(1,'TAU',1,[1e-4 1e-3 1e-2 1e-1 1e-0],'tau','',0,'Regularization parameter','column',P); % Regularization parameter
P=addP(0,'SOLVTYPE','Born',{'Born' 'USprior'},'Solver','',1,'1. Born 2. USprior 3.GN 4.LM 5.L1 6.FIT','',P);
P=addP(0,'EXPDELTA','all',{'baric' 'peak' 'all'},'IrfChoice','',0,'Substitute the IRF with delta function on the baricenter (1 = baric) or peak (2 = peak) of the IRF. 3 = all tu use the experimental IRF','',P);
P=addP(0,'MUAB',0.01,0.005:0.005:0.03,'MuaB','mm-1',0,'Background Absorption','',P); % Background Absorption
P=addP(0,'MUSB',1.0,1.0,'MusB','mm-1',0,'Background Reduced Scattering','',P); % Background Reduced Scattering
P=addP(0,'INRI',1.4,0.005:0.005:0.03,'InternalRefInd','',0,'Internal refractive index','',P); % Background Absorption
P=addP(0,'EXRI',1,1.0,'ExternalRefInd','',0,'External refractive index','',P); % Background Reduced Scattering
P=addP(0,'X1',-32,-32,'x1','mm',0,'Voxels x1','',P); % Voxels x1
P=addP(0,'X2',32,32,'x2','mm',0,'Voxels x2','',P); % Voxels x2
P=addP(0,'DX',6,[1 2 5],'dx','mm',0,'voxel resolution','',P); % Voxels x1
P=addP(0,'Y1',-32,24,'y1','mm',0,'Voxels y1','',P); % Voxels y1
P=addP(0,'Y2',32,24,'y2','mm',0,'Voxels y2','',P); % Voxels y2
P=addP(0,'Z1',0,0,'z1','mm',0,'Voxels z1','',P); % Voxels z1
P=addP(0,'Z2',32,32,'z2','mm',0,'Voxels z2','',P); % Voxels z2
P=addP(0,'NUMBER_HETE',1,[1 2],'NumberHete','',0,'Numeber of perturbations','',P);
P=addP(0,'INCTYPE1','Mua',{'Mua' 'Musp'},'Inc1Type','',0,'Inclusion type','',P);
P=addP(2,'XP1',35,-20:5:20,'XP1','mm',0,'Perturbation X (-30/30)','x',P); % Perturbation X (-30/30)
P=addP(3,'YP1',0,-20:5:20,'YP1','mm',0,'Perturbation Y (-20/20)','y',P); % Perturbation Y (-20/20)
P=addP(4,'ZP1',16,5:5:25,'ZP1','mm',0,'Perturbation Z','row',P); % Perturbation Z
P=addP(0,'SIG1',5,10,'Sigma1Heterog','mm',0,'Perturbation sigma','',P);
P=addP(0,'PROFILE1','Gaussian',{'Gaussian' 'Step'},'Inc1Profile','',0,'Profile of inc#1','',P);
P=addP(0,'INCPEAKVAL1',0.04,[1 2 5],'IncPeakVal1','mm-1',1,'Absorption Perturbation','',P); % Perturbation Absorption
if P(NUMBER_HETE).Default > 1
    P=addP(0,'INCTYPE2','Musp',{'Mua' 'Musp'},'Inc2Type','',0,'Inclusion type','',P);
    P=addP(0,'XP2',35,-20:5:20,'XP2','mm',0,'Perturbation X (-30/30)','',P); % Perturbation X (-30/30)
    P=addP(0,'YP2',25,-20:5:20,'YP2','mm',0,'Perturbation Y (-20/20)','',P); % Perturbation Y (-20/20)
    P=addP(0,'ZP2',16,5:5:20,'ZP2','mm',0,'Perturbation Z','',P); % Perturbation Z
    P=addP(0,'SIG2',5,10,'Sigma2Heterog','mm',0,'Perturbation sigma','',P);
    P=addP(0,'PROFILE2','Gaussian',{'Gaussian' 'Step'},'Inc2Profile','',0,'Profile of inc#1','',P);
    P=addP(0,'INCPEAKVAL2',1,[0.05 0.1 0.15 0.2 0.25 0.3],'IncPeakVal2','mm-1',1,'Perturbation Scattering','',P); % Perturbation Absorption
end
P=addP(0,'DT',(50e3/1024/4),[10 55 110 250],'dt','ps',0,'Bin size of temporal scale','',P); % Bin size of temporal scale
P=addP(0,'NT',600,1E-1,'NumTempSteps','',0,'Number of temporal steps','',P); % Regularization parameter
P=addP(0,'NOISETYPE','none',{'none' 'Poisson'},'AddedNoise','',0,'Type of noise added on data','',P);
P=addP(0,'SELF_NORM',0,[0 1],'CountsNormalization','',0,'true for self-normalized TPSF','',P);
P=addP(0,'CR',1e6,[1E5 1E6 1E7 1E8],'TotalCounts','cps',0,'Max Count Rate','',P); % Max Count Rate
P=addP(0,'RAD',1,[0 1],'ApplyRadiometry','',0,'Apply radiometry (true false)','',P); % Max Count Rate
P=addP(0,'PW',1,[0.1 1 10],'InjectedPower','mW',0,'Injected Power','',P); % Injected Power
P=addP(0,'TA',1,10,'AcqTime','s',1,'Acquisition Time','',P); % Acquisition Time
P=addP(0,'OE',0.9,1,'OpticalEfficiency','',0,'Optical efficiency of the optical path','',P); % Acquisition Time
P=addP(0,'LAMBDA',800,1,'Lambda','nm',0,'Wavelenght','',P); % Acquisition Time
P=addP(0,'EA',7,1,'EffectiveArea','',0,'Effective area of the detector','',P); % Acquisition Time
P=addP(0,'QE',0.04,1,'QuantumEfficiency','',0,'Quantum efficiency of the detector','',P); % Acquisition Time
P=addP(0,'SD','norhozero',{'all' 'rhozero' 'norhozero'},'SourceDetArrange','',0,'Source Detector arrangement (1=all; 2=only rhozero; 3=no rhozero)','',P); % Source Detector arrangement (1=all; 2=only rhozero; 3=no rhozero)
P=addP(0,'CUT',1,[0 1],'CuttingCounts','',0,'Cutting of counts (0=no gated; 1=gated)','',P); % Cutting of counts (1=gated; 2=no gated; 3=each gate=countrate/numgate)
P=addP(0,'ND',3,[1 3 5 10],'DelaysNumber','',0,'Number of delays over the whole time distribution','',P); % Number of delays over the whole time distribution
P=addP(0,'LJ',1,[0 1],'LoadJac','',0,'Decide if load precomputed jacobian','',P);
P=addP(0,'LF',1,[0 1],'LoadForward','',0,'Decide if load forward model','',P);
[~,PspaceFileName] = fileparts([mfilename('fullpath'),'.m']);