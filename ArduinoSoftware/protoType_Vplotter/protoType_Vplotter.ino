///////////////////////////////////////////////////////////////////
// Stepper motor control in base for V-plotter system
//
// using RS485 sensor print with ATmega168 @ 16 MHz
//
// Sensor pcb pinout:
// 1 PB0  D8   Motor R pulse
// 2 PB1  D9   Motor R dir
// 3 PB2  D10  Motor R enable
// 4 PB3  D11
// 5 PC0  A0   Motor L pulse
// 6 PC1  A1   Motor L dir
// 7 PC2  A2   Motor L enable
// 8 PC3  A3
//
// dynamixel protocol message consists of the following bytes:
// 0xFF 0xFF ID MessageLength command data[1] .. data [n] checksum
//
/////////////// WinAVR defines ////////////////////////////////////
#define toggle(pin) digitalWrite(pin, !digitalRead(pin))
#define  outb(addr, data)  addr = (data)
#define inb(addr)   (addr)
#define BV(bit)     (1<<(bit))
#define cbi(reg,bit)  reg &= ~(BV(bit))
#define sbi(reg,bit)  reg |= (BV(bit))
/////////////////////////////////////////////////////////
//
// global defines for dynamixel communication protocol
//
#define SR 2
#define DYNAMIXEL_RETURN_SIZE 16
#include "DynamixelReader.h"



unsigned long loopTime;

unsigned long stepperLpos;
unsigned long stepperRpos;
int stepperLdir;
int stepperRdir;

String buffer;
char c;

int dirPinL, dirPinR;
int puslePinL, puslePinR;

static char test[15];

//distannce the motors are apart in mm
#define BASESPEED 3000

#define MOTORDISTANCE 2030
#define SPACING 30

#define MMPERROTATIONL 245
#define MMPERROTATIONR 234
#define STEPSPERROTATION 3200

#define DIRPINL A1
#define PULSEPINL A0
#define ENABLEL A2

#define DIRPINR 9
#define PULSEPINR 8
#define ENABLER 10

/* LEDS */
#define LED_RED 3
#define LED_GREEN 12
#define LED_YELLOW 13

//initial pos is 1 mtr from both motors
void setup() {
  Serial.begin(57600);
  pinMode(DIRPINL, OUTPUT);
  pinMode(PULSEPINL, OUTPUT);
  pinMode(ENABLEL, OUTPUT);

  pinMode(DIRPINR, OUTPUT);
  pinMode(PULSEPINR, OUTPUT);
  pinMode(ENABLER, OUTPUT);

  digitalWrite(DIRPINL, LOW);
  digitalWrite(PULSEPINL, LOW);
  digitalWrite(ENABLEL, HIGH); // always on

  digitalWrite(DIRPINR, LOW);
  digitalWrite(PULSEPINR, LOW);
  digitalWrite(ENABLER, HIGH); // always on

  pinMode(SR, OUTPUT);
  digitalWrite(SR, LOW); //listen

  pinMode(LED_GREEN, OUTPUT);
  digitalWrite(LED_GREEN, HIGH);
  pinMode(LED_YELLOW, OUTPUT);
  digitalWrite(LED_YELLOW, HIGH);
  pinMode(LED_RED, OUTPUT);
  digitalWrite(LED_RED, HIGH);
  //calibrate
float tempL = 1490 / (float)MMPERROTATIONL;
  float tempR = 1490 / (float)MMPERROTATIONR;
  tempL *= STEPSPERROTATION;
  tempR *= STEPSPERROTATION;
  stepperLpos = tempL;
  stepperRpos = tempR;
  stepperLdir = 0;
  stepperRdir = 0;
}
long timer = millis();
boolean started = false;
//void loop(){
//
//  while(Serial.available()>0){
//    readSerial();
//  }
//}
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

