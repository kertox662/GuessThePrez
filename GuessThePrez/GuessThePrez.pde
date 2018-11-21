import processing.sound.*; //<>// //<>//
import g4p_controls.*;
import java.awt.Font;


//=====================================================================
//===========================Variables=================================
//=====================================================================
Candidate[] masterCandidatesUS;
Candidate[] masterCandidatesCan;
Question[] questionsUS;
Question[] questionsCan;
ArrayList<Candidate> currentCandidates;
ArrayList<Candidate> undoCandidateClipboard;

SoundFile[] sounds;

PImage[] portraits;
boolean playAgain = true;

PImage cross;

color blackAlpha = color(0, 100);

PImage canadaFlag;
PImage usFlag;
PImage ovalOffice;
PImage pmOffice;

boolean isLoading = true;
boolean isStarted = false;
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

//=====================================================================
//===================Functions and Procedures==========================
//=====================================================================

void setup() {
    size(660, 750);
    textAlign(CENTER);
    imageMode(CENTER);
    //blendMode(REPLACE);
    stroke(0);
    strokeWeight(2);

    currentCandidates = new ArrayList<Candidate>();
    undoCandidateClipboard = new ArrayList<Candidate>();

    thread("loadData");
}

void draw() {
    if (isLoading) 
        drawLoading();
    else if (isAnswerFound()) {
        drawFinal();
        questionLabel.setText("Press Restart to Play Again");
        previousButton.setVisible(false);
    } else {
        drawRegular();
        if (currentQuestion != null)
            updateGuiQuestion();
    }
}


//=====================================================================
//========================Drawing Procedures===========================
//=====================================================================

void drawPortraits() {
    try {
        resetFormatting();
        for (int i=0; i<currentCandidates.size(); i++) {
            fill(0, 127, 127);
            image(currentCandidates.get(i).portrait, i%8*padX+xOff, int(i/8)*padY+yOff);
            if (textWidth(currentCandidates.get(i).name) > 120) { 
                textSize(8); 
                textLeading(8);
            }
            text(currentCandidates.get(i).name, i%8*padX+xOff, int(i/8)*padY+yOff + 87, 60, 100);
            resetFormatting();
        }
    }
    catch(IndexOutOfBoundsException e) {
    }
}

void drawRegular() {
    fill(0, 200, 0);
    textSize(10);
    textLeading(10);
    drawBackground();
    playSound(0);

    if (!isStarted) {
        drawTitle(width/2, height/2 - 50);
    } else {
        fill(0, 200, 0);
        resetFormatting();
        drawPortraits();

        if (showSelected)
            coverAffected(getHovered());

        drawTitle(width/2, 35);

        if (undoCandidateClipboard.size() == 0 || isAnswerFound())
            previousButton.setVisible(false);
        else
            previousButton.setVisible(true);
    }
}

void drawFinal() {
    drawBackground();
    if (!isConfettiSet) {
        setupConfetti();
    }
    drawConfetti();
    float boxWidth = max(textWidth("My Guess is: " + currentCandidates.get(0).name), textWidth(title) + 20);
    fill(blackAlpha);
    if(curMode.equals("Canadian"))
        rect(width/2, height/2 + 45, boxWidth + 20,300);
    drawTitle(width/2, height/2 - 80);
    textSize(20);
    displayLastCandidate();
    if (curMode.equals("American"))
        playSound(1);
    else
        playSound(2);
}

void displayLastCandidate() {
    Candidate c = currentCandidates.get(0);
    image(c.portraitL, width/2, height/2 + 50);
    //fill(0, 180, 150);
    fill(255);
    text("My Guess is: " + c.name, width/2, height/2 + c.portraitL.height/2 + 60);
}

