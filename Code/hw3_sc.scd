s.boot


(
 SynthDef.new(\vocarmonizer, { arg effectBus, darkness=0, gain1=0.5, gain2=0.5, gain3=0.5;
  var second, third, fourth, output;
  var input = SoundIn.ar(0);

  var interval_struct=[[0, 4, 7, 12],[0, 4, 7, 11],[0, 4, 7, 10],[0, 3, 7, 12],[0, 3, 7, 10],[0, 3, 6, 10]];

  var chord = Select.kr(darkness, interval_struct);

  /* qui faccio il pitch shift e genero le voci */
  second = PitchShift.ar(in:input, pitchRatio:2**(chord[1]/12), mul:gain1);
  third = PitchShift.ar(in:input, pitchRatio:2**(chord[2]/12), mul:gain2);
  fourth = PitchShift.ar(in:input, pitchRatio:2**(chord[3]/12), mul:gain3);
  output = Mix.ar([input, second, third, fourth]);
  Out.ar(effectBus, output);
}).add;
)


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



NetAddr.localAddr
NetAddr.useDoubles = true;



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


