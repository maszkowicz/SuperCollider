// Sonification Test writen by Daniel Maszkowicz
// Part of Beginner SuperCollider Workshop
// SZKMD production - ooo.szkmd.ooo

// Server Commands before booting (not compulsory)
Server.default.options.numOutputBusChannels=4; //2 is default
Server.default.options.numInputBusChannels=2; //2 is default

// Server Commands
s.boot;
s.scope;
s.meter;

//if we want to quit (not now...)
s.quit;

// FIRST STEPS
// Run the synth and stop it
// MAC users : cmd + .
// PC users : ctrl + .
{SinOsc.ar(440,0,0.1)}.play;

// Let's see the output signal
s.scope;
// or
{SinOsc.ar(440,0,0.1)}.scope;

// It's a mono signal, we want it stereo right? .dup means duplication from mono to stereo
{SinOsc.ar(440,0,0.1).dup}.play;

// what about playing with frequencies in each channnel?
{SinOsc.ar(400,0,0.1)}.play(outbus: 0, fadeTime: 1.0);
{SinOsc.ar(401,0,0.1)}.play(outbus: 1, fadeTime: 1.0);

// This also works, this way implicitely assumes we have a two channels generator
{SinOsc.ar([440, 441],0,0.1)}.play;

//Channel duplication and phase assignation
{SinOsc.ar(freq: [100,100,100,100], phase: [0,pi/2,pi,3*pi/2], mul: 0.1)}.scope;

// Use of a variable such as 'a','b','c',.... warning, some letters such a 's' are reserved by the system
// Play with a and b, play them separately, together, whatever...
// warning if you run twice a, the first one will be out of control, only chance to switch it OFF is to switch everything OFF.
a={SinOsc.ar(mul: 0.1, freq: 200).dup}.play;
a.free;
b={SinOsc.ar(freq: 300, phase: 0, mul: 0.1).dup}.play;
b.free;

// another way naming variables with more than one letter is using '~'
~sinewave1={SinOsc.ar(freq: 440, phase: 0, mul: 0.1).dup}.play;
~sinewave2={SinOsc.ar(freq: 445, phase: 0, mul: 0.1).dup}.play;
~sinewave3={SinOsc.ar(freq: 432, phase: 0, mul: 0.1).dup}.play;
~sinewave4={SinOsc.ar(freq: 441, phase: 0, mul: 0.1).dup}.play;
~sinewave1.free;
~sinewave2.free;
~sinewave3.free;
~sinewave4.free;

// ON and OFF are a bit Harsh, let's add some fade IN and fade OUT. Here 1 second
~sinewave1={SinOsc.ar(freq: 440, phase: 0, mul: 0.1).dup}.play(fadeTime: 1.0);
~sinewave2={SinOsc.ar(freq: 445, phase: 0, mul: 0.1).dup}.play(fadeTime: 1.0);
~sinewave3={SinOsc.ar(freq: 432, phase: 0, mul: 0.1).dup}.play(fadeTime: 1.0);
~sinewave4={SinOsc.ar(freq: 441, phase: 0, mul: 0.1).dup}.play(fadeTime: 1.0);
~sinewave1.release(1.0);
~sinewave2.release(1.0);
~sinewave3.release(1.0);
~sinewave4.release(1.0);

// COMBINING SYNTHS

// Let's run a pulse wave on the Sinewave amplitude
a={SinOsc.ar(freq: 432, phase: 0, mul: 0.2*LFPulse.kr(freq: 1, iphase: 0.0, width: 0.5, mul: 1.0, add: 0.0)).dup}.play;
a.free;

// Smooth it by adding function .lag(0.1)
// We play it now at 7.83 Hz (Schumman frequency for Earth's electromagnetic field)
a={SinOsc.ar(freq: 432, phase: 0, mul: 0.2*LFPulse.kr(freq: 7.83, iphase: 0.0, width: 0.5, mul: 1.0, add: 0.0).lag(0.1)).dup}.play;
a.free;

// We want to use the computer mouse for controlling the frequencies
// MouseX.kr(100,500,'exponential') for base sine frequency
// MouseY.kr(1,10,'linear') for beat freqeuncy
a={SinOsc.ar(freq: MouseX.kr(100,400,'exponential'), phase: 0, mul: 0.2*LFPulse.kr(freq: MouseY.kr(1,10,'linear'), iphase: 0.0, width: 0.5, mul: 1.0, add: 0.0).lag(0.1)).dup}.play;
a.free;

// Note, we notice the use of '.ar' and '.kr' in the used Synths that are appearing in blue. '.ar' means it is an array that outputs sound typically (44,1kHz), '.kr' is used for controlling synths, much lower sampling frequency

