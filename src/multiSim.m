%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% multi SIM: script to perform multiple KERNEL simulations              %
%                                                                       %
% v1:                                                                   %
% Input and Output parameters in anonymous format                       %
% Antonio Pifferi 11/02/2017                                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ==================== INITIALIZATION ====================================

%%% The following structures and variables are reserved for multiSim:
%%% P, F, IDP, IDF, C, Var, DIR_SIM, DIR_KERNEL, DIR_MULTISIM, SAVE_FIG,
%%% ROOT_FIG, SIM_TITLE, SIM_TEST, START_PATH
%%% H (if using the interface)


clc
close all
cmdirs = regexp([matlabpath pathsep],['.[^' pathsep ']*' pathsep],'match')';
START_PATH = fileparts([mfilename('fullpath'),'.m']);
cd('../');
addpath(genpath(pwd));
cd(START_PATH);
try
    if exist('H','var')
        if H.isComingFromInterface %redundant
            LoadIniFile = true;
            save(H.IniPath,'SIM_TITLE','-append');
            load(H.IniPath);
            isComingFromInterface = true;
        end
    else
        isComingFromInterface = false;
        Answer = questdlg('Want to load a ini file?','Select input','No');
        switch lower(Answer)
            case 'yes'
                LoadIniFile = true;
            case 'no'
                LoadIniFile = false;
            case 'cancel'
                warndlg('Exiting multiSim. Simulation not started','Warning');
                cd(START_PATH);
                matlabpath([cmdirs{:}])
                return;
        end
        if LoadIniFile
            [FileName,PathName,FilterIndex]=uigetfile('*.*','Load init file');
            if FilterIndex == 0, return, end
            MsgH = msgbox('Please wait...Loading...','Wait');
            load([PathName,FileName]);%,'P','F','DIR_SIM','DIR_KERNEL','DIR_MULTISIM','IP','IF');
            delete(MsgH);
        end
    end
    
    Answer = questdlg('Want to just compile the Sim.mat file?','Select input','No');
    switch lower(Answer)
        case 'yes'
            isCompileIni = true;
        case 'no'
            isCompileIni = false;
        case 'cancel'
            warndlg('Exiting multiSim. Simulation not started','Warning');
            cd(START_PATH);
            matlabpath([cmdirs{:}])
            return;
    end
    
    if isCompileIni == false
        Answer = questdlg('Want to get notified by mail of the end of simulation?','Select input','No');
        switch lower(Answer)
            case 'yes'
                [isSendEmail,NOWPOS]=GetEmailData;
                if ~isSendEmail
                    %RetrieveDataEmail(NOWPOS);
                    matlabpath([cmdirs{:}]);
                    warndlg('Exiting multiSim. Simulation not started','Warning');
                    return
                end
            case 'no'
                isSendEmail = false;
            case 'cancel'
                warndlg('Exiting multiSim. Simulation not started','Warning');
                cd(START_PATH);
                matlabpath([cmdirs{:}])
                return;
        end
    end
    %% ==================== INPUT SECTION =====================================
    
    if LoadIniFile == false
        clearvars('-except','LoadIniFile','isSendEmail','isComingFromInterface','isCompileIni','Address','cmdirs','NOWPOS','START_PATH');
        
        % ========================= OPTIONS ===================================
        
        Options
        
        % ========================= INITIALIZE PARAMETER SPACE ================
        
        Pspace
        
        % ===================== INITIALIZE FIGURE OF MERIT SPACE ==============
        
        Fspace
    end
    
    %% =================== COMPLETE/LOAD P and F ==============================
    
    nP=numel(P);
    nF=numel(F);
    nL=1; for iP=1:nP, nL=nL*P(iP).Dim; end
    for iF=1:nF, F(iF).Value=zeros(nL,1); end %#ok<SAGROW>
    
    %% =================== INITIALIZE VARIABLE SPACE ==========================
    
    Var=struct('iP',[],'Dim',[]);
    for iP=1:nP
        if(P(iP).Order>0)
            Var.iP(P(iP).Order)=iP;
            Var.Dim(P(iP).Order)=P(iP).Dim;
        end
    end
    
    %% ======================= DATA SAVING ====================================
    ROOT_FIG = datestr(now,'yyyymmdd_HHMMSS');
    DIR_MULTISIM = [mfilename('fullpath'),'.m'];
    if SIM_TEST == true
        newDir=[DIR_SIM filesep 'Test'];
        if exist(newDir,'file'), rmdir(newDir,'s'), end
        newDir=[DIR_SIM filesep 'Test'];
    else
        if strcmp(SIM_TITLE,'-Default-'), SIM_TITLE = ROOT_FIG; end
        newDir=[DIR_SIM filesep SIM_TITLE '-' ROOT_FIG];
    end
    Root=[newDir filesep ROOT_FIG];
    mkdir(newDir);
    save([newDir filesep 'Sim.mat'],'P','F','DIR_SIM','DIR_KERNEL','DIR_MULTISIM','ROOT_FIG','SIM_TITLE')
    
    for inP = 1:nP
        IDP.(P(inP).ID) = inP;
        save([newDir filesep 'Sim.mat'],P(inP).ID,'-append');
    end
    save([newDir filesep 'Sim.mat'],'IDP','-append');
    for inF = 1:nF
        IDF.(F(inF).ID) = inF;
        save([newDir filesep 'Sim.mat'],F(inF).ID,'-append');
    end
    save([newDir filesep 'Sim.mat'],'IDF','-append');
    
    if LoadIniFile == false, copyfile([FspaceFileName '.m'],newDir); copyfile([PspaceFileName '.m'],newDir); copyfile([OptionsFileName '.m'],newDir); end
    if isCompileIni, mh=msgbox({'Sim.mat file saved in: ', newDir},'Success');  WinOnTop(mh,true); cd(START_PATH); matlabpath([cmdirs{:}]); return, end
    
    %% =================== LOOP ON VARIABLES ==================================
    if HIDE_FIG == true
        if isComingFromInterface
            WinOnTop(H.MultiSimInterface,true);
        end
        set(groot,'DefaultFigureVisible','off');  set(0,'DefaultFigureVisible','off'); set(0,'DefaultFigureWindowStyle','docked');
        warning('off','MATLAB:Figure:SetOuterPosition'); warning('off','MATLAB:Figure:SetPosition');
    end
    
    if DIARY, diary(fullfile(newDir,'Diary.txt')); end
    try
        for iL=1:nL
            indRange=zeros(1,5);
            for iP=1:nP
                [indRange(1), indRange(2), indRange(3), indRange(4), indRange(5)]=ind2sub(Var.Dim,iL);
                if P(iP).Order>0, P(iP).Value=P(iP).Range(indRange(P(iP).Order)); if iscell(P(iP).Value), P(iP).Value = P(iP).Range{indRange(P(iP).Order)}; end%#ok<SAGROW>
                else, P(iP).Value=P(iP).Default; end %#ok<SAGROW>
            end
            
            %% ============================ KERNEL ====================================
            
            if(iL==1)
                Now0=now();
                DIR_MULTISIM=[mfilename('fullpath'),'.m'];
                cd(fileparts(DIR_KERNEL));
                [KERNEL_PATH,KERNEL]=fileparts(DIR_KERNEL);
                if LoadIniFile == false
                    cd(['../personalSim/' SIM_TYPE])
                    copyfile('Init_DOT.m',newDir); copyfile('RecSettings_DOT.m',newDir); copyfile('SetIO_DOT.m',newDir); copyfile('SetQM_DOT.m',newDir);
                    %                     cd(fileparts(DIR_KERNEL));
                end
                initialVars = who;
                addpath(KERNEL_PATH)
            end
            eval(KERNEL); 
            %run(DIR_KERNEL); % This is the main Simulation Kernel.
            clearvars('-except',initialVars{:},'BuffOverride','initialVars');
            NowL=now();
            ut=(NowL-Now0)/iL;
            disp('----------------End Loop---------------');
            disp(datetime('now'))
            disp(['Loop iL=' num2str(iL) '/' num2str(nL) ', Loop Duration=' datestr(ut,'dd:HH:MM:SS') ', Tot time=' datestr(ut*nL,'dd:HH:MM:SS') ', Rem=' datestr(ut*(nL-iL),'dd:HH:MM:SS')]);
            disp(['ETA: ' char(datetime(NowL+ut*(nL-iL),'ConvertFrom','datenum'))])
            mess=[]; for iv=1:max([P.Order]), mess=[mess P(Var.iP(iv)).Label '=' num2str(P(Var.iP(iv)).Value) ',   ']; end %#ok<AGROW>
            disp(mess);
            disp('----------------End Loop---------------');
            if isComingFromInterface
                mess = [];
                if iL == 1, H.OH(H.SimStatus).String = {}; end
                for iv=1:max([P.Order]), mess=[mess P(Var.iP(iv)).Label '=' num2str(P(Var.iP(iv)).Value) ',   ']; end %#ok<AGROW>
                H.OH(H.SimStatus).String = [H.OH(H.SimStatus).String;{['Loop:' num2str(iL) '/' num2str(nL)], ['Remaining: ', datestr(ut*(nL-iL),'dd:HH:MM:SS')], mess,''}'];
            end
            save([newDir filesep 'Sim.mat'],'F','P','-append');
        end
    catch ME
        if DIARY, diary off; end
        if HIDE_FIG == true
            if isComingFromInterface
                WinOnTop(H.MultiSimInterface,false);
            end
            set(groot,'DefaultFigureVisible','on');  set(0,'DefaultFigureVisible','on'); set(0,'DefaultFigureWindowStyle','normal');
            warning('on','MATLAB:Figure:SetOuterPosition'); warning('on','MATLAB:Figure:SetPosition');
        end
        ErrorDisplay(ME);
        isSendErrorEmail = isSendEmail;
        if isSendErrorEmail
            %[TOAdds,Sender]=RetrieveDataEmail;
            TOAdds = NOWPOS;
            Sender.email = 'noreply.simulation@gmail.com';
            Sender.password = 'simulation';
            Object = '[SIMULATION]';
            if ~exist('mess','var'), mess = []; end
            Body = {['Encountered error: ',ME.message],['Last available loop (',num2str(iL),'/',num2str(nL),') info: '], mess};
            SendEmail(Sender,TOAdds,Object,Body);
            clear TOAdds Sender
        end
        cd(START_PATH);
        matlabpath([cmdirs{:}])
        if not(isComingFromInterface), clearvars; end
        return
    end
    cd(fileparts(DIR_MULTISIM));
    DIR_MULTISIM = [mfilename('fullpath'),'.m'];
    matlabpath([cmdirs{:}]);
    cd('../');
    addpath(genpath(pwd));
    %% ========================= PLOTTING =====================================
    save([newDir filesep 'Sim.mat'],'F','-append');
    if HIDE_FIG == true
        if isComingFromInterface
            WinOnTop(H.MultiSimInterface,true);
        end
        set(groot,'DefaultFigureVisible','on');  set(0,'DefaultFigureVisible','on'); set(0,'DefaultFigureWindowStyle','normal');
        warning('on','MATLAB:Figure:SetOuterPosition'); warning('on','MATLAB:Figure:SetPosition');
    end
    
    close all
    
    
    %     for iF=1:nF
    %         multiFigure(P,nP,Var,F,iF,'C',Root,SAVE_FIG);
    %         close all
    %         multiFigure(P,nP,Var,F,iF,'P',Root,SAVE_FIG);
    %         close all
    %     end
    
    
    %% ========================= SENDING EMAIL ================================
    
    if isSendEmail
        try
            %[TOAdds,Sender]=RetrieveDataEmail(NOWPOS);
            TOAdds = NOWPOS;
            Sender.email = 'noreply.simulation@gmail.com';
            Sender.password = 'simulation';
            Object = '[SIMULATION]';
            if SIM_TEST == true
                Body = {['Completed Test simulation at ',ROOT_FIG],'Results are available in:',[newDir filesep 'Sim.mat']};
            else
                Body = {['Completed simulation "',SIM_TITLE,'" started at: "',ROOT_FIG],'Results are available in:',[newDir filesep 'Sim.mat']};
            end
            SendEmail(Sender,TOAdds,Object,Body);
            clear TOAdds Sender
        catch ME
            ErrorDisplay(ME);
            matlabpath([cmdirs{:}]);
            if not(isComingFromInterface), clearvars; end
        end
    end
    MsgH = msgbox('Simultation Completed. Hurray!!','Success');
    WinOnTop(MsgH,true);
    
    %% ========================= RESTORING PATH ===============================
    cd(START_PATH);
    matlabpath([cmdirs{:}])
    if HIDE_FIG == true
        if isComingFromInterface
            WinOnTop(H.MultiSimInterface,false);
        end
        set(groot,'DefaultFigureVisible','on');  set(0,'DefaultFigureVisible','on'); set(0,'DefaultFigureWindowStyle','normal');
        warning('on','MATLAB:Figure:SetOuterPosition'); warning('on','MATLAB:Figure:SetPosition');
    end
catch ME
    if HIDE_FIG == true
        if isComingFromInterface
            WinOnTop(H.MultiSimInterface,false);
        end
        set(groot,'DefaultFigureVisible','on');  set(0,'DefaultFigureVisible','on'); set(0,'DefaultFigureWindowStyle','normal');
        warning('on','MATLAB:Figure:SetOuterPosition'); warning('on','MATLAB:Figure:SetPosition');
    end
    ErrorDisplay(ME);
    cd(START_PATH);
    matlabpath([cmdirs{:}])
end
if DIARY, diary off; end
if not(isComingFromInterface), clearvars; end