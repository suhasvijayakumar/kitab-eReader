Help document for eBook Reader, BCI Practical 2014 project. 

QuickStart
----------
Note:	.bat files - Windows machines
		.sh  files - Linux/Mac machines

To run the eBook Reader:

1) Start a buffer by running: dataAcq/startBuffer.bat or buffer/startBuffer.sh
	(optional) 
	(1.1) 	If you don't have a measurement system connected, start a simulated data source by running: 
			dataAcq/startSignalProxy.bat or dataAcq/startSignalProxy.sh
2) Start Matlab based signal processing script by running: 
	eReader/startSigProcBuffer.bat or eReader/startSigProcBuffer.sh
3) Start Matlab based experiment control & stimulus presentation script by running : 
	eReader/runReader.bat or runReader.sh
4) BCI Controller will pop-up with the following function keys
	4.1	Subject Name    -- Type in the subject's name in the experiment control window, and then run through each of the following experiment phases: 
	4.2	CapFitting 		-- Check for the quality of the data/brain activity being recorded by the electrodes.  This will show a topographic plot of the head with the electrodes coloured from red=bad to green=good.  Add additional gel/water or adjust ground until they are satisfactorily not red!
		EEG       		-- Real-time EEG viewer to check electrode connection quality.  This shows a topographic arrangement of the electrodes with the current (filtered) signal in each electrode.  If you have a well connected set of electrodes you should be able to see eye-blinks in the more frontal electrodes, and muscle artifacts (such as jaw clenching) in all of the electrodes.
	4.3	Test Run  		-- Practice the task to be used in the BCI. A red fixation cross cues the user to get ready and lasts for 1 second before presenting one of the following 5 cues for calibration 
            R - Right   -> Right-hand movement -> navigate to next page
            L - Left    -> Left-hand movement  -> navigate to the previous page
			U - Tongue  -> Tongue movement     -> increase fontsize
			D - Toes    -> Both toe movement   -> decrease fontsize
			keep clam   -> Do nothing          -> to represent the reading state
	4.4	Calibrate  		-- Get calibration data by performing the task as instructed in 2 blocks, each lasting about 4 minutes
	4.5	Train Classifier-- Train a classifier using the calibration data.  3 windows will pop-up showing: Per-class ERsPs, per-class AUCs, and cross-validated classification performance.  Close the classification performance window to continue to the next stage.
	4.6 Testing -- test the trained classifier in the following two ways
			a. Prompt test - Stimulus presentation is similar to the calibration phase but now, even the classifier feedback is given. This lasts for less than 3 minutes and gives one a general idea of how "efficient" the classifier is.
			b. Reader      - Presents a story with 20 pages giving feedback (changing the pages/fontsize) every second to simulate a reading experience.

File List
---------

General Setup/GUI Files:

configReader.m 								-- basic configuration variables for the reader to specify various parameters like stimulus presentation time, colour, size and what characters to present etc.
runReader.m  runReader.sh runReader.bat	 	-- Controller functions to run the reader stimulus and experiment control
controller.m controller.fig 				-- files to generate the GUI and function call-backs for the experiment control
startSigProcBuffer.m startSigProcBuffer.bat -- control functions to run the various signal-processing functions as requested by the runReader.m experiment controller.
eegMob_Ch10_10-20.png						-- an image file for cap fitting reference for a 10 channel tmsi mobita setup. 
cap_tmsi_mobita_reader10					-- text file with 10 electrodes setting for mobita
cap_tmsi_mobita_reader32					-- text file with 32 electrodes setting for mobita

Experiment Phase Files:

readerCalibrateStimulus.m     -- generate the calibration phase stimulus, i.e. show fixation, cued targets etc.
readerEpochFeedbackStimulus.m -- generate stimulus for the testing phase, where it cues the user to perform an action and gives the classier feedback
readerEpochFeedbackSignals.m  -- makes classifier prediction and gives appropriate feedback values for every trial 
readerNeuroFeedbackStimulus.m -- generate the stimulus for the Reader feedback phase - makes a story with 20 pages for testing purposes.
readerContFeedbackSignals.m   -- makes classifier prediction and gives feedback every second to the readerNeuroFeedbackStimulus.m 



