% Run configuration file to get all the required parameters
configReader();

% Make the target sequence
tgtSeq = mkStimSeqRand(nFunction,nSequence);

clf;

set(gcf,'color',[0 0 0],'toolbar','none','menubar','none'); % Black figure
set(gca,'visible','off','color',[0 0 0]); % Black axes

h=text(0.5,0.9,'text','HorizontalAlignment','center','VerticalAlignment','middle',...
       'FontUnits','normalized','fontsize',.1,'color',[1 1 1],'visible','off'); 
   
set(h,'string','We appreciate your enthusiasm!','visible','on');
msg = msgbox({'Click OK when you are ready.'},'Start?');
while ishandle(msg); 
    pause(.2); 
end;

% Reset figure to start the experiment
clf;
set(gcf,'color',[0 0 0],'toolbar','none','menubar','none'); % Black figure
set(gca,'visible','off','color',[0 0 0]); % Black axes

% Draw a cross to get participant's attention
h=text(0.5,0.5,'+','HorizontalAlignment','center','VerticalAlignment','middle',...
       'FontUnits','normalized','fontsize',.3,'color',tgtColor,'visible','on'); 

% Set marker to start training   
sendEvent('stimulus.training','start');
pause(3);

for bi=1:nBlock;
    
    sendEvent('stimulus.block','start');
    for si=1:nSequence;
    
        sleepSec(intertrialDuration);
  
        % Redraw figure at the beginning - just to be consistent 
        
        % Alert the subject - trial start alert = red baseline fixation cross
        clf;
        set(gcf,'color',[0 0 0],'toolbar','none','menubar','none');
        set(gca,'visible','off','color',[0 0 0]); 
        h=text(.5,.5,'+','HorizontalAlignment','center','VerticalAlignment','middle',...
               'FontUnits','normalized','fontsize',.3,'color',fixColor,'visible','on'); 
        drawnow;
           
        sendEvent('stimulus.baseline','start'); % Baseline marker - starts
        sleepSec(baselineDuration);
        sendEvent('stimulus.baseline','end'); % Baseline marker - ends
        
        % Erase fixation
        set(h,'color',bgColor);
        drawnow;
  
        % Present target stimulus
        fprintf('%d) tgt=%d : ',si,find(tgtSeq(:,si)==1));
        
        set(h,'string',stimulus(find(tgtSeq(:,si)==1),:),'color',tgtColor,'visible','on'); % White stimulus = trial under progress
        drawnow;
        sendEvent('stimulus.target',find(tgtSeq(:,si)==1));
        sendEvent('stimulus.trial','start');
        sleepSec(trialDuration); % Wait for the trial to end (=stimulus presentation time).
  
        % Blank screen to indicate trial has ended
        set(h,'color',bgColor);
        drawnow;
        sendEvent('stimulus.trial','end');
  
        ftime=getwTime();
        fprintf('\n');
    end % End of sequences
    
    if(bi<nBlock) % If there are more training blocks left, show this message.
        msg=msgbox({'You did great! Press OK to go to the next training block.'},'Continue?');
        while ishandle(msg); 
            pause(.2); 
        end;
    end
    
    % End block marker
    sendEvent('stimulus.block','end');
end

% End training marker
sendEvent('stimulus.training','end');

% Express eternal gratitude
clf;
set(gcf,'color',[0 0 0],'toolbar','none','menubar','none'); % black figure
set(gca,'visible','off','color',[0 0 0]); % black axes
h=text(0.5,0.9,'Thank you for being your awesome self.','HorizontalAlignment','center','fontsize',.2,'color',tgtColor,'visible','on');
pause(3);