function [isSendEmail,varargout]=GetEmailData()
%SenderInfo = inputdlg({'Email:','Password:'},'Datas will be immediately deleted',1,{'mario.rossi@mail.it                                  ','12345678'},'on');
%SenderInfo = inputdlg({'Email:','Password:'},'Suggested: username@gmail.com. Polimi server may not work properly',[1, length('Datas will be immediately deleted')+80]);
SenderInfo{1} = 'noreply.simulation@gmail.com';
SenderInfo{2} = 'simulation';
if isempty(SenderInfo)
    isSendEmail = false;
    if (nargout-1)==1, varargout{1} = []; end
    return; 
else
     isSendEmail = true; %#ok<NASGU>
end 
    Sender.email = lower(SenderInfo{1});
    Sender.password = SenderInfo{2};
    TOAdds = inputdlg({'Address1:','Address2:','Address3','Address4','Address5'},...
        'Enter up to 5 email addresses,a message will be sent at the end of the simulation',[1, length('Enter up to 5 email addresses,a message will be sent at the end of the simulation')+80]);
    if isempty(TOAdds)
        isSendEmail = false;
        if (nargout-1)==1, varargout{1} = []; end
        return; 
    else
        isSendEmail = true;
    end
    %DIR = tempname;
    %mkdir(DIR);
    %SubDir = now;
    %save([DIR '\' num2str(SubDir) '.mat'],'TOAdds','Sender');
    if (nargout-1)==1, varargout{1} = TOAdds; end
    %clear Sender TOAdds DIR SubDir
end