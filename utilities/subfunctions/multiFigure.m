function [varargout]=multiFigure(P,nP,Var,F,iF,Type,Root,SaveFig)
for iP=1:nP
    if(P(iP).Order>0)
        Var.iP(P(iP).Order)=iP;
        Var.Dim(P(iP).Order)=P(iP).Dim;
    end
end
nV = numel(Var.iP);

kk=1.001;
Value=reshape(F(iF).Value,Var.Dim);
MainTitle=[F(iF).Label ' - '];
for iP=1:nP
    if((P(iP).Order==0)&&(P(iP).Title==1)), MainTitle=[MainTitle P(iP).Label '=' num2str(P(iP).Default) P(iP).Unit ', ']; end %#ok<AGROW>
end
%tresh_z=F(iF).Treshold;
%levels=F(iF).Levels;

scrsz = get(0,'ScreenSize');
ox = find(strcmpi({P(:).PlotPos}','x'));  oy = find(strcmpi({P(:).PlotPos}','y')); or = find(strcmpi({P(:).PlotPos}','row'));
oc = find(strcmpi({P(:).PlotPos}','column')); ow = find(strcmpi({P(:).PlotPos}','window'));
dox = find(Var.iP == ox); doy = find(Var.iP == oy); dor = find(Var.iP == or); doc = find(Var.iP == oc); dow = find(Var.iP == ow);
switch nV
    case 2
        PermuteVector = [dox doy]; nr = 1; nc = 1; nw = 1;
    case 3
        PermuteVector = [dox doy dor]; nr=P(or).Dim; nc = 1; nw = 1;
        lr=P(or).Label; ur=P(or).Unit;
    case 4
        PermuteVector = [dox doy dor doc]; nr=P(or).Dim; nc=P(oc).Dim; nw = 1;
        lr=P(or).Label; lc=P(oc).Label; ur=P(or).Unit; uc=P(oc).Unit;
    otherwise
        PermuteVector = [dox doy dor doc dow]; nr=P(or).Dim; nc=P(oc).Dim; nw=P(ow).Dim;
        lr=P(or).Label; lc=P(oc).Label; ur=P(or).Unit; uc=P(oc).Unit;
end
Value=permute(Value,PermuteVector);
nx=P(ox).Dim; ny=P(oy).Dim;
x=P(ox).Range; y=P(oy).Range;% r=P(or).Range; c=P(oc).Range; w=P(ow).Range;
lx=P(ox).Label; ly=P(oy).Label;% lr=P(or).Label; lc=P(oc).Label; %lw=P(ow).Label;
ux=P(ox).Unit; uy=P(oy).Unit; %ur=P(or).Unit; uc=P(oc).Unit; %uw=P(ow).Unit;

for iw=1:nw
    h(iw)=figure('Name',[F(iF).Label '_' num2str(iw) '_' Type],'Position',[0 0 scrsz(3) scrsz(4)]);
    subplot1(nr,nc, 'XTickL', 'Margin', 'YTickL', 'Margin','YScale','linear');
    for ir=1:nr
        for ic=1:nc
            subplot1(ic+nc*(ir-1));
            zvalues=squeeze(Value(:,:,ir,ic,iw)');
            if (nx==1)&&(ny==1), zvalues=repmat(zvalues,2,2); xx=[x kk*x]; yy=[y kk*y];
            elseif (nx==1), zvalues=repmat(zvalues,1,2); xx=[x kk*x]; yy=y;
            elseif (ny==1), zvalues=repmat(zvalues,2,1); xx=x; yy=[y kk*y];
            else, xx=x; yy=y;
            end
            %if(min(xx)<0.5*max(xx)), minx=0; else minx=min(xx); end
            %if(min(yy)<0.5*max(yy)), miny=0; else miny=min(yy); end
            if Type=='C'
                caxis([F(iF).minV F(iF).maxV])
                pcolor(xx,yy,zvalues); hold on; shading interp; colormap('jet');
                contour(xx,yy,zvalues,F(iF).Levels,'b','ShowText','on'); hold on;
                contour(xx,yy,zvalues,[F(iF).Treshold 1E30],'k','LineWidth',2);
                %xlim([minx max(xx)]); ylim([miny max(yy)]);
                %xlim([min(xx) max(xx)]); ylim([min(yy) max(yy)]);
                grid on;
            else
                semilogy(xx,zvalues); hold on;
                %xlim([minx max(xx)]);
                ylim([F(iF).minV F(iF).maxV]);
                grid on;
            end
            if(ir==nr), xlabel([lx ' (' ux ')']); end
            if nV == 2
                if(ic==1), ylabel({[ly ' (' uy ')']}); end
            else
                if nV == 3
                    if(ic==1), ylabel({[lr ' = ' num2str(P(or).Range(ir)) ' ' ur];[ly ' (' uy ')']}); end
                else
                    if(ic==1), ylabel({[lr ' = ' num2str(P(or).Range(ir)) ' ' ur];[ly ' (' uy ')']}); end
                    if(ir==1), title([lc ' = ' num2str(P(oc).Range(ic)) ' ' uc]); end
                end
                
                hold off;
            end
        end
    end
    if Type=='P', legend(num2str(yy')); end %else, colorbar; end
    suptitle(MainTitle);
    NameFig=[Root '_' num2str(iw) '_' Type '_' F(iF).Label];
    [~,fname]=fileparts(NameFig);
    h(iw).Tag = fname; %#ok<AGROW>
    if nargout, varargout{1}=h; end
    if SaveFig, save_figure(NameFig,h,'-jpg','-pdf','-eps'); end
end