// Let's have some fun and put a Sinwave function controlling the freqeuncy of the main Sinewave Generator
// 200+SinOsc.kr(1,0,10,0) outputs a signal between 180 and 220 pulsating at a frequency of 1Hz
a={SinOsc.ar(freq: 200+SinOsc.kr(1,0,20,0), phase: 0, mul: 0.2*LFPulse.kr(freq: 8, iphase: 0.0, width: 0.5, mul: 1.0, add: 0.0).lag(0.1)).dup}.play;
a.release(1);

// Let's do some fun paning effects controlled with the mouse

a={Pan2.ar(SinOsc.ar(freq: 300, phase: 0, mul: 0.1), MouseX.kr(-1,1,'linear')) }.play
a.free;

// One fun Synth

{ Blip.ar(MouseY.kr(100,1000,'exponential'),MouseX.kr(1,100,'linear'),0.2).dup }.play;

// A fun Synth given as a example of Gendy1
// (An implementation of the dynamic stochastic synthesis generator conceived by Iannis Xenakis)
// in the example there is no variables, we added them, they are not compulsory
(
c={
    Pan2.ar(
        SinOsc.ar(
            Gendy1.kr(2, 4,
                SinOsc.kr(0.1, 0, 0.49, 0.51),
                SinOsc.kr(0.13, 0, 0.49, 0.51),
                3.4, 3.5,
                SinOsc.kr(0.17, 0, 0.49, 0.51),
                SinOsc.kr(0.19, 0, 0.49, 0.51),
                10, 10, 50, 350),
        0, 0.3),
    0.0)
}.play
)
c.free;

// Let's record a bit of the previous sound!

//MAC STYLE filepath
s.record(path: "~/Desktop/test_recording.wav".standardizePath, numChannels: 2);
//PC STYLE filepath
s.record(path: "c:\SuperCollider\Workshop\test_recording.wav".standardizePath, numChannels: 2);
// Stop Recording (don't forget it....)
s.stopRecording;

// Quick test for Quadriphony
(
z={ Out.ar(0,Pan4.ar(
	in:PinkNoise.ar(1),
	xpos:MouseX.kr(-1,1,'linear'),
	ypos:MouseY.kr(-1,1,'linear'),
	level:0.1))}.play(fadeTime: 1)
)
z.free;

// Fun interractive code, the annoying bee

(
~bee={ Pan4.ar(
	in:Gendy1.ar(minfreq: 100,
		maxfreq:200,
		ampscale: 0.5,
		durscale: 0.5,
		initCPs: 12)*
	(1-(sqrt(squared(MouseX.kr(-0.8,0.8,'linear'))+squared(MouseY.kr(0.8,-0.8,'linear'))))),
	xpos:MouseX.kr(-1,1,'linear'),
	ypos:MouseY.kr(-1,1,'linear'),
	level:0.5)}.play(fadeTime: 20.0);
)
~bee.release(2);

//Let's note the use of the outer brackets
//click 2 time on the first or last bracket to select the whole code.

// Check HELP for other sound generators by writing "Synth" in Search!

// WRITING SYNTHS AND FUNCTIONS

// play with frequencies

(
u={ var freq1,freq2;
    freq1 = 396; //396 Liberating Guilt and Fear
	freq2 = 639; //639 Connecting/Relationships
	Mix.new([SinOsc.ar([freq1-0.5,freq1+0.5],0,0.2),
		SinOsc.ar([freq2-0.4,freq2+0.4],0,0.1),
		PinkNoise.ar(0.02)])//76.37
}.play(outbus: 0, fadeTime: 5.0)
)
u.release(5);

(
v={ var freq1,freq2;
    freq1 = 528; //528 Transformation and Miracles (DNA Repair) LOVE
	freq2 = 136.1; //136.10 Cosmic Ohm
	Mix.new([SinOsc.ar([freq1-0.5,freq1+0.5,freq1-0.8,freq1+0.8],0,0.2),
		SinOsc.ar([freq2-0.4,freq2+0.4,freq2-0.7,freq2+0.7],0,0.1),
		PinkNoise.ar(0.02)])//76.37
}.play(outbus: 0, fadeTime: 5.0)
)
v.release(5);

//Use of Blip arays (Band Limited Impulse Generator)

