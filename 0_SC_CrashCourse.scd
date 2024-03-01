// Introduction to SuperCollider writen by Daniel Maszkowicz
// Part of Beginner SuperCollider Workshop
// SZKMD production - ooo.szkmd.ooo

///////////////////////////////////////////////////////////
//// PART I : First Sounds
///////////////////////////////////////////////////////////

// For runing code in Supercollider
// Shift + Enter -> evaluate a line
// CMD + Enter -> evaluatet a region

// check available sound devices
ServerOptions.inDevices
ServerOptions.outDevices

// manually choose input and output device (usually SuperCollider does it automatically)
Server.default.options.inDevice="Built-in Microph"
Server.default.options.outDevice="Built-in Output"

// Server Commands (one can aslo find them in "Server" menu or with keyboard shortcuts)
s.boot // boots the server
s.scope // plots audio outputs
s.meter // displays audio inputs // outputs
s.plotTree // displays local Node Tree
s.freqscope // diplays spectral audio output

//if we want to quit (but not now...)
s.quit

// FIRST STEPS
// Evaluate the following function and stop it (shift+enter or cmd+enter)
// Here the most simple function ever (click on function then cmd+D for help)
// to stop you can use cmd+-
{SinOsc.ar(440,0,0.1,0)}.play
//This is equivalent
{SinOsc.ar(440, mul: 0.1)}.play
//This is aswell
{SinOsc.ar(440)*0.1}.play
//This also (click in the middle of brackets and run with cmd+enter)
(
{SinOsc.ar(
	freq: 440,
	phase: 0,
	mul: 0.1,
	add:0)}.play
)

// Let's plot the output signal
s.scope
// or
{SinOsc.ar(freq: 440, mul: 0.1)}.scope
// or
{SinOsc.ar(freq: 440, mul: 0.1)}.freqscope

// Note, we notice the use of '.ar' and '.kr' in the used Synths that are appearing in blue. '.ar' means it is an array that outputs sound typically (44.1kHz), '.kr' is used for controlling synths, much lower sampling frequency
//By default, control rate ugens generate one sample value for every sixty-four sample values made by an audio rate ugen. Control rate ugens thus use fewer resources and are less computationally expensive than their audio rate counterparts.
//Use control rate ugens as modulators, that is, as signals that shape an audio signal.

// try the control rate try 440Hz and 44Hz, what happens? read more about Niquist frequency and alliazing
{SinOsc.kr(freq: 44, mul: 0.1)}.scope

// Let's play sounds again

// It's a mono signal, we want it stereo right? .dup means duplication from mono to stereo
{SinOsc.ar(freq: 440, mul: 0.1).dup}.play
// This also works
{SinOsc.ar(freq: 440, mul: 0.1).dup(2)}.play
// That as well, choose your favourite
{SinOsc.ar(freq: 440, mul: 0.1)!2}.play

// What about playing with frequencies in each channnel?
// Here we use cmd + enter for evaluating both line at a time, note the appearance of ";" for separating the two lines and the braquets for saying they are executed at the same time
(
{SinOsc.ar(freq: 400, mul: 0.1)}.play(outbus: 0);
{SinOsc.ar(freq: 401, mul: 0.1)}.play(outbus: 1)
)

//Same as using an array of generators:
{[SinOsc.ar(freq: 400, mul: 0.1),SinOsc.ar(402, mul: 0.1)]}.play

// This way implicitely assumes we have a two channels generator
// multichannel expansion is THE BIG plus of SuperCollider over all others
{SinOsc.ar(freq: [440, 441], mul: 0.1)}.play

// This way allows different amplitudes
{SinOsc.ar(freq: [440, 500], mul: [0.02, 0.2])}.play

//Channel duplication and phase assignation
{SinOsc.kr(freq: [10,10], phase: [0,pi/2])}.scope

// We can also multiply  functions
{SinOsc.ar(freq: [440, 441], mul: 0.1)*SinOsc.kr(freq: [1, 2], phase: [0,pi/2])}.scope

