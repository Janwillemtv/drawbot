class Cursor{
  int x,y,size;
  Cursor(){
  x = 0;
  y = 0;
  size = 10;
  }
  
  void drawCursor(){
    stroke(color(255,0,0));
    strokeWeight(4);
    noFill();
    
    ellipse(x/visualFix+visualOffset,y/visualFix+visualOffset,size,size);
  
  }
  
  void setPosition(int X, int Y){
    x = X;
    y = Y;
  }
  
  
}