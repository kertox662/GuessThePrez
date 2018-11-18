import g4p_controls.*;
import java.awt.Font;


Candidate[] masterCandidates;
ArrayList<Candidate> currentCandidates;
ArrayList<Candidate> undoCandidateClipboard;
Question[] questions;

PImage[] portraits;
boolean playAgain = true;
String[] topRow; 

PImage cross;


boolean isLoading = true;
int loaded = 0, loadMax = 0;
String curLoadProcess = "Loading";

Question currentQuestion;

boolean showSelected = true;
String [] modes = {"American", "Canadian"};
String curMode = modes[0];

color[] usColors = {color(255, 0, 0), color(255), color(0, 0, 255)};
color[] canadaColors = { color(255, 0, 0), color(255)};
String title = "Guess The Prez!";
int curColor = 0;
int curTitleIndex = 0;
int animSpeed = 10;
boolean playAnim = true;

final int padX = 80, padY = 105;
final int xOff = 40, yOff = 98;



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
    undoCandidateClipboard = new ArrayList<Candidate>();


    fill(0);

    thread("loadData");
}

void draw() {
    if (isLoading) {

        drawLoading();
    } else {
        fill(0);
        textSize(10);
        textLeading(10);
        background(127);
        drawPortraits();

        if (showSelected)
            coverAffected(getHovered());

        drawTitle(width/2, 35);
    }
}

void reset() {
    setCurrentCandidates(masterCandidates);
    for (Question q: questions){
        q.resetQuestion();
    }
    
    
    
}

void drawPortraits() {
    for (int i=0; i<currentCandidates.size(); i++) {
        image(currentCandidates.get(i).portrait, i%8*padX+xOff, int(i/8)*padY+yOff);
        text(currentCandidates.get(i).name, i%8*padX+xOff - 30, int(i/8)*padY+yOff + 37, 60, 1000);
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
    questions = new Question[file[0].split(",").length - 1];

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
        questions[i-1] = new Question(topRow[i], answers);
        loaded++;
    }

    setCurrentCandidates(masterCandidates);

    portraits = loadPortraits(masterCandidates);

    currentQuestion = questions[0];
    createGUI();

    modeDropList.setItems(modes, 0);

    getNextQuestion();

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

void coverAffected(int toCover) {
    if (toCover == 0) return;
    boolean boolCover = (toCover == 1)?false:true;
    for (int i = 0; i < currentCandidates.size(); i++) {
        if (currentQuestion.answers.get(i) == boolCover)
            image(cross, i%8*padX+xOff, int(i/8)*padY+yOff);
    }
}

void drawTitle(int cX, int y) {
    textSize(30);
    if (animSpeed == 0 || !playAnim) {
        fill(usColors[0]);
        text(title, cX, y);
        return;
    }

    char[] titleChars = title.toCharArray();
    float x = cX - textWidth(title)/2;
    for (int i = 0; i < titleChars.length; i++) {
        if (i < curTitleIndex) {
            fill(usColors[(curColor + 1)%usColors.length]);
        } else {
            fill(usColors[curColor]);
        }
        text(str(titleChars[i]), x, y);
        x += textWidth(str(titleChars[i]));
    }


    if (title.charAt(curTitleIndex) == ' ')
        curTitleIndex++;

    if (curTitleIndex >= title.length() - 1) {
        curColor = ++curColor % usColors.length;
        curTitleIndex = 0;
    }
    if (frameCount%animSpeed == 0)
        curTitleIndex++;
}

void drawLoading() {
    background(255);
    fill(255);
    rect(100, height/2 - 25, width - 200, 50);
    fill(255, 0, 0);
    rect(100, height/2 - 25, (width - 200) * ((float)loaded / loadMax), 50);
    textSize(20);
    text("Loading, Please Wait...", width/2, height/2 - 50);
    textSize(12);
    text(curLoadProcess, width/2, height/2 + 50 );
}

void updateGuiQuestion() {
    questionLabel.setText("Question: " + currentQuestion.text);
}

int getHovered() {
    if (yesButton == null || noButton == null) return 0;
    if (yesButton.isOver(guiWin.mouseX, guiWin.mouseY))
        return 1;
    else if (noButton.isOver(guiWin.mouseX, guiWin.mouseY))
        return 2;
    else 
    return 0;
}
