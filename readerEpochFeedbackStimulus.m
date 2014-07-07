configReader();

% make the target sequence
tgtSeq=mkStimSeqRand(nFunction,nSequence);

msg=msgbox({'Thank you for participating in our experiment. Press OK to start training.'},'Start?');
while ishandle(msg); 
    pause(.2); 
end;

clf;

set(gcf,'color',[0 0 0],'toolbar','none','menubar','none'); % black figure
set(gca,'visible','off','color',[0 0 0]); % black axes

h=text(.5,.5,'text','HorizontalAlignment','center','VerticalAlignment','middle',...
       'FontUnits','normalized','fontsize',.3,'color',[1 1 1],'visible','off'); 

% Start the experiment with baseline stimulus
set(h,'string','+','color',tgtColor,'visible','on');
sendEvent('stimulus.training','start');
pause(3);

% initialize the state so don't miss classifier prediction events
status=buffer('wait_dat',[-1 -1 -1],buffhost,buffport); 
state =[status.nsamples status.nevents 0];
endTesting=false; 
dvs=[];

for si=1:nTestSequence;

%    if ( ~ishandle(h) || endTesting ) 
%        break; 
%    end;
  
  sleepSec(intertrialDuration);
 
  % show the screen to alert the subject to trial start
  
  % red fixation indicates trial about to start/baseline
  clf;
  set(gcf,'color',[0 0 0],'toolbar','none','menubar','none'); % black figure
  set(gca,'visible','off','color',[0 0 0]); % black axes
  h=text(.5,.5,'text','HorizontalAlignment','center','VerticalAlignment','middle',...
       'FontUnits','normalized','fontsize',.3,'color',[1 1 1],'visible','off');
   
  set(h,'string','+','color',fixColor,'visible','on');
  drawnow;
  
  sendEvent('stimulus.baseline','start');
  sleepSec(baselineDuration);
  sendEvent('stimulus.baseline','end');
  
  set(h,'color',bgColor);
  drawnow;

 % show the target
  fprintf('%d) tgt=%d : ',si,find(tgtSeq(:,si)==1));
  
  set(h,'string',stimulus(find(tgtSeq(:,si)==1),:),'color',tgtColor,'visible','on'); % white indicates trial running
  drawnow;
  
  sendEvent('stimulus.target',find(tgtSeq(:,si)==1));
  
  sendEvent('stimulus.trial','start');
  % wait for trial end
  sleepSec(trialDuration);
  
  % wait for classifier prediction event
  if( verb>0 ) 
      fprintf(1,'Waiting for predictions\n'); 
  end;
  [data,devents,state]=buffer_waitData(buffhost,buffport,state,'exitSet',{500 'classifier.prediction'},'verb',verb);
  
  % do something with the prediction (if there is one), i.e. give feedback
  if( isempty(devents) ) % extract the decision value
    fprintf(1,'Error! no predictions, continuing');
  else
    dv = devents(end).value;
    if ( numel(dv)==1 )
      if ( dv>0 && dv<=nSymbs && isinteger(dv) ) % dvicted symbol, convert to dv equivalent
        tmp=dv; 
        dv=zeros(nFunction,1); 
        dv(tmp)=1;
      else % binary problem, convert to per-class
        dv=[dv -dv];
      end
    end
    
    % give the feedback on the predicted class
    prob=1./(1+exp(-dv));
    prob=prob./sum(prob);
    if ( verb>=0 ) 
      fprintf('dv:');
      fprintf('%5.4f ',dv);
      fprintf('\t\tProb:');
      fprintf('%5.4f ',prob);
      fprintf('\n'); 
    end;  
    [ans,predTgt]=max(dv); % prediction is max classifier output
    
    set(h,'string',stimulus((predTgt),:),'color',[0 1 0],'visible','on'); % green indicates the feedback
    drawnow;
    
%     set(h,'string',stim(find(tgtSeq(:,si)==1),:),'color',tgtColor,'visible','on'); % white indicates trial running
%     drawnow;
   
    sendEvent('stimulus.predTgt',predTgt);
  end % if classifier prediction
  
  sleepSec(feedbackDuration);
  
  % reset the cue and fixation point to indicate trial has finished  
  clf;
  set(gcf,'color',[0 0 0],'toolbar','none','menubar','none'); % black figure
  set(gca,'visible','off','color',[0 0 0]); % black axes
  h=text(.5,.5,'text','HorizontalAlignment','center','VerticalAlignment','middle',...
       'FontUnits','normalized','fontsize',.3,'color',[1 1 1],'visible','off');
   
  %set(h,'string','+','color',tgtColor,'visible','on'); 
  set(h,'string','+','color',bgColor,'visible','on');
  drawnow;
  
  sendEvent('stimulus.trial','end');
  
end % loop over sequences in the experiment

% end training marker
sendEvent('stimulus.testing','end');

% Express eternal gratitude
clf;
set(gcf,'color',[0 0 0],'toolbar','none','menubar','none'); % black figure
set(gca,'visible','off','color',[0 0 0]); % black axes
h=text(0,.5,'text','color',[1 1 1],'visible','off');
set(h,'string','This ends testing phase.','visible','on','fontsize',.3);
pause(3);