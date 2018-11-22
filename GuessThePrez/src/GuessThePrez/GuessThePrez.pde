import processing.sound.*;  //<>//
import g4p_controls.*;
import java.awt.Font;


//=====================================================================
//===========================Variables=================================
//=====================================================================
Candidate[] masterCandidatesUS; //Holds data that will be loaded in such as questions and candidates
Candidate[] masterCandidatesCan;
Question[] questionsUS;
Question[] questionsCan;
ArrayList<Candidate> currentCandidates;
ArrayList<Candidate> undoCandidateClipboard;

SoundFile[] sounds;

PImage cross; //Cross to display over would-be-eliminated candidates

color blackAlpha = color(0, 100); //Color of background to contrast some text;

PImage canadaFlag; //Backgrounds
PImage usFlag;
PImage ovalOffice;
PImage pmOffice;

boolean isLoading = true; //Loading process variables
boolean isStarted = false;
int loaded = 0, loadMax = 0;
String curLoadProcess = "Loading";

Question currentQuestion;

boolean showSelected = true;//Variables to affect gameplay
String [] modes = {"American", "Canadian"};
String curMode = modes[0];

color[] usColors = {color(255, 0, 0), color(255), color(0, 0, 255)}; //Variables to control title animation
color[] canadaColors = { color(255, 0, 0), color(255)};
String title = "Guess The Prez!";
int curColor = 0;
int curTitleIndex = 0;
int animSpeed = 10;
boolean playAnim = true;

final int padX = 80, padY = 105; //These edit how the portraits are displayed
final int xOff = 40, yOff = 98;

//=====================================================================
//===================Functions and Procedures==========================
//=====================================================================

void setup() {
    size(660, 750);
    textAlign(CENTER);
    imageMode(CENTER);
    stroke(0);
    strokeWeight(2);

    currentCandidates = new ArrayList<Candidate>();
    undoCandidateClipboard = new ArrayList<Candidate>();

    thread("loadData"); //The data is loaded in a separate thread to allow for the loading screen to be drawn
}

void draw() {
    if (isLoading) //Do loading bar
        drawLoading();
    else if (isAnswerFound()) { //Display the final candidate and do GUI cleanup with question and buttons
        drawFinal();
        questionLabel.setText("Press Restart to Play Again");
        previousButton.setVisible(false); //User won't be able press the undo button when the final answer is found
    } else {
        drawRegular();
        if (currentQuestion != null)
            updateGuiQuestion();
    }
}


//=====================================================================
//========================Drawing Procedures===========================
//=====================================================================

void drawPortraits() { //Draws the portraits of every remaining candidate
    try {
        resetFormatting();
        for (int i=0; i<currentCandidates.size(); i++) {
            fill(0, 127, 127);
            image(currentCandidates.get(i).portrait, i%8*padX+xOff, int(i/8)*padY+yOff); //Draws the portrait image
            if (textWidth(currentCandidates.get(i).name) > 120) { //If string is too long, decreases font size
                textSize(8); 
                textLeading(8);
            }
            text(currentCandidates.get(i).name, i%8*padX+xOff, int(i/8)*padY+yOff + 87, 60, 100); //Displays name under protrait
            resetFormatting();
        }
    }
    catch(IndexOutOfBoundsException e) { //Need to catch in case the user responds to the question leaving less candidates
                                         //than the current index that is being drawn
    }
}

void drawRegular() { //The regular draw procedure to call during the majority of play
    fill(0, 200, 0);
    textSize(10);
    textLeading(10);
    drawBackground();
    playSound(0); //0 index is background music

    if (!isStarted) {//If on start screen
        drawTitle(width/2, height/2 - 50); //Draws title around the middle of the screen
    } else { //Normal gameplay
        fill(0, 200, 0);
        resetFormatting();
        drawPortraits();

        if (showSelected) //If the user wants to see the effects of the answers
            coverAffected(getHovered()); //Use which button the mouse is over to choose what candidates to cover

        drawTitle(width/2, 35); //Draws title at the top

        if (undoCandidateClipboard.size() == 0 || isAnswerFound()) //If there is no one to undo, then the undo button will be invisible
            previousButton.setVisible(false); 
        else
            previousButton.setVisible(true);
    }
}

