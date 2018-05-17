function [FileName,PathName,FilterIndex]=uigetfilecustom(varargin)
AppDataTempPath = getapplicationdatadir(fullfile('\Temp'),false,true);
TempPath = fullfile(AppDataTempPath,'temppath.mat');
if exist(TempPath,'file')    % Load the Sim.mat file
    load(TempPath) %#ok<*LOAD>
    if exist('PathName','var')
        switch numel(varargin)
            case 0
                Type = {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files'}; Title = 'Select File to Open';
            case 1
                Type = varargin{1}; Title = 'Select File to Open';
            case 2
                Type = varargin{1}; Title = varargin{2};
            case 3
                Type = varargin{1}; Title = varargin{2}; PathName = varargin{3};
        end
        [FileName,PathName,FilterIndex] = uigetfile(Type,Title,PathName);
    else
        [FileName,PathName,FilterIndex] = uigetfile(varargin{:});
    end
else
    [FileName,PathName,FilterIndex] = uigetfile(varargin{:});
    save(TempPath,'FilterIndex');
end
if FilterIndex == 0, return, end
VarArginFile = varargin;
if isempty(VarArginFile)
    save(TempPath,'PathName','-append');
else
    save(TempPath,'PathName','VarArginFile','-append');
end

end