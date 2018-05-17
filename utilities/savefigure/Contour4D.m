function h=Contour4D(P,nP,Var,F,iF,SaveFig);
    kk=1.001;
    Value=reshape(F(iF).Value,Var.Dim);
    MainTitle=[F(iF).Label ' - '];
    for iP=1:nP
        if(P(iP).Order==0), MainTitle=[MainTitle P(iP).Label '=' num2str(P(iP).Default) P(iP).Unit ', ']; end
    end
    tresh_z=F(iF).Treshold;
    scrsz = get(0,'ScreenSize');
    ox=Var.iP(1); oy=Var.iP(2); or=Var.iP(3); oc=Var.iP(4);
    nx=P(ox).Dim; ny=P(oy).Dim; nr=P(or).Dim; nc=P(oc).Dim;
    x=P(ox).Range; y=P(oy).Range; r=P(or).Range; c=P(oc).Range;
    lx=P(ox).Label; ly=P(oy).Label; lr=P(or).Label; lc=P(oc).Label;
    ux=P(ox).Unit; uy=P(oy).Unit; ur=P(or).Unit; uc=P(oc).Unit;

    figure('Name',F(iF).Label,'Position',[0 0 scrsz(3) scrsz(4)]);
    levels=[1E-7 1E-6 1E-5 1E-4 1E-3 1E-2 3E-2 6E-2 1E-1 3E-1 6E-1 1E0 1E1 1E2 1E3 1E4 1E5 1E6 1E7 1E8 1E9 1E10 1E11 1E12];
    subplot1(nr,nc, 'XTickL', 'Margin', 'YTickL', 'Margin','YScale','linear');
    for ir=1:nr,
        for ic=1:nc,
            subplot1(ic+nc*(ir-1));
            zvalues=squeeze(Value(:,:,ir,ic)');
            if (nx==1)&&(ny==1), zvalues=repmat(zvalues,2,2); xx=[x kk*x]; yy=[y kk*y];
            elseif (nx==1), zvalues=repmat(zvalues,1,2); xx=[x kk*x]; yy=y;
            elseif (ny==1), zvalues=repmat(zvalues,2,1); xx=x; yy=[y kk*y];
            else xx=x; yy=y; end
            contour(xx,yy,zvalues,levels,'b','ShowText','on'); hold on;
            %set(gca,'YScale','log')
            contour(xx,yy,zvalues,[tresh_z 1E30],'k','LineWidth',2);
            %contourf(x,y,zvalues,[-1E30 1E-3],'r','LineWidth',2);
            if(min(xx)<0.5*max(xx)), minx=0; else minx=min(xx); end
            if(min(yy)<0.5*max(yy)), miny=0; else miny=min(yy); end
            xlim([minx max(xx)]); ylim([miny max(yy)]);
            if(ir==nr), xlabel([lx ' (' ux ')']); end
            if(ic==1), ylabel({[lr ' = ' num2str(P(or).Range(ir)) ' ' ur];[ly ' (' uy ')']}); end
            if(ir==1), title([lc ' = ' num2str(P(oc).Range(ic)) ' ' uc]); end
            %pcolor(x,y,zvalues); shading interp; colormap(pink);
            hold off;
        end
    end
    h=0;
    suptitle(MainTitle);
    %NameFig=['..\Results\multiSolus\' F(iF).Label '_' P(ox).Label '_' P(or).Label '_' P(oc).Label];
    datetxt = datestr(now,'yyyy_mm_dd_HH_MM_SS');
    NameFig=['c:\temp\' 'c_' F(iF).Label '_' datetxt];
    if SaveFig, save_figure(NameFig); end
end