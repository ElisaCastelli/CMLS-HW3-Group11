(
thisProcess.removeOSCRecvFunc(f);
s.killAll
)

s.boot

//harmonizer
(
 SynthDef.new(\vocarmonizer, { arg bus, darkness=0, gain1=0.5, gain2=0.5, gain3=0.5;
  //chord voices
  var second, third, fourth, output;

  //input signal from mic
  var input = SoundIn.ar(0);

  //this array contains the structure of each chord ordered by darkness (which is then used as index)
  var interval_struct=[[0, 4, 7, 12],[0, 4, 7, 11],[0, 4, 7, 10],[0, 3, 7, 12],[0, 3, 7, 10],[0, 3, 6, 10]];
  var chord = Select.kr(darkness, interval_struct);

  //computation of the pitchShift for each voice
  second = PitchShift.ar(in:input, pitchRatio:2**(chord[1]/12), mul:gain1);
  third = PitchShift.ar(in:input, pitchRatio:2**(chord[2]/12), mul:gain2);
  fourth = PitchShift.ar(in:input, pitchRatio:2**(chord[3]/12), mul:gain3);

  //mixing all the voices and writing to the private bus
  output = Mix.ar([input, second, third, fourth]);
  Out.ar(bus, output);
}).add;
)



//delay effect
(
SynthDef(\delay, { arg bus, delaytime=0.5;
  var input, effect;

  //input signal from private bus
  input = In.ar(bus);

  //delay effect and writing to the private bus
  effect= DelayN.ar(input, 1, delaytime).dup; //delaytime in seconds
  Out.ar(bus,effect);
}).add;
)



//reverb effect
(
SynthDef(\reverb,{ arg bus, roomSize=0.5, roomWetDry=0.5;
  var input, effect;

  //input signal from private bus
  input = In.ar(bus);

  //delay effect and writing to 0, 1 busses
  effect = FreeVerb.ar(input, roomSize, roomWetDry, 0.5);
  Out.ar([0, 1], effect);
}).add;
)


(
b = Bus.audio(s);

z = Synth.new("delay", [\bus, b]);
y = Synth.before(z, "vocarmonizer", [\bus, b]);
x = Synth.after(z,"reverb", [\bus, b]);
)



NetAddr.localAddr
// NetAddr.useDoubles = true;

(
f = {
	arg msg;

	var oscMsg = msg[0];
	var param = msg[1];
	var drk, dly;

	/* chords are mapped to their respective darkness. As specified before, darkness is then used as index to select the
	respective chord interval structure and generate the voices. */
	var chordToDarkness = [0, 3, 1, 4, 2, 5];

	if(msg[0] == '/chord' ,{
		drk = chordToDarkness[param];
        postln(oscMsg);
		postln("darkness:" +drk);
		y.set("darkness", drk);
	} );
	if(msg[0] == '/darkness', {
		postln(oscMsg);
		postln("darkness:" +param);
		y.set("darkness", param);
	} );
	if(msg[0] == '/gain1', {
		postln("gain1 :" +param);
		y.set("gain1", param);
	} );
	if(msg[0] == '/gain2', {
         postln(oscMsg);
		postln("gain2 :" +param);
		y.set("gain2", param);
	} );
	if(msg[0] == '/gain3', {
         postln(oscMsg);
		postln("gain3 :" +param);
		y.set("gain3", param);
	} );
	if(msg[0] == '/dlytime', { //delaytime in seconds
		dly = 0.05+ 5*msg[1];
		postln(oscMsg);
		postln("delay time :" + dly);
		z.set("delaytime", dly);
	} );
	if(msg[0] == '/roomsize', {
         postln(oscMsg);
		postln("room size :" + param);
		x.set("roomSize", param);
	} );
	if(msg[0] == '/revamt', {
         postln(oscMsg);
		postln("rev amt :" + param);
		x.set("roomWetDry", param);
	} ) ;
};

thisProcess.addOSCRecvFunc(f);
)


thisProcess.removeOSCRecvFunc(f);
