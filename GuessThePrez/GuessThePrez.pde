import g4p_controls.*;
import java.awt.Font;

Candidate[] masterCandidates;
ArrayList<Candidate> currentCandidates;

Question[] masterQuestions;
PImage[] portraits;
PImage cross;

boolean playAgain = true;

Question currentQuestion;

void setup() {
    size(660, 750);
    
    imageMode(CENTER);
    blendMode(REPLACE);
    textAlign(CENTER);
    textSize(10);
    textLeading(10);
    
    currentCandidates = new ArrayList<Candidate>();
    
    fill(0);
    
    loadData();
    portraits = loadPortraits(masterCandidates);
    
    createGUI();
}

void draw() {
    background(255);
    drawPortraits();
    
    if(!playAgain){
        noLoop();
    }
}

void drawPortraits() {
  for (int i=0; i<currentCandidates.size(); i++) {
    image(currentCandidates.get(i).portrait, i%8*80+40, int(i/8)*105+48);
    text(currentCandidates.get(i).name, i%8*80+10, int(i/8)*105+85, 60, 1000);
  }
}

PImage[] loadPortraits(Candidate[] c) {
    PImage[] images = new PImage[c.length];
    for (int i = 0; i < images.length; i++) {
        c[i].setPortrait(loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg"));
        c[i].portrait.resize(60, 75);
        images[i] = loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg");
        images[i].resize(60, 75);
    }

    return images;
}

void loadData(){
    String[] file = loadStrings("President_Data.csv");
    for(int i = 0; i < file.length; i++){
        file[i] = trim(file[i]);
    }
    
    masterCandidates = new Candidate[file.length-1];
    masterQuestions = new Question[file[0].split(",").length - 1];
    
    for (int i = 1; i < file.length; i++) {
        masterCandidates[i-1] = new Candidate(file[i].split(",")[0]);
    }
    
    String[] topRow = file[0].split(",");
    for(int i = 1; i < topRow.length; i++){
        ArrayList<Boolean> answers = new ArrayList<Boolean>();
        for(int j = 1; j < masterCandidates.length; j++){
            answers.add(boolean(file[j].split(",")[i]));
        }
        masterQuestions[i-1] = new Question(topRow[i], answers);
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