(
a={ Mix.new([Blip.ar([71.77,72.52,72.22,72.97],7,0.1),
	Blip.ar([79.77,80.52,80.22,80.97],
		14.rand+7,0.1)])//76.37
}.play(outbus: 0, fadeTime: 5.0)
)
(
b={ Mix.new([Blip.ar([56.01,56.76,56.46,57.21],7,0.1),
	Blip.ar([64.01,64.76,64.46,65.21],
		14.rand+7,0.1)])//60.61
}.play(outbus: 0, fadeTime: 5.0)
)
(
c={ Mix.new([Blip.ar([40.81,41.56,41.26,42.01],9,0.1),
	Blip.ar([48.81,49.56,49.26,50.01],
		14.rand+7,0.1)])//45.41
}.play(outbus: 0, fadeTime: 5.0)
)
(
f={ Mix.new([Blip.ar([27.51,28.26,27.96,28.71],11,0.1),Blip.ar([35.51,36.26,35.96,36.71],10,0.1)])//32.11
}.play(outbus: 0, fadeTime: 5.0)
)
(
a.release(5);
b.release(5);
c.release(5);
f.release(5);
)

// Let's write our own Synth! First we define it, then we run one or two instances of it,
// and we can modify parameters
(
SynthDef(
	\Noise_Machine,
	{
		arg amp = 0, ffreq = 1000, rq = 0.8, out=0;
		var snd;
		snd = BrownNoise.ar(amp);
		snd = BPF.ar(snd, ffreq, rq);
		Out.ar(out,Pan2.ar(
			in:snd,
			pos:LFNoise1.ar(1,0.7),
			level:1));
	}
).add;
)

// Run the line one after the other and understand what we do
~noise1 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,300,\rq,0.8]);
~noise1.set(\ffreq,200)
~noise1.set(\rq,0.1)
~noise2 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,1000,\rq,0.3]);
~noise1.set(\rq,0.5)
~noise2.set(\ffreq,2000)
~noise3 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,500,\rq,0.8]);
~noise3.set(\ffreq,666)

~noise1.free;
~noise2.free;
~noise3.free;

//Let's do another one, define a simple sinwave bus
(
SynthDef(
	\sinewave,
	{
		arg amp = 0, freq = 100, beat = 1, out=0;
		var snd;
		snd = SinOsc.ar([freq,freq+beat]);
		Out.ar(out,snd*amp);
	}
).add;
)

~sine1 = Synth(\sinewave,[\amp,0.1,\freq,100,\beat,1,\out,0]);
~sine1.free;

//Use of Ausio busses

~noisebus=Bus.audio(s,2);
~sinewavebus=Bus.audio(s,2);

// let's define output of Synth to a given bus
~noise1 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,300,\rq,0.8,\out,~noisebus]);
~noise2 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,1000,\rq,0.3,\out,~noisebus]);
~sine1 = Synth(\sinewave,[\amp,0.1,\freq,100,\beat,1,\out,~sinewavebus]);

//let's write a mixer for mixing two busses into output
(
SynthDef(
	\mixer,
	{
		var select;
		select = MouseX.kr(0,1,'linear');
		Out.ar(0,InBus.ar(~noisebus,2,0)*select);
		Out.ar(0,InBus.ar(~sinewavebus,2,0)*(1-select));
	}
).add
)

~mixer = Synth(\mixer);
s.freeAll;

//Use of control busses with the previously defined Noise Machine Synth

~rq_bus = Bus.control(s,1);
~amp_bus = Bus.control(s,1);

// Mi 80.91, Sol# 101.94, Si 121.23, Ré# 152.74

~noise1 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*80.91,\rq,0.1,\out,0]);
~noise2 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*101.94,\rq,0.1,\out,0]);
~noise3 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*121.23,\rq,0.1,\out,0]);
~noise4 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*152.74,\rq,0.1,\out,0]);

~noise1.map(\amp, ~amp_bus,\rq, ~rq_bus);
~noise2.map(\amp, ~amp_bus,\rq, ~rq_bus);
~noise3.map(\amp, ~amp_bus,\rq, ~rq_bus);
~noise4.map(\amp, ~amp_bus,\rq, ~rq_bus);

// Write in control bus directly

~rq_bus.set(0.0001)
~amp_bus.set(10)

// Or use a Synth that outputs in the control bus directly

(
SynthDef(
	\param_sender,
	{
		Out.kr(~amp_bus,MouseY.kr(0.0001,10,'exponential'));
		Out.kr(~rq_bus,MouseX.kr(0.0001,10,'exponential'))
	}
).add;
)

~param = Synth(\param_sender);
~param.free;
s.freeAll;

//reading a file and spacialize it, here I use the sound we recorded previously

// Binaural
(
~spacesound = Buffer.read(s, "/Users/Szkomaga/Desktop/SonificationTalk2020/Workshop/test_recording.wav");
m={Pan2.ar(PlayBuf.ar(1,~spacesound, loop:1, rate:MouseX.kr(0.1,2,'linear')),
	pos:SinOsc.ar(freq:0.5),
	level:0.8)}.play(outbus: 0, fadeTime: 1);
)
m.release;

