class Interface {
  String messageProgress = " ";
  String current;

  void drawProgress(boolean dState) {
    if (dState == true) {
      fill(255, 0, 0);
      textFont(fontM, 32);
      text(messageProgress, width/2-70, height/2+30);
    }
    else {
      fill(0, 0, 255);
      textFont(fontM, 32);
      text(messageProgress, width/2-70, height/2+30);
    }
  }

  void drawMessageBox(boolean mState) {
    if (mState == true) {
      // noFill();
      // stroke(255, 0, 0);
      // rect(width/2, height/2, 50, 50);
      imageMode(CENTER);
      image(flashlightIconB, width/2, height/2);
      imageMode(CORNER);
    }
    else {
      // noFill();
      // stroke(0, 0, 255);
      // rect(width/2, height/2, 50, 50);
      imageMode(CENTER);
      image(flashlightIconW, width/2, height/2);
      imageMode(CORNER);
    }
  }

  void drawSpaceBox(boolean nState) {
    if (nState == true) {
      // noFill();
      // stroke(255, 0, 0);
      // rect(640, 0, 50, 50);
      // fill(255, 0, 0);
      // textFont(fontN, 32);
      // textSize(12);
      // text("space", 600, 40);
    }
    else {
      // noFill();
      // stroke(0, 0, 255);
      // rect(640, 0, 50, 50);
      // fill(0, 0, 255);
      // textFont(fontN, 32);
      // textSize(12);
      // text("space", 600, 40);
    }
  }

  void drawSendBox(boolean sState) {
    if (sending == false) {
      if (sState == true) {
        // noFill();
        // stroke(255, 0, 0);
        // rect(640, 480, 50, 50);
        // fill(255, 0, 0);
        // textFont(fontN, 32);
        // textSize(12);
        // text("send", 580, 450);
        image(sendIconB, 585, 420);
      }
      else {
        // noFill();
        // stroke(0, 0, 255);
        // rect(640, 480, 50, 50);
        // fill(0, 0, 255);
        // textFont(fontN, 32);
        // textSize(12);
        // text("send", 609, 450);
        image(sendIconW, 585, 420);
      }
    }
  }

  void drawClearBox(boolean cState) {
    if (sending == false) {
      if (cState == true) {
        // noFill();
        // stroke(255, 0, 0);
        // rect(0, 480, 50, 50);
        // fill(255, 0, 0);
        // textFont(fontN, 32);
        // textSize(12);
        // text("clear", 5, 450);
        image(clearIconB, 8, 440);
      }
      else {
        // noFill();
        // stroke(0, 0, 255);
        // rect(0, 480, 50, 50);
        // fill(0, 0, 255);
        // textFont(fontN, 32);
        // textSize(12);
        // text("clear", 5, 450);
        image(clearIconW, 8, 440);
      }
    }
  }
}

