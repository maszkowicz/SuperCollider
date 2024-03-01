s.boot;
s.quit;

//OPTIONAL PART SEND OSC MESSAGES
//Open the sender node (local server, local port)
~sender = NetAddr.new("127.0.0.1", 9001);
//send simple messages
~sender.sendMsg("/message", 0);
//send a bundle, several message at the same time
~sender.sendBundle(0,["/message1", 0],["/message2", 0],["/message3", 0]);

//RECEIVE OSC MESSAGES
//Open the receiver port
thisProcess.openUDPPort(8888);
thisProcess.openUDPPort(8889);
thisProcess.openPorts; //check open ports
OSCFunc.trace(true)
OSCFunc.trace(false)

// TEST FROM PHONE - Sensor2OSC - https://sensors2.org/osc/
// sending OSC on port 8889 (set local Wi-FI network with fixed IP 192.168.43.54)

(
SynthDef(
	\bip_space,
	{
		arg out=0, freq=200, pan=0, pulse=4, depth=1;
		var bippulse=Clip.kr((pulse.abs),4,16);
		var input = SinOsc.ar(
			freq: freq,
			phase: 0,
			mul: 0.2*LFPulse.kr(
				freq: bippulse,
				iphase: 0.0,
				width: 0.5,
				mul: 1.0,
				add: 0.0).lag(0.1)).lag(0.01);
		Out.ar(out,PanAz.ar(6,input,pan,1,depth,0))
	}
).add;
)

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

~multichannel_output_bip = Synth(\bip_space,[\out,0,\freq,200,\depth,1,\pulse,4,\nbchannels,4]);//1/2 rate
~multichannel_output_bip.free;


~orientation = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		var pan = msg.at(1)/180-1;
		~multichannel_output_bip.set(\pan,pan);
		msg.postln
	},'/orientation',nil);
~orientation.free

~acceleration = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		var pulse = msg.at(1);
		~multichannel_output_bip.set(\pulse,pulse);
		msg.postln
	},'/accelerometer',nil);
~acceleration.free

// TEST FROM M5STICK-C with custom programme
// sending OSC on port 8889 (set local Wi-FI network with fixed IP 192.168.43.54)

(
SynthDef(
	\Noise_Machine,
	{
		arg whichNoise = 0, whichFilter = 0, amp = 0.06, ffreq = 1000, rq = 0.8, out=0, pan=0, depth=4;
		var snd;
		//var windfreq = 900+100*LFNoise1.ar(1,1).lag(0.01);
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
		Out.ar(out,PanAz.ar(6,snd,pan,1,depth,0))
	}
).add;
)

~multichannel_output_wind = Synth(\Noise_Machine,[\whichNoise,0,\whichFilter,0,\amp,0,\ffreq,763,\rq, 1/200,\out,0]);//1/2 rate
~multichannel_output_wind.free;

~m5xyz = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		var pan = msg.at(6)/180;
		var depth = 12-(11*(abs(abs((msg.at(5)/90))-1)));
		~multichannel_output_wind.set(\pan,pan);
		~multichannel_output_wind.set(\depth,depth);
		msg.postln
	},'/m5xyz',nil);
~m5xyz.free







