clear all
%Fontsize=7; % Thinkpad X1
Fontsize=16; % PC InstAS 300%
fontreduction = 9;

nspline = 10; % nodes of the spline segments (6)
outrange = 90; % average range of values to remove outliers (90)


% requires package statistics for VRP cleaning
pkg load statistics % only needed in octave to load the signal package
pkg load io % only needed in octave to load and save xlsx files
pkg load matgeom % to draw arrows


function [subDirsNames] = GetSubDirsFirstLevelOnly(parentDir)
    % Get a list of all files and folders in this folder.
    files = dir(parentDir);
    % Get a logical vector that tells which is a directory.
    dirFlags = [files.isdir];
    % Extract only those that are directories.
    subDirs = files(dirFlags); % A structure with extra info.
    % Get only the folder names into a cell array.
    subDirsNames = {subDirs(3:end).name};
end

%path = 'c:\Users\kob\Documents\GitHub\analysistools\';
path = 'c:\temp\LSME\VRP\';

cd(path);
partlist = GetSubDirsFirstLevelOnly(pwd)
clf
%hold on
for partidx = 1:size(partlist,2)
  disp('_________________________________')
  actpart = char(partlist(partidx))
  cd(actpart)
  figpath=path;
  reclist = dir('*.vph');
  for recidx = 1:size(reclist,1)
    disp('_________________________________')
    fname_org = reclist(recidx).name;
    fname=[fname_org(1:end-4)];
    fname=strrep(fname,'.','_')
    fnamestr=strrep(fname,'_','\_');
    fnamecellarray=cellstr(fname);


    csvfile=[path, fname_org];
    fid = fopen(fname_org);
    vrptext = textscan(fid,"%s");
    fclose(fid);
    vrptext = cell2mat(vrptext);

    offset = 60;
    fRangemin = 0;
    do
      offset++;
      xtract = vrptext{offset};
      fmax=str2num(xtract);
      xtract = vrptext{offset+17};
      fRangemin=str2num(xtract);
    until ((fRangemin != 0) & (not(isempty(fmax))))

    xtract = vrptext{offset+5};
    fmin=str2num(xtract)
    fmax
    xtract = vrptext{offset+15};
    Lmin=str2num(xtract)
    xtract = vrptext{offset+10};
    Lmax=str2num(xtract)
    fRangemin;
    xtract = vrptext{offset+116};
    fRangemax=str2num(xtract);

    for idx = 1:100
      counter= idx-1+offset+17;
      freqvec(idx) = str2num(vrptext{counter});
    end

    counterVRPstart = counter+1;
    xtract = vrptext{counterVRPstart};
    Lrangemax=str2num(xtract);

    counter=counterVRPstart+79*101;
    xtract = vrptext{counter};
    Lrangemin=str2num(xtract);
    Lrangemax;
    %clf
    for rowidx=1:Lrangemax-Lrangemin+1
        lineidx = counterVRPstart+(rowidx-1)*size(freqvec,2);
        for colidx = 1:size(freqvec,2)
          idx = lineidx+colidx+rowidx-1;
          VRPstr=vrptext{idx};
          VPR(rowidx,colidx) = str2num(VRPstr);
        end
    end
    Lvec = [Lrangemax:-1:Lrangemin];
    [M,c]=contour(freqvec,Lvec,VPR);

    xlabel('Frequenz (Hz)')
    ylabel('SPL (dB)')
    title([strrep(fname,'_','\_'), ' - frange: ',num2str(fmin), '..',num2str(fmax), ' = ',num2str(fmax-fmin), 'Hz, Lrange: ',num2str(Lmin), '..',num2str(Lmax), ' = ',num2str(Lmax-Lmin), 'dB']);
    grid on
    set(gca,"XScale","log")
    set(gca,"XMinorGrid","on")
    set (gca,"yminorgrid","on");
    set(gca,"Fontsize",5)
    set(gca,"Xlim",[fRangemin-1 fRangemax+100])
    set(gca,"Ylim",[Lrangemin-1 Lrangemax+1])

    pSPL=zeros(1,100);
    fSPL=zeros(1,100);
    dada=get(c,"zdata");
    for Fidx= 1:100
        try
            pSPLidx(Fidx)=max(find(dada(:,Fidx)));
            pSPL(Fidx) = Lvec(pSPLidx(Fidx));
            fSPLidx(Fidx)=min(find(dada(:,Fidx)));
            fSPL(Fidx) = Lvec(fSPLidx(Fidx));
        end
    end
    pSPLl  = pSPL(find(pSPL));
    pFreq = freqvec(find(pSPL));
    fSPLl  = fSPL(find(fSPL));
    fFreq = freqvec(find(fSPL));
    line(pFreq,pSPLl,'LineWidth',1,'Color', 'c')
    line(fFreq,fSPLl,'LineWidth',1,'Color', 'm')

    TFmax = isoutlier (fSPLl, "movmedian", outrange, "SamplePoints", fFreq);
    TFmin = isoutlier (pSPLl, "movmedian", outrange, "SamplePoints", pFreq);
    fF = fFreq(~TFmax); % Frequencies of forte curve
    fL = fSPLl(~TFmax); % Levels of forte curve
    pF = pFreq(~TFmin); % Frequencies of piano curve
    pL = pSPLl(~TFmin); % Levels of piano curve

    line(fFreq(~TFmax),fSPLl(~TFmax),'LineWidth',1,'Color',"r")
    line(pFreq(~TFmin),pSPLl(~TFmin),'LineWidth',1,'Color',"b")
    hold on
    % Transformation der x-Koordinaten auf logarithmische Skala
    fF = log10(fF);
    pF = log10(pF);

    % Spline-Interpolation

    % forte curve
