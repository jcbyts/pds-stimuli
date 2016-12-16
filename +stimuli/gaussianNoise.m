classdef gaussianNoise < handle
    %GAUSSIANNOISE draw multiscale gaussian noise blobs
    %   Detailed explanation goes here
    
    properties
        ptr
        tex
        rect
        contrast
        lifetime
        N
        step
        levels
        sigma0
        count
        x
        y
        gridpos
        sc
        aspectratio
        dc
        scale
        dim
        ranNumGen
    end
    
    properties (Access = private)
        mypars
        texrect
        inrect
        dstRects
        sigmas
        ns
        sx
        sy
        life
        levelix
    end
    
    methods
        % constructor
        function n=gaussianNoise(ptr, varargin)
            ip=inputParser();
            ip.addParameter('N', 4)
            ip.addParameter('levels', 4)
            ip.addParameter('sigma0', 2)
            ip.addParameter('step', 1)
            ip.addParameter('sc', 30)
            ip.addParameter('dim', [1920 1080])
            ip.addParameter('contrast', .5)
            ip.addParameter('aspectratio', 1.0)
            ip.addParameter('dc', .5)
            ip.addParameter('lifetime', 1)
            ip.addParameter('rng', RandStream('twister'))
            ip.parse(varargin{:})
            
            n.ptr=ptr;
            n.lifetime=ip.Results.lifetime;
            n.contrast=ip.Results.contrast;
            n.N=ip.Results.N;
            n.step=ip.Results.step;
            n.sigma0=ip.Results.sigma0;
            n.levels=ip.Results.levels;
            n.ns=n.N.^(1:n.levels);
            n.count=sum(n.ns);
            n.dim=ip.Results.dim;
            n.sc=ip.Results.sc;
            n.aspectratio=ip.Results.aspectratio;
            n.dc=ip.Results.dc;
            n.ranNumGen=ip.Results.rng;
            
        end
        
        
        function setup(n)
            % Initialize matrix with spec for all 'ngabors' patches to start off
            % identically:
            n.mypars = repmat([n.contrast, n.sc, n.aspectratio, 0]', 1, n.count);
            
            [n.tex, n.texrect] = CreateProceduralGaussBlob(n.ptr, 250, 250, [0 0 0 0], 1, .5);

            Screen('DrawTexture', n.ptr, n.tex, [], CenterRectOnPoint(n.texrect, n.dim(1)/2, n.dim(2)/2), [], [], [], [], [], kPsychDontDoRotation, [n.contrast, n.sc, n.aspectratio, 0]);
            n.inrect = repmat(n.texrect', 1, n.count);
            n.sigmas = n.sigma0./((n.step*2).^((1:n.levels)-1));
            
            n.sx=ceil(n.dim(1)./n.sigmas);
            n.sy=ceil(n.dim(2)./n.sigmas);
            
            n.life=randi(n.ranNumGen,n.lifetime,[1 n.count]); 
            
            % get index for each level
            n.levelix=arrayfun(@(x,y) x:y, 1+[0 cumsum(n.ns(1:end-1))], cumsum(n.ns), 'UniformOutput', false);
            n.scale=zeros(1,n.count);
            
            for level=1:n.levels
                n.scale(n.levelix{level})=n.sigmas(level);
            end
            
            n.x=zeros(1, n.count);%rand(n.ranNumGen,1,n.count) * n.dim(1);
            n.y=zeros(1, n.count);%rand(n.ranNumGen,1,n.count) * n.dim(2);
            n.gridpos=zeros(1, n.count);
            n.mypars(1,:) = sign(randn(n.ranNumGen,1,n.count))*n.contrast;
            n.dstRects = CenterRectOnPointd(n.inrect .* repmat(n.scale,4,1), n.x, n.y);
        end
        
        function update(n)
            
            
            for level=1:n.levels
                ix=n.life==0 & n.scale==n.sigmas(level);
                c=sum(ix);
                if c==0
                    continue
                end
                
                n.gridpos(ix)=randi(n.sx(level)*n.sy(level), [c 1]);
                [i,j]=ind2sub([n.sy(level) n.sx(level)], n.gridpos(ix));
    
                n.x(ix)=((j-1) ./ n.sx(level)) * (n.dim(1));
                n.y(ix)=((i-1) ./ n.sy(level)) * (n.dim(2));
                
                n.life(ix)=n.lifetime+1;
            end
            
            n.life=n.life-1;

            tx=n.scale.*n.texrect(3)/2;
            ty=n.scale.*n.texrect(4)/2;
            n.dstRects=[n.x-tx;n.y-ty;n.x+tx;n.y+ty];
        end
        
        function ix=getLevelIndex(n, level)
            ix=n.levelix{level};
        end
        
        function [gridx, gridy]=getGrid(n, level)
            if exist('level', 'var')
                xgrid=(((1:n.sx(level))-1) ./n.sx(level)) * n.dim(1);
                ygrid=(((1:n.sy(level))-1) ./n.sy(level)) * n.dim(2);
                [gridx,gridy]=meshgrid(xgrid, ygrid);
            else
                
                gridx=cell(n.levels,1);
                gridy=cell(n.levels,1);
                
                for level=1:n.levels
                    xgrid=(((1:n.sx(level))-1) ./n.sx(level)) * n.dim(1);
                    ygrid=(((1:n.sy(level))-1) ./n.sy(level)) * n.dim(2);
                    [gridx{level},gridy{level}]=meshgrid(xgrid, ygrid);
                end
            end
        end
        
        function c=getContrast(n)
            c=n.mypars(1,:);
        end
        
        function draw(n)
            Screen('DrawTextures', n.ptr, n.tex, [], n.dstRects, 0, 0, [], [], [], kPsychDontDoRotation, n.mypars);
        end
        
        function img=image(n)
            [xx,yy]=meshgrid(0:(n.dim(1)-1), 0:(n.dim(2)-1));
            s=[n.texrect(3) n.texrect(4)];
            fun=@(x,y,s,c) c*exp(- ( (xx-x).^2 + (yy - y).^2)/(2*s^2));
            img=0;
            for i=1:n.count
                tmp=fun(n.x(i), n.y(i), n.scale(i).*n.sc, n.mypars(1,i)*n.contrast);
                tmp=tmp*512;
                % window out texture region
                ix=abs(xx-n.x(i))>s(1)*n.scale(i) & abs(yy-n.y(i))>s(2)*n.scale(i);
                tmp(ix)=0;
                img=img+tmp;
            end
            img(abs(img)<1)=0;
            img=img+127;
            img=ceil(img);
        end
        
        function lvl=getLevels(n,idx)
            gridx=n.getGrid;
            nb=cumsum(cellfun(@(x) numel(x), gridx));
            si=[1; nb(1:end-1)+1]; % starting index for each level
            lvl=arrayfun(@(x) find(x >= si & x <= nb), idx(:));
        end
        
        function [B, x0, y0]=getBasis(n, idx, win)
            warning('implement version that uses procedural gaussians')
            [xx,yy]=meshgrid(1:n.dim(1),1:n.dim(2)); % pixels of screen
            [gridx, gridy]=n.getGrid;
            nb=cellfun(@(x) numel(x), gridx);
            si=[1; nb(1:end-1)+1]; % starting index for each level
            ilevel=arrayfun(@(x) find(x >= si & x <= nb), idx(:));
            
            if exist('win', 'var')
               ii=((xx>=win(1) & xx<=win(3) & yy >= win(2) & yy <= win(4)));

               xx=reshape(xx(ii), [win(4)-win(2)+1 win(3)-win(1)+1]); 
               yy=reshape(yy(ii), [win(4)-win(2)+1 win(3)-win(1)+1]); 
            end
            B=zeros(numel(xx), numel(idx));
            
            for level=1:n.levels
                gridi=idx(ilevel==level) - (si(level)-1);
                if isempty(gridi)
                    continue
                end
                xp=gridx{level}(gridi);
                yp=gridy{level}(gridi);
                
                B(:,ilevel==level)=n.contrast*exp(-.5*(bsxfun(@minus, xx(:), xp(:)').^2 + ...
                    bsxfun(@minus, yy(:), yp(:)').^2)/(n.sc*n.sigmas(level))^2);
            end
            
            x0=xx(1,:);
            y0=yy(:,1)';
            
        end
        
        
        function [Bw, x0, y0]=evaulateWeightsOnBasis(n, idx, w, win)
            warning('implement version that uses procedural gaussians')
            [xx,yy]=meshgrid(1:n.dim(1),1:n.dim(2)); % pixels of screen
            [gridx, ~]=n.getGrid;
            nb=cellfun(@(x) numel(x), gridx);
            si=[1; nb(1:end-1)+1]; % starting index for each level
            ilevel=arrayfun(@(x) find(x >= si & x <= nb), idx(:));
            
            if exist('win', 'var')
               ii=((xx>=win(1) & xx<=win(3) & yy >= win(2) & yy <= win(4)));

               xx=reshape(xx(ii), [win(4)-win(2)+1 win(3)-win(1)+1]); 
               yy=reshape(yy(ii), [win(4)-win(2)+1 win(3)-win(1)+1]); 
            end
            Bw=zeros(numel(xx),1);
            
            for i=1:numel(idx)
                pos=n.getXYcenters(idx(i));
                sig=n.sigmas(ilevel(i));
                
                g=n.contrast*exp(-.5* ((xx(:)-pos(1)).^2 + ...
                    (yy(:)-pos(2)).^2)/(n.sc*sig)^2);
                Bw=Bw+g*w(i);
            end
            
            x0=xx(1,:);
            y0=yy(:,1)';
            
        end
        
        
        function pos=getXYcenters(n,idx)
            [gridx, gridy]=n.getGrid;
            gridx=cell2mat(cellfun(@(x) x(:), gridx, 'UniformOutput', false));
            gridy=cell2mat(cellfun(@(x) x(:), gridy, 'UniformOutput', false));
            pos = [gridx(idx) gridy(idx)];
        end
        
        function [fr, po, co]=getProjectedStim(n, pos, idx)
            
%             nFrames=size(pos,1);
            c=sign(n.getContrast)';
            
            fr=[];
            po=[];
            co=[];
            
            for i=1:numel(idx)
                ii=pos==idx(i);
                
                if ~any(ii(:))
                    continue
                end
                [tmpfr,tmpsh]=ind2sub(size(pos),find(ii));
                
                fr=[fr; tmpfr(:)];
                po=[po; i*ones(numel(tmpfr),1)];
                co=[co; c(tmpsh)];
            end
            
%             posNew=zeros(numel(pos),1);
%             for i=1:numel(idx)
%                 posNew(pos==idx)=i;
%             end
%             cut=posNew==0;
%             fr(cut)=[];
%             posNew(cut)=[];
%             con(cut)=[];
%             
%             XB=sparse(fr, pos, con, nFrames, numel(idx));
        end
        
        function ix=getNextLevelIdx(n, idx)
            if ~exist('idx', 'var') || isempty(idx)
                gridx=n.getGrid(1);
                ix=1:numel(gridx);
                return
            end
            lvls=n.getLevels(idx);
            currentLevel=max(lvls);
            if currentLevel==n.levels
                return
            end
            thisLevel=idx(lvls==currentLevel);
            pos=n.getXYcenters(thisLevel);
            minxy=min(pos, [], 1);
            maxxy=max(pos, [], 1);
            [gridx, gridy]=n.getGrid;
            nb=sum(cellfun(@numel, gridx(1:currentLevel)));
            gridx=gridx{currentLevel+1};
            gridy=gridy{currentLevel+1};
            s=2*n.sigmas(currentLevel)*n.sc;
            win=[minxy(1)-s minxy(2)-s maxxy(1)+s maxxy(2)+s];
            
            ii=gridx(:)>=win(1) & gridx(:) <= win(3) ...
                & gridy(:)>=win(2) & gridy(:) <= win(4);
            ix=nb+find(ii);
        end
    end
    
end



