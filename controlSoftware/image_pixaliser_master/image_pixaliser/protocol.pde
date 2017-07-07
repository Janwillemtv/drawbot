void sendPosition(int x, int y) {
  int zOffset = 700;//beginhoogte
  int xCenter = 1015;//het midden van de plotter
  int imageWidth = spacing*dotsWidth;
  int xOffset = xCenter-imageWidth/2;
  dynamixelWrite(10, 3, x+xOffset, (y)+zOffset);
  println("send Position: " + x + " " + y/2);
}


void sendRealPosition(int x, int y) {
  //int zOffset = 600;//beginhoogte
  //int xCenter = 1015;//het midden van de plotter
  //int imageWidth = spacing*dotsWidth;
  //int xOffset = xCenter-imageWidth/2;
  dynamixelWrite(10, 3, x, (y));
  println("send Position: " + x + " " + y/2);
}
void sendPositionRelative(int command, int steps) {
  dynamixelWrite(10, 4, command, steps);
  println("send Relative Position: " + command + " " + steps);

}

void sendCalibrate(int mm){
   dynamixelWrite(10, 6, mm, 0);
   println("send Calibrate");
}

void sendColor(int id) {
  int sendId = colorWheel.getColorWheelId(id);
  //int sendId = id;
  dynamixelWrite(20, 3, sendId, sendId);
  println("send colorID: " + sendId);
}

void testColor(int id) {
  //int sendId = colorWheel.getColorWheelId(id);
  //int sendId = id;
  dynamixelWrite(20, 3, id, id);
  println("send colorID: " + id);
}

int value[] = new int[36];
int diffValue[] = new int[6];
int scaling = 64;

int addressBuffer = 0; 
int dataLengthBuffer = 0; 
int checksumBuffer = 0;
int errorBuffer = 0;
int dataindex = 0;
int dataBuffer[] = new int[32];
int receivedbytes = 0;

int sendMessage;
String mode="RUN";
int n=21;
int slave = 0;


/******************************************************************
 * Dynamixel functions from here. 
 *
 ******************************************************************/
void dynamixelWrite(int id, int command, int valueX, int valueY) {
  byte x_hi = (byte)(valueX>>8);
  byte x_lo = (byte)(valueX & 0xFF);
  byte y_hi = (byte)(valueY>>8);
  byte y_lo = (byte)(valueY & 0xFF);
  // calculate checksum
  int checksum = ~(id + 0x06 + command + x_hi + x_lo + y_hi + y_lo);
  port.write(new byte[] {
    (byte)0xFF, (byte)0xFF, // Header
    (byte)id, 
    (byte)0x06, // Data length
    (byte)command, 
    (byte)x_hi, 
    (byte)x_lo, 
    (byte)y_hi, 
    (byte)y_lo, 
    (byte)checksum
    }
    );
}

void DynamixelWriteByte(int id, int address, int value) {
  // calculate checksum
  int checksum = ~(id + 0x05 + 0x03 + address + value);
  port.write(new byte[] {
    (byte)0xFF, (byte)0xFF, // Header
    (byte)id, 
    (byte)0x05, // Data length
    (byte)0x03, // Write command
    (byte)address, // Starting address (Dynamixel ram, goal velocity)
    (byte)value, 

    (byte)checksum
    }
    );
}




void serialEvent(int c) {
  //  print(c);
  try {
    switch(receivedbytes) {
    case 0:
      if (c==0xFF) receivedbytes=1;
      break;
    case 1:
      if (c==0xFF) receivedbytes=2;
      break;
    case 2:
      addressBuffer = c;
      checksumBuffer = c;
      //println(" "+checksumBuffer);
      receivedbytes=3;
      break;
    case 3:
      dataLengthBuffer = c;
      checksumBuffer+=c;
      //     println(dataLengthBuffer);
      //println(" "+checksumBuffer);
      receivedbytes = 4;
      break;
    case 4:
      errorBuffer = c;
      checksumBuffer += c;
      receivedbytes=5;
      //println(" "+checksumBuffer);
      break;
    case 5:
      checksumBuffer +=c;
      //println(" "+checksumBuffer);
      int checksum = checksumBuffer & 0xFF;
      println("Received message ID: " + addressBuffer + ", error: " + errorBuffer + ", checksum: " + checksum);
      
      if ((checksumBuffer &0xFF) == 0xFF) {

        println("ID: " + addressBuffer + ", returnmessage: " + errorBuffer);
        if(addressBuffer==10 && errorBuffer ==13) positionOK = true;
        else if(addressBuffer==20 && errorBuffer ==13) colorOK = true;
        else if(addressBuffer==10 && errorBuffer ==14) calibrationOK = true;
      }
receivedbytes = 0;
      break;
    default:
      break;
    }
  }
  catch(Exception e) {
    println("no valid data");
    receivedbytes = 0;
  }
}
void getValue(int ID)
{  
  int checksum = ~(ID + 0x05 + 0x02 + 0x24 + 12);
  port.write(new byte[] {
    (byte)0xFF, (byte)0xFF, // Header
    (byte)ID, 
    (byte)0x05, // Data length
    (byte)0x02, // Read command
    (byte)0x24, // Starting address (Dynamixel ram, goal position)
    (byte)12, 
    (byte)checksum
    }
    );
  //port.flush();
}