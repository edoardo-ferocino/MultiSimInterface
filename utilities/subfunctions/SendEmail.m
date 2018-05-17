function SendEmail(FROM,TO,SUBJECT,BODY,varargin)
SenderUserName = FROM.email;
SenderPassword = FROM.password;

if (nargin-4) == 1
    ATTACH = varargin{1};
    if iscell(ATTACH), nAtt = numel(ATTACH); end
else
    nAtt = 0;
end

if iscell(TO), nRec = numel(TO); SingleRec = 0; else, nRec = 1; SingleRec = 1; end

try
    rmpref('Internet');
catch ME
    if strcmpi(ME.message,'MATLAB:rmpref:GroupMustExist'), end
end

if strfind(lower(SenderUserName),'gmail')
    Gmail(SenderUserName,SenderPassword,'465','true','true');
else
    if strfind(lower(SenderUserName),'polimi')
        Polimi(SenderUserName,SenderPassword,'587','true','true'),
    else
        errordlg('Email server not supported','Email not sent');
        return
    end
end


try
    for iRec = 1:nRec
        if SingleRec
            TOAddress = TO;
        else
            if ~isempty(TO{iRec})
                TOAddress = TO{iRec};
            else
                break
            end
        end
        if nAtt == 0
            sendmail(TOAddress,SUBJECT,BODY);
        else
            sendmail(TOAddress,SUBJECT,BODY,ATTACH);
        end
    end
catch ME
    errordlg(ME.message,'Email NOT sent');
end
rmpref('Internet')
end

function Polimi(SenderUserName,SenderPassword,Port,IsAuth,IsTTLS)
 setpref('Internet', 'SMTP_Server',   'smtp.office365.com');
setpref('Internet', 'SMTP_Username', SenderUserName); %12345678@polimi.it
setpref('Internet', 'SMTP_Password', SenderPassword);
setpref('Internet','E_mail',SenderUserName);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth',                IsAuth);  
props.setProperty('mail.smtp.starttls.enable',     IsTTLS);
props.setProperty('mail.smtp.socketFactory.port',  Port); % 25
props.remove('mail.smtp.socketFactory.class');
end

function Gmail(SenderUserName,SenderPassword,Port,IsAuth,IsTTLS)
setpref('Internet', 'SMTP_Server',   'smtp.gmail.com');
setpref('Internet', 'SMTP_Username', SenderUserName);
setpref('Internet', 'SMTP_Password', SenderPassword);
setpref('Internet','E_mail',SenderUserName);
props = java.lang.System.getProperties;
props.setProperty('mail.smtp.auth',                IsAuth);
props.setProperty('mail.smtp.starttls.enable',     IsTTLS);
props.setProperty('mail.smtp.socketFactory.port',  Port);
props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
end