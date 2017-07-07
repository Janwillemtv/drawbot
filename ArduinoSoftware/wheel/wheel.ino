#include<stdlib.h>

#define SR 2
#define DYNAMIXEL_RETURN_SIZE 16
#include "DynamixelReader.h"

#include <Servo.h> 

Servo myservo;
long stepperPos;

int stepperDir;

int currentId;

int totalSteps,stepsPerId;

int servoPins[] = { 8, 9, 10, 11, A0, A1, A2, A3};



String buffer;
char c;

int dirPinL, dirPinR;
int puslePinL, puslePinR;

static char test[15];

//distannce the motors are apart in mm
#define BASESPEED 2000

#define MOTORDISTANCE 1160

#define MMPERROTATION 60
#define STEPSPERROTATION 800

#define ENABLE 5
#define DIRPIN 6
#define PULSEPIN 7
#define ENDSTOP 4

/* LEDS */
#define LED_RED 3
#define LED_GREEN 12
#define LED_YELLOW 13

void setup() {
  Serial.begin(57600);
  pinMode(ENABLE,OUTPUT);
  pinMode(DIRPIN,OUTPUT);
  pinMode(PULSEPIN,OUTPUT);
  pinMode(ENDSTOP,INPUT_PULLUP);
  digitalWrite(DIRPIN,LOW);
  digitalWrite(PULSEPIN,LOW);

  pinMode(SR, OUTPUT);
  digitalWrite(SR, LOW); //listen

  pinMode(LED_GREEN, OUTPUT);
  digitalWrite(LED_GREEN, HIGH);
  pinMode(LED_YELLOW, OUTPUT);
  digitalWrite(LED_YELLOW, HIGH);
  pinMode(LED_RED, OUTPUT);
  digitalWrite(LED_RED, HIGH);
  
  
  int nrOfIds = 8;
  //tooth ditribution wheel 10:70
  //microstep 8
  //steps per rotation motor 8*200=1600
  //1600*7=11200 steps per rotation wheel
  totalSteps = 11200;
  stepsPerId = totalSteps/nrOfIds;
   
  
  
  calibrateWheel();
   
   
 
  stepperPos = 0;
  stepperDir = 0;
  
//  for(int i = 0; i < sizeof(servoPins); i++){
//    myservo.attach(servoPins[i]);
//    myservo.write(100);
//    delay(100);
//    myservo.detach();
//    
//  }
 
}
long timer = millis();
unsigned long loopTime;
boolean started = false;
void loop() {
  if (millis() > loopTime + 1) {
    loopTime = millis();
    nudgeTimeOut();
    // wdt_reset(); // pat the dog
  }
  if (getTimeOut() > 500) // safe values!!
  {
    digitalWrite(LED_RED, LOW);
    digitalWrite(LED_GREEN, HIGH);
    // think about what to do here: motors on, off?
    //delay(300);
  }

  else {
    digitalWrite(LED_RED, HIGH);
    digitalWrite(LED_GREEN, LOW);
  }
  DynamixelPoll();
}



//in mm

void goToId(int id){
  if(id>currentId){
    stepperDir = 1;
      
  }else{
    stepperDir = 0;
   
  }
  makeStep(stepsPerId*(abs(currentId-id)));
  currentId = id;
  
}
void makeStep(int nr){
  int stepSpeed = 3000;
  int minStepSpeed = 400;
  for(int i = 0; i < nr; i++){
 
    if(stepperDir == 0){
      digitalWrite(DIRPIN,HIGH);
      stepperPos++;
    }else{
      digitalWrite(DIRPIN,LOW);
      stepperPos--;
    }
    digitalWrite(PULSEPIN,HIGH);
    delayMicroseconds(stepSpeed);
    digitalWrite(PULSEPIN,LOW);
    delayMicroseconds(stepSpeed);
    if(stepSpeed<=minStepSpeed){
      stepSpeed = minStepSpeed;
    }else{
      stepSpeed -=50;
    };
    
  }
 
}

void calibrateWheel(){
  boolean calibrating = true;
  int total = 0;
  stepperDir = 1;
  while(stepperPos < totalSteps){
    //if(millis()-oldTime>1000){
   
    
//      Serial.println(avarage);
//      Serial.println(newAvarage);
//Serial.println(digitalRead(ENDSTOP));
    if(digitalRead(ENDSTOP)==0){
      boolean check = true;
      for(int i = 0; i<500; i++){
        if(digitalRead(ENDSTOP) ==1){
          check = false;
        }
        delay(1);
      }
      if(check){
       stepperPos = 0;
      calibrating = false;
      break;
      }else{
        makeStep(20);
      }
    }else{
      
      makeStep(20);
    }
    }
   // }

  
if(calibrating){
  if(stepperDir == 0) stepperDir = 1;
  else stepperDir = 0;
  calibrateWheel();
}

}

void spray(int id){//moet nog geimplementeerd
  myservo.attach(servoPins[id]);
  
  myservo.write(170);              // tell servo to go to position in variable 'pos' 
  delay(500); 
  myservo.write(100);
  delay(300);
  myservo.detach();
                            // waits 15ms for the servo to reach the position 
 
}


//void readSerial(){
//  c = Serial.read();
//  if(c!= '\n'){
//    buffer += c;
//  }else{
//  char temp = buffer.charAt(0);
//  switch(temp){
//    case 'S':
//      int x = getValue(buffer, ' ', 1).toInt();
//      //int y =  getValue(buffer, ' ', 2).toInt();
//      
//      
//      Serial.println(x);
//      
//      goToId(x);
//      spray(x);
//     
//      buffer = "";
//      break;
//  }
//  
//  }
//  
//
//}

//String getValue(String data, char separator, int index)
//{
//    int found = 0;
//    int strIndex[] = { 0, -1 };
//    int maxIndex = data.length() - 1;
//
//    for (int i = 0; i <= maxIndex && found <= index; i++) {
//        if (data.charAt(i) == separator || i == maxIndex) {
//            found++;
//            strIndex[0] = strIndex[1] + 1;
//            strIndex[1] = (i == maxIndex) ? i+1 : i;
//        }
//    }
//    return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
//}

void ProcessDynamixelData(const unsigned char ID, const int dataLength, const unsigned char* const Data) {
  if (ID == BOARD_ID) {
    toggle(LED_GREEN);
    if (Data[0] == 0x03) { // dynamixel write move absolute

      int xValue = (((int)Data[1]) << 8 ) + Data[2];
      int yValue = (((int)Data[3]) << 8 ) + Data[4];
      // todo: sanitycheck here
 //     moveTo(xValue, yValue);
       digitalWrite(LED_YELLOW,LOW);
       goToId(xValue);
       delay(300);
      spray(xValue);
      digitalWrite(LED_YELLOW,HIGH);
      ReturnDynamixelData(20,13);
    }
  } // else don't process the command
}


void ReturnDynamixelData(const unsigned char ID, int Data) {
  unsigned char buffer[10];
  unsigned int checksum = 0;
  buffer[0] = (0xFF);
  buffer[1] = (0xFF);
  buffer[2] = (ID);
  buffer[3] = (1); // was dataLegth+2
  buffer[4] = Data&0xFF;

  buffer[5] = (~(Data + ID + 1));

  // OK, do transmission now: //
  digitalWrite(SR, HIGH); // send data to HOST
  Serial.write(buffer, 6);
  Serial.flush(); // wait for buffer to empty
  digitalWrite(SR, LOW);
}
