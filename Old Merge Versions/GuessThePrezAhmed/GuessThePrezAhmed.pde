import g4p_controls.*;
import java.awt.Font;

Candidate[] masterCandidates;
ArrayList<Candidate> currentCandidates;

Question[] masterQuestions;

PImage[] portraits;
PImage cross;

boolean isLoading = true;
int loaded = 0, loadMax = 0;
String curLoadProcess = "Loading";

boolean playAgain = true;

Question currentQuestion;

void setup() {
    size(660, 750);

    imageMode(CENTER);
    blendMode(REPLACE);
    textAlign(CENTER);
    textSize(10);
    textLeading(10);
    stroke(0);
    strokeWeight(2);

    currentCandidates = new ArrayList<Candidate>();

    fill(0);

    thread("loadData");
    createGUI();
}

void draw() {

    if (isLoading) {
        background(255);
        fill(255);
        rect(100, height/2 - 25, width - 200, 50);
        fill(255, 0, 0);
        rect(100, height/2 - 25, (width - 200) * ((float)loaded / loadMax), 50);
        textSize(20);
        text("Loading, Please Wait...", width/2, height/2 - 50);
        textSize(12);
        text(curLoadProcess, width/2, height/2 + 50 );
    } else {
        fill(0);
        textSize(10);
        textLeading(10);
        
        background(255);
        drawPortraits();

        coverAffected(2);
        
        if (!playAgain) {
            noLoop();
        }
    }
}

void drawPortraits() {
    for (int i=0; i<currentCandidates.size(); i++) {
        image(currentCandidates.get(i).portrait, i%8*80+40, int(i/8)*105+48);
        text(currentCandidates.get(i).name, i%8*80+10, int(i/8)*105+85, 60, 1000);
    }
}




void loadData() {
    String[] file = loadStrings("President_Data.csv");
    for (int i = 0; i < file.length; i++) {
        file[i] = trim(file[i]);
    }

    String[] topRow = file[0].split(",");

    loadMax = 3*(file.length - 1) + topRow.length;

    curLoadProcess = "Loading - cross.png";
    cross = loadImage("cross.png");
    loaded++;

    masterCandidates = new Candidate[file.length-1];
    masterQuestions = new Question[file[0].split(",").length - 1];

    curLoadProcess = "Loading - Candidates";
    for (int i = 1; i < file.length; i++) {
        masterCandidates[i-1] = new Candidate(file[i].split(",")[0]);
        loaded++;
    }

    curLoadProcess = "Loading - Questions";
    for (int i = 1; i < topRow.length; i++) {
        ArrayList<Boolean> answers = new ArrayList<Boolean>();
        for (int j = 1; j < file.length; j++) {
            answers.add(boolean(file[j].split(",")[i]));
        }
        masterQuestions[i-1] = new Question(topRow[i], answers);
        loaded++;
    }

    setCurrentCandidates(masterCandidates);

    portraits = loadPortraits(masterCandidates);

    currentQuestion = masterQuestions[0];
    
    isLoading = false;
}

PImage[] loadPortraits(Candidate[] c) {
    PImage[] images = new PImage[c.length];
    for (int i = 0; i < images.length; i++) {
        curLoadProcess = "Loading - " +join(c[i].name.split(" "), "-")+".jpg";
        c[i].setPortrait(loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg"));
        c[i].portrait.resize(60, 75);
        loaded++;
        images[i] = loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg");
        images[i].resize(60, 75);
        loaded++;
    }

    return images;
}



void setCurrentCandidates(Candidate[] candidates) {
    currentCandidates.clear();
    for (Candidate c : candidates)
        currentCandidates.add(c);
}

void coverAffected(int toCover) {
    if (toCover == 0) return;
    boolean boolCover = (toCover == 1)?false:true;
    for (int i = 0; i < currentCandidates.size(); i++) {
        if (currentQuestion.answers.get(i) == boolCover)
            image(cross, i%8*80+40, int(i/8)*105+48);
    }
}
