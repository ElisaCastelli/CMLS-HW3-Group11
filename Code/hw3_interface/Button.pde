import java.util.Arrays;

class Button {
  float xpos;
  float ypos;
  int nButtons;
  float heightRect;
  float widthRect;
  PFont buttonFont;
  int fontSizeButton;
  String[] labels;
  String oscID;
  boolean[] isON = new boolean[6]; // default is false
  boolean isClicked;

  Button(float xpos, float ypos, int nButtons, String[] l, String id) {
    this.xpos = xpos;
    this.ypos = ypos;
    this.nButtons = nButtons;
    heightRect = height/7.8;
    widthRect = width/(nButtons+2);
    fontSizeButton = height/45;
    buttonFont = createFont("Helvetica", fontSizeButton);
    this.labels = l;
    this.oscID = id;
    isClicked = false;
  }

  void display() {
    stroke(dirtyWhite);

    rectMode(CENTER);
    textFont(buttonFont);
    float x;
    color cBG, cLabel;
    
  // N buttons in a row
    for (int i = 0; i < nButtons; i = i+1) {
      x = (3+2*i)*(width/((nButtons+2)*2));

      if (isON[i]) {
        cBG = yellow;
        cLabel = darkgrey;
      } else {
        cBG = darkgrey;
        cLabel = dirtyWhite;
      }
      fill(cBG);
      rect(x, ypos, widthRect, heightRect);

      fill(cLabel);
      textAlign(CENTER, CENTER);
      text(labels[i], x, ypos-(fontSizeButton/3));
    }
  }

  void clicked(float x, float y) {
    if (isInBtn(x, y)) {
      int clickedButton = floor(x/widthRect);
      //print("Clicked Button is " + str(clickedButton));
      reset();
      isClicked = true;
      isON[clickedButton-1] = true;

      sendButtonOSC(clickedButton-1, oscID);
    }
  }

  boolean isInBtn(float x, float y) {
    //print("is in btn?  ");
    if (x>(xpos-nButtons*widthRect/2) && x<(xpos+nButtons*widthRect/2) && y>(ypos-heightRect/2) && y<(ypos+heightRect/2)) {
      //print("yes \n");
      return true;
    } else {
      //print("no \n");
      return false;
    }
  }
  void reset() {
    // Reset the button 
    Arrays.fill(isON, false);
    isClicked = false;
  }

  void sendButtonOSC(int btn, String id) {
    // Send OSC message to Supercollider; it sends the value of the button in 0...Nbuttons-1
    OscMessage myMessage = new OscMessage(id);
    myMessage.add(btn);
    oscP5.send(myMessage, myRemoteLocation); 
    myMessage.print();
  }
}
