function varargout = HideFig(varargin)
    if nargin == 0
        check_status = true;
    else
        check_status = false;
    end
    if check_status == false
        status = {'on','off'};
        status=status{logical(varargin{1})+1};
        if strcmpi(status,'on'), WindowStyle = 'normal'; else, WindowStyle = 'docked'; end
        set(groot,'DefaultFigureVisible',status);
        set(0,'DefaultFigureVisible',status);
        set(0,'DefaultFigureWindowStyle',WindowStyle);
        warning(status,'MATLAB:Figure:SetOuterPosition');
        warning(status,'MATLAB:Figure:SetPosition');    
    else
        gr = get(groot,'Default');
        varargout{1} = gr;
    end
end