// NOW WE WANT MORE SOUND SOURCES
// Use of a global variable such as 'a','b','c',.... warning, some letters such a 's' are reserved by the system
// Play with a and b, evaluate them separately, free them whenever...
// warning if you run twice a function named with the same variable, the new pointer will replace the first one, so it will get out of control, only chance to switch it OFF is to switch everything OFF with cmd+-.
a={SinOsc.ar(freq: 200, mul: 0.1).dup}.play
b={SinOsc.ar(freq: 300, mul: 0.1).dup}.play
// for releasing them
a.free
b.free

// another way naming global variables with more than one letter is using '~'
~sine1={SinOsc.ar(freq: 440, mul: 0.1).dup}.play
// for releasing it
~sine1.free

// ON and OFF are a bit Harsh, let's add some fade IN and fade OUT. Here 1 second, and play with different sounds
~sine1={SinOsc.ar(freq: 440, mul: 0.1).dup}.play(fadeTime: 1.0)
~sine2={SinOsc.ar(freq: 445, mul: 0.1).dup}.play(fadeTime: 1.0)
~sine3={SinOsc.ar(freq: 432, mul: 0.1).dup}.play(fadeTime: 1.0)
~sine4={SinOsc.ar(freq: 441, mul: 0.1).dup}.play(fadeTime: 1.0)
// For releasing them
~sine1.release(1.0)
~sine2.release(1.0)
~sine3.release(1.0)
~sine4.release(1.0)

// Let's record the output, press recorder on, play the sound, press stop
//numChannels is optionnal, default is 2, but sky is the limit.
// Type standadizePath in MacOSX for finding your home directory
"~/".standardizePath

s.record(path: "~/Desktop/test_recording.wav".standardizePath, numChannels: 2)
// Stop Recording (don't forget it....)
s.stopRecording

///////////////////////////////////////////////////////////
//// PART II : Combining UGens and Functions
///////////////////////////////////////////////////////////

// read about UGens in Document Browser, Tour of UGens, and look for nice Synths in examples

// Let's run a pulse wave on the Sinewave amplitude
(
a={SinOsc.ar(
	freq: 432,
	phase: 0,
	mul: 0.2*LFPulse.kr(
		freq: 1,
		iphase: 0.0,
		width: 0.5,
		mul: 1.0,
		add: 0.0),
	add: 0).dup}.play
)
// For releasing it
a.free

// Same same but using a local variable
// Note the use of ";" of reparating lines

(
a={
	var freq, mul, width;
	freq = 432;
	width = 0.5;
	mul = 0.2*LFPulse.kr(freq: 1, width: width);
	SinOsc.ar(freq: freq, mul: mul).dup}.play
)
// For releasing it
a.free

// Smooth it by adding function .lag(0.1)
// We play it now at 7.83 Hz (Schumman frequency for Earth's electromagnetic field)

(
a={
	var freq, mul, width;
	freq = 432;
	width = 0.5;
	mul = 0.2*LFPulse.kr(freq: 7.83, width: width).lag(0.1);
	SinOsc.ar(freq: freq, mul: mul).dup}.play
)
// For releasing it
a.release(1)

// We want to use the computer mouse for controlling the frequencies
// MouseX.kr(100, 500, 'exponential') for base sine frequency
// MouseY.kr(1, 10, 'linear') for beat freqeuncy

(
a={
	var freq, mul, width;
	freq = MouseX.kr(100, 400, 'exponential');
	width = 0.5;
	mul = 0.2*LFPulse.kr(
		freq: MouseY.kr(1, 10, 'linear'), width: width).lag(0.1);
	SinOsc.ar(freq: freq, mul: mul).dup}.play
)
// For releasing it
a.free

// Let's have some fun and put a Sinwave function controlling the freqeuncy of the main Sinewave Generator
// 200+SinOsc.kr(1,0,20,0) outputs a signal between 180 and 220 pulsating at a frequency of 1Hz

(
a={
	var freq, mul, width;
	freq = SinOsc.kr(freq: 1, mul: 20, add: 200);
	width = 0.5;
	mul = 0.2*LFPulse.kr(freq: 8, width: width).lag(0.1);
	SinOsc.ar(freq: freq, mul: mul).dup}.play
)
// For releasing it
a.release(1)

// Let's do some fun paning effects controlled with the mouse
// By the way, check out this writing style, neat isn't it?

