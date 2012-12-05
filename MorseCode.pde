class MorseCode {

  String characterReturn;         // character to be returned from Morse Code
  String[] messagechar = new String[200]; // surely not the best way to do this, but time runs out!
  int index = 0;                  // location in the string array

  Boolean messageDetect = false;  // true when a light sequnece is detected in message zone
  Boolean messageFound = false;   // true when a character is detected
  Boolean decode = false;         // ready for blinks to be decoded, used to prevent eronius blink detection
  Boolean interpretDone = false;  // ready to clear the string array

  Boolean spaceDetect = false;    // true when a light sequnece is detected in space zone
  Boolean spaceAdded = false;     // true when a space is ready to be added
  Boolean clearDetect = false;    // true when a light sequnece is detected in clear zone
  Boolean clearStarted = false;   // true when clearing has been sent
  Boolean sendDetect = false;     // true when a light sequnece is detected in send zone
  Boolean sent = false;           // true when sent command has been sent
  Boolean done = false;           // true when detection sequence is done

    String rawcharacter[] = {
    "null", "null", "null", "null"
  }; // morse code is 4 segements

  int pos = 0;            // position in the chracter string

  int start, end, timer, sTimer, cTimer, nTimer; // millis timers for checking if there is a command
  float l;                // length of end - start

  MorseCode() {
  }

  boolean detectMessage() {

    color messagePixel = cam.pixels[155200];  // pixel near the center of the screen to check brightness
    float messagePixelDistance = dist(0, 0, 255, hue(messagePixel), saturation(messagePixel), brightness(messagePixel));

    if (messagePixelDistance < 30) {     // if the pixel gets really bright, there is a message being sent!
      messageDetect = true;             // tells function to check for message
      navigation.drawMessageBox(true);
      navigation.drawProgress(true);
    }
    else {
      messageDetect = false;
      navigation.drawMessageBox(false);
      navigation.drawProgress(false);
    }



    if (messageDetect == true && decode == false) {   // check to see how long the flash is using a millis timer
      start = millis();
      timer = 0;
      decode = true;
    }

    if (messageDetect == false && decode == true) {   // if we've seen the end of the flash & we are detecting a message,
      end = millis();                                // figure out how long the flash was 
      // println(end);
      l = end - start;

      if (l > 1 && l < 400) {                        // between 1 and 400 miliseconds it must be a dot
        rawcharacter[pos] = "dot";
        pos++;                                       // move forward in the rawCharacter array
        messageFound = true;
        navigation.messageProgress = navigation.messageProgress + " . ";
      }
      if (l > 401 && l < 800) {                      // between 401 and 800 milliseconds it must be a dash
        rawcharacter[pos] = "dash";
        pos++;                                       // move forward in the rawCharacter array
        messageFound = true;
        navigation.messageProgress = navigation.messageProgress + " _ ";
      }
      decode = false;                                // got ya! ready for the next one
      println(rawcharacter);
    }

    if (done == true && interpretDone == true) {      // clear everything out after a message has been found
      timer = 0;
      for (int i = 0; i < 4; i++) {
        rawcharacter[i] = "null";
        pos = 0;
      }
      navigation.messageProgress = " ";
      done = false;
      messageFound = false;
      interpretDone = false;
    }

    timer++;

    if ( timer > 31 && messageFound == true) {      // if the timer is more than 31, the character must be done
      return done = true;
    }
    else if (pos > 3 && messageFound == true) {     // morse code is in up to 4 segments but no more (exclusing numbers)
      return done = true;
    }
    else {
      return false;                                 // no message to be found
    }
  }

  boolean detectSpace() { // same logic as above, detects the desire to add a space

      color spacePixel = cam.pixels[1940]; // pixel in the upper right corner of the frame
    float spacePixelDistance = dist(0, 0, 255, hue(spacePixel), saturation(spacePixel), brightness(spacePixel));

    if (spacePixelDistance < 10) {
      spaceDetect = true;                 
      navigation.drawSpaceBox(true);
      nTimer = millis();
    }
    else {
      spaceDetect = false;
      navigation.drawSpaceBox(false);
    }

    if (spaceDetect == true && spaceAdded == false) {
      spaceAdded = true;
      return true;
    }
    else if ((nTimer + 2000) < millis() && spaceAdded == true) {
      spaceAdded = false;
      nTimer = 0;
      return false;
    }
    else {
      return false;
    }
  }

  boolean detectClear() { // same logic as above, detects the desire to clear the message

    color clearPixel = cam.pixels[306539];
    float clearPixelDistance = dist(0, 0, 255, hue(clearPixel), saturation(clearPixel), brightness(clearPixel));

    if (clearPixelDistance < 10) {
      clearDetect = true;                 
      navigation.drawClearBox(true);
      cTimer = millis();
      // println("cleardetect");
    }
    else {
      clearDetect = false;
      navigation.drawClearBox(false);
    }

    if (clearDetect == true && clearStarted == false) {
      clearStarted = true;
      return true;
    }
    else if ((cTimer + 2000) < millis() && clearStarted == true) {
      clearStarted = false;
      cTimer = 0;
      return false;
    }
    else {
      return false;
    }
  }

  boolean detectSend() { // same logic as above, detects the desire to send the message

    color sendPixel = cam.pixels[306595];
    float sendPixelDistance = dist(0, 0, 255, hue(sendPixel), saturation(sendPixel), brightness(sendPixel));


    if (sendPixelDistance < 5) {
      sTimer = millis(); 
      sendDetect = true;  
      navigation.drawSendBox(true);
    }
    else {
      sendDetect = false;
      navigation.drawSendBox(false);
    }

    if (sendDetect == true && sent == false) {

      sent = true;
      return true;
    }
    else if ((sTimer + 5000) < millis() && sent == true) {
      sent = false;
      sTimer = 0;
      return false;
    }
    else {
      return false;
    }
  }


  String interpret() {
    for (int i = 0; i < 4; i++) {                    // put the raw "dash" or "dot" into our array for sending to the lights
      if (rawcharacter[i] != "null") {
        messagechar[index] = rawcharacter[i];
        index++;
      }
      else {
        break;
      }
    }
    messagechar[index] = "wait";
    index++;

    // decode to human readable

    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dash" && rawcharacter[2] == "null" && rawcharacter[3] == "null") {
      characterReturn =  "A";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dot" && rawcharacter[2] == "dot" && rawcharacter[3] == "dot") {
      characterReturn =  "B";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dot" && rawcharacter[2] == "dash" && rawcharacter[3] == "dot") {
      characterReturn =  "C";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dot" && rawcharacter[2] == "dot" && rawcharacter[3] == "null") {
      characterReturn =  "D";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "null" && rawcharacter[2] == "null" && rawcharacter[3] == "null") {
      characterReturn =  "E";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dot" && rawcharacter[2] == "dash" && rawcharacter[3] == "dot") {
      characterReturn =  "F";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dash" && rawcharacter[2] == "dot" && rawcharacter[3] == "null") {
      characterReturn =  "G";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dot" && rawcharacter[2] == "dot" && rawcharacter[3] == "dot") {
      characterReturn =  "H";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dot" && rawcharacter[2] == "null" && rawcharacter[3] == "null") {
      characterReturn =  "I";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dash" && rawcharacter[2] == "dash" && rawcharacter[3] == "dash") {
      characterReturn =  "J";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dot" && rawcharacter[2] == "dash" && rawcharacter[3] == "null") {
      characterReturn =  "K";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dash" && rawcharacter[2] == "dot" && rawcharacter[3] == "dot") {
      characterReturn =  "L";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dash" && rawcharacter[2] == "null" && rawcharacter[3] == "null") {
      characterReturn =  "M";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dot" && rawcharacter[2] == "null" && rawcharacter[3] == "null") {
      characterReturn =  "N";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dash" && rawcharacter[2] == "dash" && rawcharacter[3] == "null") {
      characterReturn =  "O";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dash" && rawcharacter[2] == "dash" && rawcharacter[3] == "dot") {
      characterReturn =  "P";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dash" && rawcharacter[2] == "dot" && rawcharacter[3] == "dash") {
      characterReturn =  "Q";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dash" && rawcharacter[2] == "dot" && rawcharacter[3] == "null") {
      characterReturn =  "R";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dot" && rawcharacter[2] == "dot" && rawcharacter[3] == "null") {
      characterReturn =  "S";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "null" && rawcharacter[2] == "null" && rawcharacter[3] == "null") {
      characterReturn =  "T";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dot" && rawcharacter[2] == "dash" && rawcharacter[3] == "null") {
      characterReturn =  "U";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dot" && rawcharacter[2] == "dot" && rawcharacter[3] == "dash") {
      characterReturn =  "V";
    }
    if (rawcharacter[0] == "dot" && rawcharacter[1] == "dash" && rawcharacter[2] == "dash" && rawcharacter[3] == "null") {
      characterReturn =  "W";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dot" && rawcharacter[2] == "dot" && rawcharacter[3] == "dash") {
      characterReturn =  "X";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dot" && rawcharacter[2] == "dash" && rawcharacter[3] == "dash") {
      characterReturn =  "Y";
    }
    if (rawcharacter[0] == "dash" && rawcharacter[1] == "dash" && rawcharacter[2] == "dot" && rawcharacter[3] == "dot") {
      characterReturn =  "Z";
    }
    interpretDone = true;
    return characterReturn;
  }
}

