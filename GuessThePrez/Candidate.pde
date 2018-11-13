class Candidate{
    
    String name;
    PImage portrait;
    
    Candidate(String name){
         this.name = name;
         this.portrait = null;
    }
    
    void setPortrait(PImage portrait){
        this.portrait = portrait;
    }
    
    Candidate fromFile(){
        return null;
    }
}

boolean checkRemainingCandidates(){
    return true;
}