(
a={
	Pan2.ar(
		in: SinOsc.ar(
			freq: 300,
			mul: 0.1),
		pos: MouseX.kr(
			minval: -1,
			maxval: 1,
			warp: 'linear'))}.play
)
a.release(1)

// ok this is the super clean way to write, the following code is equivalent:

a={Pan2.ar(SinOsc.ar(300,0,0.1),MouseX.kr(-1,1,'linear'))}.play
// For releasing it
a.free

// Let's look for fun UGens in the help browser
// Look for Blip (clic on the text "Blip" and press cmd + D)
// Look for LFCub
// Look for Gendy1 (An implementation of the dynamic stochastic synthesis generator conceived by Iannis Xenakis)
// Here I copy pasted an example fro the help file, but we can also run it directly from the help file
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
// For releasing it
c.free

// Quick test for Quadraphony
(
z={
	Pan4.ar(
		in:PinkNoise.ar(),
		xpos:MouseX.kr(-1, 1, 'linear'),
		ypos:MouseY.kr(-1, 1, 'linear'),
		level:0.1)}.scope
)
// For releasing it
z.free

// Fun interractive code, the annoying bee
// test the source first
(
{Gendy1.ar(
	minfreq: 100,
	maxfreq: 200,
	ampscale: 0.5,
	durscale: 0.5,
	initCPs: 12)}.play
)
// For releasing it, You can still use "CMD" + "."

(
~bee={
	Pan2.ar(
		in: Gendy1.ar(1, 1, 1, 1, 100, 200, 0.5, 0.5, 12),
		pos: MouseX.kr(-1, 1, 'linear'),
		level:0.5)}.play
)
// For releasing it
~bee.release(1)

// Let's expand it to quadraphony
(
~bee={
	Pan4.ar(
		in: Gendy1.ar(
			minfreq: 100,
			maxfreq: 200,
			ampscale: 0.5,
			durscale: 0.5,
			initCPs: 12),
		xpos:MouseX.kr(-1, 1, 'linear'),
		ypos:MouseX.kr(-1, 1, 'linear'),
		level:0.5)}.play
)
// For releasing it
~bee.release(1)

// Let's expand it to multichannel with random position
(
~bee={
	PanAz.ar(
		numChans: 6,
		in: Gendy1.ar(
			minfreq: 100,
			maxfreq: 200,
			ampscale: 0.5,
			durscale: 0.5,
			initCPs: 12),
		pos:LFNoise1.kr(freq:5),
		level:0.1,
		width:2)}.play
)
// For releasing it
~bee.release(1)

// Let's record the output, press recorder on, play the sound, press stop
//numChannels is optionnal, default is 2, but sky is the limit.
// Type standadizePath in MacOSX for finding your home directory
"~/".standardizePath

s.record(path: "~/Desktop/test_recording.wav".standardizePath, numChannels: 2)
// Stop Recording (don't forget it....)
s.stopRecording

///////////////////////////////////////////////////////////
//// PART III : Duplicating functions and Synths
///////////////////////////////////////////////////////////

// play with the following function with local variables and duplicate the function with other values

(
u={
	var freq1, freq2, beat1, beat2;
	freq1 = 396; //396 Liberating Guilt and Fear
	freq2 = 639; //639 Connecting/Relationships
	beat1 = 1; // Delta brainwaves
	beat2 = 4; // Theta brainwaves
	Mix.new([
		SinOsc.ar(
			freq: [freq1-beat1/2, freq1+beat1/2],
			mul: 0.2),
		SinOsc.ar(
			freq: [freq2-beat2/2, freq2+beat2/2],
			mul: 0.2)])
}.play(fadeTime: 5.0)
)
// For releasing it
u.release(5)

(
v={
	var freq1, freq2, beat1, beat2;
	freq1 = 528; //528 Love Miracles (DNA Repair)
	freq2 = 136.1; //136.10 Cosmic Ohm
	beat1 = 1; // Delta brainwaves
	beat2 = 4; // Theta brainwaves
	Mix.new([
		SinOsc.ar(
			freq: [freq1-beat1/2, freq1+beat1/2],
			mul: 0.2),
		SinOsc.ar(
			freq: [freq2-beat2/2, freq2+beat2/2],
			mul: 0.2)])
}.play(fadeTime: 5.0)
)
// For releasing it
v.release(5)

