function f=marmoview()
% marmoview style GUI for PLDAPS

% initialize with whatever preferences exist
m=struct;
marmoviewPrefs=getpref('marmoview');
if isempty(marmoviewPrefs)
    m.guipos=[560,100,600,600];
end
m.settingsFile=[];
p=pldaps;

f = figure(666); clf
f.Visible='off';
f.Position=m.guipos;

% Title
fsz=f.Position(3:4);
hTitle=uicontrol('Style', 'text', 'String', ...
    'MarmoView Plugin for PLDAPS v4.2', ...
    'Units', 'normalized', ...
    'Position', [.01 .92 .6 .08]);
hTitle.FontSize=12;
hTitle.HorizontalAlignment='left';

% Panel 1: loading files
hp=uipanel('Title', 'Protocol', ...
    'Position', [.01 .75 .35 .2]);

hp=uipanel('Title', 'Protocol', ...
    'Position', [.01 .5 .35 .2]);

% Construct the components.
hLoad    = uicontrol('Style','pushbutton',...
    'String','Load','Units', 'normalized', ...
    'Position',[.02 .8 .08 .05], ...
    'Callback', @load_Callback);

hInit    = uicontrol('Style','pushbutton',...
    'String','Initialize','Units', 'normalized', ...
    'Position',[.12 .8 .08 .05], ...
    'Callback', @init_Callback);

hClear    = uicontrol('Style','pushbutton',...
    'String','Clear','Units', 'normalized', ...
    'Position',[.22 .8 .08 .05]);

hBlk    = uicontrol('Style','pushbutton',...
    'String','Blk','Units', 'normalized', ...
    'Position',[.12 .87 .05 .05]);

hImg    = uicontrol('Style','pushbutton',...
    'String','Img','Units', 'normalized', ...
    'Position',[.22 .87 .05 .05]);


% 
% 
% hmesh    = uicontrol('Style','pushbutton',...
%     'String','Mesh','Position',[315,180,70,25]);
% hcontour = uicontrol('Style','pushbutton',...
%     'String','Contour','Position',[315,135,70,25]);
% 
% 
% htext  = uicontrol('Style','text','String','Select Data',...
%     'Position',[10,90,60,15]);
% hpopup = uicontrol('Style','popupmenu',...
%     'String',{'Peaks','Membrane','Sinc'},...
%     'Position',[300,50,100,25]);
% 
% ha = axes('Units','pixels','Position',[50,60,200,185]);

% align([hsurf,hmesh,hcontour,htext,hpopup],'Center','None');

f.Name='MarmoView';
f.NumberTitle='off';
f.ToolBar='none';
f.MenuBar='none';
f.Visible = 'on';

function load_Callback(source, eventData) %#ok<*INUSD>
    [settingsFile, pathname]=uigetfile();
    run(fullfile(pathname,settingsFile))
end

function init_Callback(source, eventData)
    if exist('p', 'var')
        p.run
    end
end

end