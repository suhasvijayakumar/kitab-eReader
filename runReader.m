configReader();

% create the control window and execute the phase selection loop
contFig=controller(); 
info=guidata(contFig); 

while (ishandle(contFig))
  set(contFig,'visible','on');
  uiwait(contFig); % CPU hog on ver 7.4
  if ( ~ishandle(contFig) ) 
      break; 
  end;
  
  set(contFig,'visible','off');
  info=guidata(contFig); 
  subject=info.subject;
  phaseToRun=lower(info.phaseToRun);
  fprintf('Start phase : %s\n',phaseToRun);
  
  switch phaseToRun;
    
   %---------------------------------------------------------------------------
   case 'capfitting';
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun);
    % wait until capFitting is done
    buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);       

   %---------------------------------------------------------------------------
   case 'eegviewer';
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun);
    % wait until capFitting is done
    buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);           
    
   %---------------------------------------------------------------------------
   case 'practice';
    sendEvent('subject',info.subject);
    sendEvent(phaseToRun,'start');
    % Override sequence number and block number
    onSequence = nSequence;
    nSequence=5;
    onBlock = nBlock; 
    nBlock=1;
    try
      readerCalibrateStimulus();
    catch
      le=lasterror;
      fprintf('ERROR Caught:\n %s\n%s\n',le.identifier,le.message);
    end
    sendEvent(phaseToRun,'end');
    % Reset to original sequence number and block number
    nSequence = onSequence;
    nBlock    = onBlock;
    
   %---------------------------------------------------------------------------
   case {'calibrate','calibration'};
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun)
    sendEvent(phaseToRun,'start');
    try
      readerCalibrateStimulus();
    catch
      le=lasterror;
      fprintf('ERROR Caught:\n %s\n%s\n',le.identifier,le.message);
      sendEvent('stimulus.training','end');    
    end
    sendEvent(phaseToRun,'end');

   %---------------------------------------------------------------------------
   case {'train','classifier'};
    sendEvent('subject',info.subject);
    sendEvent('startPhase.cmd',phaseToRun);
    % wait until training is done
    buffer_waitData(buffhost,buffport,[],'exitSet',{{phaseToRun} {'end'}},'verb',verb);  

   %---------------------------------------------------------------------------
   case {'epochfeedback'};
    sendEvent('subject',info.subject);
    %sleepSec(.1);
    sendEvent(phaseToRun,'start');
    %try
      sendEvent('startPhase.cmd','epochfeedback');
      readerEpochFeedbackStimulus();
    %catch
    %   le=lasterror;fprintf('ERROR Caught:\n %s\n%s\n',le.identifier,le.message);
    %end
    sendEvent('stimulus.test','end');
    sendEvent(phaseToRun,'end');

   %---------------------------------------------------------------------------
   case {'readerfeedback'};
    sendEvent('subject',info.subject);
    %sleepSec(.1);
    sendEvent(phaseToRun,'start');
   % try
      sendEvent('startPhase.cmd','readerfeedback');
      readerNeuroFeedbackStimulus();

   %catch
      % le=lasterror;
      % fprintf('ERROR Caught:\n %s\n%s\n',le.identifier,le.message);
    % end 
    
    sendEvent('stimulus.test','end');
    sendEvent(phaseToRun,'end');
   %---------------------------------------------------------------------------
  end
  
  info.phasesCompleted={info.phasesCompleted{:} info.phaseToRun};
  if ( ~ishandle(contFig) ) 
    oinfo=info; % store old info
    contFig=controller(); % make new figure
    info=guidata(contFig); % get new info
                           % re-place old info
    info.phasesCompleted=oinfo.phasesCompleted;
    info.phaseToRun=oinfo.phaseToRun;
    info.subject=oinfo.subject; 
    set(info.subjectName,'String',info.subject);
    guidata(contFig,info);
  end;
end

uiwait(msgbox({'Thank you for participating in our experiment.'},'Thanks','modal'),10);
pause(1);

% shut down signal proc
sendEvent('startPhase.cmd','exit');