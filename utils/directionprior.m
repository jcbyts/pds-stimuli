classdef directionprior < handle
%     pr = directionprior(n,type,varargin)
            % direction = generatingDistribution(n, type)
            % n    - number of directions (uniformly spaced from 0 to 360)
            % type - generating distribution (string or functionhandle)
    
    properties
        num
        cond
        direction
        probability
        fixClr
        args
        fun
    end
    
    methods
        function pr = directionprior(n,type,varargin)
            % direction = generatingDistribution(n, type)
            % n    - number of directions (uniformly spaced from 0 to 360)
            % type - generating distribution (string or functionhandle)
            
            pr.num = n;
            pr.direction = 0:(360/n):(360-(360/n));
            pr.cond = type;
            
            switch type
                case {'uniform', 0}
                    priorDist = ones(1,n);
                    pr.fixClr = [1 1 1];
                    pr.fun = @(x) ones(1,numel(x))./360;
                case {'horizontal', 1}
                    priorDist = cosd(pr.direction).^8;
                    pr.fixClr = [0.8500    0.3250    0.0980];
                case {'vertical', 2}
                    priorDist = sind(pr.direction).^8;
                    pr.fixClr = [0.4940    0.1840    0.5560];
                case 3
                    priorDist = zeros(1,n);
                    priorDist(pr.direction > 70 & pr.direction < 110) = 1;
                    pr.fixClr = [0.9290    0.6940    0.1250];
                case {'bimodal', 4}
                    if numel(varargin)==2
                        pr.args = cell2mat(varargin);
                    else
                        pr.args = [0 10];
                    end
                    vmpdf = @(x,mu,k) exp(k * cosd(x-mu)) / (sum(x > 0 & x <= 360) * besseli(0,k));
                    priorDist = vmpdf(pr.direction, pr.args(1), pr.args(2))/2 + vmpdf(pr.direction, pr.args(1)-180, pr.args(2))/2;
                    pr.fun = @(x) vmpdf(x, pr.args(1), pr.args(2))/2 + vmpdf(x, pr.args(1)-180, pr.args(2))/2;
                case {'unimodal', 5}
                    if numel(varargin)==2
                        pr.args = cell2mat(varargin);
                    else
                        pr.args = [0 10];
                    end
%                     vmpdf = @(x,mu,k) exp(k * cosd(x-mu)) / (sum(x > 0 & x <= 360) * besseli(0,k));
                    vmpdf = @(x,mu,k) exp(k * cosd(x-mu)) / (360 * besseli(0,k));
                    priorDist = vmpdf(pr.direction, pr.args(1), pr.args(2));
                    pr.fun = @(x) vmpdf(x, pr.args(1), pr.args(2));
                otherwise
                    priorDist=ones(1,n); % uniform
                    pr.fixClr = [1 1 1];
            end
            
            % sample from weighted distribution
            pr.probability = priorDist/sum(priorDist); % normalize to sum to 1
            
        end
        
        function phi = drawfromprior(pr, setupRNG)
            % uniform random number between 0-1
            if nargin > 1 && isa(setupRNG, 'RandStream')
                rnd = rand(setupRNG);
            else
                rnd = rand;
            end
            
            % function for indexing into available directions
            binfun = @(x) 1 + (x == 0) + ceil(x / mean(diff(pr.direction)));
            
            % interpolate from inverse cdf
            F = griddedInterpolant(cumsum(pr.probability), pr.direction, 'pchip');
            
            phi = binfun(F(rnd));
            phi = pr.direction(phi);
            
%             [pru, iu] = unique(cumsum(pr.probability));
%             
%             directions = pr.direction(iu);
%             phi = interp1(pru, pr.direction(iu), rnd);
%             
%             phi = binfun(F(rnd));
%             phi = pr.direction(phi);
           
            assert(~isnan(phi), 'error: returned angle is nan')

            
        end
    end
    
end