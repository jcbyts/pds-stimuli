classdef HDmovie < handle
    % HDMOVIE class plays movies in Psychtoolbox
    properties
        ptr
        dim
        filename
        frate
        duration
        frameIndex
        movie
        tex
    end
    
    properties (Access = private)
        movietexture
        lastpts
        pts
        count
        texids
        texpts
    end
    
    methods
        function h=HDmovie(filename, ptr, varargin)
            ip=inputParser();
            ip.addParameter('frate', 120)
            ip.addParameter('dim', [1920 1080])
            ip.parse(varargin{:})
            
            h.ptr=ptr;
            h.dim=ip.Results.dim;
            h.filename=filename;
            h.frate=ip.Results.frate;
            h.frameIndex=[1 inf];
            
        end
        
        function open(h)
            
            [h.movie, h.duration, h.frate] = Screen('OpenMovie', h.ptr, h.filename,4);%, [], [], [], 3);
            nFrames=ceil(h.duration*h.frate);
            if isinf(h.frameIndex(2))
                h.frameIndex(2)=nFrames;
            end
            
            Screen('SetMovieTimeIndex', h.movie, h.frameIndex(1)/h.frate, 0);
            
            h.movietexture=0;     % Texture handle for the current movie frame.
            h.lastpts=-1;         % Presentation timestamp of last frame.
            h.pts=-1;
            h.count=0;            % Number of loaded movie frames.
            
            
            nLoadFrames=diff(h.frameIndex)+1;
            h.texids = zeros(1,nLoadFrames);
            h.texpts = zeros(1,nLoadFrames);
            
            % Start playback of movie. This will start
            % the realtime playback clock and playback of audio tracks, if any.
            % Play 'movie', at a playbackrate = rate, with 1.0 == 100% audio volume.
            Screen('PlayMovie', h.movie, 1, 0, 1.0);
            [h.movietexture, h.pts] = Screen('GetMovieImage', h.ptr, h.movie);
            
        end
        
        function loadFrames(h)
            % this often crashed PTB and is going to be removed
            fprintf('Loading frames from [%s]\n', h.filename)
            while h.count < (h.frameIndex(2)-h.frameIndex(1))
                [h.movietexture, h.pts] = Screen('GetMovieImage', h.ptr, h.movie);%, 1, [], [], 0);
            
            
                if (h.movietexture > 0) && ( (h.pts - h.lastpts) >= (1/h.frate) )% || (indexisFrames == 2))
                    % Store its texture handle and exact movie timestamp in
                    % arrays for later use:
                    h.count=h.count + 1;
%                     disp(h.count)
                    
                    h.texids(h.count)=h.movietexture;
                    h.texpts(h.count)=h.pts;
                    
                    h.lastpts=h.pts;
                end
            end
            fprintf('Done\n')
            
        end
        
        function update(h)
            if (h.movietexture == 0) && ( (h.pts - h.lastpts) >= (1/h.frate) )% || (indexisFrames == 2))
                [h.movietexture, h.pts] = Screen('GetMovieImage', h.ptr, h.movie);%, 1, [], [], 0);
            end
        end
        
        function draw(h)
            if h.movietexture > 0
                % Yes. Draw the new texture immediately to screen:
                Screen('DrawTexture', h.ptr, h.movietexture, [], [0 0 h.dim(1) h.dim(2)]);
                
                % Release texture:
                Screen('Close', h.movietexture);
                h.movietexture=0;
            end
        end
        
        function drawNext(h)
            
            [h.movietexture, h.pts] = Screen('GetMovieImage', h.ptr, h.movie);%, 1, [], [], 0);
            
            if h.movietexture > 0
                % Yes. Draw the new texture immediately to screen:
                Screen('DrawTexture', h.ptr, h.movietexture, [], [0 0 h.dim(1) h.dim(2)]);
                
                % Release texture:
                Screen('Close', h.movietexture);
            end
        end
        
        function drawFrame(h, currentindex)
            Screen('DrawTexture', h.ptr, h.texids(currentindex));
        end
        
        function closeMovie(h)
%             Screen('Close', h.texids(1:h.count));
            % Close movie file.
            Screen('CloseMovie', h.movie);
        end
        
        
    end
    
    
end
