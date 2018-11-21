import processing.sound.*;
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

PImage canadaFlag;
PImage usFlag;

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

    imageMode(CENTER);
    blendMode(REPLACE);
    resetFormatting();
    stroke(0);
    strokeWeight(2);

    currentCandidates = new ArrayList<Candidate>();
    undoCandidateClipboard = new ArrayList<Candidate>();

    thread("loadData");
}

void draw() {
    if (isLoading) {
        drawLoading();
    } else if (isAnswerFound()) {
        drawBackground();
        if (!isConfettiSet) {
            setupConfetti();
        }
        drawConfetti();
        displayLastCandidate();
        if (curMode.equals("American"))
            playSound(1);
        else
            playSound(2);
    } else {
        fill(0, 200, 0);
        textSize(10);
        textLeading(10);
        drawBackground();
        playSound(0);

        if (!isStarted) {
            drawTitle(width/2, height/2 - 50);
        } else {
            fill(0, 200, 0);
            textSize(10);
            textLeading(10);
            drawPortraits();

            if (showSelected)
                coverAffected(getHovered());

            drawTitle(width/2, 35);
        }
    }
}


//=====================================================================
//========================Drawing Procedures===========================
//=====================================================================

void drawPortraits() {
    try {
        resetFormatting();
        for (int i=0; i<currentCandidates.size(); i++) {
            if (textWidth(currentCandidates.get(i).name) > 180) {
            }
            image(currentCandidates.get(i).portrait, i%8*padX+xOff, int(i/8)*padY+yOff);
            text(currentCandidates.get(i).name, i%8*padX+xOff - 30, int(i/8)*padY+yOff + 37, 60, 300);
            println(i%8*padX+xOff - 30, int(i/8)*padY+yOff + 37);
        }
    }
    catch(IndexOutOfBoundsException e) {
    }
}

void displayLastCandidate() {
    Candidate c = currentCandidates.get(0);
    image(c.portraitL, width/2, height/2 + 50);
    fill(0, 180, 150);
    text("My Guess is: " + c.name, width/2, height/2 + c.portraitL.height/2 + 110);
}

void drawBackground() {
    if (curMode.equals("American")) {
        imageMode(CORNER);
        image(usFlag, 0, 0);
        imageMode(CENTER);
    } else {
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
    textSize(30);
    if (animSpeed == 0 || !playAnim) {
        fill(usColors[0]);
        text(title, cX, y);
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
    fill(0,255,0);

    isConfettiSet = false;

    undoCandidateClipboard.clear();
    resetFormatting();
    getNextQuestion();
}

void resetFormatting() {
    textAlign(CENTER);
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

    loadMax = 2*(fileUS.length + fileCan.length - 2)  + 37;

    curLoadProcess = "Loading - Misc Images";
    cross = loadImage("Images/cross.png");
    loaded++;
    usFlag = loadImage("Images/AmericanFlag.jpg");
    loaded++;
    canadaFlag = loadImage("Images/CanadianFlag.jpg");
    loaded++;

    sounds=new SoundFile[3];
    curLoadProcess = "Loading - Music - Background Music";
    sounds[0]=new SoundFile(this, "Music/naruto.mp3");
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
        curLoadProcess = "Loading - " +join(c[i].name.split(" "), "-")+".jpg";
        c[i].setPortrait(loadImage("Images/portraits/"+join(c[i].name.split(" "), "-")+".jpg"), false);
        c[i].portrait.resize(60, 75);
        loaded++;
        c[i].setPortrait(loadImage("Images/portraits/"+join(c[i].name.split(" "), "-")+".jpg"), true);
        c[i].portraitL.resize(180, 225);
        loaded++;
    }
}

void finishSetup() {
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