//Let's play now with a drony function making use of Blip arays (Band Limited Impulse Generator). We introduce the arguments and duplicate the function with other values

(
a={
	arg freq1 = 72, freq2 = 80, beat = 0.25, nh = 7, amp = 0.1;
	Mix.new([
		Blip.ar([freq1-beat, freq1+beat], nh, amp),
		Blip.ar([freq2-beat, freq2+beat], nh, amp)])
}.play(fadeTime: 5.0)
)
a.set(\freq1, 60)
a.set(\freq2, 90)
a.set(\nh, 14)
(
b={
	arg freq1 = 56, freq2 = 64, beat = 0.25, nh = 7, amp = 0.1;
	Mix.new([
		Blip.ar([freq1-beat, freq1+beat], nh, amp),
		Blip.ar([freq2-beat, freq2+beat], nh, amp)])
}.play(fadeTime: 5.0)
)
(
c={
	arg freq1 = 41, freq2 = 49, beat = 0.25, nh = 7, amp = 0.1;
	Mix.new([
		Blip.ar([freq1-beat, freq1+beat], nh, amp),
		Blip.ar([freq2-beat, freq2+beat], nh, amp)])
}.play(fadeTime: 5.0)
)
(
f={
	arg freq1 = 28, freq2 = 36, beat = 0.25, nh = 10, amp = 0.1;
	Mix.new([
		Blip.ar([freq1-beat, freq1+beat], nh, amp),
		Blip.ar([freq2-beat, freq2+beat], nh, amp)])
}.play(fadeTime: 5.0)
)
//Let's release them all at once
(
a.release(5);
b.release(5);
c.release(5);
f.release(5);
)

//this following example has been writen by Eli Fieldsteel in his youtube Supercollider tutorials, it's a very fun Function introducing random values

(
z = {
	arg noiseHz=8;
	var freq, amp, sig;
	freq = LFNoise0.kr(noiseHz).exprange(200, 1000);
	amp = LFNoise1.kr(12).exprange(0.02, 0.3);
	sig = SinOsc.ar(freq).dup*amp;
	FreeVerb.ar(sig, 0.5, 0.5, 0.5)
}.play
)
z.set(\noiseHz, 64)
z.set(\noiseHz, exprand(4,64))
z.free;

// Let's write our own Synth! First we define it, then we run one or two instances of it,
// and we can modify parameters
(
SynthDef(
	\Noise_Machine,{
		arg amp = 0, ffreq = 1000, rq = 0.8, out=0;
		var snd, outsignal;
		snd = BrownNoise.ar(amp);
		snd = BPF.ar(snd, ffreq, rq);
		outsignal = Pan2.ar(
				in:snd,
				pos:LFNoise1.ar(1, 0.7),
				level:1);
		Out.ar(out, outsignal)}).add
)

// Run the line one after the other and understand what we do
~noise1 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,300,\rq,0.8])
~noise1.set(\ffreq,200)
~noise1.set(\rq,0.1)
~noise2 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,1000,\rq,0.3])
~noise1.set(\rq,0.5)
~noise2.set(\ffreq,2000)
~noise3 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,500,\rq,0.8])
~noise3.set(\ffreq,666)
// For releasing them, one by one
~noise1.free
~noise2.free
~noise3.free

// this following example has been writen by Eli Fieldsteel in his youtube Supercollider tutorials, this introduces distinct channels output

(
SynthDef(
	\pulseTest1,{
		arg fund = 40, maxPartial = 4, ampHz = 4, width = 0.5;
		var amp1, amp2, freq1, freq2, sig1, sig2;
		amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
		amp2 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
		freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
		freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
		//freq1=freq1*LFPulse.kr(8,add:1);
		//freq2=freq2*LFPulse.kr(8,add:1);
		sig1=Pulse.ar(freq1, width, amp1);
		sig2=Pulse.ar(freq2, width, amp2);
		//sig1=FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
		//sig2=FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
		Out.ar(0,sig1);
		Out.ar(1,sig2)}).add
)

