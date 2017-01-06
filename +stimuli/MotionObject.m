classdef MotionObject < handle
    % MOTION OBJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        p@pldaps
        xy@double
        radius@double
        visible@logical
        type@char
        motion@char
        forcefield@logical
        speed@double
        direction@double
    end
    
    properties (Access = public)
        dxdy
        xypixx
        MarmoFaces
        texid
        dstRect
        rotAngle
        alpha
        srcRect
        ctrHold
        ctrExplode
        deathExplode
        explodeThresh
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
    
    methods
        function m=MotionObject(p, varargin)
            m.p=p;
            ip=inputParser();
            %ip.addParameter('xy', randn(1,2)*5)
            xx = (rand-0.5)*40;
            yy = (rand-0.5)*40;
            ip.addParameter('xy', [xx yy]); % cover space uniform
            %***** two kinds of objects, 
            %***** small and slow, low reward, (glow yellow)
            %***** and fast and big, higher reward (glow red)
            stimtype = 1+floor( rand * 3.99999);
            m.stimtype = stimtype;
            m.invade = 1;  % no expansion rate
            m.removed = 0;  % take out of game (allow to clear board)
            m.maxradius = 8.0;
            m.deathExplode = 0;
            switch stimtype
                case 1,  
                  ip.addParameter('radius', 4)
                  ip.addParameter('speed',12+rand*4);
                  ip.addParameter('explode',60);  % red
                  ip.addParameter('faceint',1+floor(rand*2));   %two face options
                  ip.addParameter('expSpeed',15);
                  ip.addParameter('dotSize',3);
                  ip.addParameter('expDur',60);
                  ip.addParameter('expRad',12);
                case 2,
                  ip.addParameter('radius', 3)
                  ip.addParameter('speed',8+rand*4);
                  ip.addParameter('explode',40);  % magenta
                  ip.addParameter('faceint',3+floor(rand*2));
                  ip.addParameter('expSpeed',10);
                  ip.addParameter('dotSize',2);
                  ip.addParameter('expDur',40);
                  ip.addParameter('expRad',8);
                case 3,    
                  ip.addParameter('radius', 2)
                  ip.addParameter('speed',4+rand*4);
                  ip.addParameter('explode',20);  % yellow
                  ip.addParameter('faceint',5+floor(rand*2));
                  ip.addParameter('expSpeed',5);
                  ip.addParameter('dotSize',1);
                  ip.addParameter('expDur',20);
                  ip.addParameter('expRad',4);                   
                otherwise,    
                  ip.addParameter('radius', 2)
                  ip.addParameter('speed',4+rand*4);
                  ip.addParameter('explode',20);  % yellow
                  ip.addParameter('faceint',7+floor(rand*3));
                  ip.addParameter('expSpeed',5);
                  ip.addParameter('dotSize',1);
                  ip.addParameter('expDur',20);
                  ip.addParameter('expRad',4);
            end
            ip.addParameter('visible', false)
            ip.addParameter('type', 'face')
            ip.addParameter('motion', 'linear')
            ip.addParameter('forcefield', false)
            ip.addParameter('direction', rand*360)
            
            ip.parse(varargin{:}); % parse optional inputs
            
            m.colorThresh   = 40;
            m.xy            = ip.Results.xy;
            m.radius        = ip.Results.radius;
            m.visible       = ip.Results.visible;
            m.type          = ip.Results.type;
            m.speed         = ip.Results.speed;
            m.direction     = ip.Results.direction;
            m.explodeThresh = ip.Results.explode;
            m.color=[1 1 1];
            m.faceint = ip.Results.faceint;
            m.expSpeed = ip.Results.expSpeed;
            m.dotSize = ip.Results.dotSize;
            m.expDur = ip.Results.expDur;
            m.expRad = ip.Results.expRad;
       
            m.repulse = zeros(1,2);
            
            if m.visible
                m.alpha=1;
            end
            m.rotAngle=0;
            m.ctrExplode=0;
            m.ctrHold=0;
            
            %********* select a set of face invaders
            if (stimtype == 4)
               if (rand < (1/2))  
                  m.invade = 1.0015;
                  m.speed = 12 + (4*rand);
               end
            end
            %****************************************
            
        end
        
        function [hit,loc,rad,death] = exploded(m)
           hit = 0;
           loc = [];
           rad = 0;
           death = 0;
           if (m.ctrExplode == 1)
               hit = 1;
               loc = m.xy;
               rad = m.expRad;
           end
           if (m.deathExplode == 1)
               death = 1;
           end
        end
        
        function wipeclear(m,loc,rad,death)
            
            if ( size(m.xy,1) == 1 )  %don't clear if it is already exploding
             if (m.removed == 0)   
               dist = norm(m.xy - loc);
               if (dist < rad)
                  if (death == 1)
                      m.deathExplode = 1;  % explosion becomes infectious
                  else
                      
                     %*******
                     winRect=m.winRect;
                     %******
                     dv = (m.xy - loc)/dist;
                     newxy = loc + (rad * dv);  % jump stim just outside radius
                     %***** safety check if explosion pushes it outside
                     %boundaries, and if so then re-initialize it
                     newxypixx = pds.deg2px(newxy',m.p.trial.display.viewdist,m.p.trial.display.w2px,false)...
                                    +m.p.trial.display.ctr(1:2)';
                     if (newxypixx(1) < winRect(1)) | (newxypixx(1) > winRect(3)) | ...
                        (newxypixx(2) < winRect(2)) | (newxypixx(2) > winRect(4)) 
                         %newxy = loc - (rad*dv);
                          m.ctrExplode = 1;  % if so, explode it as well
                          if (death == 0)
                             m.p.trial.exploded=m.p.trial.exploded+1;  % can get points, else not
                          end
                     else
                          m.xy = newxy;
                     end
                     %******
                  end
              end 
            end
          end
        end
        
        function move(m)
            
            if m.ctrExplode > m.expDur   %duration of explosion
                m.xy=randn(1,2)*5;
                if (m.stimtype < 3)
                  m.expRad = 16 - (m.stimtype*4);
                end
                if (m.invade > 1)
                  m.radius = 2;  % reset to small stimulus
                  m.dotSize = 1;
                  m.expDur = 20;
                  m.expSpeed = 5;
                  m.speed = 12 + (rand*4);  % faster
                  m.explodeThresh = 20;
                  m.expRad = 4;  
                end
                %*****************
                m.refresh;
                %*******************
                m.ctrExplode=0;
                m.deathExplode = 0;
                m.ctrHold = 0;
            end
            
            if m.ctrExplode>0
                return
            end
            
            % m.rotAngle=m.rotAngle+.1;
            if (m.removed == 0) & (m.invade > 1) % if invader mode
               m.radius = m.radius * m.invade;
               m.dxdy = m.dxdy * m.invade;
               m.dotSize = m.dotSize * m.invade;
               m.expDur = m.expDur * m.invade;
               m.expSpeed = m.expSpeed * m.invade;
               % m.speed = m.speed * m.invade;
               m.explodeThresh = m.explodeThresh * m.invade;
      
               %*********** death explosion ******
               if (m.radius > m.maxradius)
                 m.ctrExplode = 1;  % no points for death explosion
                 m.deathExplode = 1;
                 m.p.trial.exploded=m.p.trial.exploded-1;
                 m.speed = 16;
                end
            end
            
            %*********
            m.xy=m.xy+m.dxdy;
            m.xypixx=pds.deg2px(m.xy',m.p.trial.display.viewdist,m.p.trial.display.w2px,false)...
                +m.p.trial.display.ctr(1:2)';
            m.srcRect=[0; 0; pds.deg2px(m.radius,m.p.trial.display.viewdist,m.p.trial.display.w2px,false)]';
            
            m.dstRect=CenterRectOnPoint(m.srcRect, m.xypixx(1), m.xypixx(2));
            
            %winRect=m.p.trial.display.ctr+[-m.p.trial.display.pWidth -m.p.trial.display.pHeight m.p.trial.display.pWidth m.p.trial.display.pHeight]/2;
            winRect = m.winRect;
            %******* if you hit a screen boundary, bounce off
            if m.xypixx(1) < winRect(1)
                m.dxdy(1) = -m.dxdy(1);
                m.repulse(1) = (m.speed * m.p.trial.display.ifi);
            end
            if m.xypixx(2) < winRect(2)
                m.dxdy(2) = -m.dxdy(2);
                m.repulse(2) = (m.speed * m.p.trial.display.ifi);
            end
            if m.xypixx(1) > winRect(3)
                m.dxdy(1) = -m.dxdy(1);
                m.repulse(1) = - (m.speed * m.p.trial.display.ifi);
            end
            if m.xypixx(2) > winRect(4)
                m.dxdy(2) = -m.dxdy(2);
                m.repulse(2) = - (m.speed * m.p.trial.display.ifi);
            end
            %**********
            m.xy = m.xy + m.repulse;
            m.repulse = m.repulse * 0.9;  % decay repulsion
            %***** more generally implement a force field away from edge
            
            m.isheld
            if m.ctrHold>m.explodeThresh
                m.ctrExplode=1;
                m.p.trial.exploded=m.p.trial.exploded+1;
                if (m.stimtype > 1) & (m.stimtype < 4)
                   m.removed = 1;
                else
                    if (rand < (1/3))
                        m.removed = 1;
                    end
                end
            end
            %************
            if (m.deathExplode)
                m.ctrExplode = 1;
                m.expRad = 16;  % max
                m.p.trial.exploded=m.p.trial.exploded-1;
                %*** and no points given ... this is infectious
            end
            %*************
        end
        
        function isheld(m)
            if (m.removed == 1)
                m.ctrHold = 0;
                return;
            end
            dist=sqrt((m.p.trial.eyeX -m.xypixx(1)).^2 + (m.p.trial.eyeY - m.xypixx(2)).^2);
            if dist<m.radius*m.p.trial.display.ppd
                m.ctrHold=m.ctrHold+1;
                val = (m.ctrHold/m.explodeThresh);
                switch m.stimtype
                    case 1,
                        m.color = [1 1 (1-val)];
                    case 2,
                        m.color = [1 (1-val) 1];
                    case 3,
                        m.color = [1 (1-val) (1-val)];
                    otherwise,
                        m.color = [(1-val) (1-val) 1];
                end
                %                 disp('held')
            else
                m.ctrHold=max(m.ctrHold-1, 0);
                val = (m.ctrHold/m.explodeThresh);
                switch m.stimtype
                    case 1,
                        m.color = [1 1 (1-val)];
                    case 2,
                        m.color = [1 (1-val) 1];
                    case 3,
                        m.color = [1 (1-val) (1-val)];
                    otherwise,
                        m.color = [(1-val) (1-val) 1];
                end
            end
        end
        
        function draw(m)
            if m.ctrExplode==0 
                if m.removed == 0
                   Screen('DrawTexture', m.p.trial.display.ptr, m.texid, [], m.dstRect, m.rotAngle, [], m.alpha, m.color)
                end
            elseif m.ctrExplode==1
                m.xy=repmat(m.xypixx', 100,1)';
                
                if (m.deathExplode == 1)
                    dcolor = [0 0 0];
                else
                  switch m.stimtype
                    case 1,  
                      dcolor=[1 1 0];
                    case 2,
                      dcolor=[1 0 1];
                    case 3,    
                      dcolor=[1 0 0];
                    otherwise,
                      dcolor = [0 0 1];
                  end
                end
                
                m.dxdy=randn(2,100)*m.expSpeed;
                Screen('DrawDots',m.p.trial.display.ptr,m.xy, m.dotSize, dcolor, [], 2);  %4 at m.dotSize
                m.ctrExplode=m.ctrExplode+1;
            else
                
                if (m.deathExplode == 1)
                    dcolor = [0 0 0];
                else
                  switch m.stimtype
                    case 1,  
                      dcolor=[1 1 0];
                    case 2,
                      dcolor=[1 0 1];
                    case 3,
                      dcolor=[1 0 0];
                    otherwise,    
                      dcolor=[0 0 1];
                  end
                end
                
                m.xy=m.xy+m.dxdy;
                
                Screen('DrawDots',m.p.trial.display.ptr,m.xy, m.dotSize, dcolor, [], 2);
                m.ctrExplode=m.ctrExplode+1;
            end
                      
        end
        
        
        function setup(m)
            %% load marmoset face textures
            % create face textures... useful for visual feedback to our subject
            m.winRect=m.p.trial.display.ctr+[-m.p.trial.display.pWidth -m.p.trial.display.pHeight m.p.trial.display.pWidth m.p.trial.display.pHeight]/2;
            MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
            MFL = struct2cell(MFL);
            %MFL = MFL([7,10,13,17,18,19,20,24,25,27]); % these faces seem most centered
            MFL = MFL([10,27,  18,19,   20,24,  7,13,25]);
            
            id = m.faceint; %randi(length(MFL));
            img = MFL{id};
            
            sz = size(img);
            % gaussian envelope...
            x = (1:sz(1))-sz(1)/2; y = (1:sz(2))-sz(2)/2;
            [x,y] = meshgrid(x,y);
            g = exp(-(x.^2+y.^2)/(2*(max(sz(1:2))/6)^2));
            g = g - min(g(:));
            g = g./max(g(:));
            img(:,:,4) = uint8(255.*g); % alpha channel: 0 = transparent, 255 = opaque
            
            m.texid=Screen('MakeTexture',m.p.trial.display.ptr,img);
            m.srcRect=[0 0 fliplr(sz(1:2))];
            
            m.refresh
            
        end
        
        function refresh(m)
            
            xx = (rand-0.5)*35;
            yy = (rand-0.5)*35;
            m.xy = [xx yy]; % cover space uniform
            
            dy=sind(m.direction)*m.speed;
            dx=cosd(m.direction)*m.speed;
            m.dxdy=[dx dy]*m.p.trial.display.ifi;
            
            m.xypixx=pds.deg2px(m.xy',m.p.trial.display.viewdist,m.p.trial.display.w2px,false)...
                +m.p.trial.display.ctr(1:2)';
            m.srcRect=[0; 0; pds.deg2px(m.radius,m.p.trial.display.viewdist,m.p.trial.display.w2px,false)]';
            
            m.dstRect=CenterRectOnPoint(m.srcRect, m.xypixx(1), m.xypixx(2));
        end
    end % methods
    
end % classdef

