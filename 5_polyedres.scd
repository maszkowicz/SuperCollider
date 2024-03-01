Server.default.options.numOutputBusChannels=4; //4 output channels
s.boot;
s.quit;

//ouvrir le noeud émetteur (Blender reçoit)
//~sender = NetAddr.new("127.0.0.1", 9001);
//envoyer un bundle (set de plusieurs messages) avec positions x,y alléatoires du listener
//~sender.sendBundle(0,["/blender/listenerx", 100.rand/100],["/blender/listenery", 100.rand/100]);
// remettre l'observateurau centre
//~sender.sendBundle(0,["/blender/listenerx", 0],["/blender/listenery", 0]);

//ouvrir le port définit par l'émetteur
thisProcess.openUDPPort(9009);
thisProcess.openPorts; //vérification des ports ouverts

// Voir ce qu'on reçoit
OSCFunc.trace(true)
OSCFunc.trace(false)

(
SynthDef(\tetra_moving_point,{
	arg origine_x=0, origine_y=0, origine_z=0, point_x=0, point_y=0, point_z=0, level=0.1,
	freqbase=432, dirac=0.1, dist_noise = 1.6;
	var dist_x, dist_y, dist_z, signal, azimuth, elevation, distance, freq, amplitude, rq, noise,
	noiselevel, encoder, decoder, w1, x1, y1, z1, w2, x2, y2, z2;
	//Déterminer la distance de la sphère par rapport à l'observateur
	dist_x = point_x-origine_x;
	dist_y = point_y-origine_y;
	dist_z = point_z-origine_z;
	//distance = ((dist_x.squared)+(dist_y.squared)+(dist_z.squared)).sqrt;
	distance = ((dist_x.squared)+(dist_y.squared)).sqrt;
    //déterminer la fréquence par rapport à la distance, avec un mini filtre passe-bas
	//freq = { |x| 3*1000/x }.value(distance).lag(0.01);
	freq = freqbase+Select.kr(distance > 5, [ 5-distance, 0]);
	//amplitude = 1/distance; if distance < 1, then answer is 1
	//amplitude = Select.kr(distance < 1, [1, 1/distance ** 0.2 ]);
	amplitude = Select.kr((distance>dirac),[(distance/dirac),Select.kr(distance > 1, [1, (1/distance) ])]);
	rq = Select.kr((distance>dist_noise),[(dist_noise-distance)*0.2+0.02,0.02]);
	noiselevel = Select.kr((distance>dist_noise),[(dist_noise-distance)*10+1,1]);

	//amplitude = Select.kr(distance > 1, [1, (100000**(1/distance.squared)/100000) ]);
	//amplitude = 1;
	//génération du son du point en mouvement
	signal = SinOsc.ar(freq:freq, mul:level*amplitude);
	noise = BPF.ar(BrownNoise.ar(level*noiselevel), freqbase, rq);
	// déterminer l'élévation du point sonore en mouvement
	elevation = 0;
	// déterminer la position angulaire de la source en mouvement par rapport à l'observateur
	//azimuth = Select.kr((dist_x <= 0), [(dist_y/dist_x).atan,
	//	Select.kr(dist_x < 0,[
	//		dist_y.sign*pi/2, Select.kr(dist_y < 0,[(dist_y/dist_x).atan+pi,(dist_y/dist_x).atan-pi])
	//		])])/pi;
	azimuth = Select.kr((dist_y <= 0), [(dist_x/dist_y).atan,
		Select.kr(dist_y < 0,[
			dist_x.sign*pi/2, Select.kr(dist_x < 0,[(dist_x/dist_y).atan+pi,(dist_x/dist_y).atan-pi])
			])])/pi;
	//Placer l'objet sonore dans l'espace
	#w1, x1, y1, z1 = PanB.ar(signal,azimuth, elevation, 1);
	#w2, x2, y2, z2 = PanB.ar(noise,azimuth, elevation, 1);
	//decoder la position de l'objet sonor sur deux canaux
	Out.ar(0,DecodeB2.ar(2, w1, x1, y1));
	Out.ar(0,DecodeB2.ar(2, w2, x2, y2))
}).add;
)

// visualiser les canaux
s.scope