(
SynthDef(
	\pulseTest2,{
		arg fund = 40, maxPartial = 4, ampHz = 4, width = 0.5;
		var amp1, amp2, freq1, freq2, sig1, sig2;
		amp1 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
		amp2 = LFPulse.kr(ampHz, 0, 0.12) * 0.75;
		freq1 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
		freq2 = LFNoise0.kr(4).exprange(fund, fund*maxPartial).round(fund);
		freq1=freq1*LFPulse.kr(8,add:1);
		freq2=freq2*LFPulse.kr(8,add:1);
		sig1=Pulse.ar(freq1, width, amp1);
		sig2=Pulse.ar(freq2, width, amp2);
		sig1=FreeVerb.ar(sig1, 0.7, 0.8, 0.25);
		sig2=FreeVerb.ar(sig2, 0.7, 0.8, 0.25);
		Out.ar(0,sig1);
		Out.ar(1,sig2)}).add
)

p=Synth(\pulseTest1)
p.set(\fund, 30)
p.set(\width, 0.5)
p.free

p=Synth(\pulseTest2)
p.set(\fund, 30)
p.set(\width, 0.5)
p.free

// Let's record the output, press recorder on, play the sound, press stop
//numChannels is optionnal, default is 2, but sky is the limit.
// Type standadizePath in MacOSX for finding your home directory
"~/".standardizePath

s.record(path: "~/Desktop/test_recording.wav".standardizePath, numChannels: 2)
// Stop Recording (don't forget it....)
s.stopRecording;

///////////////////////////////////////////////////////////
//// PART IV : Use of Busses and Groups
///////////////////////////////////////////////////////////

// Let's create two busses

~noisebus=Bus.audio(s,2)
~sinewavebus=Bus.audio(s,2)
~fxsendbus=Bus.audio(s,2)

//Let's get our noise machine we got previously

(
SynthDef(
	\Noise_Machine,{
		arg amp = 0, ffreq = 1000, rq = 0.8, out=0;
		var snd, outsignal;
		snd = BrownNoise.ar(amp);
		snd = BPF.ar(snd, ffreq, rq);
		outsignal = Pan2.ar(
				in:snd,
				pos:LFNoise1.ar(1,0.7),
				level:1);
		Out.ar(out, outsignal)}).add
)

// Let's test it:
~noise1 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,300,\rq,0.8])
~noise1.set(\ffreq,200)
~noise1.set(\rq,0.1)
~noise1.free

//Let's create a generator that does some pulses

(
SynthDef(
	\sinewave,{
		arg amp = 0, freq = 100, pulse = 4, beat = 1, out=0;
		var snd, snamp, snfreq;
		snamp = LFPulse.ar(pulse).lag(0.05);
		snfreq = LFNoise0.kr(pulse).exprange(freq, freq*3).round(freq);
		snd = SinOsc.ar([snfreq, snfreq+beat])*snamp;
		Out.ar(out, snd*amp)}).add
)

// Let's test it:
~sine1 = Synth(\sinewave,[\amp,0.2,\freq,200,\pulse,4,\beat,1,\out,0])
// For releasing it
~sine1.free

// Let's build a simple effect doing a reverbe

(
SynthDef(
	\stereoreverb,{
		arg in, out=0;
		var sig;
		sig = In.ar(in,2);
		sig = FreeVerb.ar(sig, 0.5, 0.8, 0.2);
		Out.ar(out,sig)}).add
)

//let's write a mixer for mixing two busses into output
(
SynthDef(
	\mixer,
	{
		var select;
		select = MouseX.kr(0,1,'linear');
		Out.ar(0,InBus.ar(~noisebus,2,0)*select);
		Out.ar(0,InBus.ar(~sinewavebus,2,0)*(1-select))
	}
).add
)

// let's define output of Synth to a given bus
~noise1 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,300,\rq,0.8,\out,~noisebus])
~noise2 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,1000,\rq,0.3,\out,~noisebus])
~sine1 = Synth(\sinewave,[\amp,0.9,\freq,100,\beat,1,\out,~fxsendbus])
~effect = Synth(\stereoreverb,[\in,~fxsendbus,\out,~sinewavebus])
~mixer = Synth(\mixer)

s.freeAll

// somehow it doesn't work, because the effect is calculated before the source... so it outputs nothing, see the local Node Tree

//We can use addAction parameter to modify the position of the Objects, check "Synth" help file for more information

