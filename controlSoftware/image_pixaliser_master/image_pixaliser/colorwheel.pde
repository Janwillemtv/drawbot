class ColorWheel{
int nrSpots;
PVector[] mapping;
color[] spots;
ColorWheel(int nrSpots){ //has to be an even number
this.nrSpots = nrSpots;
if(nrSpots%2!=0) nrSpots = 8;
mapping = new PVector[nrSpots]; //first value the id of the can, second value the colorID
for(int i = 0; i<mapping.length; i++){
  mapping[i] = new PVector(i,0);
}
spots = new color[nrSpots];
}

void configure(){
  //-1 means empty
  int nrColors = colors.size();
  int colorIt = 0;
  if(nrColors <= nrSpots){
    int number = floor(nrSpots/2);
    
    for(int i = 0; i<number; i++){
      if(colorIt +2<=nrColors){
      PVector temp = colors.get(colorIt);
      spots[i] = color(temp.x,temp.y,temp.z);
      mapping[i].y = colorIt;
      colorIt++;
      
      temp = colors.get(colorIt);
      spots[i+number] = color(temp.x,temp.y,temp.z);
      mapping[i+number].y = colorIt;
      colorIt++;
      }else if(colorIt +1<=nrColors){
   
        PVector temp = colors.get(colorIt);
        spots[i] = color(temp.x,temp.y,temp.z);
        mapping[i].y = colorIt;
        colorIt++;
        
        spots[i+number] = -1;
        mapping[i+number].y = -1;
    
      }else{
        spots[i] = -1;
        mapping[i].y = -1;
        
        spots[i+number] = -1;
        mapping[i+number].y = -1;
      }
      
      
    }
    
    
  }else{
    //error does not fit
  }
  
  
}

void drawColorWheel(int x, int y,int size){
  stroke(255);
  strokeWeight(1);
  int offset = 20;
  fill(155, 108, 27);
  ellipse(x,y,size,size);
  for(int i = 0; i<spots.length; i++){
  pushMatrix();
  translate(x,y);
  rotate((2*PI/spots.length*i)+0.5*PI);
  if(spots[i] == -1){
    fill(255,0,0);
    rect(size/4,-size/16,size/8,size/8);
  }else{
    fill(spots[i]);
    ellipse(size/3,0,size/4,size/4);
  }
  
  popMatrix();
  }
  
}

int getColorWheelId(int id){
  int returnNumber = 0;
  for(int i = 0; i<mapping.length; i++){
    if(mapping[i].y==id) {
      returnNumber = (int)mapping[i].x;
      break;
    }else{ 
    
  }

  }
  return returnNumber;
}

}