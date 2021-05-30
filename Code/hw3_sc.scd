s.boot


(
 SynthDef.new(\vocarmonizer, { arg effectBus, darkness=0, gain1=0.5, gain2=0.5, gain3=0.5;
  var second, third, fourth, output;
  var input = SoundIn.ar(0);
  /* definisco la struttura intervallare degli accordi. Nell'ordine ho accordo maggiore, maggiore7 (delta), dominante (7), minore, minore7, semi-diminuito. Questo ordine rispecchia proprio la scala darkness. Quindi l'utente può selezionare un accordo o cliccando singolarmente sul suo bottone oppure variando la scala darkness (se i due non sono "allineati" sullo stesso accordo non importa). Nella scala darkness naturalmente sulla prima tacca c'è l'accordo maggiore (darkness=0), poi maggiore7 (darkness=1) etc.; spero di essere stato chiaro lul
  */
  var interval_struct=[[0, 4, 7, 12],[0, 4, 7, 11],[0, 4, 7, 10],[0, 3, 7, 12],[0, 3, 7, 10],[0, 3, 6, 10]];


  /* qui devo utilizzare questa UGen Select semplicemente per usare la darkness come indice e mettere nella variabile chord la struttura intervallare che l'utente vuole. Questo perchè se non erro l'arg è passato a tasso di controllo, e scrivendo chord=interval_struct[darkness] non funzionerebbe.
  Bada: il parametro darkness serve a selezionare l'accordo sia che l'utente utilizzi lo slider discreto darkness, sia che utilizzi i bottoni singoli! Usiamo quello come arg per selezionare l'accordo. I numeri che arrivano come arg sono infatti gli stessi in entrambi i casi*/
  var chord = Select.kr(darkness, interval_struct);

  /* qui faccio il pitch shift e genero le voci */
  second = PitchShift.ar(in:input, pitchRatio:2**(chord[1]/12), mul:gain1);
  third = PitchShift.ar(in:input, pitchRatio:2**(chord[2]/12), mul:gain2);
  fourth = PitchShift.ar(in:input, pitchRatio:2**(chord[3]/12), mul:gain3);
  output = Mix.ar([input, second, third, fourth]);
  Out.ar(effectBus, output);
}).add;
)


/* da qui in poi è abbastanza self explanatory xd. Nota che il bus interno che entra ed esce da ciascun synth è sempre lo stesso. Poi tutto va a finire sui due canali pubblici*/
(
SynthDef(\delay, { arg inBus, outBus=0, delaytime=0.5;
  var input, effect;
  input = In.ar(inBus, 1);
  effect= DelayN.ar(input, 1, delaytime).dup; //delaytime in seconds
  Out.ar(outBus,effect);
}).add;
)


(
SynthDef(\reverb,{ arg inBus, roomSize=0.5, roomWetDry=0.5;
  var input, effect;
  input = In.ar(inBus);
  effect = FreeVerb.ar(input, roomSize, roomWetDry, 0.5);
  Out.ar([0, 1], effect);
}).add;
)


b = Bus.audio(s);

(
z = Synth.new("delay", [\inBus, b]);
y = Synth.before(z, "vocarmonizer", [\effectBus, b]);
x = Synth.after(z,"reverb", [\inBus, b]);
)


//x.free;
//y.free;
//z.free;


NetAddr.localAddr
NetAddr.useDoubles = true;

//OSCdef('test', {arg msg; y.set("gain3", msg[1]);}, "/newgain");


(
f = {
	arg msg;

	var oscMsg = msg[0];
	var chordToDarkness = [0, 3, 1, 4, 2, 5];

	if(msg[0] == '/chord' ,{
		var ch,drk;
		ch=msg[1];
		drk = chordToDarkness[ch];
        postln(oscMsg);
		postln("darkness:" +drk);
		y.set("darkness", drk);
	} );
	if(msg[0] == '/darkness', {
		var drk;
		drk=msg[1];
        postln(oscMsg);
		postln("darkness:" +drk);
		y.set("darkness", drk);
	} );
	if(msg[0] == '/gain1', {
		var gain;
		gain=msg[1];
        postln(oscMsg);
		postln("gain1 :" +gain);
		y.set("gain1", gain);
	} );
	if(msg[0] == '/gain2', {
		var gain;
		gain = msg[1];
        postln(oscMsg);
		postln("gain2 :" +gain);
		y.set("gain2", gain);
	} );
	if(msg[0] == '/gain3', {
		var gain;
		gain=msg[1];
        postln(oscMsg);
		postln("gain3 :" +gain);
		y.set("gain3", gain);
	} );
	if(msg[0] == '/dlytime', { //delaytime in seconds
		var dly;
		dly = 0.05+ 5*msg[1];
        postln(oscMsg);
		postln("delay time :" + dly);
		z.set("delaytime", dly);
	} );
	if(msg[0] == '/roomsize', {
		var room;
		room = msg[1];
		room = 0.19624628126621;
        postln(oscMsg);
		postln("room size :" + room);
		x.set(\roomSize, room);
	} );
	if(msg[0] == '/revamt', {
		var wet;
		wet=msg[1];
        postln(oscMsg);
		postln("rev amt :" + wet);
		x.set("roomWetDry", wet);
	} ) ;
};

thisProcess.addOSCRecvFunc(f);
)


thisProcess.removeOSCRecvFunc(f);



//y.set("darkness",0);