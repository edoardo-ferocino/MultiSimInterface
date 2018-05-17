function [TOAdds,Sender]=RetrieveDataEmail(varargin)
if nargin, if isempty(varargin{1}), TOAdds = []; Sender = []; return, end
    Path = getapplicationdatadir('\Temp',0,1);
    List=dir(Path);
    ListIdx = [List.isdir]';
    List=char(List(ListIdx).name);
    ListIdx=strfind(string([List(:,1:2)]),'tp');
    for iL = 1:numel(ListIdx)
        if isempty(ListIdx{iL})
            continue
        else
            DirContent = dir(fullfile(Path,List(iL,:)));
            for iDC = 1:numel(DirContent)
                if (DirContent(iDC).bytes ~= 0)
                    Name = sscanf(DirContent(iDC).name,'%d.%d');
                    if ~isempty(Name)
                        if nargin
                            if strcmp(num2str(varargin{1}),DirContent(iDC).name(1:end-4))
                                load(fullfile(DirContent(iDC).folder,DirContent(iDC).name));
                                rmdir(DirContent(iDC).folder,'s');
                                break;
                            end
                        else
                            load(fullfile(DirContent(iDC).folder,DirContent(iDC).name));
                            rmdir(DirContent(iDC).folder,'s');
                            break;
                        end
                    end
                end
            end
        end
    end
end

end