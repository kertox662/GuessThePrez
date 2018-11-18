import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import g4p_controls.*; 
import java.awt.Font; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GuessThePrez extends PApplet {





Candidate[] masterCandidatesUS;
Candidate[] masterCandidatesCan;
Question[] questionsUS;
Question[] questionsCan;
ArrayList<Candidate> currentCandidates;
ArrayList<Candidate> undoCandidateClipboard;


PImage[] portraits;
boolean playAgain = true;

PImage cross;

PImage canadaFlag;
PImage usFlag;

boolean isLoading = true;
boolean hasStarted = false;
int loaded = 0, loadMax = 0;
String curLoadProcess = "Loading";

Question currentQuestion;

boolean showSelected = true;
String [] modes = {"American", "Canadian"};
String curMode = modes[0];

int[] usColors = {color(255, 0, 0), color(255), color(0, 0, 255)};
int[] canadaColors = { color(255, 0, 0), color(255)};
String title = "Guess The Prez!";
int curColor = 0;
int curTitleIndex = 0;
int animSpeed = 10;
boolean playAnim = true;

final int padX = 80, padY = 105;
final int xOff = 40, yOff = 98;



public void setup() {
    
    
    imageMode(CENTER);
    blendMode(REPLACE);
    resetFormating();
    stroke(0);
    strokeWeight(2);

    currentCandidates = new ArrayList<Candidate>();
    undoCandidateClipboard = new ArrayList<Candidate>();

    thread("loadData");
}

public void draw() {
    if (isLoading) {

        drawLoading();
    } else {
        fill(0, 200, 0);
        textSize(10);
        textLeading(10);
        //background(127);
        drawBackground();
        drawPortraits();

        if (showSelected)
            coverAffected(getHovered());

        drawTitle(width/2, 35);
    }
}

public void drawPortraits() {
    try {
        for (int i=0; i<currentCandidates.size(); i++) {
            if(textWidth(currentCandidates.get(i).name) > 180){
                
            }
            image(currentCandidates.get(i).portrait, i%8*padX+xOff, PApplet.parseInt(i/8)*padY+yOff);
            text(currentCandidates.get(i).name, i%8*padX+xOff - 30, PApplet.parseInt(i/8)*padY+yOff + 37, 60, 1000);
        }
    }
    catch(IndexOutOfBoundsException e) {
    }
}

public void drawBackground() {
    if (curMode.equals("American")) {
        imageMode(CORNER);
        image(usFlag, 0, 0);
        imageMode(CENTER);
    } else {
        image(canadaFlag, width/2, height/2);
    }
}


public void reset() {
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
    
    getNextQuestion();
}

public void resetFormating(){
    textAlign(CENTER);
    textSize(10);
    textLeading(10);
}


public void loadData() {
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

    loadMax = 3*(fileUS.length + fileCan.length - 2) + topRowUS.length + topRowCan.length + 1;

    curLoadProcess = "Loading - Misc Images";
    cross = loadImage("cross.png");
    loaded++;
    usFlag = loadImage("AmericanFlag.jpg");
    loaded++;
    canadaFlag = loadImage("CanadianFlag.jpg");
    loaded++;

    masterCandidatesUS = new Candidate[fileUS.length-1];
    questionsUS = new Question[topRowUS.length - 1];

    masterCandidatesCan = new Candidate[fileCan.length-1];
    questionsCan = new Question[topRowCan.length - 1];

    curLoadProcess = "Loading - Candidates";
    for (int i = 1; i < fileUS.length; i++) {
        masterCandidatesUS[i-1] = new Candidate(fileUS[i].split(",")[0]);
        loaded++;
    }

    for (int i = 1; i < fileCan.length; i++) {
        masterCandidatesCan[i-1] = new Candidate(fileCan[i].split(",")[0]);
        loaded++;
    }

    curLoadProcess = "Loading - Questions";
    for (int i = 1; i < topRowUS.length; i++) {
        ArrayList<Boolean> answers = new ArrayList<Boolean>();
        for (int j = 1; j < fileUS.length; j++) {
            answers.add(PApplet.parseBoolean(fileUS[j].split(",")[i]));
        }
        questionsUS[i-1] = new Question(topRowUS[i], answers);
        loaded++;
    }

    for (int i = 1; i < topRowCan.length; i++) {
        ArrayList<Boolean> answers = new ArrayList<Boolean>();
        for (int j = 1; j < fileCan.length; j++) {
            answers.add(PApplet.parseBoolean(fileCan[j].split(",")[i]));
        }
        questionsCan[i-1] = new Question(topRowCan[i], answers);
        loaded++;
    }

    setCurrentCandidates(masterCandidatesUS);

    loadPortraits(masterCandidatesUS);
    loadPortraits(masterCandidatesCan);

    createGUI();

    modeDropList.setItems(modes, 0);

    getNextQuestion();

    isLoading = false;
}

public void loadPortraits(Candidate[] c) {
    for (int i = 0; i < c.length; i++) {
        curLoadProcess = "Loading - " +join(c[i].name.split(" "), "-")+".jpg";
        c[i].setPortrait(loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg"), false);
        c[i].portrait.resize(60, 75);
        loaded++;
        c[i].setPortrait(loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg"), true);
        c[i].portraitL.resize(300, 375);
        loaded++;
    }
}

public void drawLoading() {
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

public void drawTitle(int cX, int y) {
    textSize(30);
    if (animSpeed == 0 || !playAnim) {
        fill(usColors[0]);
        text(title, cX, y);
        return;
    }

    int[] colorArray = curMode.equals("American")?usColors:canadaColors;

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

public void updateGuiQuestion() {
    questionLabel.setText("Question: " + currentQuestion.text);
}

public void coverAffected(int toCover) {
    if (toCover == 0) return;
    boolean boolCover = (toCover == 1)?false:true;
    for (int i = 0; i < currentCandidates.size(); i++) {
        if (currentQuestion.answers.get(i) == boolCover)
            image(cross, i%8*padX+xOff, PApplet.parseInt(i/8)*padY+yOff);
    }
}

public int getHovered() {
    if (yesButton == null || noButton == null) return 0;
    if (yesButton.isOver(guiWin.mouseX, guiWin.mouseY))
        return 1;
    else if (noButton.isOver(guiWin.mouseX, guiWin.mouseY))
        return 2;
    else 
    return 0;
}

public void keyPressed(){
    if(key == ESC)
        exit();
}
class Candidate {
    
    String name;
    PImage portrait;
    PImage portraitL;
    
    Candidate(String name) {
      this.name = name;
      this.portrait = null;
    }  
    
    public void setPortrait(PImage portrait, boolean doLarge){
      if(doLarge)
        this.portraitL = portrait;
      else
        this.portrait = portrait;
    }
    
}

public void setCurrentCandidates(Candidate[] candidates) {
    currentCandidates.clear();
    for (Candidate c : candidates)
        currentCandidates.add(c);
}

public boolean isAnswerFound(){
    return currentCandidates.size() == 1;
}

public void undoCandidates(){
    for(int i = undoCandidateClipboard.size() - 1; i >= 0; i--){
        int undoInd = getMasterIndex(masterCandidatesUS, undoCandidateClipboard.get(i));
        for(int j = 0; j < currentCandidates.size(); j++){
            
            if(getMasterIndex(masterCandidatesUS, currentCandidates.get(j)) > undoInd){
                currentCandidates.add(j, undoCandidateClipboard.get(i));
                for(Question q : questionsUS){
                    q.answers.add(j, q.masterAnswers[undoInd]);
                }
                break;
            }
            if(j == currentCandidates.size() - 1){
                currentCandidates.add(undoCandidateClipboard.get(i));
                for(Question q : questionsUS){
                    q.answers.add(q.masterAnswers[undoInd]);
                }
                break;
            }
        }
        
    }
    undoCandidateClipboard.clear();
}

public int getMasterIndex(Candidate[] cs, Candidate c){
    for(int i = 0; i < cs.length; i++){
        if(cs[i] == c)
            return i;
    }
    return -1;
}
class Question {
    String text;
    Boolean[] masterAnswers;
    ArrayList<Boolean> answers;

    Question(String t, ArrayList<Boolean> answers) {
        this.text=t;
        this.answers = answers;
        masterAnswers = new Boolean[answers.size()];
        for (int i = 0; i < masterAnswers.length; i++) {
            masterAnswers[i] = answers.get(i);
        }
    }     

    public int getDifferenceInResults() {
        int numTrue = 0, numFalse = 0;
        for (int i = 0; i < answers.size(); i++) {
            if (answers.get(i))
                numTrue++;
            else
                numFalse++;
        }
        return abs(numTrue - numFalse);
    }

    public void resetQuestion() {
        this.answers.clear();
        for (Boolean b : this.masterAnswers)
            answers.add(b);
    }
}

public void getNextQuestion() {
    int minDiff = currentCandidates.size() + 1;
    Question[] usedQuestions = (curMode.equals("American"))?questionsUS:questionsCan;
    for (Question q : usedQuestions) {
        minDiff = min(q.getDifferenceInResults(), minDiff);

        if (q.getDifferenceInResults() <= minDiff)
            currentQuestion = q;
    }

    updateGuiQuestion();
}

public void respondToQuestion(boolean response) {
    undoCandidateClipboard.clear();
    for (int i = currentCandidates.size() - 1; i >= 0; i--) {
        if (currentQuestion.answers.get(i) != response) {
            undoCandidateClipboard.add(currentCandidates.get(i));
            currentCandidates.remove(i);
            if (curMode.equals("American")) {
                for (int j = 0; j < questionsUS.length; j++)
                    questionsUS[j].answers.remove(i);
            }
            else{
                for (int j = 0; j < questionsCan.length; j++)
                    questionsCan[j].answers.remove(i);
            }
        }
    }
    getNextQuestion();
    println(isAnswerFound());
}

/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this fileUS.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void drawGuiWin(PApplet appc, GWinData data) { //_CODE_:guiWin:679824:
  appc.background(230);
} //_CODE_:guiWin:679824:

public void clickYes(GButton source, GEvent event) { //_CODE_:yesButton:682798:
  respondToQuestion(true);
  getNextQuestion();
} //_CODE_:yesButton:682798:

public void clickNo(GButton source, GEvent event) { //_CODE_:noButton:464313:
  respondToQuestion(false);
  getNextQuestion();
} //_CODE_:noButton:464313:

public void PreviousQuestion(GButton source, GEvent event) { //_CODE_:previousButton:565747:
  undoCandidates();
  getNextQuestion();
} //_CODE_:previousButton:565747:

public void toggleDisplayEffects(GCheckbox source, GEvent event) { //_CODE_:showEffectBox:597986:
  showSelected = showEffectBox.isSelected();
} //_CODE_:showEffectBox:597986:

public void selectMode(GDropList source, GEvent event) { //_CODE_:modeDropList:585678:
  curMode = source.getSelectedText();
  if(curMode.equals("American"))
      title = "Guess The Prez!";
  else
      title = "Guess The Minister";
  reset();
  
} //_CODE_:modeDropList:585678:

public void clickReset(GButton source, GEvent event) { //_CODE_:ResetButton:688049:
  reset();
} //_CODE_:ResetButton:688049:

public void toggleAnimateTitle(GCheckbox source, GEvent event) { //_CODE_:animateTitleCheck:211146:
  playAnim = animateTitleCheck.isSelected();
} //_CODE_:animateTitleCheck:211146:

public void changeAnimSpeed(GSlider source, GEvent event) { //_CODE_:animSpeedSlider:955392:
  int divisor = 100 - source.getValueI();
  animSpeed = (divisor / 5);
} //_CODE_:animSpeedSlider:955392:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setCursor(ARROW);
  surface.setTitle("Sketch Window");
  guiWin = GWindow.getWindow(this, "Guesser_Controls", 0, 0, 400, 400, JAVA2D);
  guiWin.noLoop();
  guiWin.addDrawHandler(this, "drawGuiWin");
  yesButton = new GButton(guiWin, 80, 50, 80, 30);
  yesButton.setText("Yes");
  yesButton.addEventHandler(this, "clickYes");
  noButton = new GButton(guiWin, 240, 50, 80, 30);
  noButton.setText("No");
  noButton.addEventHandler(this, "clickNo");
  previousButton = new GButton(guiWin, 80, 85, 120, 30);
  previousButton.setText("Correct Previous Answer");
  previousButton.addEventHandler(this, "PreviousQuestion");
  questionLabel = new GLabel(guiWin, 50, 5, 300, 40);
  questionLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  questionLabel.setText("Question:");
  questionLabel.setOpaque(false);
  showEffectBox = new GCheckbox(guiWin, 80, 125, 160, 20);
  showEffectBox.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  showEffectBox.setText("Show Effects of Answers?");
  showEffectBox.setOpaque(false);
  showEffectBox.addEventHandler(this, "toggleDisplayEffects");
  showEffectBox.setSelected(true);
  modeDropList = new GDropList(guiWin, 250, 125, 90, 57, 2);
  modeDropList.setItems(loadStrings("list_585678"), 0);
  modeDropList.addEventHandler(this, "selectMode");
  ResetButton = new GButton(guiWin, 80, 150, 80, 30);
  ResetButton.setText("Restart");
  ResetButton.addEventHandler(this, "clickReset");
  animateTitleCheck = new GCheckbox(guiWin, 80, 220, 120, 20);
  animateTitleCheck.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  animateTitleCheck.setText("Animate Title?");
  animateTitleCheck.setOpaque(false);
  animateTitleCheck.addEventHandler(this, "toggleAnimateTitle");
  animateTitleCheck.setSelected(true);
  animSpeedSlider = new GSlider(guiWin, 79, 250, 100, 50, 10.0f);
  animSpeedSlider.setShowValue(true);
  animSpeedSlider.setShowLimits(true);
  animSpeedSlider.setLimits(50, 0, 100);
  animSpeedSlider.setNbrTicks(11);
  animSpeedSlider.setStickToTicks(true);
  animSpeedSlider.setShowTicks(true);
  animSpeedSlider.setNumberFormat(G4P.INTEGER, 0);
  animSpeedSlider.setOpaque(false);
  animSpeedSlider.addEventHandler(this, "changeAnimSpeed");
  animationSpeedLabel = new GLabel(guiWin, 180, 265, 140, 20);
  animationSpeedLabel.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  animationSpeedLabel.setText("Title Animation Speed");
  animationSpeedLabel.setOpaque(false);
  guiWin.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow guiWin;
GButton yesButton; 
GButton noButton; 
GButton previousButton; 
GLabel questionLabel; 
GCheckbox showEffectBox; 
GDropList modeDropList; 
GButton ResetButton; 
GCheckbox animateTitleCheck; 
GSlider animSpeedSlider; 
GLabel animationSpeedLabel; 
    public void settings() {  size(660, 750); }
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "GuessThePrez" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
