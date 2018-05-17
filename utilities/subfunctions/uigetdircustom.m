function [DirName]=uigetdircustom(varargin)
AppDataTempPath = getapplicationdatadir(fullfile('\Temp'),false,true);
TempPath = fullfile(AppDataTempPath,'temppath.mat');
if exist(TempPath,'file')    % Load the Sim.mat file
    load(TempPath)
    if exist('DirName','var')
        switch numel(varargin)
            case 0
                Title = 'Select Directory to Open';
            case 1
                Title = varargin{1};
            case 2
                Title = varargin{1}; DirName = varargin{2};
        end
        DirName = uigetdir(DirName,Title);
    else
        DirName = uigetdir(varargin{:});
    end
else
    DirName = uigetdir(varargin{:});
    save(TempPath,'DirName');
end
if DirName == 0, return, end
VarArginDir = varargin;
if isempty(VarArginDir)
    save(TempPath,'DirName','-append');
else
    save(TempPath,'DirName','VarArginDir','-append');
end

end