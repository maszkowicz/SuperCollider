// Sonification Test writen by Daniel Maszkowicz
// Part of Beginner SuperCollider Workshop
// SZKMD production - ooo.szkmd.ooo
//
// Synth Sinegrane found in The Sonification Handbook - Chapter 10 - Laboratory Methods for Experimental Sonification, chapter by Till Bovermann, Julian Rohrhuber and Alberto de Campo

// Full book in open access
// https://sonification.de/handbook/

s.quit
s.boot;

(
SynthDef(\sinegrain, {
	|out = 0, attack = 0.01, decay = 0.01, freq=300, pan = 0, amp = 0.5|
	var sound, env;
	// an amplitude envelope with fixed duration
	env = EnvGen.ar(Env.perc(attack, decay), doneAction: 2);
	// the underlying sound
	sound = FSinOsc.ar(freq);
	// use the envelope to control sound amplitude:.
	sound = sound*(env*amp);
	// add stereo panning
	sound = Pan2.ar(sound, pan);
	// write to output bus
	Out.ar(out, sound)
}).add;
)

//test the synth!

p=Synth(\sinegrain,[\out,0,\freq,500,\attack,0.01,\decay,3,\amp,0.5,\dur,0.2]);

// Run a pattern (\dur is a variable used in Pbind)
(
p=Pbind(\instrument, \sinegrain,
	\freq, Pseq([300,400, 370, 330, 350],2),
	\attack, 0.1,
	\decay, 2,
	\pan, Pseq([-1,1],inf),
	\dur, 0.5,
	\amp, 0.1
).play;
)
p.stop;

//Let's grab the Data

//MAC STYLE filepath
~mycsv=CSVFileReader.readInterpret(".../1_CSV_data.csv",true,true);

//Check the file
~mycsv.size
~mycsv.at(0)
~mycsv.at(0).asArray.at(0)
~mycsv.at(0).asArray.at(1)
~mycsv.at(0).asArray.at(2)
~mycsv.at(0).asArray.at(3)
~mycsv.at(0).asArray.at(4)
~mycsv.at(1)
// etc....

//~mycsv is an array of arrays, we need to seperates each "columns" into seperate arrays by extracting it at each line....
~mycsv_0=Array.fill(~mycsv.size,{arg i;~mycsv.at(i).asArray.at(0)});
~mycsv_1=Array.fill(~mycsv.size,{arg i;~mycsv.at(i).asArray.at(1)});
~mycsv_2=Array.fill(~mycsv.size,{arg i;~mycsv.at(i).asArray.at(2)});
~mycsv_3=Array.fill(~mycsv.size,{arg i;~mycsv.at(i).asArray.at(3)});
~mycsv_4=Array.fill(~mycsv.size,{arg i;~mycsv.at(i).asArray.at(4)});

// Normalize the data between a max val and min val and match them to sound parameters
~freq1=~mycsv_0.normalize(100,1000);
~levels1=~mycsv_1.normalize(0.1,1);
~attack1=~mycsv_2.normalize(0.01,0.1);
~decay1=~mycsv_3.normalize(0.1,0.2);
~dur1=~mycsv_4.normalize(0.02,0.1);

//test it in the Synth
(
p=Pbind(\instrument, \sinegrain,
	\freq, Pseq(~freq1,1),
	\attack, Pseq(~attack1,),
	\decay, Pseq(~decay1,1),
	\pan, 0,
	\dur, Pseq(~dur1,1),
	\amp, Pseq(~levels1,1)
).play;
)
p.stop;

//Let's switch collumns and play two data sets at a time!

~freq1=~mycsv_0.normalize(100,1000);
~levels1=~mycsv_1.normalize(0.1,1);
~attack1=~mycsv_2.normalize(0.01,0.1);
~decay1=~mycsv_3.normalize(0.1,0.2);
~dur1=~mycsv_4.normalize(1,2);