void moveRel(int motorL, int motorLdir, int motorR, int motorRdir) {
  unsigned long timer = micros();
  stepperLdir = motorLdir;
  stepperRdir = motorRdir;

  //  if(motorL>0){
  //    stepperLdir = 0;
  //  }else{
  //    stepperLdir = 1;
  //  }

  //  if(motorR>0){
  //    stepperRdir = 0;
  //  }else{
  //    stepperRdir = 1;
  //  }
//  if (motorLdir == 0)stepperLpos += motorL;
//  else stepperLpos -= motorL;
//  if (motorRdir == 0)stepperRpos += motorR;
//  else stepperRpos -= motorR;

  int rampUp = 500;
  int rampDown = 0;
  boolean done = false;
  while (!done) {
    if (motorL < 500)rampDown = 500 - motorL;
    if (motorR < 500)rampDown = 500 - motorR;
    if (micros() - timer > 3000 + rampUp + rampDown) {
      if (motorL > 0) {
        makeStep(0);
        motorL--;
      }
      if (motorR > 0) {
        makeStep(1);
        motorR--;
      }
      if (rampUp > 0)rampUp--;
      timer = micros();
      if (motorL == 0 && motorR == 0)done = true;
    }

  }


}

void calibratePos(float mm) {
  float tempL = mm / (float)MMPERROTATIONL;
  float tempR = mm / (float)MMPERROTATIONR;
  tempL *= STEPSPERROTATION;
  tempR *= STEPSPERROTATION;
  stepperLpos = tempL;
  stepperRpos = tempR;
  stepperLdir = 0;
  stepperRdir = 0;

  static unsigned char returnData[] = "ok";
  ReturnDynamixelData(10, 14);

}

//in mm
void moveTo(float x, float y) {
  digitalWrite(LED_YELLOW, LOW);
  if (x >= 0 && y >= 0) {
    float Ldistance = sqrt(pow(y, 2) + pow(x, 2));
    float Rdistance = sqrt((pow(y, 2) + pow(((float)MOTORDISTANCE - x), 2)));

    Serial.println("String distance: " + String((int)Ldistance) + "    " + String((int)Rdistance));
    float LstepDistance = ((Ldistance / (float)MMPERROTATIONL) * (float)STEPSPERROTATION);
    float RstepDistance = ((Rdistance / (float)MMPERROTATIONR) * (float)STEPSPERROTATION);

    LstepDistance = floor(LstepDistance);
    RstepDistance = floor(RstepDistance);
    // int Ldistance = (int)((sqrt(pow(y,2)+pow(x,2)))/MMPERROTATION)*STEPSPERROTATION;

    // int Rdistance = (int)((sqrt(pow(y,2)+pow(MOTORDISTANCE - x,2)))/MMPERROTATION)*STEPSPERROTATION;
    Serial.println("String step distance: " + String(LstepDistance) + "    " + String(RstepDistance));
    long motorLdistance = LstepDistance - stepperLpos;
    if (motorLdistance > 0) {
      stepperLdir = 0;
    } else {
      stepperLdir = 1;
      motorLdistance = abs(motorLdistance);
    }

    long motorRdistance = RstepDistance - stepperRpos;
    if (motorRdistance > 0) {
      stepperRdir = 0;
    } else {
      stepperRdir = 1;
      motorRdistance = abs(motorRdistance);
    }

    Serial.println("String steps away: " + String(motorLdistance) + "dir " + stepperLdir + "    " + String(motorRdistance) + "dir " + stepperRdir);
    //Serial.println("MM away: " + String(((float)motorLdistance / STEPSPERROTATION)*MMPERROTATION));
    float motorLspeed = (float)motorLdistance / (float)motorRdistance;
    float motorRspeed = (float)motorRdistance / (float)motorLdistance;

    dtostrf(motorLspeed, 7, 3, test);
    Serial.print("Motor speed ");
    Serial.print(test);
    Serial.print("   ");
    dtostrf(motorRspeed, 7, 3, test);
    Serial.println(test);


    unsigned long timerL = micros();
    unsigned long timerR = micros();
    int rampUp = 500;
    int rampDown = 0;

    while (motorLdistance > 0 && motorRdistance > 0) {
      if (motorLdistance < 500)rampDown = 500 - motorLdistance;
      if(motorRdistance < 500)rampDown = 500 - motorRdistance;
      if (micros() - timerL >= (BASESPEED / motorLspeed) + rampUp + rampDown) {
        makeStep(0);
        motorLdistance--;

        if (rampUp > 0)rampUp--;
        timerL = micros();
      }
      if (micros() - timerR >= (BASESPEED / motorRspeed) + rampUp + rampDown) {
        makeStep(1);
        motorRdistance--;
        if (rampUp > 0)rampUp--;
        timerR = micros();
      }

    }
    //stepperLpos = LstepDistance;
    //stepperRpos = RstepDistance;

  }
  static unsigned char returnData[] = "ok";
  ReturnDynamixelData(10, 13);
  digitalWrite(LED_YELLOW, HIGH);
}

