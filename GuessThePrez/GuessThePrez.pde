import g4p_controls.*;
import java.awt.Font;

Candidate[] masterCandidates;
ArrayList<Candidate> currentCandidates;

Question[] questions;
PImage[] portraits;
PImage cross;

boolean playAgain = true;

Question currentQuestion;

void setup() {
    size(660, 750);
    
    imageMode(CENTER);
    textAlign(CENTER);
    blendMode(REPLACE);
    
    
    fill(0);
    
    loadData();
    portraits = loadPortraits(masterCandidates);
    createGUI();
}

void draw() {
    background(255);
    while(playAgain){
        drawPortraits();
    }
    
}

void drawPortraits() {
  for (int i=0; i<currentCandidates.size(); i++) {
    image(currentCandidates.get(i).portrait, i%8*80+40, int(i/8)*95+48);
    text(currentCandidates.get(i).name, i%8*80+40, int(i/8)*95+48);
  }
}

PImage[] loadPortraits(Candidate[] c) {
    PImage[] images = new PImage[c.length];
    for (int i = 0; i < images.length; i++) {
        c[i].setPortrait(loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg"));
        images[i] = loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg");
        images[i].resize(60, 75);
    }

    return images;
}

void loadData(){
    String[] file = loadStrings("President_Data.csv");
    
    masterCandidates = new Candidate[file.length-1];
    for (int i = 1; i < file.length; i++) {
        masterCandidates[i-1] = new Candidate(trim(file[i].split(","))[0]);
    }
    setCurrentCandidates(masterCandidates);
}

void setCurrentCandidates(Candidate[] candidates){
    currentCandidates.clear();
    for(Candidate c: candidates)
        currentCandidates.add(c);
}

void coverAffected(int toCover){
    if(toCover == 0) return;
    boolean boolCover = (toCover == 1)?false:true;
    for(int i = 0; i < currentCandidates.size(); i++){
        if(currentQuestion.answers.get(i) == boolCover)
            image(cross, i%8*80+40, int(i/8)*95+48);
    }
}
