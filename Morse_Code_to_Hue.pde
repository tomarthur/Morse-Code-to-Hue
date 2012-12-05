/* 
  Tom Arthur 
  tom.arthur@nyu.edu

  ICM Final - Fall 2012
  Professor Matt Parker


  Attribution: 
  Morse Code logic based on Mirte Morse Code Encoder (http://www.openprocessing.org/sketch/79076)
  Philips HUE API Hacking based on Ross McKillop (http://rsmck.co.uk/hue)
*/

import processing.video.*;
//import org.json.*;

Light firstLight;      // first philips HUE light to be controlled by JSON PUT commands
// Light secondLight;     // first philips HUE light to be controlled by JSON PUT commands
Boolean light1on, sending;

// Light test strings
String morseOn = "{\"on\": true, \"ct\": 154, \"bri\": 254, \"transitiontime\": 2}";  // Light ON & white command for Morse Code
String morseOff = "{\"on\": false, \"transitiontime\": 1}";                           // Light OFF command for Morse Code

String redAlertOn = "{\"on\": true, \"bri\": 254, \"hue\": 546, \"sat\": 254, \"transitiontime\": 2}";  // Light ON command for new message alert
String redAlertOff = "{\"on\": false, \"transitiontime\": 3}";                                          // Light OFF command for new message alert

String turnOn = "{\"on\": true}";     // Turn light on to whatever color it was left at
String turnOff = "{\"on\": false}";   // Turn light off


Capture cam;             // activate camera
PImage displayImg;       // image shown on screen

MorseCode mCode;         // process video brightness for different actions
Interface navigation;    // navigation drawn on video

String textMessage = ""; // message on screen created from Morse Code

PFont fontM;             // text message font
PFont fontN;             // navigation font

PImage sendIconW, sendIconB, clearIconW, clearIconB, flashlightIconW, flashlightIconB;

void setup () {
  size(640, 480);
  smooth();
  colorMode(HSB, 255);
  rectMode(CENTER);

  println("initializing lights...");

  firstLight = new Light("http://bridge_ip/api/apikey/lights/1/state"); // !! Important note, make sure to adjust the substring length in light.pde
  // secondLight = new Light("http://bridge_ip/api/apikey/lights/2/state");

  println("lights initialized.");

  // check state of lights, turn off if already on
  light1on = firstLight.on();

    if (light1on == true){
        firstLight.send(turnOff);
        light1on = firstLight.on();
        println("light 1 " + light1on);
    }

  cam = new Capture(this, 640, 480);
  cam.start();
  displayImg = new PImage(640, 480);

  mCode = new MorseCode();        // morse code processing class
  navigation = new Interface();   // visual interface class

  fontM = loadFont("GothamHTF-Bold-48.vlw");
  fontN = loadFont("GothamHTF-Thin-12.vlw");

  //Load interface iamges

  sendIconW = loadImage("light.png");
  sendIconW.resize(50, 0);
  sendIconB = loadImage("lightB.png");
  sendIconB.resize(50, 0);

  clearIconW = loadImage("delete.png");
  clearIconW.resize(40, 0);
  clearIconB = loadImage("deleteB.png");
  clearIconB.resize(40, 0);

  flashlightIconW = loadImage("flashlight.png");
  flashlightIconW.resize(100, 0);
  flashlightIconB = loadImage("flashlightB.png");
  flashlightIconB.resize(100, 0);

  sending = false;




}

void draw () {

  if (cam.available()) {
    cam.read();

    for (int x = 0; x < cam.width; x++) {
      for (int y = 0; y < cam.height; y++) {
        int dIndex = x + y * cam.width;                
        int cIndex = (width - x - 1) + y * cam.width;
        displayImg.pixels[dIndex] = cam.pixels[cIndex];     //reverse like a mirror 
      }
    }

    displayImg.updatePixels();
    image(displayImg, 0, 0);                                // display camera image

    if (mCode.detectMessage() == true){                     // if a character was detected, add it to the message on screen
      String charFrom = mCode.interpret();   
      textMessage = textMessage + charFrom;                 // add found character to string
    }

    if (mCode.detectSpace() == true)                        // add space if detected
    {
      textMessage = textMessage + " ";
    }

    if (mCode.detectClear() == true)                        // backspace/clear if detected (major error location)
    {
      if (textMessage.length() > 0) {
      textMessage = textMessage.substring(0, textMessage.length()-1);
        if(mCode.index != 0){
          mCode.index--;
          while(mCode.messagechar[mCode.index] != "null") {
            // println(mCode.index);
            mCode.messagechar[mCode.index] = "null";
            if (mCode.index != 0){
              mCode.index--;
            }
         }
       }
      }
    }

    if (mCode.detectSend() == true)         // send message to HUE lights if detected
    {
      // put every letters commands into an array for the message (ex dash dash dash dash dot dot dot dash)
      // figure out the pause between letters (maybe after the letter codes like 'wait' & double wait for spaces)
      // playback the letters in a for loop, sending commands as I go
      // consider just hooking up an LED without the internets
      if (sending == false){
      thread("sendIt");
    }
    }

    fill(255);
    textFont(fontM, 32);
    text(textMessage, 30, 30);                   // draw morse code message on screen
   }


}

void sendIt () {    // Run as a thread so the sketch doesn't appear to freeze.
int counter = 0;
sending = true;
  while (counter < 4){  // Notify that a message is being sent with red flashes
  firstLight.send(redAlertOn);
  delay(700);
  firstLight.send(redAlertOff);
  delay(500);
  counter++;
  }
 delay(100);
 firstLight.send(turnOff);
 delay(2000);

  for (int i = 0; i < mCode.messagechar.length; i++){     // for the length of the message character array, send dot or dash messages to philips hue lights,
        String current = mCode.messagechar[i];            //  timing has to be held in processing, there  is not currently a way to send the entire sequence
        println(current);
        if (current == "dot"){
          firstLight.send(morseOn);
          delay(500);
          firstLight.send(morseOff);
          delay(1500);
        }
        if (current == "dash"){
          firstLight.send(morseOn);
          delay(1000);
          firstLight.send(morseOff);
          delay(1500);

        }
        if (current == "wait"){
          delay(2500);
        }
        if (current == "null"){
          break;
        }
      }

for (int i = 0; i < mCode.messagechar.length; i++)        // clear out the character array
{
  mCode.messagechar[i] = "null";
}

mCode.index = 0;

for (int i = textMessage.length(); i > 0; i--) {          // clear out the message string
  textMessage = textMessage.substring(0, textMessage.length()-1);
}

sending = false;

}
