% =========================================================================
%%                         Inizialization code
% =========================================================================
function varargout = MultiSimInterface(varargin)
% MULTISIMINTERFACE MATLAB code for MultiSimInterface.fig
%      MULTISIMINTERFACE, by itself, creates a new MULTISIMINTERFACE or raises the existing
%      singleton*.
%
%      H = MULTISIMINTERFACE returns the handle to a new MULTISIMINTERFACE or the handle to
%      the existing singleton*.
%
%      MULTISIMINTERFACE('CALLBACK',hO,ED,H,...) calls the local
%      function named CALLBACK in MULTISIMINTERFACE.M with the given input arguments.
%
%      MULTISIMINTERFACE('Property','Value',...) creates a new MULTISIMINTERFACE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultiSimInterface_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultiSimInterface_OpeningFcn via varargin.
%
%      *See GUI Options on GsUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIH

% Edit the above text to modify the response to help MultiSimInterface

% Last Modified by GUIDE v2.5 27-Oct-2017 14:49:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @MultiSimInterface_OpeningFcn, ...
    'gui_OutputFcn',  @MultiSimInterface_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
end

%% --- Executes just before MultiSimInterface is made visible.
function MultiSimInterface_OpeningFcn(hO, ~, H, varargin)

H.output = hO;
H=FindAllH(H);
H.cmdirs = regexp([matlabpath pathsep],['.[^' pathsep ']*' pathsep],'match')';
START_PATH = fileparts([mfilename('fullpath'),'.m']);
cd('../');
addpath(genpath(pwd));
cd(START_PATH);
guidata(hO, H);
end

%% --- Outputs from this function are returned to the command line.
function varargout = MultiSimInterface_OutputFcn(hO, ~, H)
FFS(hO);
varargout{1} = H.output;
end

%% --- Executes during object creation, after setting all properties.
function MultiSimInterface_CreateFcn(hO, ~, H)
clc
FIGsH = get(0,'Children');
nIter = 0;
H.RootInterfaceName = 'MultiSimInterface';
for iFig = 1:numel(FIGsH)
    if isempty(strfind(FIGsH(iFig).Name,H.RootInterfaceName)) || isempty(FIGsH(iFig))
        delete(FIGsH(iFig));
    else
        nIter = nIter +1;
    end
end
H.NumOccur = nIter;
H=FindAllH(H);
guidata(hO, H);
end

% =========================================================================
%%                      UI Control Functions
% =========================================================================

%% --- Executes on button press in LoadData.
function LoadData_Callback(~, ~, H) %#ok<*DEFNU>
[FileName,PathName,FilterIndex]=uigetfilecustom('*.mat;*.xml');
if FilterIndex == 0, return, end
FFS(findobj('Name',H.InterfaceName));
FullPath = [PathName,FileName];
ClearContent(H);
LoadData(FullPath,H)
end