~noise1 = Synth(\Noise_Machine, [\amp,0.1,\ffreq,300,\rq,0.8,\out, ~noisebus])
~noise2 = Synth(\Noise_Machine, [\amp,0.1,\ffreq,1000,\rq,0.3,\out, ~noisebus])
~sine1 = Synth(\sinewave, [\amp,0.9,\freq,100,\beat,1,\out, ~fxsendbus])
~effect = Synth(\stereoreverb, [\in, ~fxsendbus, \out, ~sinewavebus], addAction: \addToTail)
~mixer = Synth(\mixer)

s.freeAll

// Let's introduc the use of groups

~sourceGroup = Group.new
~fxGroup = Group.after(~sourceGroup)
~mixerGroup = Group.after(~fxGroup)

~noise1 = Synth(\Noise_Machine, [\amp,0.1,\ffreq,300,\rq,0.8,\out, ~noisebus], ~sourceGroup)
~noise2 = Synth(\Noise_Machine, [\amp,0.1,\ffreq,1000,\rq,0.3,\out, ~noisebus], ~sourceGroup)
~sine1 = Synth(\sinewave, [\amp,0.9,\freq,100,\beat,1,\out, ~fxsendbus], ~sourceGroup)
~effect = Synth(\stereoreverb,[\in, ~fxsendbus, \out, ~sinewavebus], ~fxGroup)
~mixer = Synth(\mixer, target: ~mixerGroup)

// The interresting thing is that one can apply simultaneous changes in a group

~sourceGroup.set(\ffreq,500) //here applies only to noisemachines
~sourceGroup.set(\pulse,8) // here applies only to pulsewaves
~sourceGroup.set(\amp,0) //here applies to ALL in source group

s.freeAll

//We can use audio busses, but we can also use control busses, let's see the following example with the previously defined Noise Machine Synth

~rq_bus = Bus.control(s,1)
~amp_bus = Bus.control(s,1)

// let's generate 4 objects from Noise_Machine

~noise1 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*80.91,\rq,0.1,\out,0])
~noise2 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*101.94,\rq,0.1,\out,0])
~noise3 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*121.23,\rq,0.1,\out,0])
~noise4 = Synth(\Noise_Machine,[\amp,0.1,\ffreq,2*152.74,\rq,0.1,\out,0])

// We map the control busses to the parameters of each object

~noise1.map(\amp, ~amp_bus, \rq, ~rq_bus)
~noise2.map(\amp, ~amp_bus, \rq, ~rq_bus)
~noise3.map(\amp, ~amp_bus, \rq, ~rq_bus)
~noise4.map(\amp, ~amp_bus, \rq, ~rq_bus)

// Then we can write in the control bus directly

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
).add
)

~param = Synth(\param_sender)
~param.free
s.freeAll

// Let's record the output, press recorder on, play the sound, press stop
//numChannels is optionnal, default is 2, but sky is the limit.
// Type standadizePath in MacOSX for finding your home directory
"~/".standardizePath

s.record(path: "~/Desktop/test_recording.wav".standardizePath, numChannels: 2)
// Stop Recording (don't forget it....)
s.stopRecording

///////////////////////////////////////////////////////////
//// PART V : Enveloppes and simple patterns
///////////////////////////////////////////////////////////

// Let's use an Enveloppe like in any good analogue Synth
(
a={
	var sig, env, amp;
	amp = 0.1;
	env = Line.kr(start: 0.1, end: 0, dur: 1, doneAction: 0);
	sig = Pulse.ar(ExpRand(30,500)).dup*env*amp
}.play
)

(
a={
	var sig, env, amp;
	amp = 0.1;
	env = Line.kr(start: -20, end: -100, dur: 1, doneAction: 0);
	sig = Pulse.ar(ExpRand(30,500)).dup*env.dbamp*amp
}.play
)

// If we check s.plotTree, we still have all those Ghost synth in the server, taking useless CPU, and worst of it, making no sound at all. Let's see what doneAction=2 does

(
a={
	var sig, env, amp;
	amp = 0.1;
	env = Line.kr(start: 0, end: -100, dur: 1, doneAction: 2);
	sig = Pulse.ar(ExpRand(30,500)).dup*env.dbamp*amp
}.play
)