void drawBackground() {
    if (curMode.equals("American")) {
        if (isAnswerFound())
            image(ovalOffice, width/2, height/2);
        else {
            imageMode(CORNER);
            image(usFlag, 0, 0);
            imageMode(CENTER);
        }
    } else {
        if (isAnswerFound())
            image(pmOffice, width/2, height/2);
        else
            image(canadaFlag, width/2, height/2);
    }
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

void drawTitle(int cX, int y) {
    textAlign(CENTER);
    textSize(30);
    fill(blackAlpha);
    if((curMode.equals("Canadian") && !isAnswerFound()) || !isStarted)
        rect(cX,y - 10,textWidth(title) + 10, 32);
    if (animSpeed == 0 || !playAnim || isAnswerFound()) {
        fill(usColors[0]);
        text(title, cX, y);
        resetFormatting();
        return;
    }

    color[] colorArray = curMode.equals("American")?usColors:canadaColors;

    char[] titleChars = title.toCharArray();
    float x = cX - textWidth(title)/2 + textWidth(title.charAt(0))/2;
    for (int i = 0; i < titleChars.length; i++) {
        if (i < curTitleIndex) {
            fill(colorArray[(curColor + 1)%colorArray.length]);
        } else {
            fill(colorArray[curColor%colorArray.length]);
        }
        text(str(titleChars[i]), x, y);
        x += (textWidth(str(titleChars[i])) + textWidth(str(titleChars[(i+1)%title.length()]))) / 2  ;
    }


    if (title.charAt(curTitleIndex%title.length()) == ' ')
        curTitleIndex++;

    if (curTitleIndex >= title.length() - 1) {
        curColor = ++curColor % colorArray.length;
        curTitleIndex = 0;
    }
    if ((frameCount%((animSpeed != 0)?animSpeed:1)) == 0)
        curTitleIndex++;
    resetFormatting();
}

void updateGuiQuestion() {
    questionLabel.setText("Question: " + currentQuestion.text);
}

void coverAffected(int toCover) {
    if (toCover == 0) return;
    boolean boolCover = (toCover == 1)?false:true;
    for (int i = 0; i < currentCandidates.size(); i++) {
        if (currentQuestion.answers.get(i) == boolCover)
            image(cross, i%8*padX+xOff, int(i/8)*padY+yOff);
    }
}



//=====================================================================
//=========================Reset Procedures============================
//=====================================================================
void reset() {    
    if (curMode.equals("American"))
        setCurrentCandidates(masterCandidatesUS);
    else
        setCurrentCandidates(masterCandidatesCan);

    for (Question q : questionsUS) {
        q.resetQuestion();
    }
    for (Question q : questionsCan) {
        q.resetQuestion();
    }

    curColor = 0;
    curTitleIndex = 0;
    fill(0, 255, 0);

    isConfettiSet = false;

    undoCandidateClipboard.clear();
    resetFormatting();
    getNextQuestion();
}

void resetFormatting() {
    textAlign(CENTER, TOP);
    textSize(10);
    textLeading(10);
}


//=====================================================================
//============================Data Loading=============================
//=====================================================================

void loadData() {
    String[] fileUS = loadStrings("President_Data.csv");
    String[] fileCan = loadStrings("Minister_Data.csv");

    for (int i = 0; i < fileUS.length; i++) {
        fileUS[i] = trim(fileUS[i]);
    }

    for (int i = 0; i < fileCan.length; i++) {
        fileCan[i] = trim(fileCan[i]);
    }


    String[] topRowUS = fileUS[0].split(",");
    String[] topRowCan = fileCan[0].split(",");

    loadMax = 2*(fileUS.length + fileCan.length - 2)  + 39;

    curLoadProcess = "Loading - Misc Images";
    cross = loadImage("Images/cross.png");
    loaded++;
    usFlag = loadImage("Images/AmericanFlag2.jpg");
    loaded++;
    canadaFlag = loadImage("Images/CanadianFlag.jpg");
    loaded++;
    ovalOffice = loadImage("Images/ovalOffice.jpg");
    ovalOffice.resize(width, height);
    loaded++;
    pmOffice = loadImage("Images/pmOffice.jpg");
    pmOffice.resize(width, height);
    loaded++;

    sounds=new SoundFile[3];
    curLoadProcess = "Loading - Music - Background Music";
    sounds[0]=new SoundFile(this, "Music/Background.mp3");
    loaded+=14;

    curLoadProcess = "Loading - Music - USanthem.mp3";
    sounds[1]=new SoundFile(this, "Music/USanthem.mp3");
    loaded+=8;

    curLoadProcess = "Loading - Music - CanadaAnthem.mp3";
    sounds[2]=new SoundFile(this, "Music/CanadaAnthem.mp3");
    loaded+=8;

    masterCandidatesUS = new Candidate[fileUS.length-1];
    questionsUS = new Question[topRowUS.length - 1];

    masterCandidatesCan = new Candidate[fileCan.length-1];
    questionsCan = new Question[topRowCan.length - 1];

    curLoadProcess = "Loading - Candidates";
    for (int i = 1; i < fileUS.length; i++) {
        masterCandidatesUS[i-1] = new Candidate(fileUS[i].split(",")[0]);
    }
    loaded++;

    for (int i = 1; i < fileCan.length; i++) {
        masterCandidatesCan[i-1] = new Candidate(fileCan[i].split(",")[0]);
    }
    loaded++;

    curLoadProcess = "Loading - Questions";
    for (int i = 1; i < topRowUS.length; i++) {
        ArrayList<Boolean> answers = new ArrayList<Boolean>();
        for (int j = 1; j < fileUS.length; j++) {
            answers.add(boolean(fileUS[j].split(",")[i]));
        }
        questionsUS[i-1] = new Question(topRowUS[i], answers);
    }
    loaded++;

    for (int i = 1; i < topRowCan.length; i++) {
        ArrayList<Boolean> answers = new ArrayList<Boolean>();
        for (int j = 1; j < fileCan.length; j++) {
            answers.add(boolean(fileCan[j].split(",")[i]));
        }
        questionsCan[i-1] = new Question(topRowCan[i], answers);
    }
    loaded++;

    setCurrentCandidates(masterCandidatesUS);

    loadPortraits(masterCandidatesUS);
    loadPortraits(masterCandidatesCan);

    finishSetup();
}

void loadPortraits(Candidate[] c) {
    for (int i = 0; i < c.length; i++) {
        curLoadProcess = "Loading - Image - " +join(c[i].name.split(" "), "-")+".jpg";
        c[i].setPortrait(loadImage("Images/portraits/"+join(c[i].name.split(" "), "-")+".jpg"), false);
        c[i].portrait.resize(60, 75);
        loaded++;
        c[i].setPortrait(loadImage("Images/portraits/"+join(c[i].name.split(" "), "-")+".jpg"), true);
        c[i].portraitL.resize(180, 225);
        loaded++;
    }
}

void finishSetup() {
    resetFormatting();
    rectMode(CENTER);
    isLoading = false;
    startButton = new GButton(this, width/2 - 30, height/2 - 30, 60, 30);
    startButton.addEventHandler(this, "startGame");
    startButton.setText("Start");
}


//=====================================================================
//======================Miscellaneous=========================
//=====================================================================

void keyPressed() {
    if (key == ESC)
        exit();
}


void playSound(int i) {
    if (!sounds[i].isPlaying()) {
        for (SoundFile s : sounds)
            s.stop();
        sounds[i].loop();
    }
}

void startGame(GButton source, GEvent e) {
    source.dispose();
    createGUI();
    modeDropList.setItems(modes, 0);
    getNextQuestion();
    isStarted = true;
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
