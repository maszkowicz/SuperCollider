Server.default.options.numOutputBusChannels=8; //8 output channels
Server.default.options.numInputBusChannels=2; //2 is default, depends on your sound interface

s.boot;

(
SynthDef(
	\Octospatialisation,
	{
		arg out=0;
		var snd, space;
		snd = SoundIn.ar(0); //get channel one sound
		space = LFNoise1.kr(5,1); //radom signal generator, first argument is frequency, second is amplitude
		Out.ar(out,PanAz.ar(
			numChans:8,
			in:snd,
			pos:space, //defined before
			level:1, //amplitude
			width:2, //Values greater than 2 will spread the pan over greater numbers of speakers. Values less than 1 will leave silent gaps between speakers.
			orientation: 0 //Should be 0 if the front is a vertex of the spanning polygon.
		));
	}
).add;
)

~octosound = Synth(\Octospatialisation,[\out,0]); //here assigns to output channel 0
s.scope; //look at the channels
~octosound.free;

// Let's record the 8 channels separately!

//MAC STYLE filepath
s.record(path: "~/Desktop/SonificationTalk2020/Workshop/test_recording2.wav".standardizePath, numChannels: 8);
//PC STYLE filepath
s.record(path: "c:\\SuperCollider\Workshop\test_recording.wav".standardizePath, numChannels: 8);
// Stop Recording (don't forget it....)
s.stopRecording;

// Three different way of spatialisation, that one can change live

(
SynthDef(
	\Octospatialisation_2,
	{
		arg out=0, switch_space=0;
		var snd, space;
		snd = SoundIn.ar(0); //get channel one sound
		space = Select.kr(
			which: switch_space,
			array: [
				LFNoise1.kr(5,1), //radom signal generator, first argument is frequency, second is amplitude
				MouseX.kr(-1,1,'linear'), //control it with mouse X position
				SinOsc.kr(1) //sine wave, the sound wil turn around
		]);
		Out.ar(out,PanAz.ar(
			numChans:8,
			in:snd,
			pos:space, //defined before
			level:1, //amplitude
			width:2, //Values greater than 2 will spread the pan over greater numbers of speakers. Values less than 1 will leave silent gaps between speakers.
			orientation: 0 //Should be 0 if the front is a vertex of the spanning polygon.
		));
	}
).add;
)

~octosound = Synth(\Octospatialisation_2,[\switch_space,0]);
s.scope
~octosound.set(\switch_space,1);
~octosound.set(\switch_space,2);
~octosound.set(\switch_space,0);
~octosound.free;

// Try your own functions!

