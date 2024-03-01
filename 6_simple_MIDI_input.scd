// Simple bass taken from Spacelab song
// https://github.com/supercollider/supercollider/blob/master/examples/pieces/spacelab.scd
// conect it to a MIDI keyboard

s.boot

// Bass Synth
(
SynthDef(\bass, { | out=0 gate=1 freq amp=0.1 |
		var aEnv, fEnv, osc, flt;
		aEnv = EnvGen.kr(Env.asr(0, 1, 1), gate, doneAction: 2);
		fEnv = EnvGen.kr(Env.perc(0, 3), levelScale: 6000);
		osc = Mix([Saw.ar(freq * [1, 1.005]), Pulse.ar(freq / 2, 0.5)]);
		flt = LPF.ar(osc, fEnv + 100, aEnv);
		Out.ar(out, flt*amp);
	}).add;
)

// test the Synth
p=Synth(\bass,[\freq, exprand(80,120)])
p.set(\gate,0)

// Connect MIDI keyboard
MIDIClient.init;
MIDIIn.connectAll;

// Create Aray of notes
~notes = Array.newClear(128);

// MIDI def for ON and OFF controls
(
MIDIdef.noteOn(\noteOn, {
	arg vel, nn, chan, src;
	[vel, nn].postln;
	~notes[nn] = Synth.new(
		\bass,
		[
			\freq, nn.midicps,
			\gate, 1,
			\out, 0
		]
	)
});
MIDIdef.noteOff(\noteOff, {
	arg vel, nn;
	~notes[nn].set(\gate,0)
});
)
