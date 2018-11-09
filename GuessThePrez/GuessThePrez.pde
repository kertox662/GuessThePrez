import g4p_controls.*;

Candidate[] candidates;
PImage[] portraits;

int temp = 0;

void setup() {
    size(600, 600);
    imageMode(CENTER);
    String[] file = loadStrings("President_Data.csv");
    candidates = new Candidate[file.length-1];
    for (int i = 1; i < file.length; i++) {
        candidates[i-1] = new Candidate(file[i].split(",")[0]);
    }

    portraits = loadPortraits(candidates);
}

void draw() {
    background(255);
    image(portraits[temp], width/2, height/2);
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
        images[i].resize(100, 128);
    }

    return images;
}
