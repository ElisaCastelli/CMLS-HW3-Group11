// oscP5 is an OSC implementation for the programming environment processing.
import oscP5.*;
//A network library for processing which supports UDP, TCP and Multicast.
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

PFont fontTitle, fontScritte;

// Buttons and labels
Button buttonScale, buttonDarkness;
String[] strScales   = new String[] {"Major", "Minor", "Delta", "Minor7", "Dominant", "Half-Diminished"};
String[] strDarkness   = new String[] {"1", "2", "3", "4", "5", "6"};

// Scrollbars
HScrollbar gain1, gain2, gain3, delayTime, revSize, revAmount;

// Color Palette
color darkgrey = #4D4D3D;
color greyA = #8B9386;
color greyB = #A9B1A1;
color yellow = #FFE849;
color dirtyWhite = #F0F0EB;

void settings() {
  float zoom = 1.2;
  size(round(1000*zoom), round(700*zoom));
  //fullScreen();
}


void setup() {
  noStroke();
  fontTitle = createFont("Dream MMA.ttf", 100);
  fontScritte = createFont("Calibri", 32);

  setupBG();

  // Sliders
  float shiftVer = height/10;
  int loosness = 5;
  float www = 7;
  float hhh = 2.3;
  gain1 = new HScrollbar(width/www, height/hhh-8, round(width/3.5), 16, loosness, "Gain Voice 1", "/gain1");
  gain2 = new HScrollbar(width/www, height/hhh-8+shiftVer, round(width/3.5), 16, loosness, "Gain Voice 2", "/gain2");
  gain3 = new HScrollbar(width/www, height/hhh-8+2*shiftVer, round(width/3.5), 16, loosness, "Gain Voice 3", "/gain3");

  delayTime = new HScrollbar(4*width/www, height/hhh-8, round(width/3.5), 16, loosness, "Delay Time", "/dlytime");
  revSize =   new HScrollbar(4*width/www, height/hhh-8+shiftVer, round(width/3.5), 16, loosness, "Room Size", "/roomsize");
  revAmount = new HScrollbar(4*width/www, height/hhh-8+2*shiftVer, round(width/3.5), 16, loosness, "Reverb Amount", "/revamt");

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 12000);
  /* myRemoteLocation is a NetAddress. a NetAddress takes 2 parameters,
   * an ip address and a port number. myRemoteLocation is used as parameter in
   * oscP5.send() when sending osc packets to another computer, device, 
   * application. 
   */
  myRemoteLocation = new NetAddress("127.0.0.1", 57120);
}

void draw() {
  // Display buttons
  buttonScale.display();
  buttonDarkness.display();

  // Diplay & update sliders
  gain1.update();
  gain1.display();

  gain2.update();
  gain2.display();

  gain3.update();
  gain3.display();

  delayTime.update();
  delayTime.display();

  revSize.update();
  revSize.display();

  revAmount.update();
  revAmount.display();
}

void setupBG() {
  // Setup of the background
  background(10);
  textAlign(CENTER);

  buttonScale = new Button(width/2, height/4.5, 6, strScales, "/chord");
  buttonDarkness = new Button(width/2, height/1.2, 6, strDarkness, "/darkness");
  
  buttonScale.isON[0] = true;

  fill(dirtyWhite);
  textFont(fontScritte);
  textSize(height/25);
  text("Darkness", width/2, height/1.3-height/25);

  textFont(fontTitle);
  textSize(height/10);
  text("vocarmonizer", width/2, height/9);
}

void mousePressed() {
  // Mutual exclusive buttons
  buttonScale.clicked(mouseX, mouseY);
  buttonDarkness.clicked(mouseX, mouseY);

  if (buttonScale.isClicked) {
    buttonDarkness.reset();
    buttonScale.isClicked = false;
  } else if (buttonDarkness.isClicked) {
    buttonScale.reset();
  }
}
