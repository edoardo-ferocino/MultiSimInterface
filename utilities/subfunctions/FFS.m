%% Creates a full screen figure
function [ varargout ] = FFS( varargin )
W='MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame';
isFH = false;
warning('off',W);
for iv=1:numel(varargin)
    if strcmpi(varargin{iv},'visible') && strcmpi(varargin{iv+1},'off')
        varargin{iv+1} = 'on';
        S=warning('query','backtrace');
        warning('off','backtrace');
        warning('FFS:VisiblePropOff','Visible property must be ''on''');
        warning(S);
    end
    if ishandle(varargin{iv})
        isFH = true;
        FH = varargin{iv};
    end
end
if ~isFH, FH=figure(varargin{:}); end
try
    jFrame = get(handle(FH),'JavaFrame');
    TimeOut = 10;
    iT = 0;
    while(~jFrame.isMaximized && iT<=TimeOut)
        pause(0.5)
        jFrame.setMaximized(true);
        pause(0.5)
        iT = iT +1;
    end
    if iT>= TimeOut
        try
            scrsz = get(0,'ScreenSize');
            FH.Position = [0 0 scrsz(3) scrsz(4)];
        catch ME
            warndlg({'Cannot set full screen the figure due to: ',ME.message});
        end
    end
    warning('on',W);
catch
    try
        scrsz = get(0,'ScreenSize');
        FH.Position = [0 0 scrsz(3) scrsz(4)];
    catch ME
        warndlg({'Cannot set full screen the figure due to: ',ME.message});
    end
end
if nargout
    varargout{1} = FH;
end
end