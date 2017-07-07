private PImage decreasePixels(PImage image, int w, int h) {
  PImage returnImage;
  returnImage = createImage(w, h, RGB);
  returnImage.loadPixels();
  image.loadPixels();
  int iW = image.width;
  int iH = image.height;
 
  
  for (int i = 0; i <w*h; i++) {
    int r = 0;
    int g = 0;
    int b = 0;
    for (int j = 0; j <(iH/h); j++) {
      for (int k = 0; k<(iW/w); k++) {
        color c = image.pixels[k+((iW/w)*(i%w))+((j*iW)+(iW*(iH/h)*floor(i/w)))];
        r += red(c);
        g += green(c);
        b += blue(c);
      }
    }
    int numberValues = (iH/h)*(iW/w);
    r = r/numberValues;
    g = g/numberValues;
    b = b/numberValues;
    color cOut = color(r, g, b);
    
    if(colors.size() != 0){
   
    int id =getColorId(r,g,b);
  
   
      //int alterHue = hues[idx];
    cOut = color(colors.get(id).x,colors.get(id).y,colors.get(id).z);
    }
    
    returnImage.pixels[i] = cOut;
  }
  returnImage.updatePixels();



  return returnImage;
}



int getColorId(int r, int g, int b){
   int difference = 1000000000;
    int id = 0;
  for(int c = 0; c < colors.size(); c++){
     float tempDiff = abs(r-colors.get(c).x)+abs(g-colors.get(c).y)+abs(b-colors.get(c).z);
     if(tempDiff<difference){
       difference = (int)tempDiff;
       id = c;
     }
  }
  return id;
}


private void addDots(PImage image) {
  dots.clear();
  int offSet =0;
  image.loadPixels();

    for (int i = 0; i < image.height; i++) {
      for (int j = 0; j < image.width; j++) {
        //println(j + " " + i);
        //color c = img.get(j,i);
        //color x = image.pixels[(i*image.width)+j];
        // println(red(x) + " " + green(x) + " " + blue(x));
        color c = image.get(j, i);
        Dot temp = new Dot(j*spacing+offSet, i*spacing+offSet, c ,
        getColorId((int)red(c),(int)green(c),(int)blue(c)),(int)random(1,trailLength));

        dots.add(temp);
        for (int k = 0; k<=dotSize; k++) {
          temp.increase();
          temp.drawDot();
        }
      }
    }
   
}

private void drawDots(){
  for(Dot dot : dots){
    dot.drawDot();
  }
}

private void drawPallet(){
  
  for(int i = 0; i < colors.size(); i++){
    
    color c = color(colors.get(i).x,colors.get(i).y,colors.get(i).z);
    fill(c);
    rect((600/colors.size())*i,650,600/colors.size(),50);
    
  }
}


private void extractColorFromImage(PImage image, PImage referenceImg) {
  colors.clear();
  image.filter(POSTERIZE, floor(colorNumber/3));
  image.loadPixels();
  referenceImg.loadPixels();
  int numberOfPixels = image.pixels.length;
  HashMap<PVector, PVector> hmColor = new HashMap<PVector, PVector>();
  HashMap<PVector, Integer> hmNumber = new HashMap<PVector, Integer>();
  

  for (int i = 0; i < numberOfPixels; i++) {
    int pixel = image.pixels[i];
    int refPixel = referenceImg.pixels[i];
    
    PVector temp = new PVector((int)red(pixel),(int)green(pixel),(int)blue(pixel));
    if(hmColor.containsKey(temp)){
      PVector cE = new PVector((int)red(refPixel),(int)green(refPixel),(int)blue(refPixel));
      hmColor.put(temp, hmColor.get(temp).add(cE));
      hmNumber.put(temp, hmNumber.get(temp) +1);
    }else{
      PVector c = new PVector((int)red(refPixel),(int)green(refPixel),(int)blue(refPixel));
      hmColor.put(temp, c);
      hmNumber.put(temp, 1);
    }
  }
  
  
  

  //
  //println(hues);

  for(Map.Entry me : hmColor.entrySet()){
    //println(me.getKey() + " is ");
    //println(me.getValue());
    int number = hmNumber.get(me.getKey());
    //println(number);
    PVector temp = (PVector)me.getValue();
    temp.div(number);
    //println(temp);
    colors.add(temp);
  }
  
   //println(colors);
  
  //println(hm);
  //int difference = 1;
  //int[] colors = new int[colorNumber];
  //ArrayList<Integer> skipList = new ArrayList<Integer>();
 
  //for(int c = 0; c < colorNumber; c++){
  //  int count = 0;
  //  int out = 0;
  //  for(int i = 0; i <360; i++){
  //    if(hues[i]>count && !skipList.contains(i)){
        
  //        count = hues[i];
  //        out = i;
        
       
  //    }
  //  }
  //  colors[c] = out;
  //  for(int j = 0; j < 2*difference; j++){
  //    skipList.add(j+(out-difference));
  //  }
  //}
  //colors = sort(colors);
  ////println(hues[245] + " " + hues[224] + " " + hues[223]);
  //int[] huesSort = reverse(sort(hues));
  
  //int[] colors2 = new int[colorNumber];
  //for (int c = 0; c<360; c++) {
  //  int temp = hm.get(c);
  //  for (int n = 0; n < colorNumber; n++) {
  //    if (temp == huesSort[n]) {
        
  //      colors2[n] = c;
  //      break;
  //    }
  //  }
  //}
  //colors2 = sort(colors2);
  
  //println(colors);
  //println(colors2);
  //colorMode(HSB, 359);
  //replaceImg.loadPixels();
  //for (int y = 0; y<replaceImg.height; y++) {
  //  for (int x = 0; x<replaceImg.width; x++) {
  //    int pixel = replaceImg.pixels[x + (y*replaceImg.width)];
  //    int hue = Math.round(hue(pixel));


  //    int distance = Math.abs(colors[0] - hue);
  //    int idx = 0;
  //    for (int c = 1; c < colors.length; c++) {
  //      int cdistance = Math.abs(colors[c] - hue);
  //      if (cdistance < distance) {
  //        idx = c;
  //        distance = cdistance;
  //      }
  //    }
  //    int alterHue = colors[idx];
  //    float alterSat = saturations[alterHue] / hues[alterHue];
  //    float alterBright = brightnesses[alterHue] / hues[alterHue];
  //    //println(alterHue + " " + alterSat + " " + alterBright);
      
      
  //    color alterColor = color(alterHue,alterSat,alterBright);
  //    replaceImg.pixels[x + (y*replaceImg.width)] = alterColor;
      
    
      
      
      
  //  }
  //}
  //colorMode(RGB, 255);

  // Find the most common hue.
  //int hueCount = hues[0];
  //int hue = 0;
  //for (int i = 1; i < hues.length; i++) {
  //  if (hues[i] > hueCount) {
  //    hueCount = hues[i];
  ////    hue = i;
  ////  }
  ////}

  //// Set the vars for displaying the color.
  //this.hue = hue;
  //saturation = saturations[hue] / hueCount;
  //brightness = brightnesses[hue] / hueCount;
  
  
}