(
// donner les frequences
~freq_tetra = 261.63;
~freq_octa = 310.07;
~freq_cube = 348.83;
~freq_icosa = 413.43;
~freq_dodeca = 413.43/2;
~level_tetra = 0.7;
~level_octa = 0.7;
~level_cube = 0.7;
~level_icosa = 0.7;
~level_dodeca = 0.7;
// créer les points sonores
~tetra1=Synth(\tetra_moving_point,[\level,~level_tetra,\freqbase,~freq_tetra]);
~tetra2=Synth(\tetra_moving_point,[\level,~level_tetra,\freqbase,~freq_tetra]);
~tetra3=Synth(\tetra_moving_point,[\level,~level_tetra,\freqbase,~freq_tetra]);
~tetra4=Synth(\tetra_moving_point,[\level,~level_tetra,\freqbase,~freq_tetra]);
~octa1=Synth(\tetra_moving_point,[\level,~level_octa,\freqbase,~freq_octa]);
~octa2=Synth(\tetra_moving_point,[\level,~level_octa,\freqbase,~freq_octa]);
~octa3=Synth(\tetra_moving_point,[\level,~level_octa,\freqbase,~freq_octa]);
~octa4=Synth(\tetra_moving_point,[\level,~level_octa,\freqbase,~freq_octa]);
~octa5=Synth(\tetra_moving_point,[\level,~level_octa,\freqbase,~freq_octa]);
~octa6=Synth(\tetra_moving_point,[\level,~level_octa,\freqbase,~freq_octa]);
~cube1=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~cube2=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~cube3=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~cube4=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~cube5=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~cube6=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~cube7=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~cube8=Synth(\tetra_moving_point,[\level,~level_cube,\freqbase,~freq_cube]);
~icosa1=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa2=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa3=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa4=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa5=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa6=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa7=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa8=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa9=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa10=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa11=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~icosa12=Synth(\tetra_moving_point,[\level,~level_icosa,\freqbase,~freq_icosa]);
~dodeca1=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca2=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca3=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca4=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca5=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca6=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca7=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca8=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca9=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca10=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca11=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca12=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca13=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca14=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca15=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca16=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca17=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca18=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca19=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
~dodeca20=Synth(\tetra_moving_point,[\level,~level_dodeca,\freqbase,~freq_dodeca]);
)

// changer la fréquence de base des points
~tetra1.set(\freqbase,432);
~tetra2.set(\freqbase,432);
~tetra3.set(\freqbase,432);
~tetra4.set(\freqbase,432);

// supprimer les points sonores
(
~tetra1.free;
~tetra2.free;
~tetra3.free;
~tetra4.free;
~octa1.free;
~octa2.free;
~octa3.free;
~octa4.free;
~octa5.free;
~octa6.free;
~cube1.free;
~cube2.free;
~cube3.free;
~cube4.free;
~cube5.free;
~cube6.free;
~cube7.free;
~cube8.free;
~icosa1.free;
~icosa2.free;
~icosa3.free;
~icosa4.free;
~icosa5.free;
~icosa6.free;
~icosa7.free;
~icosa8.free;
~icosa9.free;
~icosa10.free;
~icosa11.free;
~icosa12.free;
~dodeca1.free;
~dodeca2.free;
~dodeca3.free;
~dodeca4.free;
~dodeca5.free;
~dodeca6.free;
~dodeca7.free;
~dodeca8.free;
~dodeca9.free;
~dodeca10.free;
~dodeca11.free;
~dodeca12.free;
~dodeca13.free;
~dodeca14.free;
~dodeca15.free;
~dodeca16.free;
~dodeca17.free;
~dodeca18.free;
~dodeca19.free;
~dodeca20.free;
)


