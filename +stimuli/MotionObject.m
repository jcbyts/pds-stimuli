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
        explodeThresh
        color
    end
    
    methods
        function m=MotionObject(p, varargin)
            m.p=p;
            ip=inputParser();
            ip.addParameter('xy', randn(1,2)*5)
            ip.addParameter('radius', 2)
            ip.addParameter('visible', false)
            ip.addParameter('type', 'face')
            ip.addParameter('motion', 'linear')
            ip.addParameter('forcefield', false)
            ip.addParameter('speed', 5+rand*10)
            ip.addParameter('direction', rand*360)
            
            ip.parse(varargin{:}); % parse optional inputs
            m.xy            = ip.Results.xy;
            m.radius        = ip.Results.radius;
            m.visible       = ip.Results.visible;
            m.type          = ip.Results.type;
            m.speed         = ip.Results.speed;
            m.direction     = ip.Results.direction;
            m.color=[1 1 1];
            
            if m.visible
                m.alpha=1;
            end
            m.rotAngle=0;
            m.ctrExplode=0;
            m.ctrHold=0;
            expthrs=[10 60];
            m.explodeThresh=expthrs(randi(2));
        end
        
        function move(m)
            if m.ctrExplode>100
                m.xy=randn(1,2)*5;
                m.refresh;
                m.ctrExplode=0;
                m.ctrHold=0;
            end
            
            if m.ctrExplode>0
                return
            end
            m.rotAngle=m.rotAngle+.1;
            m.xy=m.xy+m.dxdy;
            m.xypixx=pds.deg2px(m.xy',m.p.trial.display.viewdist,m.p.trial.display.w2px,false)...
                +m.p.trial.display.ctr(1:2)';
            m.srcRect=[0; 0; pds.deg2px(m.radius,m.p.trial.display.viewdist,m.p.trial.display.w2px,false)]';
            
            m.dstRect=CenterRectOnPoint(m.srcRect, m.xypixx(1), m.xypixx(2));
            
            winRect=m.p.trial.display.ctr+[-m.p.trial.display.pWidth -m.p.trial.display.pHeight m.p.trial.display.pWidth m.p.trial.display.pHeight]/2;
            %******* if you hit a screen boundary, bounce off
            if m.xypixx(1) < winRect(1)
                m.dxdy(1) = -m.dxdy(1);
            end
            
            if m.xypixx(2) < winRect(2)
                m.dxdy(2) = -m.dxdy(2);
            end
            
            if m.xypixx(1) > winRect(3)
                m.dxdy(1) = -m.dxdy(1);
            end
            
            if m.xypixx(2) > winRect(4)
                m.dxdy(2) = -m.dxdy(2);
            end
            
            m.isheld
            if m.ctrHold>m.explodeThresh
                m.ctrExplode=1;
                m.p.trial.exploded=m.p.trial.exploded+1;
            end
            
        end
        
        function isheld(m)
            dist=sqrt((m.p.trial.eyeX -m.xypixx(1)).^2 + (m.p.trial.eyeY - m.xypixx(2)).^2);
            if dist<m.radius*m.p.trial.display.ppd
                m.ctrHold=m.ctrHold+1;
                if m.explodeThresh>25
                    m.color=[1 [1 1]-(m.ctrHold/m.explodeThresh)];
                else
                    m.color=[1 1 1-(m.ctrHold/m.explodeThresh)];
                end
                %                 disp('held')
            else
                m.ctrHold=max(m.ctrHold-1, 0);
                if m.explodeThresh>25
                    m.color=[1 [1 1]-(m.ctrHold/m.explodeThresh)];
                else
                    m.color=[1 1 1-(m.ctrHold/m.explodeThresh)];
                end
            end
        end
        
        function draw(m)
            if m.ctrExplode==0
                Screen('DrawTexture', m.p.trial.display.ptr, m.texid, [], m.dstRect, m.rotAngle, [], m.alpha, m.color)
            elseif m.ctrExplode==1
                m.xy=repmat(m.xypixx', 100,1)';
                m.dxdy=randn(2,100)*15;
                
                if m.explodeThresh>25
                    dcolor=[1 0 0];
                else
                    dcolor=[1 1 0];
                end
                Screen('DrawDots',m.p.trial.display.ptr,m.xy, 4, dcolor, [], 2);
                m.ctrExplode=m.ctrExplode+1;
            else
                if m.explodeThresh>25
                    dcolor=[1 0 0];
                else
                    dcolor=[1 1 0];
                end
                m.xy=m.xy+m.dxdy;
                %                 m.dxdy=rand(2,100);
                
                Screen('DrawDots',m.p.trial.display.ptr,m.xy, 4, dcolor, [], 2);
                m.ctrExplode=m.ctrExplode+1;
            end
            
            %             if m.ctrExplode==200
            %                 m.ctrExplode=0;
            %             end
            
        end
        
        
        function setup(m)
            %% load marmoset face textures
            % create face textures... useful for visual feedback to our subject
            MFL=load(fullfile(marmoview.supportDataDir,'MarmosetFaceLibrary.mat'));
            MFL = struct2cell(MFL);
            MFL = MFL([7,10,13,17:20,24,25,27]); % these faces seem most centered
            
            id = randi(length(MFL));
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