%    pp = spline(x, [0, y, 0]);
    fLsplineobject = spline (fF,[0,fL,0]);
    ffspline = logspace(log10(min(fF)),log10(max(fF)),nspline);
%    ffspline = linspace(min(fF),max(fF),nspline);
    fLspline = ppval(fLsplineobject, ffspline);
    % piano curve
    pLsplineobject = spline (pF, [0,pL,0]);
%    pfspline = linspace(min(pF),max(pF),nspline);
    pfspline = logspace(log10(min(pF)),log10(max(pF)),nspline);
    pLspline = ppval(pLsplineobject, pfspline);

    x1 = ffspline;  % Abszissen für die erste Kurve (logarithmisch)
    y1 = fLspline;  % Ordinaten der ersten Kurve
    x2 = pfspline;  % Abszissen für die zweite Kurve (logarithmisch)
    y2 = pLspline;  % Ordinaten der zweiten Kurve

    % Numerische Integration der Fläche zwischen den beiden Kurven (Trapezregel)
    A = trapz(x1, y1 - y2);  % Fläche zwischen den beiden Kurven

    % Berechnung der x-Koordinate des Schwerpunkts
    x_center = trapz(x1, x1 .* (y1 - y2)) / A;

    % Berechnung der y-Koordinate des Schwerpunkts
    y_center = trapz(x1, 0.5 * (y1 + y2) .* (y1 - y2)) / A;

    xs = 10.^(x_center);

    % Rücktransformation der Frequenzachse von log nach lin
    ffspline = 10.^(ffspline);
    pfspline = 10.^(pfspline);
    ys = y_center;

    % Ausgabe der Ergebnisse

    plot (ffspline,fLspline,'LineWidth',3,"r");
    plot (pfspline,pLspline,'LineWidth',3,"b");

    disp(['Schwerpunkt x-Koordinate: ', num2str(xs)]);  % zurücktransformieren
    disp(['Schwerpunkt y-Koordinate: ', num2str(ys)]);

    % Elipsen-Berechnung
    [X,Y] = calculateEllipse(xs,ys, 10, 1, 0);
    plot(X, Y,'LineWidth',5,'g');

    % evaluate Euclidian distances
    lf = [(ffspline(1)+(ffspline(2)))/2, (fLspline(1)+(fLspline(2)))/2];
    idxmf = floor(size(ffspline,2)/2);
    idxmL = floor(size(fLspline,2)/2);
    mf = [(ffspline(idxmf)+(ffspline(idxmf+1)))/2, (fLspline(idxmL)+(fLspline(idxmL+1)))/2];
    hf = [(ffspline(end-1)+(ffspline(end)))/2, (fLspline(end-1)+(fLspline(end)))/2];
    line([xs, lf(1)], [ys, lf(2)], "linestyle", "-", ...
    "LineWidth",3, "color", "g")
    line([xs, mf(1)], [ys, mf(2)], "linestyle", "-", ...
    "LineWidth",3, "color", "g")
    line([xs, hf(1)], [ys, hf(2)], "linestyle", "-", ...
    "LineWidth",3, "color", "g")

    lp = [(pfspline(1)+(pfspline(2)))/2, (pLspline(1)+(pLspline(2)))/2];
    idxmf = floor(size(pfspline,2)/2);
    idxmL = floor(size(pLspline,2)/2);
    mp = [(pfspline(idxmf)+(pfspline(idxmf+1)))/2, (pLspline(idxmL)+(pLspline(idxmL+1)))/2];
    hp = [(pfspline(end-1)+(pfspline(end)))/2, (pLspline(end-1)+(pLspline(end)))/2];
    line([xs, lp(1)], [ys, lp(2)], "linestyle", "-", ...
    "LineWidth",3, "color", "g")
    line([xs, mp(1)], [ys, mp(2)], "linestyle", "-", ...
    "LineWidth",3, "color", "g")
    line([xs, hp(1)], [ys, hp(2)], "linestyle", "-", ...
    "LineWidth",3, "color", "g")

    hold off

    clear ExcelContent;
    ExcelContent= [{[actpart,'\',fname]}];
    rstatus = xlswrite ([path,'VRP_',fname], ExcelContent,'A1:A1');
    ExcelContent= [{'fsoft'},{'Lsoft'},{'floud'},{'Lloud'}];
    rstatus = xlswrite ([path,'VRP_',fname], ExcelContent,'A2:D2');
    ExcelContent= [[pF'],[pL']];
    rstatus = xlswrite ([path,'VRP_',fname], ExcelContent,'A3:B1000');
    ExcelContent= [[fF'],[fL']];
    rstatus = xlswrite ([path,'VRP_',fname], ExcelContent,'C3:D1000');

    ca={"< A1/,A","< A2/A", "< A3/a", "< A4/a'", "< A5/a''", "< A6/a'''"};
    cdes={"< Db2/Des", "< Db3/des", "< Db4/des'", "< Db5/des''", "< Db6/des'''"};
    %cd={"< D2/D", "< D3/d", "< D4/d'", "< D5/d''", "< D6/d'''"};
    cf={"< F2/F", "< F3/f", "< F4/f'", "< F5/f''", "< F6/f'''"};
    fa  =55;
    fdes=69.2957;
    %fd  =73.4162;
    ff  =87.3071;
    ypos =44;

    for fidx = 0:4
      text(2^fidx*fa, ypos, ca(fidx+1),"Fontsize",Fontsize-fontreduction)
      text(2^fidx*fdes, ypos, cdes(fidx+1),"Fontsize",Fontsize-fontreduction)
      text(2^fidx*ff, ypos, cf(fidx+1),"Fontsize",Fontsize-fontreduction)
      line([2^fidx*fa, 2^fidx*fa],[Lrangemin-1 Lrangemax+1],'LineWidth',1,'LineStyle',':','Color', 'g')
      line([2^fidx*fdes, 2^fidx*fdes],[Lrangemin-1 Lrangemax+1],'LineWidth',1,'LineStyle',':','Color', 'g')
      line([2^fidx*ff, 2^fidx*ff],[Lrangemin-1 Lrangemax+1],'LineWidth',1,'LineStyle',':','Color', 'g')
    endfor

    set(gca,"Fontsize",Fontsize)
    saveas(gcf,[path,fname(1:end-4),'_VRP.png'])
  endfor
  cd ..
endfor
%hold off
