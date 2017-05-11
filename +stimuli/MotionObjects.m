classdef MotionObjects < handle
    % MOTION OBJECT Summary of this class goes here
    %   Call by passing in a pldaps and the number of objects
    %   m=MotionOject(pldapsObject, Num, varargin)
    %   
    %   All arguments can be vectorized and if they are, must be size Num
    properties (Access = public)
        ptr                     % pointer to PTB display
        hReward                 % reward class
        N@double                % number of motion objects
        radius@double           % array of object sizes
        visible@logical         % visible or not
        type                    % stimulus type (1: face, 2: dotfield)
        motion@double           % motion type (1: linear)
        forcefield@logical      % false
        speed@double            % array of speeds
        direction@double        % array of directions
        exploded
        dx@double               
        dy@double
        xpx@double
        ypx@double
        x@double
        y@double 
        
        % dots for explosions
        dotx@double
        doty@double
        dotdx@double
        dotdy@double
        dotS@double
        dotC@double
        dotCtr@double
        dotI@double
        
        objects
        texid
        dstRects
        MarmoFaces
        rotAngles
        alpha
        srcRect
        ctrHold
        ctrExplode
        deathExplode@logical
        expThresh
        colorThresh
        color
        faceint
        stimtype
        expSpeed
        dotSize
        expDur
        expRad
        winRect
        repulse
        invade
        maxradius
        removed
    end
    
    properties (Access = private)
        dWidth % display width
        dHeight
        pWidth
        pHeight
        
        ifi % inter frame interval (1/framerate)
        ppd
        ctr
    end
    
    methods
        % --- Contstructor make motion objects
        function m=MotionObjects(p, N, varargin)
            % m=MotionOject(pldapsObject, Number, varargin)
            % Since we're setting most of the parameters here, we don't
            % need to parse a lot of arguments. Let's just set it up
            
            % --- Save all important pldaps variables
            m.ptr       = p.trial.display.ptr;
            
            m.hReward   = stimuli.reward(p);
            m.dWidth    = p.trial.display.dWidth;
            m.dHeight   = p.trial.display.dHeight;
            m.pWidth    = p.trial.display.pWidth;
            m.pHeight   = p.trial.display.pHeight;
            
            m.ppd     = p.trial.display.ppd;
            m.ctr     = p.trial.display.ctr;
            m.ifi     = p.trial.display.ifi;
            
            m.N=N; % number
            
            ip=inputParser();
            ip.addParameter('initialRange', 40)
            ip.addParameter('forceField', false)
            ip.addParameter('motionType', 'linear')
            ip.addParameter('type', 'face')
            
            ip.parse(varargin{:}); % parse optional inputs
            
            m.type = ip.Results.type;
            
            switch m.type
                case {1, 'face', 'Face'}
                    m.objects = stimuli.face(p);
                case {2, 'grating', 'Grating'}
                    m.objects = stimuli.gratings(p);
            end
            % -------------------------------------------------------------
            % --- Build objects based on argument sets
            m.x=(rand(1,m.N)-0.5)*ip.Results.initialRange;
            m.y=(rand(1,m.N)-0.5)*ip.Results.initialRange;
            
            
            %***** two kinds of objects, 
            %***** small and slow, low reward, (glow yellow)
            %***** and fast and big, higher reward (glow red)
            m.stimtype      = randi(3,1,m.N); %1+floor( rand(1,m.N) * 3.99999);
            m.invade        = ones(1,m.N);  % no expansion rate
            m.removed       = zeros(1,m.N);  % take out of game (allow to clear board)
            m.maxradius     = 8.0;
            m.deathExplode  = false(1,m.N);
            m.direction     = rand(1,m.N)*360;
            
            m.visible=false(1,m.N);
            m.exploded = 0;
            
            % initialize variables
            m.radius        = nan(1,m.N);
            m.speed         = nan(1,m.N);
            m.dotSize       = nan(1,m.N);
            m.faceint       = nan(1,m.N);
            m.expSpeed      = nan(1,m.N);
            m.expThresh     = nan(1,m.N);
            m.expDur        = nan(1,m.N);
            m.expRad        = nan(1,m.N);
            m.repulse       = ones(1,m.N);
            m.color         = ones(3,m.N);
            m.colorThresh   = 40;
            m.alpha         = ones(1,m.N); % faces appear gradually
            m.rotAngles     = zeros(1,m.N);
            m.ctrExplode    = zeros(1,m.N);
            m.ctrHold       = zeros(1,m.N);
            
            % --- setup parameters based on reward category
            for i = unique(m.stimtype(:)')
                
                ix=m.stimtype==i;
                n=sum(ix);
                
                switch i
                    case 1
                        m.radius(ix)        = 1;
                        m.speed(ix)         = 12+rand(1,n)*4;
                        m.expThresh(ix)     = 90;  % red
                        m.faceint(ix)       = randi(2,1,n); % two face options
                        m.expSpeed(ix)      = 15;
                        m.dotSize(ix)       = 3;
                        m.expDur(ix)        = 60;
                        m.expRad(ix)        = 12;
                    case 2
                        m.radius(ix)        = 1;
                        m.speed(ix)         = 8+rand(1,n)*4;
                        m.expThresh(ix)     = 60;  % red
                        m.faceint(ix)       = 2+randi(2,1,n); % two face options
                        m.expSpeed(ix)      = 10;
                        m.dotSize(ix)       = 2;
                        m.expDur(ix)        = 40;
                        m.expRad(ix)        = 8;
                    case 3
                        m.radius(ix)        = 1;
                        m.speed(ix)         = 4+rand(1,n)*4;
                        m.expThresh(ix)     = 30;  % red
                        m.faceint(ix)       = 4+randi(2,1,n); % two face options
                        m.expSpeed(ix)      = 5;
                        m.dotSize(ix)       = 2;
                        m.expDur(ix)        = 20;
                        m.expRad(ix)        = 4;
                    otherwise
                        m.radius(ix)        = 1;
                        m.speed(ix)         = 4+rand(1,n)*4;
                        m.expThresh(ix)     = 30;  % red
                        m.faceint(ix)       = 7+randi(2,1,n); % two face options
                        m.expSpeed(ix)      = 5;
                        m.dotSize(ix)       = 1;
                        m.expDur(ix)        = 20;
                        m.expRad(ix)        = 4;
                end
            end
            
            
            %********* select a set of face invaders
            invaders=(m.stimtype == 4);
            if any(invaders)
                ix=invaders & (rand(1,m.N)< 0.5);
                m.invade(ix) = 1.0015;
                m.speed(ix)  = 12 + 4*rand(1,sum(ix));
            end % invader selection
            
            % ---- Setup explosion dots
            maxDots=100*m.N;
            m.dotx    = nan(1,maxDots);
            m.doty    = nan(1,maxDots);
            m.dotdx   = nan(1,maxDots);
            m.dotdy   = nan(1,maxDots);
            m.dotS    = nan(1,maxDots);
            m.dotI    = reshape(ones(100,1)*(1:m.N), 1, maxDots);
            m.dotC    = zeros(3, maxDots);
            m.dotCtr  = zeros(1, maxDots);
            
        end % constructor
        
%         function [hit,loc,rad,death] = exploded(m)
%            hit = 0;
%            loc = [];
%            rad = 0;
%            death = 0;
%            if (m.ctrExplode == 1)
%                hit = 1;
%                loc = m.xy;
%                rad = m.expRad;
%            end
%            if (m.deathExplode == 1)
%                death = 1;
%            end
%         end
        
        function wipeclear(m) %,loc,rad,death)