void makeStep(int id) {
  //Serial.println(id);
  if (id == 0) {

    if (stepperLdir == 0) {
      digitalWrite(DIRPINL, LOW);
      stepperLpos++;
    } else {
      digitalWrite(DIRPINL, HIGH);
      stepperLpos--;
    }
    digitalWrite(PULSEPINL, LOW);
    delayMicroseconds(15);
    digitalWrite(PULSEPINL, HIGH);
    delayMicroseconds(15);
  } else if (id == 1) {
    if (stepperRdir == 0) {
      digitalWrite(DIRPINR, HIGH);
      stepperRpos++;
    } else {
      digitalWrite(DIRPINR, LOW);
      stepperRpos--;
    }
    //Serial.println("step");
    digitalWrite(PULSEPINR, LOW);
    delayMicroseconds(15);
    digitalWrite(PULSEPINR, HIGH);
    delayMicroseconds(15);
  }
  ;


}



//void readSerial() {
//  digitalWrite(LEDGREEN, LOW);
//  c = Serial.read();
//  if (c != '\n') {
//    buffer += c;
//  } else {
//    char temp = buffer.charAt(0);
//    switch (temp) {
//      case 'M':
//        int x = getValue(buffer, ' ', 1).toInt();
//        int y =  getValue(buffer, ' ', 2).toInt();
//
//        moveTo(x, y);
//        Serial.println(x + " " + y);
//        buffer = "";
//        break;
//    }
//
//  }
//  digitalWrite(LEDGREEN, HIGH);
//
//}

//String getValue(String data, char separator, int index)
//{
//  int found = 0;
//  int strIndex[] = { 0, -1 };
//  int maxIndex = data.length() - 1;
//
//  for (int i = 0; i <= maxIndex && found <= index; i++) {
//    if (data.charAt(i) == separator || i == maxIndex) {
//      found++;
//      strIndex[0] = strIndex[1] + 1;
//      strIndex[1] = (i == maxIndex) ? i + 1 : i;
//    }
//  }
//  return found > index ? data.substring(strIndex[0], strIndex[1]) : "";
//}

void ProcessDynamixelData(const unsigned char ID, const int dataLength, const unsigned char* const Data) {
  if (ID == BOARD_ID) {
    toggle(LED_GREEN);
    if (Data[0] == 0x03) { // dynamixel write move absolute

      int xValue = (((int)Data[1]) << 8 ) + Data[2];
      int yValue = (((int)Data[3]) << 8 ) + Data[4];
      // todo: sanitycheck here
      moveTo(xValue, yValue);
    } else if (Data[0] == 0x04) { // dynamixel write move relative

      int command = (((int)Data[1]) << 8 ) + Data[2];
      int steps = (((int)Data[3]) << 8 ) + Data[4];


      if (command == 0) {
        moveRel(steps, 1, steps, 1);
      }
      if (command == 1) {
        moveRel(steps, 0, steps, 0);
      }
      if (command == 2) {
        moveRel(steps, 0, 0, 0);
      }
      if (command == 3) {
        moveRel(steps, 1, 0, 0);
      }
      if (command == 4) {
        moveRel(0, 0, steps, 0);
      }
      if (command == 5) {
        moveRel(0, 0, steps, 1);
      }

    } else if (Data[0] == 0x06) { // dynamixel write calibrate

      int cal = (((int)Data[1]) << 8 ) + Data[2];
      //int yValue = (((int)Data[3]) << 8 ) + Data[4];
      // todo: sanitycheck here
      calibratePos(cal);
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
  buffer[4] = Data & 0xFF;

  buffer[5] = (~(Data + ID + 1));

  // OK, do transmission now: //
  digitalWrite(SR, HIGH); // send data to HOST
  Serial.write(buffer, 6);
  Serial.flush(); // wait for buffer to empty
  digitalWrite(SR, LOW);
}


