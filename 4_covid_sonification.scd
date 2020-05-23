//Has been created for Covid-19 Pandemic Reader
//sonification by Daniel Maszkowicz
//Works welll with python programme given in Jupyter Notebook
//4_play_with_covid_data.ipynb
//
//https://github.com/maszkowicz/CovidPandemic_Reader
//http://ooo.szkmd.ooo

s.boot;

//Open an OSC receiver port
thisProcess.openUDPPort(9002);
//Check open ports in SC server
thisProcess.openPorts;

//Simple Synth that can be implemented
(
SynthDef(
	\covid_sound,
	{
		arg out=0, amp=0.0, freq=131.6, pulse=8.0, pan = 0;
		var modulator = LFPulse.kr(freq: pulse, iphase: 0.0, width: 0.1, mul: 1.0, add: 0.0).lag(0.1);
		var sound = SinOsc.ar(freq: freq, phase: 0, mul: 0.4*modulator);
		var panning = pan;
		//panning = LFNoise1.ar(16,1).lag(0.01); // comment or un-comment for a random panning effect
		var level = Clip.kr(amp,0,0.7);
		Out.ar(out, Pan2.ar(sound, panning, level))
	}
).add;
)

//run the synth, we mute it by setting amplitude to 0
~covid = Synth(\covid_sound,[\amp,0]);
//let's try the Synth
~covid.set(\amp,0.3);
~covid.set(\freq,432);
~covid.set(\pulse,16);
~covid.set(\pan,-0.5);
~covid.set(\pan,0.5);
~covid.set(\pan,0);
//Ok, it works fine, let's mute it again
~covid.set(\amp,0.3);

// we can also release the Synth, if needed
~covid.free

// At this point we need to commicate with the Jupyter Notebook 4_play_with_covid_data.ipynb
//create a first OSC receiver for testing purpose
~test = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		msg.postln
	},'/test',nil);

// Let's create some real ones
~cases = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		var freq, pulse;
		freq=((msg.at(1).log)*200);
		pulse=((msg.at(1).log10+2)*2);
		~covid.set(\freq,freq);
		~covid.set(\pulse,pulse);
		msg.postln
	},'/cases',nil);

~curve = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		var amp;
		amp = (100000**(msg.at(1)))/1000;
		~covid.set(\amp,amp);
		~covid.set(\pan,msg.at(2));
		msg.postln
	},'/curve',nil);


//Let's also have something to record a session right?

~start = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		msg.postln;
		s.record(path: "~/Desktop/pandemic.wav".standardizePath)
	},'/startrecord',nil);

~stop = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		msg.postln;
		s.stopRecording
	},'/stoprecord',nil);


(
~cases.free;
~curve.free;
~start.free;
~stop.free;
~covid.set(\amp,0)
)
