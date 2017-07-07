class Dot{
  int x,y;
  color c;
  int colorId;
  int size = 0;
  int spacing = 1;
  
  ArrayList<Dot> trail = new ArrayList<Dot>();
  Dot(int x, int y, color c, int cId, int trailLength){
    
    this.x = x;
    this.y = y;
    this.c = c;
    this.colorId = cId;
    if(trailLength != 0) createTrail(trailLength);
  }
  
  void createTrail(int trailLength){
    int offSet = (int)random(-2,2);
    for(int i = 0; i < trailLength; i++){
      
      trail.add(new Dot(offSet,(i*spacing),c,0,0));
    }
  }
  
  void increase(){
    size +=1;
  }
  
  void drawDot(){
    
  
    fill(c);
    noStroke();
    for(int i = trail.size()-1; i > 0; i--){
      int tempSize = size - i;
      if(tempSize < 3) tempSize = 2;
      pushMatrix();
      translate(x/visualFix+visualOffset,y/visualFix+visualOffset);
      ellipse(trail.get(i).x,trail.get(i).y,tempSize,tempSize);
      popMatrix();
    }
      ellipse(x/visualFix+visualOffset,y/visualFix+visualOffset,size,size);
  }
  
  int getX(){
    return x;
  }
  
  int getY(){
    return y;
  }
  
  int getColorId(){
    return colorId;
  }
  
}