void drawFinal() { //Draws the final candidate with a different background and a confetti animation
    drawBackground();
    if (!isConfettiSet) {
        setupConfetti();
    }
    drawConfetti();
    
    float boxWidth = max(textWidth("My Guess is: " + currentCandidates.get(0).name), textWidth(title) + 20);
    fill(blackAlpha);
    if(curMode.equals("Canadian"))
        rect(width/2, height/2 + 45, boxWidth + 20,300); //Draw box for contrast
    
    drawTitle(width/2, height/2 - 80); //Draws title above candidate
    
    textSize(20);
    displayLastCandidate();
    
    if (curMode.equals("American"))
        playSound(1); //Ending sound - American Anthem
    else
        playSound(2); //Ending sound - Canadian Anthem
}

void displayLastCandidate() {
    Candidate c = currentCandidates.get(0);
    image(c.portraitL, width/2, height/2 + 50);
    fill(255);
    text("My Guess is: " + c.name, width/2, height/2 + c.portraitL.height/2 + 60); //Displays the name of the guessed candidate
}

void drawBackground() {//Draws either the flags for normal play, or offices for end screen
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

void drawLoading() { //Draws loading screen in the middle of the screen
    background(255);
    fill(255);
    rect(100, height/2 - 25, width - 200, 50);
    fill(255, 0, 0);
    rect(100, height/2 - 25, (width - 200) * ((float)loaded / loadMax), 50); //Displays a red bar inside a white box proportionally
    textSize(20);                                                            //to how much data has loaded
    text("Loading, Please Wait...", width/2, height/2 - 50);
    textSize(12);
    text(curLoadProcess, width/2, height/2 + 50 ); //Displays the current process that is loading
}

void drawTitle(int cX, int y) { //Draws the title based on a center and height
    textAlign(CENTER);
    textSize(30);
    fill(blackAlpha);
    if((curMode.equals("Canadian") && !isAnswerFound()) || !isStarted)
        rect(cX,y - 10,textWidth(title) + 10, 32);
    if (animSpeed == 0 || !playAnim || isAnswerFound()) { //If user set to static or displaying last static, make the title the first usColor
        fill(usColors[0]);
        text(title, cX, y);
        resetFormatting();
        return;
    }

    color[] colorArray = curMode.equals("American")?usColors:canadaColors;

    char[] titleChars = title.toCharArray(); //The title is displayed as a series of characters, so that they can be colored differently
    float x = cX - textWidth(title)/2 + textWidth(title.charAt(0))/2;
    for (int i = 0; i < titleChars.length; i++) {
        if (i < curTitleIndex) { //If the current index has not reached the different color index, choose the further color in the array
            fill(colorArray[(curColor + 1)%colorArray.length]);
        } else {
            fill(colorArray[curColor%colorArray.length]);
        }
        text(str(titleChars[i]), x, y);
        x += (textWidth(str(titleChars[i])) + textWidth(str(titleChars[(i+1)%title.length()]))) / 2; /* Increase the x coordinate by
                                                                                            The pixel width of the two adjacent characters
                                                                                            divided by 2, this takes care of the gap for
                                                                                            center aligned characters */
    }


    if (title.charAt(curTitleIndex%title.length()) == ' ') //If the next character is a space, skip it for the different color border index
        curTitleIndex++;

    if (curTitleIndex >= title.length() - 1) { //If the color border has reached the end, switch to next color
        curColor = ++curColor % colorArray.length;
        curTitleIndex = 0;
    }
    if ((frameCount%((animSpeed != 0)?animSpeed:1)) == 0) //If the framecount is a multiple of animSpeed, increase the colour border index
        curTitleIndex++;
    resetFormatting();
}

void updateGuiQuestion() { //Sets the question label to the current question
    questionLabel.setText("Question: " + currentQuestion.text);
}

void coverAffected(int toCover) { //Displays a cross on candidates that would be elimated by responding with the hovered answer
    if (toCover == 0) return; //If not hovering over yes or no, then don't cover anyone
    boolean boolCover = (toCover == 1)?false:true; //Yes is 1 , No is 2. This inverts this to show who does not follow the response
    for (int i = 0; i < currentCandidates.size(); i++) {
        if (currentQuestion.answers.get(i) == boolCover)
            image(cross, i%8*padX+xOff, int(i/8)*padY+yOff);
    }
}



//=====================================================================
//=========================Reset Procedures============================
//=====================================================================
void reset() { //Resets all of the important variables including candidates and questions
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

    undoCandidateClipboard.clear(); //New game, so no undo should be possible
    resetFormatting();
    getNextQuestion(); //Gets the next questions as after reset, a better question may appear
}

void resetFormatting() { //Resets the text formatting as some commands change some of the properties
    textAlign(CENTER, TOP);
    textSize(10);
    textLeading(10);
}


//=====================================================================
//============================Data Loading=============================
//=====================================================================

void loadData() {
    String[] fileUS = loadStrings("President_Data.csv"); //Load files
    String[] fileCan = loadStrings("Minister_Data.csv");

    for (int i = 0; i < fileUS.length; i++) { //Remove whitespace and \n for easy conversion to boolean.
        fileUS[i] = trim(fileUS[i]);
    }

    for (int i = 0; i < fileCan.length; i++) {
        fileCan[i] = trim(fileCan[i]);
    }


    String[] topRowUS = fileUS[0].split(","); //Gets the question rows
    String[] topRowCan = fileCan[0].split(",");

    loadMax = 2*(fileUS.length + fileCan.length - 2)  + 39; //The "amount of files" needed to be loaded. This is not proportional
                                                            //to the true amount as some files such as music should affect the loading
                                                            //bar more due to the time it takes to load them

    curLoadProcess = "Loading - Misc Images"; //Load images
    cross = loadImage("Images/cross.png");
    loaded++; //This is used for the loading bar to show progress
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

    sounds=new SoundFile[3]; //Load sounds
    curLoadProcess = "Loading - Music - Background Music";
    sounds[0]=new SoundFile(this, "Music/Background.mp3");
    loaded+=14; //music is weighted high for the loading bar

    curLoadProcess = "Loading - Music - USanthem.mp3";
    sounds[1]=new SoundFile(this, "Music/USanthem.mp3");
    loaded+=8;

    curLoadProcess = "Loading - Music - CanadaAnthem.mp3";
    sounds[2]=new SoundFile(this, "Music/CanadaAnthem.mp3");
    loaded+=8;

    masterCandidatesUS = new Candidate[fileUS.length-1]; //Create question and candidate array
    questionsUS = new Question[topRowUS.length - 1];

    masterCandidatesCan = new Candidate[fileCan.length-1];
    questionsCan = new Question[topRowCan.length - 1];

    curLoadProcess = "Loading - Candidates";
    for (int i = 1; i < fileUS.length; i++) { //File candidate arrays
        masterCandidatesUS[i-1] = new Candidate(fileUS[i].split(",")[0]);
    }
    loaded++; //Questions and Candidates are weighted low

    for (int i = 1; i < fileCan.length; i++) {
        masterCandidatesCan[i-1] = new Candidate(fileCan[i].split(",")[0]);
    }
    loaded++;

    curLoadProcess = "Loading - Questions"; //File question arrays
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

    setCurrentCandidates(masterCandidatesUS); //Defualts to american

    loadPortraits(masterCandidatesUS); //Loads images of leaders
    loadPortraits(masterCandidatesCan);

    finishSetup();
}

void loadPortraits(Candidate[] c) { /*Loads two separate instances of each portrait for the candidates
This is because PImage.resize() changes the actual dimensions for the instance instead of return a PImage,
and resizing constantly would cause loss of pixel quality*/
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

void finishSetup() { //Changes some variables to complete the setup
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

void keyPressed() { //Quits the game
    if (key == ESC)
        exit();
}


void playSound(int i) { //If the requested sound isn't playing, then stops all sounds and plays requested sound
    if (!sounds[i].isPlaying()) {
        for (SoundFile s : sounds)
            s.stop();
        sounds[i].loop();
    }
}

void startGame(GButton source, GEvent e) {//Creates GUI when start button is pressed and goes to normal play
    source.dispose();
    createGUI();
    modeDropList.setItems(modes, 0);
    getNextQuestion();
    isStarted = true;
}

int getHovered() { //Returns what button is hovered over. Yes is 1, No is 2, None is 0
    if (yesButton == null || noButton == null) return 0;
    if (yesButton.isOver(guiWin.mouseX, guiWin.mouseY))
        return 1;
    else if (noButton.isOver(guiWin.mouseX, guiWin.mouseY))
        return 2;
    else 
    return 0;
}