// Yes! we can run it ad infinium, the server will remain clear at all times

// Let's add some frequency movement
(
a={
	var sig, env, freq, amp;
	amp = 0.1;
	env = XLine.kr(start: 1, end: 0.0001, dur: 1, doneAction: 2);
	freq = XLine.kr(start: 400, end: 50, dur: 1, doneAction: 2);
	sig = Pulse.ar(freq*ExpRand(0.8,1.2)).dup*env*amp
}.play
)

// There is one fantastic UGen, called Env, that amazingly combine with EnvGen Let's see how it works
(
a={
	var env, freq, amp;
	amp = 0.1;
	env = EnvGen.kr(envelope: Env(
		levels: [0, 1, 0.2, 0],
		times: [0.2 , 0.2, 1],
		curve: [8,-8,-8]), doneAction: 2);
	freq = XLine.kr(start: 400, end: 50, dur: 1);
	Pulse.ar(ExpRand(30,500)).dup*env*amp
}.play
)
// Let's try and plot some Enveloppes, copy-paste it in the function
Env(levels: [0, 1, 0.2, 0], times: [0.2 , 0.2, 1], curve: [8,-8,-8]).plot

// Let's rewrite the function with paramatrable envelope and make it a Synthdefinition
(
SynthDef(
	\zarbisaw,{
		arg freq = 100, amp = 0.1, atk = 0.2,
		sust = 0.2, level = 0.2, dec = 1, width=0.05;
		var sig, env;
		env = EnvGen.kr(envelope: Env(
			levels: [0, 1, level, 0],
			times: [atk , sust, dec],
			curve: [8,-8,-8]), doneAction: 2);
		freq = freq*ExpRand(0.99,1.01);
		sig = VarSaw.ar(freq, 0, width)*env*amp;
		Out.ar(0, Pan2.ar(sig, pos: LFNoise0.kr(10)))}).add
)

Synth(\zarbisaw,[\atk,0.5])

//At this point we would like to introduce iterations briefly (check Routines, forks, and more in documentation)
10.do{Synth(\zarbisaw,[\atk,exprand(0.38,0.42)])}

// we would like to add the iteration in the Synth

(
SynthDef(
	\zarbisaw,{
		arg freq = 100, amp = 0.1, atk = 0.2,
		sust = 0.2, level = 0.2, dec = 1, width=0.05;
		var sig, env;
		sig = 0;
		env = EnvGen.kr(envelope: Env(
			levels: [0, 1, level, 0],
			times: [atk , sust, dec],
			curve: [8,-8,-8]), doneAction: 2);
		10.do{
			freq = freq*ExpRand(0.99,1.01);
			sig = sig + VarSaw.ar(freq, 0, width)
		};
		Out.ar(0, Pan2.ar(sig*env*amp, pos: LFNoise0.kr(10)))}).add
)
// Let's test it again
Synth(\zarbisaw,[\atk,0.5, \freq, exprand(80,120), \width, exprand(0.05,0.5)])

// It is finally time to briefly introduce Patterns !
(
p = Pbind(
	\instrument, \zarbisaw,
	\dur, Pseq([0.5, 1, 1, 0.25, 0.25],inf), // defined sequence
	\freq, Pexprand(100,1000,inf), // exponentially distributer randomness
	\width, Pwhite(0.05,0.5,inf) //random number generator
).play
)
p.stop
p.play

(
p = Pbind(
	\instrument, \zarbisaw,
	\dur, Pseq([0.5, 1, 1, 0.25, 0.25],inf), // defined sequence
	//\freq, Pexprand(100,1000,inf).trace, // exponentially distributer randomness
	\midinote, Pexprand(50,80,inf).round(1).trace, //use midinotes as well!, works only if frequency parameter from synth is "freq"
	\width, Pwhite(0.05,0.5,inf) //random number generator
).play
)
p.stop
p.play

// For a brillant demonstration illustrating the use of Patterns, and some a bit more evolved objects such as Ppar.. please download this wonderfull Kraftwerk song here: https://github.com/supercollider/supercollider/blob/master/examples/pieces/spacelab.scd

///////////////////////////////////////////////////////////
//// EPILOGUE : Find Examples and Understand the Code
///////////////////////////////////////////////////////////

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

