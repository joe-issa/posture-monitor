import controlP5.*; //import all from controlP5
import processing.serial.*; //import all from processing.serial

Serial port;

ControlP5 cp5;
PFont font, font2, caption;
Toggle mode;
PrintWriter output;
//PGraphics buffer;

int state = 0;

void setup(){ //GUI Setup

  size(375, 400); //Window Size, (W, H)
  
  printArray(Serial.list());   //prints all available serial ports
  
  port = new Serial(this, "COM3", 9600); // "COM3" Might be different on different devices
  cp5 = new ControlP5(this);
  font = createFont("Times New Roman Bold", 20);    // custom fonts for buttons and title
  //caption = createFont("Times New Roman Bold", 12);    // custom fonts for captions
  font2 = createFont("Times New Roman Bold", 32);
  
  mode = cp5.addToggle("Mode")     //"red" is the name of button
    .setPosition(112.5, 250)  // Origin is the upper left corner of the Window
    .setSize(150, 70)      //(W, H)
    .setFont(font)
    .setMode(ControlP5.SWITCH)
  ;   

  //cp5.addButton("pic")
    // .setPosition(30,70)
    // .setImages(loadImage("good_posture.jpg"))
     //.updateSize()
     ;
     
  //buffer = createGraphics(375,375,P2D)
  ;

  output = createWriter("daq.txt");
  
}

void draw(){  //GUI Loop

  if (port.available() > 0) {
  delay(10);
  String line = port.readString();
  delay(10);
  //String state = port.readStringUntil(',');
  print(line);
  state = line.charAt(0);
  output.println(line);
}
  delay(10);
  
  background(230); // background color of window (r, g, b) or (0 to 255)
  
  fill(0, 0, 255);               //text color (r, g, b)
  textFont(font);
  text("Posture Monitor", 120, 30);  // ("text", x, y)
  
  text("Massage", 25, 290);
  text("Monitor", 275, 290);
  
  if (state == '0') {
    text("Looks like you have a good posture.", 40, 100);
    text("Keep it UP!", 140, 160);

  }
  else if (state == '1') {
    text("Woah! Looks like you have a bad posture.", 10, 100);
    text("Let's fix that!", 135, 160);
  }
  else if (state == '2') {
    text("You've been sitting here for too long", 30, 100);
    text("We suggest going for a walk or", 55, 135);
    text("doing some stretching exercises", 50, 170);

  }
  else if (state == '3') {
    text("Massage mode activated!", 80, 100);
    text("Massaging...", 140, 160);
  }
  
  
  //textFont(caption);
  //text("Mintoboru on Shutterstock and Lilanakani on istockphoto.com", 30, 400);
  
}

void Mode(){
  if (mode.getValue() == 0.0) {
    port.write('o');
    println("Monitor Button Pressed"); }
  else {
    port.write('a');
    println("Massage Button Pressed");
 }
}

void keyPressed(){
  

  output.close();
  println("End Line");
  exit();
  }