%             
%             if ( size(m.xy,1) == 1 )  %don't clear if it is already exploding
%              if (m.removed == 0)   
%                dist = norm(m.xy - loc);
%                if (dist < rad)
%                   if (death == 1)
%                       m.deathExplode = 1;  % explosion becomes infectious
%                   else
%                       
%                      %*******
%                      winRect=m.winRect;
%                      %******
%                      dv = (m.xy - loc)/dist;
%                      newxy = loc + (rad * dv);  % jump stim just outside radius
%                      %***** safety check if explosion pushes it outside
%                      %boundaries, and if so then re-initialize it
%                      newxypixx = pds.deg2px(newxy',m.p.trial.display.viewdist,m.p.trial.display.w2px,false)...
%                                     +m.p.trial.display.ctr(1:2)';
%                      if (newxypixx(1) < winRect(1)) | (newxypixx(1) > winRect(3)) | ...
%                         (newxypixx(2) < winRect(2)) | (newxypixx(2) > winRect(4)) 
%                          %newxy = loc - (rad*dv);
%                           m.ctrExplode = 1;  % if so, explode it as well
%                           if (death == 0)
%                              m.p.trial.exploded=m.p.trial.exploded+1;  % can get points, else not
%                           end
%                      else
%                           m.xy = newxy;
%                      end
%                      %******
%                   end
%               end 
%             end
%           end
        end
        
        % -----------------------------------------------------------------
        % General move function
        function move(m)
            
            % --- Reset Exploded  Faces
            iiExploded  = m.ctrExplode > m.expDur;
            iiInvade    = m.invade > 1;
            
            if any(iiExploded)
                % remove dots from being shown
                for i = unique(find(iiExploded))
                    m.dotx(m.dotI==i)=nan;
                end
                m.x(iiExploded) = randn(1, sum(iiExploded))*5; % reset position
                m.y(iiExploded) = randn(1, sum(iiExploded))*5; % reset position
                m.expRad(iiExploded & (m.stimtype < 3)) = 16 - m.stimtype(iiExploded & (m.stimtype < 3))*4;
                ii=iiInvade & iiExploded;
                if any(ii) % reset to small stimulus
                    m.radius(ii)    = 2;
                    m.dotSize(ii)   = 1;
                    m.expDur(ii)    = 20;
                    m.expSpeed(ii)  = 5;
                    m.expRad(ii)    = 4;
                    m.speed(ii)     = 12 + rand(1,sum(ii))*4;
                    m.expThresh(ii) = 20;
                end
                
                
                %*****************
                m.refresh(iiExploded);
                %*******************
                
                m.ctrExplode(iiExploded)    = 0;
                m.deathExplode(iiExploded)  = 0;
                m.ctrHold(iiExploded)       = 0;
                
                
            end
            
            iiIntact  = m.ctrExplode == 0;% & ~m.removed;
            
            ii = iiIntact & iiInvade;
            if any(ii) % any intact invaders
               m.radius(ii)    = m.radius(ii) .* m.invade(ii);
               m.dx(ii)        = m.dx(ii) .* m.invade(ii);
               m.dy(ii)        = m.dy(ii) .* m.invade(ii);
               m.dotSize(ii)   = m.dotSize(ii) .* m.invade(ii);
               m.expDur(ii)    = m.expDur(ii) .* m.invade(ii);
               m.expSpeed(ii)  = m.expSpeed(ii) .* m.invade(ii);
               m.expThresh(ii) = m.expThresh(ii) .* m.invade(ii);
            end
            
            % --- death explode
            ii=m.radius > m.maxradius;
            if any(ii)
                m.ctrExplode(ii)    = 1;
                m.deathExplode(ii)  = 1;
                m.exploded          = m .exploded-1;
                m.speed(ii)         = 16;
            end
            
            % --- Bounce of walls
            ii=m.x > m.dWidth/2 | m.x < -m.dWidth/2;
            m.dx(ii) = -m.dx(ii);
            m.x(ii)  = m.x(ii) + m.repulse(ii) .* m.dx(ii); % repulse
            
            ii=m.y > m.dHeight/2 | m.y < -m.dHeight/2;
            m.dy(ii) = -m.dy(ii);
%             m.y(ii)  = m.y(ii) + m.repulse(ii) .* m.dy(ii); % repulse
            
            % --- Translate position
            m.x = m.x + m.dx;
            m.y = m.y + m.dy;
                        
            % --- Calculate texture rectangles
            m.dstRects = kron([-1; -1; 1; 1], m.radius*m.ppd) + kron([1; 1], [m.ppd*m.x + m.ctr(1); -m.ppd*m.y + m.ctr(2)]);
            
            iiExplode = m.ctrHold>m.expThresh & iiIntact;
            if any(iiExplode)
                m.ctrExplode(iiExplode)=1;
                m.exploded=m.exploded+1;
                
                % flag for removal
                m.removed(iiExplode & ( (m.stimtype > 1 & m.stimtype < 4) | rand(1, m.N) < (1/3)))=1;
            end
            
%             if any(m.deathExplode)
% %                 m.ctrExplode(m.deathExplode)=1;
%                 m.expRad(m.deathExplode)=16;
%                 m.exploded=m.exploded-sum(m.deathExplode);
%             end
            
            iiExplode=(m.ctrExplode==1); % first frame of explosion
            if any(iiExplode)
                m.hReward.give();
                
               for i = find(iiExplode)
                    ii=m.dotI==i;
                    
                    m.dotx(ii)=m.x(i)*m.ppd + m.ctr(1);
                    m.doty(ii)=-m.y(i)*m.ppd + m.ctr(2);
                    m.dotdx(ii)=randn(1,100)*m.expSpeed(i);
                    m.dotdy(ii)=randn(1,100)*m.expSpeed(i);
                    m.dotC(:,ii)=repmat(m.color(:,i),1, 100);
                    m.dotS(ii)=m.dotSize(i);
               end
            end
            
        end
        
        function isheld(m, xy)
            
            xDeg=(xy(1) - m.ctr(1)) / m.ppd;
            yDeg=-(xy(2) - m.ctr(2)) / m.ppd;
            
            dist=sqrt((xDeg - m.x).^2 + (yDeg - m.y).^2);
            
            iiHeld = ((dist < m.radius) - .5) * 2;
            
            m.ctrHold = m.ctrHold + iiHeld;
            m.ctrHold(m.ctrHold < 0) = 0;
            val = m.ctrHold ./ m.expThresh;
            
            cidx = ([0 0 1; 0 1 0; 0 1 1; 1 1 0]);
            % ugh, gotta for-loop here I think
            for i = unique(m.stimtype)
                iix=m.stimtype==i;
                iip=logical(double(cidx(i,:))'*double(iix));
                m.color(iip) = ones(sum(cidx(i,:)),1)*(1-val(iix));
            end
        end
        
        function draw(m)

            iiTex=m.ctrExplode==0;
            if any(iiTex)
                Screen('DrawTextures', m.ptr, m.texid(iiTex), [], m.dstRects(:,iiTex), m.rotAngles(iiTex), [], m.alpha(iiTex), m.color(:,iiTex));
            end
            
            
            %                 
            
            iiExplode=~isnan(m.dotx);
            if any(iiExplode)
                m.dotx(iiExplode)=m.dotx(iiExplode) + m.dotdx(iiExplode);
                m.doty(iiExplode)=m.doty(iiExplode) + m.dotdy(iiExplode);
                m.dotCtr(iiExplode)=m.dotCtr(iiExplode)+1;
                i=unique(m.dotI(iiExplode));
                m.ctrExplode(i)=m.ctrExplode(i)+1;
                
                xy=[m.dotx(iiExplode); m.doty(iiExplode)];
                dcolor=m.dotC(:,iiExplode);
                dotSz=m.dotS(iiExplode);
                Screen('DrawDots',m.ptr,xy, dotSz, dcolor, [], 2);
            end
%             elseif m.ctrExplode==1
%                 m.xy=repmat(m.xypixx', 100,1)';
%                 
%                 if (m.deathExplode == 1)
%                     dcolor = [0 0 0];
%                 else
%                   switch m.stimtype
%                     case 1,  
%                       dcolor=[1 1 0];
%                     case 2,
%                       dcolor=[1 0 1];
%                     case 3,    
%                       dcolor=[1 0 0];
%                     otherwise,
%                       dcolor = [0 0 1];
%                   end
%                 end
%                 
%                 m.dxdy=randn(2,100)*m.expSpeed;
%                 Screen('DrawDots',m.p.trial.display.ptr,m.xy, m.dotSize, dcolor, [], 2);  %4 at m.dotSize
%                 m.ctrExplode=m.ctrExplode+1;
%             else
%                 
%                 if (m.deathExplode == 1)
%                     dcolor = [0 0 0];
%                 else
%                   switch m.stimtype
%                     case 1,  
%                       dcolor=[1 1 0];
%                     case 2,
%                       dcolor=[1 0 1];
%                     case 3,
%                       dcolor=[1 0 0];
%                     otherwise,    
%                       dcolor=[0 0 1];
%                   end
%                 end
%                 
%                 m.xy=m.xy+m.dxdy;
%                 
%                 Screen('DrawDots',m.p.trial.display.ptr,m.xy, m.dotSize, dcolor, [], 2);
%                 m.ctrExplode=m.ctrExplode+1;
%             end
                      
        end
        
        
        function setup(m)
            %% load marmoset face textures
            % create face textures... useful for visual feedback to our subject
            m.winRect=m.ctr +[-m.pWidth -m.pHeight m.pWidth m.pHeight]/2;
            MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
            MFL = struct2cell(MFL);
            %MFL = MFL([7,10,13,17,18,19,20,24,25,27]); % these faces seem most centered
            MFL = MFL([10,27,  18,19,   20,24,  7,13,25]);
            
            for k = 1:m.N
                img = MFL{m.faceint(k)};
                
                sz = size(img);
                % gaussian envelope...
                xx = (1:sz(1))-sz(1)/2; yy = (1:sz(2))-sz(2)/2;
                [xx,yy] = meshgrid(xx,yy);
                g = exp(-(xx.^2+yy.^2)/(2*(max(sz(1:2))/6)^2));
                g = g - min(g(:));
                g = g./max(g(:));
                img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
                
                m.texid(k)=Screen('MakeTexture',m.ptr,img);
            end
%             m.srcRect=[0 0 fliplr(sz(1:2))];
            
            m.refresh
            
        end
        
        function refresh(m, ix)
            
            if nargin<2
                ix = true(1,m.N);
                m.dx = zeros(1,m.N);
                m.dy = zeros(1,m.N);
                m.dstRects = zeros(4, m.N);
            end
            
            m.x(ix) = (rand(1,sum(ix))-0.5) * 35;
            m.y(ix) = (rand(1,sum(ix))-0.5) * 35;
            
            m.dx(ix) = cosd(m.direction(ix)) .* m.speed(ix) .* m.ifi;
            m.dy(ix) = sind(m.direction(ix)) .* m.speed(ix) .* m.ifi;
            
            % --- Calculate texture rectangles
            m.dstRects = kron([-1; -1; 1; 1], m.radius*m.ppd) + kron([1; 1], [m.ppd*m.x + m.ctr(1); -m.ppd*m.y + m.ctr(2)]);
            
%             m.dstRects(:,ix) = kron([-1; -1; 1; 1], m.radius(ix)) + kron([1; 1], [m.x(ix); m.y(ix)]);
        end % refresh
        
    end % methods
    
end % classdef

