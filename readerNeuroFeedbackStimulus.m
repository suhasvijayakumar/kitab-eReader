configReader();

pageCount=1;
sizeCount=0.1;

page1  = {'Nobody came to my'; 'seventh birthday party.'};
page2  = {'There was a table laid';'with jellies and trifles,';'with a party hat';'beside each place'};
page3  = {'and a birthday cake with';'seven candles on it';'in the centre of the table.'};
page4  = {'The cake had a';'book drawn on it,';'in icing.'};
page5  = {'My mother,who';'had organised the party,';'told me that the lady'};
page6  = {'at the bakery said that';'they had never put a';'book on a cake before.'}; 
page7  = {'Mostly for boys';'it was footballs';'or spaceships.';'I was their first book.'};
page8  = {'When it became obvious';'that nobody was coming,';'my mother lit the candles'};
page9  = {'on the cake, and I';'blew them out.';'I ate a slice of the cake,';};
page10 = {'as did my little sister';'and one of her friends';'(both attending the party'};
page11 = {'as observers only),';'before they fled,';'giggling, to the garden.'};
page12 = {'Party games had been';'prepared by my mother,';'but as nobody was there,'};
page13 = {'not even my sister,';'none of the party games';'were played, and I'};
page14 = {'unwrapped the';'newspaper around the';'pass-the-parcel';'gift myself, revealing'};
page15 = {'a blue plastic Batman';'figure. I was sad';'that nobody had'};
page16 = {'come to my party,';'but happy that I had';'a Batman figure,'};
page17 = {'and there was a';'birthday present waiting';'to be read,'};
page18 = {'a boxed set of the';'Narnia books,';'which I took upstairs.'};
page19 = {'I lay on the bed';'and lost myself';'in the stories.'};
page20 = {'I liked that.';'Books were safer';'than other people';'anyway.'};

clf;

set(gcf,'Name','eBook Reader - close window to stop.','color',[0 0 0],'toolbar','none','menubar','none'); % black figure
set(gca,'visible','off','color',[0 0 0]); % black axes

% play the stimulus
h=text(.5,.5,'text','HorizontalAlignment','center','VerticalAlignment','middle',...
       'FontUnits','normalized','fontsize',.3,'color',[1 1 1],'visible','off'); 

% Start the experiment with baseline stimulus
set(h,'string','+','color',tgtColor,'visible','on');
drawnow;

sendEvent('stimulus.testing','start');
  
% show the screen to alert the subject to trial start
set(h,'string','+','color',fixColor,'visible','on');
drawnow;

sendEvent('stimulus.baseline','start');
sleepSec(baselineDuration);
sendEvent('stimulus.baseline','end');

set(h,'color',bgColor);
drawnow;

% for the trial duration update the fixatation point in response to prediction events
status=buffer('wait_dat',[-1 -1 -1],buffhost,buffport); % get current state
nevents=status.nevents; 
nsamples=status.nsamples;

trlStartTime=getwTime();
trialDuration = 60*60; % 1hr...
timetogo=trialDuration;
dv = zeros(nFunction,1);

while (timetogo>0)
 % if ( ~ishandle(fig) ) break; end;
  timetogo = trialDuration - (getwTime()-trlStartTime); % time left to run in this trial
  % wait for events to process *or* end of trial
  status=buffer('wait_dat',[-1 nevents min(5000,timetogo*1000/4)],buffhost,buffport); 
  fprintf('.');
  stime =getwTime();
  if ( status.nevents <= nevents ) % new events to process
    fprintf('Timeout waiting for prediction events\n');
    drawnow;
    continue;
  end
  
  events=[];
  if (status.nevents>nevents) 
      events=buffer('get_evt',[nevents status.nevents-1],buffhost,buffport); 
  end;
  nevents=status.nevents;
  mi=matchEvents(events,{'stimulus.prediction'});
  predevents=events(mi);
  
  % make a random testing event
  if ( 0 ) 
      predevents=struct('type','stimulus.prediction','sample',0,'value',ceil(rand()*nFunction+eps)); 
  end;
  if ( ~isempty(predevents) ) 
    [ans,si]=sort([predevents.sample],'ascend'); % proc in *temporal* order
    for ei=1:numel(predevents);
      ev=predevents(si(ei));% event to process
      pred=ev.value;
    
      % now do something with the prediction....
      if ( numel(pred)==1 )
        if ( pred>0 && pred<=nFunction && isinteger(pred) ) % predicted symbol, convert to dv
          tmp=pred; pred=zeros(nFunction,1); pred(tmp)=1;
        else % binary problem
          pred=[pred -pred];
        end
      end
      dv = expSmoothFactor*dv + pred(:);
      prob = 1./(1+exp(-dv(:))); 
      prob=prob./sum(prob); % convert from dv to normalised probability
      if ( verb>=0 ) 
        fprintf('%d) dv:',ev.sample);
        fprintf('%5.4f ',pred);
        fprintf('\t\tProb:');
        fprintf('%5.4f ',prob);
        fprintf('\n'); 
      end;
      
      % feedback information. Do according to the prediction.
      [ans,predTgt]=max(dv);
      
              switch stimulus(predTgt,:);
        
            case '    R    ';
                sendEvent('subject',info.subject);
                pageCount=pageCount+1;
                if (pageCount>20)
                    pageCount = 20;
                end
                if (pageCount==20)
                    instruction = text('visible','on','fontsize',0.1);
                    set(instruction,'String','You have reached the last page, please go back.','color',[0 1 0]);
                    pause(1); clear instruction;
                end
            
            %---------------------------------------------------------------------------

            case '    L    ';
                sendEvent('subject',info.subject);
                pageCount=pageCount-1;
                if (pageCount<1)
                    pageCount = 1;
                end
                if (pageCount==1)
                    instruction = text('visible','on','fontsize',0.1);
                    set(instruction,'String','You are on first page. Please proceeed to the next one.','color',[0 1 0]);
                    pause(1); clear instruction;
                end

            %---------------------------------------------------------------------------

            case '    U    ';
            sendEvent('subject',info.subject);
            sizeCount=sizeCount+0.025;
            if (sizeCount>0.2)
                sizeCount=0.2;
            end
            if (sizeCount==.2)    
                instruction = text('visible','on','fontsize',0.1);
                set(instruction,'String','You have reached maximum size, please decrease fontsize.','color',[0 1 0]);
                pause(1); clear instruction;
            end
            %---------------------------------------------------------------------------

            case '    D    ';
            sendEvent('subject',info.subject);
            sizeCount=sizeCount-0.025;
            if (sizeCount<0.025)
                sizeCount=0.025;
            end
            if (sizeCount==.025)    
                instruction = text('visible','on','fontsize',0.1);
                set(instruction,'String','You have reached minimum size, please increase fontsize.','color',[0 1 0]);
                pause(1); clear instruction;
            end
            %---------------------------------------------------------------------------

            case 'keep calm';
            sendEvent('subject',info.subject);
            %---------------------------------------------------------------------------
      
        end
          
        set(h,'string',eval(['page' num2str(pageCount)]),'color',[1 1 1],'visible','on','fontsize',sizeCount);
        drawnow;
        
    end
  end % if prediction events to processa  
end % loop over epochs in the sequence

% end training marker
sendEvent('stimulus.testing','end');