~freq2=~mycsv_4.normalize(200,5000);
~levels2=~mycsv_3.normalize(0.01,0.1);
~attack2=~mycsv_0.normalize(0.01,0.1);
~decay2=~mycsv_2.normalize(0.1,0.2);
~dur2=~mycsv_1.normalize(1,2);

(
p=Ppar([
	Pbind(\instrument, \sinegrain,
	\freq, Pseq(~freq1,inf),
	\attack, Pseq(~attack1,inf),
	\decay, Pseq(~decay1,inf),
	\pan, 0,
	\dur, Pseq(~dur1,inf),
	\amp, Pseq(~levels1,inf)
	),
	Pbind(\instrument, \sinegrain,
	\freq, Pseq(~freq2,inf),
	\attack, Pseq(~attack2,inf),
	\decay, Pseq(~decay2,inf),
	\pan, 0,
	\dur, Pseq(~dur2,inf),
	\amp, Pseq(~levels2,inf)
	)
]).play;
)
p.stop;

// Let's add another Synth with a Slew rate.
// Warning, Pbind is creating another Synth at each time it is called,
// that's why we use Synths with enveloppes so they "disapear" after their short sound so another sound
// can be called, that is also why Slew does not work when directly put into this kind of Synths..
// But, we can create another Synth that is running all the time that gets a frequency information from
// The Synth that is called by Pbind, through a control bus.

// Try the Sineslew Synth, see how it works, change frequencies and slewrates.

(
SynthDef(\sineslew, {
	|out = 0, freq=300, amp = 0.05, slewrate = 1|
	var sound, f;
	// add slew rate on frequency
	f=Slew.kr(freq,slewrate,slewrate);
	sound = Blip.ar(f,5,amp).dup;
	Out.ar(out, sound)
}).add;
)

~sineslewtest=Synth(\sineslew,[\out,0,\freq,400,\amp,0.05,\slewrate,500])
~sineslewtest.set(\freq,300)
~sineslewtest.set(\freq,400)
~sineslewtest.set(\slewrate,200)
~sineslewtest.free;

// The original Synth has been modified, one line has been added to output a control parameter,
//we need also to set a control bus, and map it to the Synth.

~ctrlbus = Bus.control(s,1);

(
SynthDef(\sinegrain, {
	|out = 0, attack = 0.01, decay = 0.01, freq=300, pan = 0, amp = 0.5|
	var sound, env;
	// an amplitude envelope with fixed duration
	env = EnvGen.ar(Env.perc(attack, decay), doneAction: 2);
	// the underlying sound
	sound = FSinOsc.ar(freq);
	// use the envelope to control sound amplitude:.
	sound = sound*(env*amp);
	// add stereo panning
	sound = Pan2.ar(sound, pan);
	// write to output bus
	Out.ar(out, sound); // Out.ar is an audio output
	Out.kr(~ctrlbus,freq/5) // Out.kr is a control output
}).add;
)

// Let's test it again and play with parameters, chang duration, slewrate,etc...

// Normalize the data between a max val and min val and match them to sound parameters
~freq=~mycsv_0.normalize(200,5000);
~levels=~mycsv_1.normalize(0.01,0.1);
~attack=~mycsv_2.normalize(0.2,0.5);
~decay=~mycsv_3.normalize(1,2);
~dur=~mycsv_4.normalize(0.3,0.5);

// let's run the Synth
~sineslewtest=Synth(\sineslew,[\out,0,\freq,400,\amp,0.01,\slewrate,200]);

// map the control bus to the frequency parameter
~sineslewtest.map(\freq, ~ctrlbus);

//Run the sonification
(
p=Pbind(\instrument, \sinegrain,
	\freq, Pseq(~freq,1),
	\attack, Pseq(~attack,1),
	\decay, Pseq(~decay,1),
	\pan, 0,
	\dur, Pseq(~dur,1),
	\amp, Pseq(~levels,1)
).play;
)
p.stop;
~sineslewtest.free;

// We could also output another parameter from \sinegrain and map it to another parameter in \sineslew
// such as \amp or \slewrate, through another control channel. Try it!
