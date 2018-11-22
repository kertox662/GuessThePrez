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
    if (!isAnswerFound()) {
        respondToQuestion(true); //Respond yes to question
        getNextQuestion();
    }
} //_CODE_:yesButton:682798:

public void clickNo(GButton source, GEvent event) { //_CODE_:noButton:464313:
    if (!isAnswerFound()) {
        respondToQuestion(false); //Respond no to question
        getNextQuestion();
    }
} //_CODE_:noButton:464313:

public void PreviousQuestion(GButton source, GEvent event) { //_CODE_:previousButton:565747:
    undoCandidates(); //Undo previous answer
    getNextQuestion();
} //_CODE_:previousButton:565747:

public void toggleDisplayEffects(GCheckbox source, GEvent event) { //_CODE_:showEffectBox:597986:
    showSelected = showEffectBox.isSelected(); //Toggles the variable to show effects of answers
} //_CODE_:showEffectBox:597986:

public void selectMode(GDropList source, GEvent event) { //_CODE_:modeDropList:585678:
    curMode = source.getSelectedText(); //Changes the mode and the title
    if (curMode.equals("American"))
        title = "Guess The Prez!";
    else
        title = "Guess The Minister!";
    reset();
} //_CODE_:modeDropList:585678:

public void clickReset(GButton source, GEvent event) { //_CODE_:ResetButton:688049:
    reset(); //Restarts the game
} //_CODE_:ResetButton:688049:

public void toggleAnimateTitle(GCheckbox source, GEvent event) { //_CODE_:animateTitleCheck:211146:
    playAnim = animateTitleCheck.isSelected(); //Toggles the title animation to play
} //_CODE_:animateTitleCheck:211146:

public void changeAnimSpeed(GSlider source, GEvent event) { //_CODE_:animSpeedSlider:955392:
    animSpeed = int(map(100 - source.getValueI(), 100, 0, 11, 1)); //Changes the animation speed of title
} //_CODE_:animSpeedSlider:955392:

public void changeVolume(GSlider source, GEvent event){ //Changes the music volume
    for(SoundFile s : sounds)
        s.amp(map(source.getValueF(), 0, 100, 0, 1));
}



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI() {
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
    animSpeedSlider = new GSlider(guiWin, 79, 250, 100, 50, 10.0);
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
    
    volumeSlider=new GSlider(guiWin, 80, 300, 100, 50, 10);
    volumeSlider.setShowValue(true);
    volumeSlider.setShowLimits(true);
    volumeSlider.setLimits(50, 0, 100);
    volumeSlider.setNbrTicks(11);
    volumeSlider.setShowTicks(true);
    volumeSlider.setNumberFormat(G4P.INTEGER, 0);
    volumeSlider.setOpaque(false);
    volumeSlider.addEventHandler(this, "changeVolume");
    
    
    volumeLabel = new GLabel(guiWin, 190, 317, 140, 20);
    volumeLabel.setTextAlign(GAlign.LEFT, GAlign.LEFT);
    volumeLabel.setText("Music Volume");
    volumeLabel.setOpaque(false);
    
    modeLabel = new GLabel(guiWin, 255, 140, 140, 20);
    modeLabel.setTextAlign(GAlign.LEFT, GAlign.LEFT);
    modeLabel.setText("Select Mode");
    modeLabel.setOpaque(false);
    
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
GLabel modeLabel;
GButton ResetButton; 
GCheckbox animateTitleCheck; 
GSlider animSpeedSlider; 
GLabel animationSpeedLabel; 
GSlider volumeSlider;
GLabel volumeLabel;
GButton startButton;
