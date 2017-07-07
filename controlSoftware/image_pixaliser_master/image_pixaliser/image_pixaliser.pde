
import java.util.Map;
import processing.serial.*;
import controlP5.*;

ControlP5 cp5;
//import java.util.Color;

Serial port;       // The Dynamixel to Serial port

enum States {
  PICK, SIMULATE, PRINT, PAUSE, DONE
};

States state;

PImage originalImg;
PImage finalImg;
boolean positionOK = true;
boolean colorOK = true;
boolean calibrationOK = false;
boolean positionDone = false;
boolean colorDone = false;
boolean done = false;
boolean calibrate = false;
boolean printStarted = false;
ArrayList<Dot> dots = new ArrayList<Dot>();
int spacing = 30;
int dotSize = 15;
int trailLength = 30;
int visualFix = 3;
int visualOffset = 15;

int colorNumber = 8;
int dotsWidth = 30;
int dotsHeight = 40;
int startId = 0;
int calibrateMM = 1490;

ArrayList<PVector> colors = new ArrayList<PVector>();
ColorWheel colorWheel = new ColorWheel(8);
String fileName = "";
boolean picker, calculate;

Cursor cursor = new Cursor();
int itterator;

public void setup() {
  size(800, 700);
  for (int i = 0; i<Serial.list ().length; i++) { 
    print("[" + i + "] ");
    println(Serial.list()[i]);
  }
  port=new Serial(this, Serial.list()[32], 57600);

  state = States.PICK;
  picker = false;
  cp5 = new ControlP5(this);
  cp5.addButton("PickPicture")
    .setPosition(600, 65)
    .setSize(200, 19);

  cp5.addTextfield("WidthDots")
    .setPosition(600, 100)
    .setSize(200, 40)
    .setAutoClear(false)
    .setText(str(dotsWidth));

  cp5.addTextfield("HeightDots")
    .setPosition(600, 170)
    .setSize(200, 40)
    .setAutoClear(false)
    .setText(str(dotsHeight));

  cp5.addButton("Resize")
    .setPosition(720, 210)
    .setSize(80, 40);

   cp5.addTextfield("StartFrom")
    .setPosition(600, 290)
    .setSize(200, 40)
    .setAutoClear(false)
    .setText(str(startId));
  
  cp5.addButton("TestHead")
    .setPosition(600, 340)
    .setSize(100, 40)
    ;


  cp5.addButton("Print")
    .setPosition(700, 380)
    .setSize(100, 40)
    ;
    
  cp5.addButton("Calibrate")
    .setPosition(700, 340)
    .setColorBackground(color(255, 0, 0))
    .setColorActive(color(255, 0, 0))
    .setSize(100, 40);
    
  cp5.addButton("Up")
    .setPosition(660, 600)
    .setColorBackground(color(20, 20, 200))
    .setColorActive(color(20, 20, 200))
    .setSize(80, 40);
    
  cp5.addButton("Down")
    .setPosition(660, 640)
    .setColorBackground(color(20, 20, 200))
    .setColorActive(color(20, 20, 200))
    .setSize(80, 40);
    
  cp5.addButton("LeftUp")
    .setPosition(600, 600)
    .setSize(60, 40);
  cp5.addButton("LeftDown")
    .setPosition(600, 640)
    .setSize(60, 40);
    
  cp5.addButton("RightUp")
    .setPosition(740, 600)
    .setSize(60, 40);
  cp5.addButton("RightDown")
    .setPosition(740, 640)
    .setSize(60, 40);
    
    cp5.addTextfield("SendPosX")
    .setPosition(600, 240)
    .setSize(50, 40)
    .setAutoClear(false);
    
   cp5.addTextfield("SendPosY")
    .setPosition(650, 240)
    .setSize(50, 40)
    .setAutoClear(false);

  cp5.addButton("SendPosition")
    .setPosition(720, 240)
    .setSize(80, 40);
}