// Quadriphony
(
~spacesound = Buffer.read(s, "/Users/Szkomaga/Desktop/SonificationTalk2020/Workshop/test_recording.wav");
m={Pan4.ar(PlayBuf.ar(1,~spacesound, loop:1),
	xpos:SinOsc.ar(freq:0.5),
	ypos:SinOsc.ar(freq:0.5,phase:pi/2),
	level:0.8)}.play(outbus: 0, fadeTime: 1);
)
m.release;


// find examples on the web and learn from them
// sccode.org is a good one, github is another

// Check my brainwave machine on http://sccode.org/1-5aK

// try to run also the following one

// The next one was found on Sccode.org, check the other examples by Bruno Ruviaro
// and reuse what you are interrested in.

// ************************************
// Subtractive Synthesis Demo (GUI)
// Patch 1 - Filtering a noise source
// Bruno Ruviaro, 2013-07-26
// ************************************

/*

Use the 2D slider to choose filter frequency (x-axis) and filter rq (y-axis). Use the menu to choose noise source: Pink Noise, White Noise, Gray Noise, Brown Noise, or Clip Noise.

Watch the Frequency Analyzer window to see how the spectrum changes.

*/
(
s.waitForBoot({
	var noise, win, slider2d, menu, controlX, controlY, volumeSlider, button;
	noise = {arg whichNoise = 0, whichFilter = 0, amp = 0.06, ffreq = 1000, rq = 0.8;
		var snd;
		amp = Lag.kr(amp, 1);
		snd = Select.ar(
			which: whichNoise,
			array: [
				PinkNoise.ar(amp),
				WhiteNoise.ar(amp * 0.6),
				GrayNoise.ar(amp * 0.7),
				BrownNoise.ar(amp),
				ClipNoise.ar(amp * 0.5)]);
		snd = Select.ar(
			which: whichFilter,
			array: [
				BPF.ar(snd, ffreq, rq),
				BRF.ar(snd, ffreq, rq)]);
		Out.ar(0, [snd, snd]);
	}.play;

	win = Window(
		name: "Subtractive Synthesis - Patch 1",
		bounds: Rect(300, 100, 600, 560));
	win.background = Color.black;

	// Slider
	controlX = ControlSpec(
		minval: 100,
		maxval: 10000,
		warp: \exp,
		step: 0.1);
	controlY = ControlSpec(
		minval: 1.0,
		maxval: 0.001,
		warp: \exp,
		step: 0.001);
	slider2d = Slider2D(win, Rect(10, 10, 580, 500));
	slider2d.x = controlX.unmap(1000);
	slider2d.y = controlY.unmap(0.5);
	slider2d.background = Color.new255(255, 102, 255);
	slider2d.knobColor = Color.black;
	slider2d.action = {|slider|
		noise.set(
			\ffreq, controlX.map(slider.x),
			\rq, controlY.map(slider.y))};

	// Noise Source menu
	menu = PopUpMenu(win, Rect(10, 520, 120, 30));
	menu.items = ["Pink Noise", "White Noise", "Gray Noise", "Brown Noise", "Clip Noise"];
	menu.action = {arg menu;
		noise.set(\whichNoise, menu.value);
		case
		{menu.value==0} {slider2d.background = Color.new255(255, 102, 255)}
		{menu.value==1} {slider2d.background = Color.new255(255, 255, 255)}
		{menu.value==2} {slider2d.background = Color.new255(192, 192, 192)}
		{menu.value==3} {slider2d.background = Color.new255(139, 69, 19)}
		{menu.value==4} {slider2d.background = Color.new255(0, 0, 0)}};

	// Filter Type button
	button = Button(win, Rect(140, 520, 40, 30));
	button.states = [["BPF", Color.white, Color.black], ["BRF", Color.white, Color.red]];
	button.action = {arg button;
		if(button.value==0,
			{
				noise.set(\whichFilter, 0);
				slider2d.knobColor = Color.black;
			},
			{
				volumeSlider.valueAction = -24;
				SystemClock.sched(0.5, {noise.set(\whichFilter, 1)});
				slider2d.knobColor = Color.red;
			});
	};

	// Volume slider
	volumeSlider = EZSlider(
		parent: win,
		bounds: Rect(190, 520, 390, 30),
		label: "VOLUME",
		controlSpec: ControlSpec(-60, 0, \lin, 0.1, -24, "dB"),
		action: {|ez| noise.set(\amp, ez.value.dbamp)},
		initVal: -24)
	.setColors(
		stringColor: Color.white,
		sliderBackground: Color.grey(0.9),
		numNormalColor: Color.black);

	FreqScope.new;
	win.front;
	CmdPeriod.doOnce({Window.closeAll});
	win.onClose = {s.freeAll; Window.closeAll};

}); // end of block
)

