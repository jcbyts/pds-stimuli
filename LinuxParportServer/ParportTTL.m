function varargout = ParportTTL(cmd, varargin)
% ParportTTL(cmd, arg);  -- Send TTL signal levels on a parallel port
% of a remote, network-connected Linux machine.
%
% ParportTTL('Open', hostName [, port=2000]);
% - Open a connection to machine 'hostName', UDP port 'port'. 'port' is
% optional and defaults to 2000.
%
% ParportTTL('Close');
% - Close connection to remote port.
%
% tRoundTrip = ParportTTL('Set', level [, duration=inf]);
% - Set TTL levels on pins D0-D7 of parallel port to 'level', ie., level is
% a 1 byte value whose bits encode low/high state of pins D0-D7. The
% optional 'duration' value allows to set duration of the signal to roughly
% 'duration' milliseconds. The default is to keep the signal until manual
% change, not lower to "all-low" after 'duration' time.
%
% The optional return argument 'tRoundTrip' contains the roundtrip time for
% setting the TTL lines in seconds.
%

% History:
% 5.10.2009  mk  Written.

persistent pserver;
persistent targetPort;
persistent targetHost;

if nargin < 1
    error('You must provide a "cmd" command argument.');
end

if strcmpi(cmd, 'Set')
    if isempty(pserver)
        error('Tried to set TTL trigger level, but connection not open!');
    end
    
    if isempty(varargin)
        error('New TTL line setting missing!');
    end
    
    req    = zeros(2, 1, 'uint8');

    % Byte 1 is new signalling level on port:
    req(1) = varargin{1};
    
    % Byte 2 is duration in msecs:
    if length(varargin) > 1
        % Given timeout in msecs:
        req(2) = varargin{2};
    else
        % Infinite timeout:
        req(2) = 0;
    end
    
    % Send set command to server:
    pnet(pserver, 'write', 'S');

    % Send its data to server:
    pnet(pserver, 'write', uint8(req));
    
    % Timestamped Trigger-Action!
    t = GetSecs;
    pnet(pserver, 'writepacket');

    % Wait for acknowledge:
    ack = []; %#ok<NASGU>
    count=pnet(pserver, 'readpacket');
    t = GetSecs - t;
    if count < 3
        fprintf('WARNING: Empty receive from parallelPortServer - Timed out?!?\n');
    end

    ack = pnet(pserver, 'read', count);
    if isempty(ack)
        fprintf('WARNING: Unable to get acknowledge for command within timeout interval! (count = %i)\n', count);
    end

    if t > 0.005
        fprintf('WARNING: Roundtrip time %f msecs for TTL trigger exceeds 5 msecs\n', t * 1000);
    end
    
    % Return roundtrip time in seconds:
    varargout{1} = t;
    
    return;
end

if strcmpi(cmd, 'Open')
    if ~isempty(pserver)
        error('Tried to open TTL trigger connection, but already open!');
    end

    if isempty(varargin)
        error('You must provide the name of the parallel port server machine, e.g., ''cardamon.kyb.local'' !');
    end
    
    targetHost = varargin{1};
    
    if length(varargin) > 1
        targetPort = varargin{2};
    else
        targetPort = 2000;
    end
        
    port = 30001;
    while isempty(pserver) && port < 40000
        pserver = pnet('udpsocket', port);
        if pserver < 0
            port = port + 1;
            fprintf('LinuxParportTTL: Failed to open UDP socket on port %i, retrying with port %i...\n', port-1, port);
            pserver = [];
        end
    end

    if isempty(pserver) || pserver < 0
        varargout{1} = 1; %#ok<NASGU>
        pserver = []; %#ok<NASGU>
        error('LinuxParportTTL: Failed to create UDP connection socket!');
    end

    % Establish a permanent connection to save per-send call overhead:
    pnet(pserver, 'udpconnect' , targetHost, targetPort);
    
    GetSecs;
    
    return;
end

if strcmpi(cmd, 'Close')
    if isempty(pserver)
        error('Tried to close TTL trigger connection, but none opened!');
    end

    % Send terminate command to server:
    pnet(pserver, 'write', 'E');
    pnet(pserver, 'writepacket', targetHost, targetPort);
    
    % Close server connection and release handle:
    pnet(pserver, 'close');
    pserver = [];
    
    return;
end

error('Unknown command provided!');
