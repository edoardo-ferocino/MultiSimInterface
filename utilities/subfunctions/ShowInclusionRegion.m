function ShowInclusionRegion(xs,ys,zs,xp,yp,zp,physicalgrid)
[xxs,yys,zzs] = ndgrid(xs,ys,zs);

DOT.Source.Pos = [xxs(:),yys(:),zzs(:)];
DOT.Detector.Pos = [xxs(:),yys(:),zzs(:)];

figure,plot3(DOT.Source.Pos(:,1),DOT.Source.Pos(:,2),DOT.Source.Pos(:,3),'r*'),grid,
xlabel('x'),ylabel('y'),zlabel('z'),hold on
plotcube([xp(end)-xp(1) yp(end)-yp(1) zp(end)-zp(1) ],...
    [xp(1) yp(1) zp(1)],0.2,[1 0 0])
set(gca,'zdir','reverse'),axis equal,
xlim([physicalgrid.x1 physicalgrid.x2]),...
    ylim([physicalgrid.y1 physicalgrid.y2]),...
    zlim([physicalgrid.z1 physicalgrid.z2])
end