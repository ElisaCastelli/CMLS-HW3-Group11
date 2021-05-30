class HScrollbar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  String label, oscID; 
  float value;

  HScrollbar (float xp, float yp, int sw, int sh, int l, String lbl, String oscID) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    this.xpos = xp;
    this.ypos = yp-sheight/2;
    spos = xpos + swidth/2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    label = lbl;
    value = 0;
    this.oscID = oscID;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      //print(getValue() + "\n");
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      spos = spos + (newspos-spos)/loose;
      // update the value of the slider and send via osc to supercollider
      // It's here to decrease the amount of osc messages sent
      value = getValue();
      sendOSC(value, oscID);
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {

    if (mouseX > xpos && mouseX < xpos+swidth &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    fill(dirtyWhite);
    textAlign(CENTER);
    textFont(fontScritte);
    textSize(height/40);
    text(label, xpos + swidth/2, ypos-8);

    noStroke();
    rectMode(CORNER); 
    fill(greyB);
    rect(xpos, ypos, swidth, sheight);
    if (over || locked) {
      fill(0);
    } else {
      fill(darkgrey);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }

  float getValue() {
    // Get the value of the slider in 0...1
    return map(spos, sposMin, sposMax, 0, 1);
  }

  void sendOSC(float v, String id) {
    // Send OSC message to Supercollider; it sends the value of the slider in 0...1
    OscMessage myMessage = new OscMessage(id);
    myMessage.add(v);
    oscP5.send(myMessage, myRemoteLocation); 
    myMessage.print();
  }
}