// Récepteurs OSC
(
~blender_tetra_point1 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~tetra1.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/tetra1',nil);
~blender_tetra_point2 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~tetra2.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/tetra2',nil);
~blender_tetra_point3 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~tetra3.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/tetra3',nil);
~blender_tetra_point4 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~tetra4.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/tetra4',nil);
~blender_octa_point1 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~octa1.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/octa1',nil);
~blender_octa_point2 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~octa2.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/octa2',nil);
~blender_octa_point3 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~octa3.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/octa3',nil);
~blender_octa_point4 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~octa4.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/octa4',nil);
~blender_octa_point5 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~octa5.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/octa5',nil);
~blender_octa_point6 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~octa6.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/octa6',nil);
~blender_cube_point1 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube1.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube1',nil);
~blender_cube_point2 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube2.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube2',nil);
~blender_cube_point3 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube3.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube3',nil);
~blender_cube_point4 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube4.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube4',nil);
~blender_cube_point5 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube5.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube5',nil);
~blender_cube_point6 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube6.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube6',nil);
~blender_cube_point7 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube7.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube7',nil);
~blender_cube_point8 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~cube8.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/cube8',nil);
~blender_icosa_point1 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa1.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa1',nil);
~blender_icosa_point2 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa2.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa2',nil);
~blender_icosa_point3 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa3.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa3',nil);
~blender_icosa_point4 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa4.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa4',nil);
~blender_icosa_point5 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa5.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa5',nil);
~blender_icosa_point6 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa6.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa6',nil);
~blender_icosa_point7 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa7.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa7',nil);
~blender_icosa_point8 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa8.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa8',nil);
~blender_icosa_point9 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa9.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa9',nil);
~blender_icosa_point10 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa10.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa10',nil);
~blender_icosa_point11 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa11.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa11',nil);
~blender_icosa_point12 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~icosa12.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/icosa12',nil);
~blender_dodeca_point1 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca1.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca1',nil);
~blender_dodeca_point2 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca2.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca2',nil);
~blender_dodeca_point3 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca3.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca3',nil);
~blender_dodeca_point4 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca4.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca4',nil);
~blender_dodeca_point5 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca5.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca5',nil);
~blender_dodeca_point6 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca6.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca6',nil);
~blender_dodeca_point7 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca7.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca7',nil);
~blender_dodeca_point8 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca8.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca8',nil);
~blender_dodeca_point9 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca9.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca9',nil);
~blender_dodeca_point10 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca10.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca10',nil);
~blender_dodeca_point19 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca19.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca19',nil);
~blender_dodeca_point18 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca18.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca18',nil);
~blender_dodeca_point17 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca17.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca17',nil);
~blender_dodeca_point16 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca16.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca16',nil);
~blender_dodeca_point15 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca15.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca15',nil);
~blender_dodeca_point14 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca14.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca14',nil);
~blender_dodeca_point13 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca13.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca13',nil);
~blender_dodeca_point12 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca12.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca12',nil);
~blender_dodeca_point11 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca11.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca11',nil);
~blender_dodeca_point20 = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~dodeca20.set(\point_x,msg[1],\point_y,msg[2],\point_z,msg[3]);
		//msg.postln
	},'/blender/dodeca20',nil);



~blender_observer = OSCFunc(
	{
		arg msg,time,address,receivedPort;
		~tetra1.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~tetra2.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~tetra3.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~tetra4.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~octa1.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~octa2.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~octa3.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~octa4.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~octa5.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~octa6.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube1.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube2.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube3.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube4.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube5.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube6.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube7.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~cube8.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa1.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa2.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa3.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa4.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa5.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa6.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa7.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa8.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa9.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa10.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa11.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~icosa12.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca1.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca2.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca3.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca4.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca5.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca6.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca7.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca8.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca9.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca10.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca11.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca12.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca13.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca14.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca15.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca16.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca17.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca18.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca19.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		~dodeca20.set(\origine_x,msg[1],\origine_y,msg[2],\origine_z,msg[3]);
		//msg.postln
	},'/blender/observer',nil);

)

(
~blender_tetra_point1.free;
~blender_tetra_point2.free;
~blender_tetra_point3.free;
~blender_tetra_point4.free;
~blender_octa_point1.free;
~blender_octa_point2.free;
~blender_octa_point3.free;
~blender_octa_point4.free;
~blender_octa_point5.free;
~blender_octa_point6.free;
~blender_cube_point1.free;
~blender_cube_point2.free;
~blender_cube_point3.free;
~blender_cube_point4.free;
~blender_cube_point5.free;
~blender_cube_point6.free;
~blender_cube_point7.free;
~blender_cube_point8.free;
~blender_icosa_point1.free;
~blender_icosa_point2.free;
~blender_icosa_point3.free;
~blender_icosa_point4.free;
~blender_icosa_point5.free;
~blender_icosa_point6.free;
~blender_icosa_point7.free;
~blender_icosa_point8.free;
~blender_icosa_point9.free;
~blender_icosa_point10.free;
~blender_icosa_point11.free;
~blender_icosa_point12.free;
~blender_dodeca_point1.free;
~blender_dodeca_point2.free;
~blender_dodeca_point3.free;
~blender_dodeca_point4.free;
~blender_dodeca_point5.free;
~blender_dodeca_point6.free;
~blender_dodeca_point7.free;
~blender_dodeca_point8.free;
~blender_dodeca_point9.free;
~blender_dodeca_point10.free;
~blender_dodeca_point11.free;
~blender_dodeca_point12.free;
~blender_dodeca_point13.free;
~blender_dodeca_point14.free;
~blender_dodeca_point15.free;
~blender_dodeca_point16.free;
~blender_dodeca_point17.free;
~blender_dodeca_point18.free;
~blender_dodeca_point19.free;
~blender_dodeca_point20.free;

~blender_observer.free;
)