%% --- Executes on button press in SaveData.
function SaveData_Callback(hO, ~, H)
try
    [pathstr,~,~]=fileparts(H.FullPath);
    if exist(H.FullPath,'file')
        Answer = questdlg('File already exist. Want to overwrite?','Alreay existing file','Yes');
        switch lower(Answer)
            case 'yes'
                delete(H.FullPath); delete([H.FullPath(1:end-4) '_Fspace.m']);
                delete([H.FullPath(1:end-4) '_Pspace.m']); delete([H.FullPath(1:end-4) '_Options.m']);
                H.FullPath = H.FullPath;
            case 'no'
                [FileName,PathName,FilterIndex] = uiputfile('*.mat;*.xml','Select save position',pathstr);
                H.FullPath = [PathName,FileName];
                if FilterIndex == 0 ,return, end
            case 'cancel'
                return;
        end
    else
    end
    
    if H.StartEdit
        for iTH = H.D:H.FOM
            switch iTH
                case H.FOM
                    ColID = H.FCol.LinLog;
                case H.C
                    ColID = H.PCCol.LinLog;
                case H.D
                    ColID = H.PDCol.LinLog;
            end
            TH = H.OH(iTH);
            TH.ColumnEditable(ColID) = false;
            TH.Data(:,ColID) =[];
        end
    end
    
    [pathstr,filename,~]=fileparts(H.FullPath);
    for iT = H.D:H.FOM
        TempH = H.OH(iT);
        set(TempH,'ColumnEditable',false(1,numel(TempH.ColumnEditable(:))))
    end
    HB = H.OH(H.HelpBox);
    HB.Enable = 'inactive';
    
    if isfield(H,'ErrorOnGetInputForTables')
        msgbox('Changes not saved. Click "Undo"','Warning!'); H=rmfield(H,'ErrorOnGetInputForTables');
        EdH = H.OH(H.EditData);
        EdH.ForegroundColor = 'k';
        guidata(hO,H);
        return;
    end
    
    %     H = getappdata(findobj('Name',H.InterfaceName),'H');
    P = H.P;
    F = H.F;
    DefVar = P(H.DefID);
    VarVar = P(H.VarID);
    
    TempH = H.OH(H.D);
    newND = numel(TempH.Data(:,1));
    Pbuff=struct('Order',[],'iP',[],'Default',[],'Range',[],'Label',[],'Unit',[],'Title',[],'Value',[],'Dim',[],'Help',[],'ID',[],'PlotPos',[]);
    inr = 1;
    for in = 1:newND
        if ~isempty(TempH.Data{in,1})
            if ischar(TempH.Data{in,H.PDCol.Value})
                STR = TempH.Data{in,H.PDCol.Range};
                Inter = find(STR==';');
                NEWCELL={STR(1:Inter(1)-1)};
                if(numel(Inter))>=2
                    for iI = 2:numel(Inter)
                        NEWCELL{iI} = STR(Inter(iI-1)+1:Inter(iI)-1);
                    end
                else
                    iI = 1;
                end
                NEWCELL{iI+1} = STR(Inter(iI)+1:end);
                Pbuff = addP(0,P(inr).ID,TempH.Data{in,H.PDCol.Value},NEWCELL,TempH.Data{in,H.PDCol.Name},TempH.Data{in,H.PDCol.Unit},TempH.Data{in,H.PDCol.Title},DefVar(in).Help,'',Pbuff); %% COLCHANGE
            else
                Pbuff = addP(0,P(inr).ID,TempH.Data{in,H.PDCol.Value},str2num(TempH.Data{in,H.PDCol.Range})',TempH.Data{in,H.PDCol.Name},TempH.Data{in,H.PDCol.Unit},TempH.Data{in,H.PDCol.Title},DefVar(in).Help,'',Pbuff); %% COLCHANGE
            end
            inr = inr +1;
        end
    end
    
    TempH = H.OH(H.C);
    newNC = numel(TempH.Data(:,1));
    rND = inr -1;
    inr = 1;
    for in = 1:newNC
        if ~isempty(TempH.Data{in,H.PCCol.Name})
            %             Pbuff = addP(inr,rND+inr,P((strcmp({P.Label},TempH.Data{in,H.PCCol.Name}))).Default,str2num(TempH.Data{in,H.PCCol.Value})',TempH.Data{in,H.PCCol.Name},TempH.Data{in,H.PCCol.Unit},TempH.Data{in,H.PCCol.Title},VarVar(in).Help,Pbuff);
            if isempty(str2num(TempH.Data{in,H.PCCol.Value}))
                STR = TempH.Data{in,H.PCCol.Value};
                Inter = find(STR==';');
                NEWCELL={STR(1:Inter(1)-1)};
                if(numel(Inter))>=2
                    for iI = 2:numel(Inter)
                        NEWCELL{iI} = STR(Inter(iI-1)+1:Inter(iI)-1);
                    end
                else
                    iI = 1;
                end
                NEWCELL{iI+1} = STR(Inter(iI)+1:end);
                Pbuff = addP(inr,P(rND+inr).ID,P(rND+inr).Default,NEWCELL,TempH.Data{in,H.PCCol.Name},TempH.Data{in,H.PCCol.Unit},TempH.Data{in,H.PCCol.Title},VarVar(in).Help,TempH.Data{in,H.PCCol.PlotOrder},Pbuff);
            else
                Pbuff = addP(inr,P(rND+inr).ID,P(rND+inr).Default,str2num(TempH.Data{in,H.PCCol.Value})',TempH.Data{in,H.PCCol.Name},TempH.Data{in,H.PCCol.Unit},TempH.Data{in,H.PCCol.Title},VarVar(in).Help,TempH.Data{in,H.PCCol.PlotOrder},Pbuff);
            end
            inr = inr +1;
        end
    end
    
    TempH = H.OH(H.FOM);
    newNF = numel(TempH.Data(:,1));
    Fbuff=struct('Value',[],'Label',[],'Unit',[],'minV',[],'maxV',[],'Levels',[],'Treshold',[],'Help',[],'ID',[]);
    inr = 1;
    for in = 1:newNF
        if ~isempty(TempH.Data{in,1})
            Fbuff = addF(F(inr).ID,TempH.Data{in,H.FCol.Name},TempH.Data{in,H.FCol.Unit},min(str2num(TempH.Data{in,H.FCol.Levels})),max(str2num(TempH.Data{in,H.FCol.Levels})),str2num(TempH.Data{in,H.FCol.Levels})',TempH.Data{in,H.FCol.Treshold},F(in).Help,Fbuff); %#ok<*ST2NM>
            Fbuff(inr).Value = F(inr).Value;
            inr = inr +1;
        end
    end
    P=Pbuff;
    F=Fbuff;
    PlotPosID(H.x)=find(strcmpi({P.PlotPos},'x')); PlotPosID(H.y)=find(strcmpi({P.PlotPos},'y'));
    PlotPosID(H.row)=find(strcmpi({P.PlotPos},'row')); PlotPosID(H.column)=find(strcmpi({P.PlotPos},'column'));
    PlotPosID(H.window)=find(strcmpi({P.PlotPos},'window'));
    H.PlotPosID = PlotPosID;
    
    [~,KERNEL,ext] = fileparts(H.DIR_KERNEL);
    KERNEL = [KERNEL,ext]; %#ok<NASGU>
    DIR_SIM = H.DIR_SIM;
    DIR_MULTISIM = H.DIR_MULTISIM; %#ok<NASGU>
    DIR_KERNEL = H.DIR_KERNEL;
    InterfaceName = H.InterfaceName; %#ok<NASGU>
    DIR_INTERFACE = H.DIR_INTERFACE; %#ok<NASGU>
    ROOT_FIG = H.ROOT_FIG; %#ok<NASGU>
    SIM_TITLE = H.SIM_TITLE;
    save(H.FullPath,'P');
    save(H.FullPath,'F','-append');
    save(H.FullPath,'KERNEL','-append');
    save(H.FullPath,'DIR_KERNEL','-append');
    save(H.FullPath,'DIR_MULTISIM','-append');
    save(H.FullPath,'DIR_SIM','-append');
    save(H.FullPath,'DIR_INTERFACE','-append');
    save(H.FullPath,'ROOT_FIG','-append');
    save(H.FullPath,'SIM_TITLE','-append');
    
    nP = numel(P);
    DefID = find([P.Order]==0);
    nD = numel(DefID); %#ok<NASGU>
    VarID = find([P.Order]~=0);
    [~,Order] = sort([P(VarID).Order]);
    VarID=VarID(Order);
    nV = numel(VarID);
    nF = numel(F);
    for inP = 1:nP
        %UpLabelP(inP).Label = upper(P(inP).Label);
    end
    for inP = 1:nP
        %IDP.(P(inP).Label) = inP; %#ok<STRNU>
        IDP.(P(inP).ID) = inP; %#ok<STRNU>
        %eval([UpLabelP(inP).Label, ' = ', num2str(inP),';']);
        %save(H.FullPath,UpLabelP(inP).Label,'-append');
        save(H.FullPath,P(inP).ID,'-append');
    end
    save(H.FullPath,'IDP','-append');
    for inF = 1:nF
        %UpLabelF(inF).Label = F(inF).Label;%upper(F(inF).Label);
    end
    for inF = 1:nF
        %IDF.(F(inF).Label) = inF; %#ok<STRNU>
        IDF.(F(inF).ID) = inF; %#ok<STRNU>
        %eval([UpLabelF(inF).Label, ' = ', num2str(inF),';']);
        %save(H.FullPath,UpLabelF(inF).Label,'-append');
        save(H.FullPath,F(inF).ID,'-append');
    end
    save(H.FullPath,'IDF','-append');
    
    %generateXML([fullfile(pathstr,filename),'.xml'],H)
    
    isVarListModified = false;
    if numel(P)~=numel(H.Pstart) || numel(F)~=numel(H.Fstart)
        isVarListModified = true;
    else
        for inP = 1:numel(P)
            for inPs = 1:numel(H.Pstart)
                if ~strcmp(P(inP).Label,H.Pstart(inPs).Label), isVarListModified = isVarListModified || false; end
                if ~strcmp(P(inP).Unit,H.Pstart(inPs).Unit), isVarListModified = isVarListModified || false; end
                %if ~strcmp(P(inP).Help,H.Pstart(inP).Help), isVarListModified = isVarListModified || false; end
            end
        end
        for inF = 1:numel(F)
            for inFs = 1:numel(H.Fstart)
                if ~strcmp(F(inF).Label,H.Fstart(inFs).Label), isVarListModified = isVarListModified || false; end
                if ~strcmp(F(inF).Unit,H.Fstart(inFs).Unit), isVarListModified = isVarListModified || false; end
                %if ~strcmp(P(inP).Help,H.Pstart(inP).Help), isVarListModified = isVarListModified || false; end
            end
        end
    end
    if isVarListModified
        warndlg({'Be careful! Be sure that the changes are consistent in your kernel'},'Warning');
        fid = fopen(fullfile(fileparts(DIR_KERNEL),'VariableList.txt'),'w');
        fprintf(fid,'%s\t%s\t%s\r\n','Label','Unit','Help');
        for iP = 1:numel(P)
            fprintf(fid,'%s\t%s\t%s\r\n',P(iP).Label,P(iP).Unit,P(iP).Help);
        end
        fclose(fid);
    end
    
    Row{1,1}='P=struct(''Order'',[],''iP'',[],''Default'',[],''Range'',[],''Label'',[],''Unit'',[],''Title'',[],''Value'',[],''Dim'',[],''Help'',[],''ID'',[],''PlotPos'',[]);';
    for iP = 1:numel(P)
        if ~ischar(eval('P(iP).Default'))
            Row{iP+1,1}=['P=addP(' num2str(P(iP).Order) ',''' P(iP).ID ''',' num2str(P(iP).Default) ',[' num2str(P(iP).Range) '],''' P(iP).Label ''',''' P(iP).Unit ''',' num2str(P(iP).Title) ',''' P(iP).Help ''',''' P(iP).PlotPos ''',P);'];
        else
            buffRange = [];
            for iR=1:numel(P(iP).Range)
                buffRange = [buffRange ' ''' P(iP).Range{iR} ''''];
            end
            Row{iP+1,1}=['P=addP(' num2str(P(iP).Order) ',''' P(iP).ID ''',''' P(iP).Default ''',{' buffRange '},''' P(iP).Label ''',''' P(iP).Unit ''',' num2str(P(iP).Title) ',''' P(iP).Help ''',''' P(iP).PlotPos ''',P);'];
        end
    end
    if exist(fullfile(pathstr,'Pspace.m'),'file')
        fid=fopen(fullfile(pathstr,[filename '_Pspace.m']),'w');
    else
        fid=fopen(fullfile(pathstr,'Pspace.m'),'w');
    end
    for iR = 1:iP+1
        fprintf(fid,'%s\r\n',Row{iR});
    end
    fclose(fid);
    
    Row = {};
    Row{1}= ['SAVE_FIG = ' num2str(get(H.OH(H.SaveFig),'Value')) ';'];
    Row{2}= ['DIR_SIM = ''' DIR_SIM ''';'];
    Row{3}= ['DIR_KERNEL = ''' DIR_KERNEL ''';'];
    Row{4}= ['SIM_TITLE = ''' SIM_TITLE ''';'];
    Row{5}= ['SIM_TEST = ' num2str(get(H.OH(H.SimTest),'Value')) ';'];
    Row{6}= 'HIDE_FIG = false;';
    if exist(fullfile(pathstr,'Options.m'),'file')
        fid=fopen(fullfile(pathstr,[filename '_Options.m']),'w');
    else
        fid=fopen(fullfile(pathstr,'Options.m'),'w');
    end
    for iR = 1:numel(Row)
        fprintf(fid,'%s\r\n',Row{iR});
    end
    fclose(fid);
    
    Row = {};
    Row{1,1}='F=struct(''Value'',[],''Label'',[],''Unit'',[],''minV'',[],''maxV'',[],''Levels'',[],''Treshold'',[],''Help'',[],''ID'',[]);';
    for iF = 1:numel(F)
        Row{iF+1,1}=['F=addF(''' F(iF).ID ''',''' F(iF).Label ''',''' F(iF).Unit ''',' num2str(F(iF).minV) ',' num2str(F(iF).maxV) ',[' num2str(F(iF).Levels) '],' num2str(F(iF).Treshold) ',''' F(iF).Help ''',F);'];
    end
    if exist(fullfile(pathstr,'Fspace.m'),'file')
        fid=fopen(fullfile(pathstr,[filename '_Fspace.m']),'w');
    else
        fid=fopen(fullfile(pathstr,'Fspace.m'),'w');
    end
    for iR = 1:iF+1
        fprintf(fid,'%s\r\n',Row{iR});
    end
    fclose(fid);
    
    if isfield(H,'Buff')
        H=rmfield(H,'Buff');
    end
    if isfield(H,'StartEdit')
        H.StartEdit = false;
    end
    EdH = H.OH(H.EditData);
    EdH.ForegroundColor = 'k';
    
    H.P = P;
    H.F = F;
    H.DefID = DefID;
    H.VarID = VarID;
    
    if nV == 5
        if iscell(P(PlotPosID(H.window)).Range)
            RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),char(P(PlotPosID(H.window)).Range')]);
        else
            RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),num2str((P(PlotPosID(H.window)).Range)','%g')]);
        end
    else
        RowName = {'1'};
    end
    
    
    FigPath=CreatePath(pathstr,{F.Label},P,PlotPosID,H,H.ROOT_FIG);
    FillTable(H.OH(H.S),FigPath,RowName,H,{F.Label});
    
    H=UpDateTables(H);
    LD = H.OH(H.LoadedDataPath);
    LD.String = H.FullPath;
    guidata(hO,H);
    
catch ME
    ErrorDisplay(ME);
end

end

%% --- Executes on selection change in Format.
function Format_Callback(~, ~, H)
VarID = H.VarID;
P = H.P;
F = H.F;
PlotPosID = H.PlotPosID;
nV = numel(VarID);
pathstr = H.pathstr;
if nV == 5
    if iscell(P(PlotPosID(H.window)).Range)
        RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),char(P(PlotPosID(H.window)).Range')]);
    else
        RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),num2str((P(PlotPosID(H.window)).Range)','%g')]);
    end
else
    RowName = {'1'};
end
FigPath=CreatePath(pathstr,{F.Label},P,PlotPosID,H,H.ROOT_FIG);
FillTable(H.OH(H.S),FigPath,RowName,H,{F.Label});
end

%% --- Executes during object creation, after setting all properties.
function Format_CreateFcn(hO, ~, ~)
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end

%% --- Executes on selection change in PlotType.
function PlotType_Callback(~, ~, H)
VarID = H.VarID;
P = H.P;
F = H.F;
PlotPosID = H.PlotPosID;
nV = numel(VarID);
pathstr = H.pathstr;
if nV == 5
    if iscell(P(PlotPosID(H.window)).Range)
        RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),char(P(PlotPosID(H.window)).Range')]);
    else
        RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),num2str((P(PlotPosID(H.window)).Range)','%g')]);
    end
else
    RowName = {'1'};
end
FigPath=CreatePath(pathstr,{F.Label},P,PlotPosID,H,H.ROOT_FIG);
FillTable(H.OH(H.S),FigPath,RowName,H,{F.Label});
end

%% --- Executes during object creation, after setting all properties.
function PlotType_CreateFcn(hO, ~, ~)
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end

%% --- Executes when selected cell(s) is changed in DT.
function DT_CellSelectionCallback(hO, ED, H)
FillDescriptor(hO, ED, H);
end

%% --- Executes when selected cell(s) is changed in ST.
function ST_CellSelectionCallback(hO, ED, H)
OpenPath(hO, ED, H)
end

%% --- Executes when selected cell(s) is changed in CT.
function CT_CellSelectionCallback(hO, ED, H)
FillDescriptor(hO, ED, H);
end

%% --- Executes when selected cell(s) is changed in FOMT.
function FOMT_CellSelectionCallback(hO, ED, H)
FillDescriptor(hO, ED, H);
end

%% --- Executes on button press in EditData.
function EditData_Callback(hO, ~, H)
for iT = H.D:H.FOM
    TempH = H.OH(iT);
    set(TempH,'ColumnEditable',true(1,numel(TempH.ColumnEditable(:))))
end
hO.ForegroundColor = 'r';
EdH = H.OH(H.HelpBox);
EdH.Enable = 'on';
for iTH = H.D:H.FOM
    switch iTH
        case H.FOM
            ColID = H.FCol.LinLog;
        case H.C
            ColID = H.PCCol.LinLog;
        case H.D
            ColID = H.PDCol.LinLog;
    end
    TH = H.OH(iTH);
    Ncol = numel(TH.Data(1,:));
    if Ncol >= ColID, break, end
    Nrow = numel(TH.Data(:,1));
    TH.Data(:,Ncol+1) = repmat({'Scale'},Nrow,1);
    TH.ColumnEditable(ColID) = true;
    TH.ColumnFormat{ColID} = {'Lin' 'Log'};
end
H.StartEdit = true;
guidata(hO,H);
end

%% --- Executes on changin of HelpBox.
function HelpBox_Callback(hO, ~, H)
if isfield(H,'Buff')
    for iP = 1:numel({H.P.Help})
        H.Buff(end).HelpP{iP} = H.P(iP).Help;
    end
    for iF = 1:numel({H.F.Help})
        H.Buff(end).HelpF{iF} = H.F(iF).Help;
    end
else
    for iP = 1:numel({H.P.Help})
        H.Buff(1).HelpP{iP} = H.P(iP).Help;
    end
    for iF = 1:numel({H.F.Help})
        H.Buff(1).HelpF{iF} = H.F(iF).Help;
    end
end
switch H.Buff(end).Table
    case H.O(H.D).Tag
        VarType = H.DefID;
        H.P(VarType(H.Buff(end).Cell(1))).Help = char(hO.String);
    case H.O(H.C).Tag
        VarType = H.VarID;
        H.P(VarType(H.Buff(end).Cell(1))).Help = char(hO.String);
    case H.O(H.FOM).Tag
        H.F(H.Buff(end).Cell(1)).Help = char(hO.String);
end
guidata(hO,H);
end

%% --- Executes during object creation, after setting all properties.
function HelpBox_CreateFcn(hO, ~, ~)
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end

%% --- Executes when entered data in editable cell(s) in DT.
function DT_CellEditCallback(hO, ED, H)
GetInputForTables(hO, ED, H);
end

%% --- Executes when entered data in editable cell(s) in CT.
function CT_CellEditCallback(hO, ED, H)
GetInputForTables(hO, ED, H);
end

%% --- Executes when entered data in editable cell(s) in FOMT.
function FOMT_CellEditCallback(hO, ED, H)
GetInputForTables(hO, ED, H);
end

%% --- Executes on button press in Cancel.
function Cancel_Callback(hO, ~, H)
for iT = H.D:H.FOM
    TempH = H.OH(iT);
    set(TempH,'ColumnEditable',false(1,numel(TempH.ColumnEditable(:))))
    TH(iT) = TempH; %#ok<*AGROW>
end
EdH = H.OH(H.HelpBox);
EdH.Enable = 'inactive';
if isfield(H,'Buff')
    TH(H.D).Data = H.Buff(1).DV{1};
    TH(H.C).Data = H.Buff(1).CV{1};
    TH(H.FOM).Data = H.Buff(1).F{1};
    for iP = 1:numel({H.P.Help})
        H.P(iP).Help = H.Buff(1).HelpP{iP};
    end
    for iF = 1:numel({H.F.Help})
        H.F(iF).Help = H.Buff(1).HelpF{iF};
    end
    H=rmfield(H,'Buff');
end
if isfield(H,'StartEdit')
    H.StartEdit = false;
    if ~isfield(H,'Buff')
        try
            TH(H.D).Data(:,H.PDCol.LinLog) = [];
            TH(H.C).Data(:,H.PCCol.LinLog) = [];
            TH(H.FOM).Data(:,H.FCol.LinLog) = [];
        catch
        end
    end
    EdH = H.OH(H.EditData);
    EdH.ForegroundColor = 'k';
end
guidata(hO,H);
end

%%
function NotesBox_Callback(~, ~, ~)
end

%% --- Executes during object creation, after setting all properties.
function NotesBox_CreateFcn(hO, ~, ~)
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end

%% --- Executes on button press in RunSim.
function RunSim_Callback(hO, ~, H)
cmdirsinterface = regexp([matlabpath pathsep],['.[^' pathsep ']*' pathsep],'match')';
addpath(pwd);
[PathName,FileName]=fileparts(H.DIR_MULTISIM);
H.DIR_INTERFACE = cd(PathName);
Out = onCleanup(@()RestorePath(H.DIR_INTERFACE,cmdirsinterface));
H.isCloseLegal = false;
H.isResizeLegal = false;
H.isComingFromInterface = true;
guidata(hO,H);
SAVE_FIG = get(H.OH(H.SaveFig),'Value'); %#ok<NASGU>
SIM_TEST = get(H.OH(H.SimTest),'Value');  %#ok<NASGU>
%HIDE_FIG = get(H.OH(H.HideFig),'Value');   %#ok<NASGU>
HIDE_FIG = false; %#ok<NASGU>
if ~isempty(strfind(H.SIM_TITLE,'Default')), SIM_TITLE = '-Default-'; else, SIM_TITLE = H.SIM_TITLE; end  %#ok<NASGU>
H.MultiSimInterface.HandleVisibility = 'off';
run(FileName);
H.MultiSimInterface.HandleVisibility = 'callback';
matlabpath([cmdirsinterface{:}])
H.isComingFromInterface = false;
H.isCloseLegal = true;
H.isResizeLegal = true;
guidata(hO,H);
cd(H.DIR_INTERFACE);
FFS(findobj('Name',H.InterfaceName));
end
function RestorePath(source_path,cmdirs)
HH = helpdlg('Restoring Paths');
cd(source_path);
matlabpath([cmdirs{:}]);
pause(1.5);
delete(HH);
end

%% --- Executes on button press in WordReport.
function WordReport_Callback(~, ~, H)
try
    PathName=fileparts(H.FullPath);
    [FileName,PathName,FilterIndex] = uiputfile('*.doc','Type Name of the Report',PathName);
    if FilterIndex == 0, return, end
    Path = [PathName,FileName];
    
    hMsgBox = waitbar(0,{'Creating Word Doc...','Please wait... Could take few seconds'});
    NH = H.OH(H.NotesBox);
    for iT = H.D:H.S
        TH(iT) = H.OH(iT);
    end
    
    if strcmp(NH.String,'Insert Notes')
        Pace = 1/4;
    else
        Pace = 1/5;
    end
    
    
    [ActXWord,WordHandle]=StartWord(Path,false);
    waitbar(Pace);
    Style='Heading 1';
    ActXWord.ActiveDocument.Styles.Item(Style).Font.ColorIndex = 'wdBlack';
    ActXWord.ActiveDocument.Styles.Item(Style).Font.Bold = 1;
    ActXWord.ActiveDocument.Styles.Item(Style).Font.Name = 'Times New Roman';
    ActXWord.ActiveDocument.Styles.Item('Normal').Font.Name = 'Times New Roman';
    ActXWord.ActiveDocument.Styles.Item('Normal').ParagraphFormat.SpaceAfter = 0;
    ActXWord.ActiveDocument.Styles.Item('Normal').ParagraphFormat.LineSpacingRule = 0;
    % Y=num2str(year(H.datetxt,'yyyymmdd'));
    % M=num2str(month(H.datetxt,'yyyymmdd'));
    % D=num2str(day(H.datetxt,'yyyymmdd'));
    % T=sscanf(H.datetxt,'%d_%d');
    % T=num2str(T(2));
    % Hour = num2str(T(1:2));
    % MM = num2str(T(3:4));
    % S = num2str(T(5:6));
    % Title=['Date (D,M,Y) and time (H,M,S) Simulation: ' D '/' M '/' Y ', ' Hour ':' MM ':' S];
    %H=num2str(hour(H.datetxt,'yyyymmdd_hh'));
    [~,Title]=fileparts(H.SIM_TITLE);
    WordText(ActXWord,Title,Style,[0,1]);%enter after text
    TextString='Default Variables';
    WordText(ActXWord,TextString,Style,[0,1]);%enter after text
    Header = {'Label','Value','Unit','Range','Help'};  %% COLCHANGE %%
    Data = [TH(H.D).Data(:,H.PDCol.Name) TH(H.D).Data(:,H.PDCol.Value) TH(H.D).Data(:,H.PDCol.Unit) TH(H.D).Data(:,H.PDCol.Range) {H.P(H.DefID).Help}'];
    Data = [Header;Data];
    WordCreateTable(ActXWord,Data,0,Pace,Pace)
    ActXWord.ActiveDocument.Tables.Item(H.D).Row.Item(1).Select;
    ActXWord.Selection.Font.Bold = true;
    ActXWord.ActiveDocument.Tables.Item(H.D).Column.Item(1).Select;
    ActXWord.Selection.Font.Bold = true;
    ActXWord.Selection.Start = ActXWord.Selection.End;
    ActXWord.ActiveDocument.Tables.Item(H.D).Row.Last.Select;
    ActXWord.Selection.MoveDown;
    waitbar(2*Pace);
    
    Style='Heading 1';
    TextString='Study Variables';
    WordText(ActXWord,TextString,Style,[0,1]);%enter after text
    Header = {'Label','Value','Unit','Help'}; %% COLCHANGE %%
    Data = [TH(H.C).Data(:,H.PCCol.Name) TH(H.C).Data(:,H.PCCol.Value) TH(H.C).Data(:,H.PCCol.Unit) {H.P(H.VarID).Help}'];
    Data = [Header;Data];
    WordCreateTable(ActXWord,Data,0,2*Pace,Pace)
    ActXWord.ActiveDocument.Tables.Item(H.C).Row.Item(1).Select;
    ActXWord.Selection.Font.Bold = true;
    ActXWord.ActiveDocument.Tables.Item(H.C).Column.Item(1).Select;
    ActXWord.Selection.Font.Bold = true;
    ActXWord.Selection.Start = ActXWord.Selection.End;
    ActXWord.ActiveDocument.Tables.Item(H.C).Row.Last.Select;
    ActXWord.Selection.MoveDown;
    waitbar(3*Pace);
    
    Style='Heading 1';
    TextString='Figures of Merit';
    WordText(ActXWord,TextString,Style,[0,1]);%enter after text
    Header = {'Label','Value','Unit','Help'};
    Data = [TH(H.FOM).Data(:,H.FCol.Name:H.FCol.Unit) {H.F.Help}'];
    Data = [Header;Data];
    WordCreateTable(ActXWord,Data,0,3*Pace,Pace)
    ActXWord.ActiveDocument.Tables.Item(H.FOM).Row.Item(1).Select;
    ActXWord.Selection.Font.Bold = true;
    ActXWord.ActiveDocument.Tables.Item(H.FOM).Column.Item(1).Select;
    ActXWord.Selection.Font.Bold = true;
    ActXWord.Selection.Start = ActXWord.Selection.End;
    ActXWord.ActiveDocument.Tables.Item(H.FOM).Row.Last(1).Select;
    ActXWord.Selection.MoveDown;
    waitbar(4*Pace);
    
    if Pace == 1/5
        Style='Heading 1';
        TextString='Note';
        WordText(ActXWord,TextString,Style,[0,1]);%enter after text
        Style='Normal';
        [nr,~]=size(NH.String);
        NoteText = char(NH.String);
        iFOMT = 1;
        for inr=1:nr
            Target = '*FIG*';
            Shift=length(Target);
            index=strfind(NoteText(inr,:),Target);
            if ~isempty(index)
                for iIndex = 1:length(index)
                    FOMT{iFOMT}.RawLabel=sscanf(NoteText(inr,index(iIndex)+Shift:end),'%s',1);
                    LabLenght = length(FOMT{iFOMT}.RawLabel)+Shift;
                    FigLocation{iFOMT}=GetLabel(FOMT{iFOMT}.RawLabel,H,TH);
                    FigText=strcat(FigLocation{iFOMT}.FOMTLabel,FigLocation{iFOMT}.FOMTypeLabel,'_',FigLocation{iFOMT}.RowName);
                    FigLocation{iFOMT}.FigText = FigText;
                    NewText=char(strcat(NoteText(inr,1:index(iIndex)-1),{' '},FigText,NoteText(inr,index(iIndex)+LabLenght:end)));
                    NoteText=string(NoteText);
                    NoteText(inr) = string(NewText);
                    NoteText = char(NoteText);
                    tempIndex = strfind(NewText,Target);
                    if ~isempty(tempIndex)
                        index(iIndex+1)=tempIndex(iIndex);
                    end
                    iFOMT = iFOMT +1;
                end
            end
        end
        WordText(ActXWord,NoteText,Style,[0,1]);
        if iFOMT ~=1
            Style='Heading 1';
            TextString = 'Figures';
            WordText(ActXWord,TextString,Style,[1,1]);%enter after text
            for iFOMT=1:numel(FigLocation)
                FigTitle{iFOMT} = strcat(FigLocation{iFOMT}.FOMTLabel,FigLocation{iFOMT}.FOMTypeLabel,'_',FigLocation{iFOMT}.RowName);
                WordText(ActXWord,char(FigTitle{iFOMT}),Style,[1,0]);
                wdAlignParagraphCenter = 1;
                ActXWord.Selection.ParagraphFormat.Alignment = wdAlignParagraphCenter;
                WordAddPicture(ActXWord,FigLocation{iFOMT}.Path,true,true);
            end
            
            for iFOMT=1:numel(FigLocation)
                Options = [0,0,0,0,0,0,0];
                found = WordFind(ActXWord,char(FigTitle{iFOMT}),Options);
                if found
                    ActXWord.ActiveDocument.Bookmarks.Add(['F',num2str(iFOMT)]);
                end
                wdScreen = 7;
                is_eof = 1;
                while(is_eof~=0)
                    is_eof=ActXWord.Selection.MoveDown(wdScreen);
                end
                ActXWord.ActiveDocument.Bookmarks.DefaultSorting = 0;
                ActXWord.ActiveDocument.Bookmarks.ShowHidden = true;
            end
            for iFOMT=1:numel(FigLocation)
                Options = [0,0,0,0,0,1,1];
                found = WordFind(ActXWord,FigLocation{iFOMT}.FigText,Options);
                if found
                    ActXWord.ActiveDocument.Hyperlinks.Add(ActXWord.Selection.Range,'',strcat('F',num2str(iFOMT)),['Fig:',num2str(iFOMT)],ActXWord.Selection.Range.Text);
                end
                is_eof = 1;
                while(is_eof~=0)
                    is_eof=ActXWord.Selection.MoveDown(wdScreen);
                end
                
            end
            
        end
        waitbar(5*Pace);
    end
    close(hMsgBox)
    CloseWord(ActXWord,WordHandle,Path);
    button = questdlg({'Completed!','Would you like to open the file?'},'','Yes','No','Yes');
    if strcmpi(button,'yes')
        winopen(Path)
    end
catch ME
    ErrorDisplay(ME);
end
end

%% --- Executes when user attempts to close MultiSimInterface.
function MultiSimInterface_CloseRequestFcn(hO, ~, H)
try
    if H.isCloseLegal
        AppDataTempPath = getapplicationdatadir(fullfile('\Temp'),false,true);
        TempPath = fullfile(AppDataTempPath,'temppath.mat');
        if exist(TempPath,'file')
            delete(TempPath)
        end
        FH = findobj('Type','Figure','-and','CloseRequestFcn','closereq_multisiminterface');
        for ifn = 1:length(FH)
         FH(ifn).CloseRequestFcn = 'closereq';
        end
        close(FH);
        %if isfield(H,'tempname'), rmdir(H.tempname,'s'); end
        matlabpath([H.cmdirs{:}])
        delete(hO);
    end
catch ME
    uiwait(errordlg([ME.message '                       '],'Forcing closing of all figures due to error:'));
    delete(hO);
end
end
%% --- Executes on button press in SaveFig.
function SaveFig_Callback(hO,~, H)
H.SaveFigVal = get(hO,'Value');
end

%%
function SimPath_Callback(~, ~, ~)
end

%% --- Executes during object creation, after setting all properties.
function SimPath_CreateFcn(hO, ~, ~)
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end


%% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over SimPath.
function SimPath_ButtonDownFcn(hO, ~, H)
[PathName]=uigetdircustom('Select the path for the simulation results to be stored');
if PathName == 0, return, end
H.DIR_SIM = PathName;
hO.String = H.DIR_SIM;
guidata(hO,H);
end

%%
function KernelPath_Callback(~, ~, ~)
end

%% --- Executes during object creation, after setting all properties.
function KernelPath_CreateFcn(hO, ~, ~)
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end

%%
function MultiSimPath_Callback(~, ~, ~)
end

%% --- Executes during object creation, after setting all properties.
function MultiSimPath_CreateFcn(hO, ~, ~)
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end

%% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over MultiSimPath.
function MultiSimPath_ButtonDownFcn(hO, ~, H)
[FileName,PathName]=uigetfilecustom('Select the path for the Kernel code');
if PathName == 0, return, end
H.DIR_MULTISIM = [PathName,FileName];
hO.String = H.DIR_MULTISIM;
guidata(hO,H);
end

%% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over KernelPath.
function KernelPath_ButtonDownFcn(hO, ~, H)
[FileName,PathName,FilterIndex]=uigetfilecustom('*.*','Select the Kernel file');
if FilterIndex == 0, return, end
H.DIR_KERNEL = [PathName,FileName];
hO.String = H.DIR_KERNEL;
guidata(hO,H);
end

%% --- Executes when MultiSimInterface is resized.
function MultiSimInterface_SizeChangedFcn(hO, ~, H)
if ~isempty(H) && isfield(H,'isResizeLegal')
    if ~H.isResizeLegal
        FFS(hO);
        return
    end
end
end

%% --- Executes on button press in SimTest.
function SimTest_Callback(hO, ~, H)
H.SimTestVal = get(hO,'Value');
end


%%
function SimTitle_Callback(hO, ~, H)
if isempty(hO.String)
    hO.String = ['Will be the name of the folder of the results. Default will be e.g. ' datestr(now,'yyyymmdd_HHMMSS')];
end
H.SIM_TITLE = hO.String;
guidata(hO,H);
end

%% --- Executes during object creation, after setting all properties.
function SimTitle_CreateFcn(hO, ~, ~)
hO.String = [hO.String 'Will be the name of the folder of the results. Default will be e.g. ' datestr(now,'yyyymmdd_HHMMSS')];
if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end

%% --- Executes during object creation, after setting all properties.
function SimStatus_CreateFcn(hO, ~, ~)

if ispc && isequal(get(hO,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hO,'BackgroundColor','white');
end
end


% =========================================================================
%%                             Functions
% =========================================================================

%%
function LoadData(FullPath,H)
clearvars('-except','FullPath','H');
FH=findobj('type','figure','CloseRequestFcn','closereq_multisiminterface');
for ifh = 1:length(FH)
    FH(ifh).CloseRequestFcn = 'closereq';
end
close(FH);
[~,~,ext] = fileparts(FullPath);
H.FullPath = FullPath;
try
    switch ext
        case '.mat' % SoloIniFIle
            LoadPF(FullPath,H);
        case '.xml'
    end
    LD = H.OH(H.LoadedDataPath);
    LD.String = H.FullPath;
catch ME
    ErrorDisplay(ME);
end
end

%%
function LoadPF(FullPath,H)
MsgH = msgbox('Please wait...','Wait','modal');
pause(0.2);
[pathstr,filename,fexte] = fileparts(FullPath);
load(FullPath,'P','F','DIR_MULTISIM','DIR_SIM','DIR_KERNEL','ROOT_FIG','SIM_TITLE');
clc
[~,Order]=sort([P(:).Order]); %#ok<NODEF>
P=P(Order);
DefID = find([P.Order]==0);
nD = numel(DefID); %#ok<NASGU>
VarID = find([P.Order]~=0);
[~,Order] = sort([P(VarID).Order]);
VarID=VarID(Order);
if isfield(P,'PlotPos')
    switch numel(VarID)
        case 2
            PlotPosID(H.x)=find(strcmpi({P.PlotPos},'x')); PlotPosID(H.y)=find(strcmpi({P.PlotPos},'y'));
        case 3
            PlotPosID(H.x)=find(strcmpi({P.PlotPos},'x')); PlotPosID(H.y)=find(strcmpi({P.PlotPos},'y'));
            PlotPosID(H.row)=find(strcmpi({P.PlotPos},'row'));
        case 4
            PlotPosID(H.x)=find(strcmpi({P.PlotPos},'x')); PlotPosID(H.y)=find(strcmpi({P.PlotPos},'y'));
            PlotPosID(H.row)=find(strcmpi({P.PlotPos},'row')); PlotPosID(H.column)=find(strcmpi({P.PlotPos},'column'));
        otherwise
            PlotPosID(H.x)=find(strcmpi({P.PlotPos},'x')); PlotPosID(H.y)=find(strcmpi({P.PlotPos},'y'));
            PlotPosID(H.row)=find(strcmpi({P.PlotPos},'row')); PlotPosID(H.column)=find(strcmpi({P.PlotPos},'column'));
            PlotPosID(H.window)=find(strcmpi({P.PlotPos},'window'));
    end
else
   PlotPosID(H.x)=VarID(1);PlotPosID(H.y)=VarID(2);PlotPosID(H.row)=VarID(3);PlotPosID(H.column)=VarID(4);PlotPosID(H.window)=VarID(5);
   P(PlotPosID(H.x)).PlotPos='x';P(PlotPosID(H.y)).PlotPos='y';P(PlotPosID(H.row)).PlotPos='row';P(PlotPosID(H.column)).PlotPos='column';P(PlotPosID(H.window)).PlotPos='window';
end
H.PlotPosID = PlotPosID;
nV = numel(VarID);
nF = numel(F); %#ok<NASGU,NODEF>
for iF = 1:nF
    F(iF).Value = real(F(iF).Value);
end
H.Pstart = P;
H.Fstart = F;

if exist('DIR_MULTISIM','var'), set(H.OH(H.PathMultiSim),'String',DIR_MULTISIM); else, DIR_MULTISIM = 'MultiSim Path'; end %#ok<NODEF>
if exist('DIR_SIM','var'), set(H.OH(H.PathSim),'String',DIR_SIM); else, DIR_SIM = 'Results Path'; end %#ok<NODEF>
if exist('DIR_KERNEL','var'), set(H.OH(H.PathKernel),'String',DIR_KERNEL); else, DIR_KERNEL = 'Kernel Path'; end %#ok<NODEF>
if exist('ROOT_FIG','var')
    H.ROOT_FIG = ROOT_FIG; %#ok<NODEF>
else
    [~,ROOT_FIG] = fileparts(pathstr);
    warndlg({'Files may be not located correctly. Please be sure the files all begin with:',ROOT_FIG},'Locate the files');
end
if exist('SIM_TITLE','var'), set(H.OH(H.SimTitle),'String',SIM_TITLE); else, SIM_TITLE = ROOT_FIG; end %#ok<NODEF>

if ~isfield(P,'Help')
    P(1).Help = [];
end
if ~isfield(F,'Help')
    F(1).Help = [];
end

H.F = F;
H.P = P;
H.VarID = VarID;
H.DefID = DefID;
H.pathstr = pathstr;
H.DIR_MULTISIM = DIR_MULTISIM;
H.DIR_KERNEL = DIR_KERNEL;
H.DIR_SIM = DIR_SIM;
H.ROOT_FIG = ROOT_FIG;
H.SIM_TITLE = SIM_TITLE;
H.IniPath = fullfile(pathstr,[filename,fexte]);
H.FirsTimeShowInclusion = true;

H=UpDateTables(H);

if nV == 5
    if iscell(P(PlotPosID(H.window)).Range)
        RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),char(P(PlotPosID(H.window)).Range')]);
    else
        RowName = string([repmat(P(PlotPosID(H.window)).Label,numel(P(PlotPosID(H.window)).Range),1),repmat('=',numel(P(PlotPosID(H.window)).Range),1),num2str((P(PlotPosID(H.window)).Range)','%g')]);
    end
else
    RowName = {'1'};
end
FigPath=CreatePath(pathstr,{F.Label},P,PlotPosID,H,ROOT_FIG);
FillTable(H.OH(H.S),FigPath,RowName,H,{F.Label});

if H.OH(H.S).Position(4)>H.OH(H.S).Extent(4)
    H.OH(H.S).Position(2)=H.OH(H.S).Position(2)+(H.OH(H.S).Position(4)-H.OH(H.S).Extent(4));
    H.OH(H.S).Position(4) = H.OH(H.S).Extent(4);
end
H.OH(H.S).Position(3) = H.OH(H.S).Extent(3);

AddCM(H.OH(H.D),H);
AddCM(H.OH(H.C),H);
AddCM(H.OH(H.FOM),H);

guidata(H.OH(H.LoadData),H);

TempString = uicontrol('Style','text');
TempString.Visible = 'off';
TempString.String = '1;2;3;4';
for iT = H.D:H.FOM
    TempHandle = H.OH(iT);
    Buff1 = TempHandle.Extent;
    Buff1 = Buff1(3);
    POS=TempHandle.Position;
    POSX = POS(3);
    
    switch iT
        case H.D
            Col2Enlarge = H.PDCol.Range;
        case H.C
            Col2Enlarge = H.PCCol.Value;
        case H.FOM
            Col2Enlarge = H.FCol.Levels;
    end
    if ~(Buff1 > POSX -0.01 && Buff1 < POSX +0.01)
        
        for inV = 1:numel(TempHandle.Data(:,Col2Enlarge))
            LENS(inV) = length(TempHandle.Data{inV,Col2Enlarge});
        end
        TempString.FontName = TempHandle.FontName;
        TempString.FontUnits = TempHandle.FontUnits;
        TempString.FontSize = TempHandle.FontSize;
        UnitPerChar = TempString.Extent(3)/length(TempString.String);
        NewLen = mean(LENS).*UnitPerChar;
        TempHandle.ColumnWidth{Col2Enlarge} = NewLen;
        Buff1 = TempHandle.Extent;
        Buff1 = Buff1(3);
        POS=TempHandle.Position;
        POSX = POS(3);
        if Buff1>POSX
            Buff = TempHandle.Extent;
            Buff = Buff(3);
            POS=TempHandle.Position;
            POSX = POS(3);
            while(POSX<=Buff)
                TempHandle.ColumnWidth{Col2Enlarge} = TempHandle.ColumnWidth{Col2Enlarge}*(1-0.01);
                Buff = TempHandle.Extent;
                Buff = Buff(3);
                POS=TempHandle.Position;
                POSX = POS(3);
            end
            TempHandle.ColumnWidth{Col2Enlarge} = TempHandle.ColumnWidth{Col2Enlarge}*(1+0.01);
        else
            Buff = TempHandle.Extent;
            Buff = Buff(3);
            POS=TempHandle.Position;
            POSX = POS(3);
            while(POSX>=Buff)
                TempHandle.ColumnWidth{Col2Enlarge} = TempHandle.ColumnWidth{Col2Enlarge}*(1+0.01);
                Buff = TempHandle.Extent;
                Buff = Buff(3);
                POS=TempHandle.Position;
                POSX = POS(3);
            end
            TempHandle.ColumnWidth{Col2Enlarge} = TempHandle.ColumnWidth{Col2Enlarge}*(1-0.01);
        end
    end
    if TempHandle.Position(4)>TempHandle.Extent(4)
        TempHandle.Position(2)=TempHandle.Position(2)+(TempHandle.Position(4)-TempHandle.Extent(4));
        TempHandle.Position(4) = TempHandle.Extent(4);
    end
end
FFS(findobj('Name',H.InterfaceName));
delete(MsgH);
end

function FillTable(TH,Data,RowName,H,varargin)
Tag = TH.Tag;
if strcmp(Tag,H.O(H.C).Tag) || strcmp(Tag,H.O(H.FOM).Tag)
    for ia = 1: numel(Data(:,H.PDCol.Value))
        B=Data{ia,H.PDCol.Value};
        if iscell(B)
            B1=strcat(B{1});
            for iB = 2:numel(B)
                B1=strcat(B1,';',B{iB});
            end
            B=B1;
            Data(ia,H.PDCol.Value) = {B};
        else
            if any(mod(Data{ia,H.PDCol.Value },1))==0
                format = '%d;';
            else
                format = '%g;';
            end
            Data(ia,H.PDCol.Value) ={num2str(B,format)};
        end
    end
end
if  strcmp(Tag,H.O(H.D).Tag)
    for ia = 1: numel(Data(:,H.PDCol.Range))
        B=Data{ia,H.PDCol.Range};
        if iscell(B)
            B1=strcat(B{1});
            for iB = 2:numel(B)
                B1=strcat(B1,';',B{iB});
            end
            B=B1;
            Data(ia,H.PDCol.Range) = {B};
        else
            if any(mod(Data{ia,H.PDCol.Range},1))==0
                format = '%d;';
            else
                format = '%g;';
            end
            Data(ia,H.PDCol.Range) ={num2str(B,format)};
        end
    end
end
TH.Data = Data;
TH.RowName = RowName;
if numel(varargin)
    TH.ColumnName = varargin{1};
end
end

function ClearContent(H)
TH = findall(findobj('Name',H.InterfaceName),'type','uitable');
nTH = numel(TH);
EmptyVal = {''};
for it=1:nTH
    TH(it).Data = EmptyVal;
    TH(it).RowName = EmptyVal;
    if strcmp(TH(it).Tag,H.O(H.S).Tag)
        TH(it).ColumnName = EmptyVal;
    end
end
EdH=H.OH(H.NotesBox);
EdH.String = 'Insert Notes';
HelpH = H.OH(H.HelpBox);
HelpH.String = 'Help';
LoadedData = H.OH(H.LoadedDataPath);
LoadedData.String = 'Loaded Data Path';
set(H.OH(H.PathMultiSim),'String','Multi Sim Path');
set(H.OH(H.PathKernel),'String','Kernel Name');
set(H.OH(H.PathSim),'String','Sim Path');
set(H.OH(H.SimTitle),'String',['Will be the name of the folder of the results. Default will be e.g. ' datestr(now,'yyyymmdd_HHMMSS')]);
set(H.OH(H.SimStatus),'String','Updates on simulation status');
end

%%
function [NewPath] = CreatePath(Path,FOMT_Name,P,PlotVar,H,varargin)
NPV = numel(PlotVar);
Format = get(H.OH(H.Format),'Value');
FormatList = get(H.OH(H.Format),'String');
Format = ['.' lower(FormatList{Format})];
PlotType = get(H.OH(H.PlotType),'Value');
PlotTypeList = get(H.OH(H.PlotType),'String');
PlotType = PlotTypeList{PlotType}; PlotType = PlotType(1);
if (nargin-5)==1
    Root = varargin{1};
else
    [~,Root]=fileparts(Path);
end
Root=fullfile(Path,Root);
if ~iscell(FOMT_Name)
    FOMT_Name = {FOMT_Name};
end
if NPV>=5
    NewPath = cell(length(P(PlotVar(H.window)).Range),numel(FOMT_Name));
else
    NewPath = cell(1,numel(FOMT_Name));
end

for iFOMT = 1:numel(FOMT_Name)
    if NPV>=5
        for iNCV = 1:length(P(PlotVar(H.window)).Range)
            NewPath{iNCV,iFOMT} = strcat(Root,'_',num2str(iNCV),'_',PlotType,'_',FOMT_Name{iFOMT},Format);
        end
    else
        NewPath{1,iFOMT} = strcat(Root,'_1_',PlotType,'_',FOMT_Name{iFOMT},Format);
    end
end
end

%%
function FillDescriptor(hO,ED,H)
if ~isempty(ED.Indices)
    if ~isfield(H,'P'), return, end
    P = H.P;
    F = H.F;
    DefVar = P(H.DefID);
    VarVar = P(H.VarID);
    switch hO.Tag
        case H.O(H.D).Tag
            HelpString = DefVar(ED.Indices(1)).Help;
        case H.O(H.C).Tag
            HelpString = VarVar(ED.Indices(1)).Help;
        case H.O(H.FOM).Tag
            HelpString = F(ED.Indices(1)).Help;
    end
    if ~isempty(HelpString)
        set(H.OH(H.HelpBox),'String',HelpString)
    else
        set(H.OH(H.HelpBox),'String','Help')
    end
    
    if isfield(H,'Buff')
        H.Buff(end+1).Table = hO.Tag;
        H.Buff(end).Cell = ED.Indices;
        pos = numel(H.Buff);
    else
        H.Buff(1).Table = hO.Tag;
        H.Buff(1).Cell = ED.Indices;
        pos = 1;
    end
    for iT = H.D:H.FOM
        TH(iT) = H.OH(iT);
    end
    H.Buff(pos).DV{1} = TH(H.D).Data;
    H.Buff(pos).DV{2} = TH(H.D).RowName;
    H.Buff(pos).CV{1} = TH(H.C).Data;
    H.Buff(pos).CV{2} = TH(H.C).RowName;
    H.Buff(pos).F{1} = TH(H.FOM).Data;
    H.Buff(pos).F{2} = TH(H.FOM).RowName;
    for iP = 1:numel({H.P.Help})
        H.Buff(pos).HelpP{iP} = H.P(iP).Help;
    end
    for iF = 1:numel({H.F.Help})
        H.Buff(pos).HelpF{iF} = H.F(iF).Help;
    end
    setappdata(findobj('Name',H.InterfaceName),'H',H);
    guidata(hO,H);
end
end

%%
function OpenPath(hO,ED,H)
if ~isempty(ED.Indices)
    if H.FirsTimeShowInclusion == true
        H.FirsTimeShowInclusion = false;
        answer = questdlg('Would like to see the inclusion region?');
        if strcmpi(answer,'yes')
            try
                cmdirs = regexp([matlabpath pathsep],['.[^' pathsep ']*' pathsep],'match')';
                START_PATH = fileparts([mfilename('fullpath'),'.m']);
                DefaultPath = regexp([path pathsep],['.[^' pathsep ']*' pathsep],'match')';
                matlabpath([DefaultPath{:}]);
                cd(START_PATH);
                cd('../');
                addpath(genpath(pwd));
                ys = [-10 10]; xs = linspace(-15,15,4); zs = 0;
                xp = H.P(string({H.P(:).ID}') == 'XP').Range; yp = H.P(string({H.P(:).ID}') == 'YP').Range; zp = H.P(string({H.P(:).ID}') == 'ZP').Range;
                pg.x1 = H.P(string({H.P(:).ID}') == 'X1').Default; pg.x2 = H.P(string({H.P(:).ID}') == 'X2').Default; pg.dx = H.P(string({H.P(:).ID}') == 'DX').Default;
                pg.y1 = H.P(string({H.P(:).ID}') == 'Y1').Default; pg.y2 = H.P(string({H.P(:).ID}') == 'Y2').Default; pg.yx = pg.dx;
                pg.z1 = H.P(string({H.P(:).ID}') == 'Z1').Default; pg.z2 = H.P(string({H.P(:).ID}') == 'Z2').Default; pg.zx = pg.dx;
                ShowInclusionRegion(xs,ys,zs,xp,yp,zp,pg)
                cd(START_PATH);
                matlabpath([cmdirs{:}]);
            catch ME
                ErrorDisplay(ME);
            end
        end
    end
    Path = hO.Data(ED.Indices(1),ED.Indices(2));
    try
        winopen(char(Path));
        msgHandle = msgbox('Opening...');
        pause(1);
        delete(msgHandle)
    catch ME
        try
            [~,fname]=fileparts(char(Path));
            FH = findobj('Tag',fname);
            if isempty(FH)
                throw(ME);
            else
                FH.Visible = 'on';
            end
%             if isfield(H,'tempname')
%                 Path = {fullfile(H.tempname,[fname '.fig'])};
%             else
%                 throw(ME);
%             end
%             winopen(char(Path));
            msgHandle = msgbox('Opening...');
            pause(1);
            delete(msgHandle)
        catch 
            answer = questdlg({'Figure not present.',' Would you like to produce the figures? (Could take a while)'},'Create figure?');
            if strcmpi(answer,'yes')
                nP = numel(H.P);
                Root = fullfile(H.pathstr,H.ROOT_FIG);
                Var=struct('iP',[],'Dim',[]);
                for iP=1:nP
                    if(H.P(iP).Order>0)
                        Var.iP(H.P(iP).Order)=iP;
                        Var.Dim(H.P(iP).Order)=H.P(iP).Dim;
                    end
                end
                PlotType = get(H.OH(H.PlotType),'Value');
                PlotTypeList = get(H.OH(H.PlotType),'String');
                PlotType = PlotTypeList{PlotType}; PlotType = PlotType(1);
                %if ~isfield(H,'tempname')
                %    H.tempname=tempname; mkdir(H.tempname);
                %end
                try
                    MsgH = msgbox('Please wait...','Success');WinOnTop(MsgH,true);
                    ProducedFig = multiFigure(H.P,nP,Var,H.F,ED.Indices(2),PlotType,Root,false);
                    for iPF = 1:length(ProducedFig)
                        ProducedFig(iPF).CloseRequestFcn = 'closereq_multisiminterface';
%                         saveas(ProducedFig(iPF),fullfile(H.tempname,[ProducedFig(iPF).Tag '.fig']))
                    end
                    H.ProducedFig = [H.ProducedFig ProducedFig];
                    close(MsgH);
                    MsgH = msgbox('Figures created','Success'); WinOnTop(MsgH,true); pause(1); 
                catch ME
                    ErrorDisplay(ME);
                end
                H.isCloseLegal = false;
                guidata(hO,H);
                H.isCloseLegal = true;
            end
        end
    end
end
guidata(hO,H);
end

%%
function GetInputForTables(hO,ED,H)
switch hO.Tag
    case H.O(H.D).Tag
        Condition = ED.Indices(2) == H.PDCol.Value || ED.Indices(2) == H.PDCol.Range;
    case H.O(H.C).Tag
        Condition = ED.Indices(2) == H.PCCol.Value;
    case H.O(H.FOM).Tag
        Condition = ED.Indices(2) == H.FCol.Levels;
end
if Condition %ED.Indices(2) == H.PCCol.Value || ED.Indices(2) == H.PDCol.Value || ED.Indices(2) == H.PDCol.Range || ED.Indices(2) == H.FCol.Levels
    try
        if isempty(ED.EditData)
            Evaluated = '';
        else
            if find(ED.EditData==';'), IsCellInput = true; else, IsCellInput = false; end
            if IsCellInput == true, Evaluated = {ED.EditData}; else, Evaluated = eval(ED.EditData); end
        end
        if IsCellInput == true
            hO.Data(ED.Indices(1),ED.Indices(2)) = Evaluated;
        else
            if numel(Evaluated)>=2
                hO.Data(ED.Indices(1),ED.Indices(2)) = {num2str(Evaluated,'%g;')};
            else
                if strcmp(hO.Tag,H.O(H.D).Tag)
                    hO.Data(ED.Indices(1),ED.Indices(2)) = {Evaluated};
                else
                    hO.Data(ED.Indices(1),ED.Indices(2)) = {num2str(Evaluated)};
                end
            end
        end
    catch ME
        ErrorDisplay(ME);
        hO.Data(ED.Indices(1),ED.Indices(2)) = {ED.PreviousData};
        H.ErrorOnGetInputForTables = true;
        guidata(hO,H);
        return
    end
end
switch hO.Tag
    case H.O(H.D).Tag
        Condition = ED.Indices(2) == H.PDCol.LinLog;
    case H.O(H.C).Tag
        Condition = ED.Indices(2) == H.PCCol.LinLog;
    case H.O(H.FOM).Tag
        Condition = ED.Indices(2) == H.FCol.LinLog;
end
if Condition
    switch ED.Indices(2)
        case H.PCCol.LinLog
            Col2Edit = H.PCCol.Value;
        case H.PDCol.LinLog
            Col2Edit = H.PDCol.Range;
        case H.FCol.LinLog
            Col2Edit = H.FCol.Levels;
    end
    if strcmpi(ED.NewData,'Log')
        H.WasLin(find(strcmp(string({H.O.Tag}'),hO.Tag)),ED.Indices(1),Col2Edit).Value = hO.Data(ED.Indices(1),Col2Edit); %#ok<FNDSB>
        hO.Data(ED.Indices(1),Col2Edit) = {num2str(log10(str2num(hO.Data{ED.Indices(1),Col2Edit})'),'%.3e;')};
        H.WasLin(find(strcmp(string({H.O.Tag}'),hO.Tag)),ED.Indices(1),Col2Edit).Logic = true; %#ok<FNDSB>
        guidata(hO,H);
    else
        if H.WasLin(find(strcmp(string({H.O.Tag}'),hO.Tag)),ED.Indices(1),Col2Edit).Logic  %#ok<FNDSB>
            hO.Data(ED.Indices(1),Col2Edit) = ...
                H.WasLin(find(strcmp(string({H.O.Tag}'),hO.Tag)),ED.Indices(1),Col2Edit).Value; %#ok<FNDSB>
            guidata(hO,H);
        end
    end
end
if isfield(H,'Buff')
    pos = numel(H.Buff);
    if pos == 1, pos = pos +1; end
else
    pos = 1;
end
switch hO.Tag
    case H.O(H.D).Tag
        H.Buff(pos).DV{1} = hO.Data;
        H.Buff(pos).DV{2} = hO.RowName;
    case H.O(H.C).Tag
        H.Buff(pos).CV{1} = hO.Data;
        H.Buff(pos).CV{2} = hO.RowName;
    case H.O(H.FOM).Tag
        H.Buff(pos).F{1} = hO.Data;
        H.Buff(pos).F{2} = hO.RowName;
end
guidata(hO,H);
end

%%
function AddCM(TH,H)
CM = uicontextmenu(findobj('Name',H.InterfaceName));
hO = TH;
Tag = hO.Tag;
hO.UIContextMenu = CM;
%uimenu('Parent',CM,'Label','Add row to end','Callback',{@AddRow,hO,H});
if strcmpi(Tag,H.O(H.D).Tag)
    UPM = uimenu('Parent',CM,'Label','Move to Variable parameter');
    UPM1 = uimenu('Parent',CM,'Label','Change order');
    for iNV = 1:numel(H.VarID)
        uimenu('Parent',UPM,'Label',strcat(H.CL,num2str(iNV)),'Callback',{@SwitchVar,hO,H});
    end
    for iND = 1:numel(H.DefID)
        uimenu('Parent',UPM1,'Label',strcat(H.DL,num2str(iND)),'Callback',{@ChangeVarOrder,hO,H});
    end
end
if strcmpi(Tag,H.O(H.C).Tag)
    UPM = uimenu('Parent',CM,'Label','Move to Default parameter');
    UPM1 = uimenu('Parent',CM,'Label','Change order');
    for iND = 1:numel(H.DefID)
        uimenu('Parent',UPM,'Label',strcat(H.DL,num2str(iND)),'Callback',{@SwitchVar,hO,H});
    end
    for iNV = 1:numel(H.VarID)
        uimenu('Parent',UPM1,'Label',strcat(H.CL,num2str(iNV)),'Callback',{@ChangeVarOrder,hO,H});
    end
end
if strcmpi(Tag,H.O(H.FOM).Tag)
    UPM = uimenu('Parent',CM,'Label','Change order');
    for iNF = 1:numel(H.F)
        uimenu('Parent',UPM,'Label',strcat(H.FOML,num2str(iNF)),'Callback',{@ChangeVarOrder,hO,H});
    end
end
end

%%
function SwitchVar(Src,~,hO,H)
H = getappdata(findobj('Name',H.InterfaceName),'H');
SRC = H.Buff(end).Cell(1);
TRG = Src.Position;
switch H.Buff(end).Table
    case H.O(H.D).Tag
        Source = H.P(H.DefID(SRC));
        Target = H.P(H.VarID(TRG));
        RealTRG = H.VarID(TRG);
        RealSRC = H.DefID(SRC);
    case H.O(H.C).Tag
        Source = H.P(H.VarID(SRC));
        Target = H.P(H.DefID(TRG));
        RealTRG = H.DefID(TRG);
        RealSRC = H.VarID(SRC);
end
H.P(RealSRC) = Target;
H.P(RealTRG) = Source;
H.P(RealSRC).PlotPos = Source.PlotPos;
H.P(RealTRG).PlotPos = Target.PlotPos;
H=UpDateTables(H);
H.P(RealSRC).Order = Source.Order;
H.P(RealTRG).Order = Target.Order;
DefID = find([H.P.Order]==0);
VarID = find([H.P.Order]~=0);
[~,Order] = sort([H.P(VarID).Order]);
VarID=VarID(Order);
H.DefID = DefID;
H.VarID = VarID;
setappdata(findobj('Name',H.InterfaceName),'H',H);
guidata(hO,H);
end

%%
function ChangeVarOrder(Src,~,hO,H)
H = getappdata(findobj('Name',H.InterfaceName),'H');
SRC = H.Buff(end).Cell(1);
TRG = Src.Position;
switch hO.Tag
    case H.O(H.D).Tag
        VarType = H.DefID;
    case H.O(H.C).Tag
        VarType = H.VarID;
end
if ~strcmp(H.O(H.FOM).Tag,hO.Tag)
    Source = H.P(VarType(SRC));
    Target = H.P(VarType(TRG));
    RealTRG = VarType(TRG);
    RealSRC = VarType(SRC);
    H.P(RealSRC) = Target;
    H.P(RealTRG) = Source;
    H.P(RealSRC).Order = Source.Order;
    H.P(RealTRG).Order = Target.Order;
    DefID = find([H.P.Order]==0);
    VarID = find([H.P.Order]~=0);
    [~,Order] = sort([H.P(VarID).Order]);
    VarID=VarID(Order);
    H.DefID = DefID;
    H.VarID = VarID;
else
    Source = H.F(SRC);
    Target = H.F(TRG);
    H.F(SRC) = Target;
    H.F(TRG) = Source;
end
H=UpDateTables(H);
setappdata(findobj('Name',H.InterfaceName),'H',H);
guidata(hO,H);
end

%%
function AddRow(~,~,hO,H)
nR = numel(hO.Data(:,1));
[RN]=sscanf(hO.RowName{nR},'%c%d');
switch hO.Tag
    case H.O(H.D).Tag
        H.P=addP(0,numel(H.P)+1,1,0,[],[],0,[],H.P);
        hO.Data(nR+1,:) = repmat({''},1,numel(hO.Data(nR,:)));%{'','','','',''};
        hO.RowName(nR+1) = {strcat(char(RN(1)),num2str(RN(2)+1))};
    case H.O(H.C).Tag
        if nR==5
            warndlg('Can not insert more than 5 variables','Warning');
        else
            hO.Data(nR+1,:) = repmat({''},1,numel(hO.Data(nR,:)));
            H.P=addP(5,numel(H.P)+1,1,0,[],[],0,[],H.P);
            hO.RowName(nR+1) = {strcat(char(RN(1)),num2str(RN(2)+1))};
        end
    case H.O(H.FOM).Tag
        H.F=addF(numel(H.F)+1,[],[],0,0,[],0,[],H.F);
        hO.Data(nR+1,:) = repmat({''},1,numel(hO.Data(nR,:)));
        hO.RowName(nR+1) = {strcat(char(RN(1)),num2str(RN(2)+1))};
end
DefID = find([H.P.Order]==0);
VarID = find([H.P.Order]~=0);
[~,Order] = sort([H.P(VarID).Order]);
VarID=VarID(Order);
H.DefID = DefID;
H.VarID = VarID;
warndlg({'Be careful! Be sure that the inserted variable is in you kernel'},'Warning');
guidata(hO,H);
end

%%
function [OUT]=GetLabel(RawLabel,H,TH)
Index=strfind(RawLabel,'_');
FOMTLabel = RawLabel(1:Index-1);
switch lower(RawLabel(Index(1)+1))
    case 'c'
        FOMTypeLabel = '_Contour';
    case 'p'
        FOMTypeLabel = '_Plot';
end
if length(Index)>1
    RowPos = str2double(RawLabel(Index(2)+1:end));
else
    RowPos = 1;
end
ColPos=find(string(TH(H.S).ColumnName)==FOMTLabel);
RowName = char(TH(H.S).RowName(RowPos));
Path=char(TH(H.S).Data(RowPos,ColPos));
if contains((Path),'.pdf')
    POS=strfind((Path),'.pdf');
    Path(POS+1:end) = 'jpg';
end

OUT.Path = Path;
OUT.FOMTLabel = FOMTLabel;
OUT.FOMTypeLabel = FOMTypeLabel;
OUT.RowPos = RowPos;
OUT.RowName = RowName;
OUT.ColPos = ColPos;
end

%%
function generateXML(FullPath,H)
P=H.P;
F=H.F;
Handle = com.mathworks.xml.XMLUtils.createDocument('Ini');
Root = Handle.getDocumentElement;
Pparams = Handle.createElement('P');
Root.appendChild(Pparams);

for ii=1:numel(P)
    Pelem = Handle.createElement(strcat('P',num2str(ii)));
    %Pfields = Handle.createElement('Fields');
    Pelem.setAttribute('Order',num2str(P(ii).Order));
    Pelem.setAttribute('ID',num2str(P(ii).ID));
    Pelem.setAttribute('Default',num2str(P(ii).Default));
    if isnumeric(P(ii).Range)
        Pelem.setAttribute('Range',num2str(P(ii).Range));
    else
        if numel(string(P(ii).Range))>1
            buffer = P(ii).Range{1};
            for iN = 2:numel(string(P(ii).Range))
                buffer = char(strcat(buffer,{' '},P(ii).Range{iN}));
            end
        else
            buffer = char(P(ii).Range);
        end
        Pelem.setAttribute('Range',buffer);
    end
    Pelem.setAttribute('Label',P(ii).Label);
    Pelem.setAttribute('Unit',P(ii).Unit);
    Pelem.setAttribute('Title',num2str(P(ii).Title));
    if numel(string(P(ii).Help))>1
        buffer = P(ii).Help(1,:);
        for iN = 2:numel(string(P(ii).Help))
            buffer = char(strcat(buffer,{' '},P(ii).Help(iN,:)));
        end
    else
        buffer = P(ii).Help;
    end
    Pelem.setAttribute('Help',buffer);
    Pparams.appendChild(Pelem);
end
Fparams = Handle.createElement('F');
Root.appendChild(Fparams);
for ii=1:numel(F)
    Felem = Handle.createElement(strcat('F',num2str(ii)));
    %Ffields = Handle.createElement('Fields');
    Felem.setAttribute('Label',F(ii).Label);
    Felem.setAttribute('Unit',F(ii).Unit);
    Felem.setAttribute('minV',num2str(F(ii).minV));
    Felem.setAttribute('maxV',num2str(F(ii).maxV));
    Felem.setAttribute('Levels',num2str(F(ii).Levels));
    Felem.setAttribute('Treshold',num2str(F(ii).Treshold));
    if numel(string(F(ii).Help))>1
        buffer = F(ii).Help(1,:);
        for iN = 2:numel(string(F(ii).Help))
            buffer = char(strcat(buffer,{' '},F(ii).Help(iN,:)));
        end
    else
        buffer = F(ii).Help;
    end
    Felem.setAttribute('Help',buffer);
    Fparams.appendChild(Felem);
end

xmlwrite(FullPath,Handle);
%type('temp.xml')
end

%%
function [H]=FindAllH(H)

H.D = 1;
H.C = 2;
H.FOM = 3;
H.S = 4;
H.HelpBox = 5;
H.EditData = 6;
H.NotesBox = 7;
H.LoadedDataPath = 8;
H.LoadData = 9;
H.PathMultiSim = 10;
H.PathSim = 11;
H.PathKernel = 12;
H.SaveFig = 13;
H.Format = 14;
H.PlotType = 15;
H.SimTest = 16;
H.SimTitle = 17;
H.SimStatus = 18;
H.SaveProducedFig = 19;
H.CreateProducedFigures = 20;

minID = H.D;
maxID = H.CreateProducedFigures;

H.Name = 1;
H.Value = 2;
H.Unit = 3;
H.Help = 4;
H.DL = 'D';
H.CL = 'C';
H.FOML = 'F';
H.Cont = 'C';
H.Plot = 'P';

if isfield(H,'TagAppend')
    return
else
    
    H.O(H.D).Tag = 'DT';
    H.O(H.C).Tag = 'CT';
    H.O(H.FOM).Tag = 'FOMT';
    H.O(H.S).Tag = 'ST';
    H.O(H.HelpBox).Tag = 'HelpBox';
    H.O(H.EditData).Tag = 'EditData';
    H.O(H.NotesBox).Tag = 'NotesBox';
    H.O(H.LoadedDataPath).Tag = 'LoadedDataPath';
    H.O(H.LoadData).Tag = 'LoadData';
    H.O(H.PathMultiSim).Tag = 'MultiSimPath';
    H.O(H.PathSim).Tag = 'SimPath';
    H.O(H.PathKernel).Tag = 'KernelPath';
    H.O(H.SaveFig).Tag = 'SaveFig';
    H.O(H.SimTest).Tag = 'SimTest';
    H.O(H.Format).Tag = 'Format';
    H.O(H.PlotType).Tag = 'PlotType';
    H.O(H.SimTitle).Tag = 'SimTitle';
    H.O(H.SimStatus).Tag = 'SimStatus';
    H.O(H.SaveProducedFig).Tag = 'SaveProducedFig';
    H.O(H.CreateProducedFigures).Tag = 'CreateProducedFigures';
    H.RootInterfaceName = 'MultiSimInterface';
    H.InterfaceName = 'MultiSimInterface';
    H.RealInterfaceName = 'MultiSimInterface';
    H.x = 1;
    H.y = 2;
    H.row = 3;
    H.column = 4;
    H.window = 5;
    
    H.SaveFigVal = false;
    H.ProducedFig = [];
    H.DIR_INTERFACE = pwd;
    H.isCloseLegal = true;
    H.isResizeLegal = true;
    H.StartEdit = false;
    H.FirsTimeShowInclusion = true;
    H.PDCol.Name = 1;
    H.PDCol.Value = 2;
    H.PDCol.Unit = 3;
    H.PDCol.Title = 4;
    H.PDCol.Range = 5;
    H.PDCol.LinLog = 6;
    H.PCCol.Name = 1;
    H.PCCol.Value = 2;
    H.PCCol.Unit = 3;
    H.PCCol.Title = 4;
    H.PCCol.PlotOrder = 5;
    H.PCCol.LinLog = 6;
    H.FCol.Name = 1;
    H.FCol.Levels = 2;
    H.FCol.Unit = 3;
    H.FCol.Treshold = 4;
    H.FCol.LinLog = 5;
    
    set(findobj('Name',H.RootInterfaceName),'Name',[H.RootInterfaceName '-' num2str(H.NumOccur)])
    H.InterfaceName = [H.RootInterfaceName '-' num2str(H.NumOccur)];
    AllObj = findobj(findobj('Name',[H.RootInterfaceName '-' num2str(H.NumOccur)]),'-depth',2);
    for iAO = 1:numel(AllObj)
        for iH = minID:maxID
            if strcmp(AllObj(iAO).Tag,H.O(iH).Tag)
                H.OH(iH) = AllObj(iAO);
            end
        end
    end
    
end

end

%%
function [H]=UpDateTables(H)
P = H.P;
F = H.F;
DefID = H.DefID;
nD = numel(DefID);
VarID = H.VarID;
nV = numel(VarID);
nF = numel(F);
TH = H.OH(H.D);
TH.ColumnFormat(H.PDCol.Title) = {'logical'};
Data = [{P(DefID).Label}' {P(DefID).Default}' {P(DefID).Unit}' num2cell(logical([P(DefID).Title])') {P(DefID).Range}']; %% COLCHANGE %%
RowName = string(strcat(repmat(H.DL,nD,1),num2str((1:nD)')));
FillTable(H.OH(H.D),Data,RowName,H);

TH = H.OH(H.C);
TH.ColumnFormat(H.PCCol.Title) = {'logical'};
Data = [{P(VarID).Label}' {P(VarID).Range}' {P(VarID).Unit}' num2cell(logical([P(VarID).Title])') {P(VarID).PlotPos}'];  %% COLCHANGE %%
RowName = string(strcat([repmat(H.CL,nV,1),num2str((1:nV)')]));
FillTable(H.OH(H.C),Data,RowName,H);

Data = [{F.Label}' {F.Levels}' {F.Unit}' {F.Treshold}'];
RowName = string([repmat(H.FOML,nF,1),num2str((1:nF)')]);
FillTable(H.OH(H.FOM),Data,RowName,H);
end


%% --- Executes on button press in SaveProducedFig.
function SaveProducedFig_Callback(hO, ~, H)
%if (get(hO,'Value')==true&&H.OH(H.CreateProducedFigures).Value==true), else, return; end
if (get(hO,'Value')==true), else, return; end
%flist=dir(H.tempname);
%FigNames = {flist([flist.isdir]~=1).name};
if isempty(H.ProducedFig), warndlg('No figures to be saved'); return, end
hMsgBox = waitbar(0,{'Saving figures','Please wait... Could take few seconds'});
for ifn = 1:length(H.ProducedFig)
    H.ProducedFig(ifn).CloseRequestFcn = 'closereq';
    save_figure(fullfile(H.pathstr,H.ProducedFig(ifn).Tag),H.ProducedFig(ifn),'-jpg','-pdf','-eps');
    close(H.ProducedFig(ifn));
    waitbar(ifn/length(H.ProducedFig))
    WinOnTop(hMsgBox,true);
end
H.ProducedFig = [];
close(hMsgBox);
guidata(hO,H);
end

% --- Executes on button press in CreateProducedFigures.
function CreateProducedFigures_Callback(hO, ~, H)
if get(hO,'Value')==true, else, return; end
H.isCloseLegal = false;
guidata(hO,H);
close all
flist=dir(H.tempname);
FigNames = {flist([flist.isdir]~=1).name};
hMsgBox = waitbar(0,{'Creating figures','Please wait... Could take few seconds'});
for ifn = 1:length(FigNames)
    winopen(fullfile(H.tempname,FigNames{ifn}))
    waitbar(ifn/length(FigNames))
    WinOnTop(hMsgBox,true);
end
close(hMsgBox);
guidata(hO,H);
end
