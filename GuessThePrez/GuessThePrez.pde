import g4p_controls.*;

Candidate[] candidates;
PImage[] portraits;

int temp = 0;

void setup() {
    size(600, 600);
    imageMode(CENTER);
    textAlign(CENTER);
    fill(0);
    String[] file = loadStrings("President_Data.csv");
    candidates = new Candidate[file.length-1];
    for (int i = 1; i < file.length; i++) {
        candidates[i-1] = new Candidate(trim(file[i].split(","))[0]);
    }

    portraits = loadPortraits(candidates);
    createGUI();
}

void draw() {
    background(255);
    image(portraits[temp], width/2, height/2);
    text(candidates[temp].name ,width/2, height/2 + portraits[temp].height/2 + 20);
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

PImage[] loadPortraits(Candidate[] c) {
    PImage[] images = new PImage[c.length];
    for (int i = 0; i < images.length; i++) {
        images[i] = loadImage("portraits/"+join(c[i].name.split(" "), "-")+".jpg");
        images[i].resize(300, int(300*1.28));
    }

    return images;
}
