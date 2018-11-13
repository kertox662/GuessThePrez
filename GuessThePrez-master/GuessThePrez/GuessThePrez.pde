import g4p_controls.*;

Candidate[] candidates;
PImage[] portraits;
boolean playAgain;
Question[] questions;
String[] topRow;

int temp = 0;

void setup() {
    size(600, 600);
    imageMode(CENTER);
    playAgain=true;
    loadData();
    portraits = loadPortraits(candidates);  
    
    while (playAgain) {
      
      
    }


}

void draw() {
    background(255);
    image(portraits[temp], width/2, height/2);
}

void loadData(){
    String[] file = loadStrings("President_Data.csv");
    topRow= new String[file[0].split(",").length];
    candidates = new Candidate[file.length-1];
    for (int i = 1; i < file.length; i++) {
        candidates[i-1] = new Candidate(file[i].split(",")[0]);
    }
    questions= new Question[file[0].split(",").length-1];
    for (int i = 1; i<topRow.length; i++){
      questions[i-1]= new Question(topRow[i]);
    }
}
        
void keyPressed() {
    if (keyCode == RIGHT)
        temp = ++temp % portraits.length;
    else if (keyCode == LEFT) {
        temp--;
        if(temp < 0)
            temp = portraits.length-1;
    }
}

void getHoveredButton() {
  
} 

PImage[] loadPortraits(Candidate[] c) {
    PImage[] images = new PImage[c.length];
    for (int i = 0; i < images.length; i++) {
        images[i] = loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg");
        images[i].resize(100, 128);
    }

    return images;
}
