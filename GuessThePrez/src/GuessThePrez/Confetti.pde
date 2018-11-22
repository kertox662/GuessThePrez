boolean isConfettiSet = false;

int numConfetti = 400; //Amount and sizes of confetti
int confettiW = 7;
int confettiL = 12;

int[] xConfetti = new int [numConfetti]; //Stores position and rotation of confetti
int[] yConfetti = new int [numConfetti];
float[] rotate = new float[numConfetti];

color red = color(255, 0, 0);
color white = color(255);
color blue = color(0, 0, 130);

color[] fills = new color [numConfetti]; //The fills of each confetti

color[] colors = {red, white, blue};



void setupConfetti() {
  int domain;
  
  if (curMode.equals("American"))
    domain = 3; //3 colors for american
    
  else
    domain = 2; //2 colors for canadian
  
  for(int i = 0; i < numConfetti; i ++){  
    int x = int(random(0, width - max(confettiL, confettiW))); //starts of with random x, y, and rotation
    int y = int(random(0, height - max(confettiL, confettiW)));
    float radians = random(-0.2, 0.2);
    
    xConfetti[i] = x;
    yConfetti[i] = y;
    rotate[i] = radians;
    
    int index = int(random(0, domain));
    
    fills[i] = colors[index];
  }
  
  isConfettiSet = true;
}

  
void drawConfetti(){
  for (int i = 0; i < numConfetti; i ++){
    fill(fills[i]);
    pushMatrix(); //Each one is drawn with the origin moved because the rotation happens around the origin
        translate(xConfetti[i], yConfetti[i]);
        rotate(rotate[i]);
        rect(0, 0, confettiW, confettiL);
    popMatrix();
    
    int deltaY = int(random(1, 3)); //falls a random amount
    float deltaRotation = random(-0.1, 0.1); //Rotates a random amound
    rotate[i] += deltaRotation;
    
    yConfetti[i] += deltaY;
    
    if(yConfetti[i] - min(confettiW, confettiL) > height)
      yConfetti[i] = 0;
  }
}