public void draw() {
  //while (port.available()>0) {
  //  serialEvent(port.read());
  //}
  //background(155, 108, 27);
  background(245);
  fill(100);
  rect(600, 0, 200, 700);
  switch(state) {
  case PICK:
    if (picker) {
      selectInput("Select a file to process:", "fileSelected");
      picker = false;
    }
    break;

  case SIMULATE:
    if (calculate) {
      originalImg = loadImage(fileName);
      finalImg = originalImg.copy();
      extractColorFromImage(finalImg, originalImg);
      finalImg = decreasePixels(originalImg, dotsWidth, dotsHeight);
      addDots(finalImg);
      colorWheel.configure();
      calculate = false;
      itterator = 0;
    }


    drawDots();
    drawPallet();
    colorWheel.drawColorWheel(700, 500, 150);
    break;

  case PRINT:
    drawDots();
    drawPallet();
    Dot temp = dots.get(itterator);
    cursor.setPosition(temp.getX(), temp.getY());
    cursor.drawCursor();
    colorWheel.drawColorWheel(700, 500, 150);
    
    while (port.available()>0) {
        serialEvent(port.read());
        //println("reading");
     }
    
    
    if(positionOK && colorOK && !positionDone && !colorDone){
      sendPosition(temp.getX(), temp.getY());
      positionOK = false;
      positionDone = true;
      colorDone = false;
    }else if(positionOK && colorOK && !colorDone && positionDone){
      sendColor(temp.getColorId());
      colorOK = false;
      colorDone = true;
    }else if(positionOK && colorOK && colorDone && positionDone){
      if(itterator> dots.size()){
        state = States.DONE;
      }else{
      positionDone = false;
      colorDone = false;
      itterator++;
      cp5.get(Textfield.class, "StartFrom").setText(str(itterator));
      }
    }else{
      print('.');
    }
    
     //sendPosition(temp.getX(), temp.getY());
     //positionOK = false;
    //while (!positionOK) {
     // while (port.available()>0) {
     //   serialEvent(port.read());
     // }
     // print('.');
     // delay(50);
    //}

    //sendColor(temp.getColorId());
    //colorOK = false;
    //while (!colorOK) {
    //  while (port.available()>0) {
    //    serialEvent(port.read());
    //  }
    //  print('.');
    //  delay(50);
    //}

    //itterator++;
    //cp5.get(Textfield.class, "StartFrom").setText(str(itterator));
    break;

  case PAUSE:
    drawDots();
    drawPallet();
    cursor.drawCursor();
    colorWheel.drawColorWheel(700, 500, 150);
    break;
    
  case DONE:
    drawDots();
    drawPallet();
    cursor.drawCursor();
    colorWheel.drawColorWheel(700, 500, 150);
    
    break;
  }








  //image(img, 0, 0, 640, 480);
  //image(testImg, 0, 0, 50, 50);
}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    fileName = selection.getAbsolutePath();
    calculate = true;
    state = States.SIMULATE;
  }
}

public void PickPicture() {
  state = States.PICK;
  picker = true;
}

public void Resize() {
  int value1, value2;
  print("the following text was submitted :");
  value1 = Integer.parseInt(cp5.get(Textfield.class, "WidthDots").getText());
  value2 = Integer.parseInt(cp5.get(Textfield.class, "HeightDots").getText());
  print(" width = " + value1);
  print(" height = " + value2);
  if (value1 < 1 || value1 > 300) value1 = 30;
  if (value2 < 1 || value2 > 300) value2 = 30;
  dotsWidth =value1;
  dotsHeight = value2;
  println(dotsWidth + " " + dotsHeight);
  calculate = true;
  println();
}

public void SendPosition() {
  int value1, value2;
  print("the following text was submitted :");
  value1 = Integer.parseInt(cp5.get(Textfield.class, "SendPosX").getText());
  value2 = Integer.parseInt(cp5.get(Textfield.class, "SendPosY").getText());
  print(" x = " + value1);
  print(" y = " + value2);
  //if (value1 < 1 || value1 > 300) value1 = 30;
  //if (value2 < 1 || value2 > 300) value2 = 30;
  sendRealPosition(value1,value2);
}

public void Calibrate(){
  if(!calibrate){
 
  sendCalibrate(calibrateMM);
  while(!calibrationOK){
    while (port.available()>0) {
      serialEvent(port.read());
    }
  }
  cp5.get(Button.class, "Calibrate").setColorBackground(color(0, 255, 0)).setColorActive(color(0, 255, 0));
  calibrate = true;
  }
}

public void Print() {
  if (state==States.SIMULATE && calculate == false && calibrate==true|| state==States.PAUSE) {
    if(!printStarted){
      itterator = Integer.parseInt(cp5.get(Textfield.class, "StartFrom").getText());
      printStarted = true;
    }
    cp5.get(Button.class, "Print").setColorBackground(color(0, 255, 0)).setColorActive(color(0, 255, 0));
    state = States.PRINT;
  } else {
    if(state == States.PRINT){
    cp5.get(Button.class, "Print").setColorBackground(color(255, 0, 0)).setColorActive(color(255, 0, 0));
    state = States.PAUSE;
    }
  }
}

public void Up(){
  if(state!=States.PRINT && state!= States.PAUSE){
    sendPositionRelative(0,1000);
  }
}

public void Down(){
  if(state!=States.PRINT && state!= States.PAUSE){
    sendPositionRelative(1,1000);
  }
}

public void LeftUp(){
  if(state!=States.PRINT && state!= States.PAUSE){
    sendPositionRelative(3,500);
  }
}

public void LeftDown(){
  if(state!=States.PRINT && state!= States.PAUSE){
    sendPositionRelative(2,500);
  }
}

public void RightUp(){
  if(state!=States.PRINT && state!= States.PAUSE){
    sendPositionRelative(5,500);
  }
}

public void RightDown(){
  if(state!=States.PRINT && state!= States.PAUSE){
    sendPositionRelative(4,500);
  }
 
}

public void TestHead(){
  for(int i = 0; i<colorNumber; i++){
    testColor(i);
    delay(1000);
  
  }

}