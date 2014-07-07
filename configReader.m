% Prevent running this file multiple times
if ( exist('readerConfig','var') && ~isempty(readerConfig) ) 
    return; 
end;
readerConfig=true;

run ../utilities/initPaths;

buffhost='localhost';
buffport=1972;
global ft_buff;
ft_buff=struct('host',buffhost,'port',buffport);

% Wait for the buffer to return valid header information
hdr=[];

% Wait for the buffer to contain valid data
while ( isempty(hdr) || ~isstruct(hdr) || (hdr.nchans==0) ) 
    try 
        hdr=buffer('get_hdr',[],buffhost,buffport); 
    catch
        hdr=[];
        fprintf('Invalid header info... waiting.\n');
    end;
    pause(1);
end;

% Set the real-time-clock to use
initgetwTime();
initsleepSec();

% Assign electordes of interest and their topolog
capFile='cap_tmsi_mobita_reader10'; % For a 32-electrodes setup use - cap_tmsi_mobita_reader32;

verb               = 1;
buffhost           = 'localhost';
buffport           = 1972;
nFunction          = 5;
nSequence          = 40;
nBlock             = 2; %number of stim blocks to use
nTestSequence      = 20;

trialDuration      = 3;
baselineDuration   = 1;
intertrialDuration = 2;
feedbackDuration   = 1;
moveScale          = .1;
stimulus = ['    R    ';
            '    L    ';
            '    U    ';
            '    D    '; 
            'keep calm'];

bgColor  = [0 0 0]; % Background color
fixColor = [1 0 0]; % Fixation cross color
tgtColor = [1 1 1]; % Target color
fbColor  = [0 1 0]; % Feedback color (in Epoch Feedback).

% Neurofeedback smoothing
trlen_ms=3000; % how often to run the classifier
trlen_ms_ol=trlen_ms;
expSmoothFactor = log(2)/log(10); % smooth the last 10...