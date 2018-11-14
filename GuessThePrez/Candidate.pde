class Candidate {
    
    String name;
    PImage portrait;
    
    Candidate(String name) {
      this.name = name;
      this.portrait = null;
    }
    
    void getDifferenceInResults() {
      
    }     
    
    void setPortrait(PImage portrait){
      this.portrait = portrait;
    }
    
    Candidate fromFile(){
      return null;
    }
}

void setCurrentCandidates(Candidate[] candidates) {
    currentCandidates.clear();
    for (Candidate c : candidates)
        currentCandidates.add(c);
}

boolean isAnswerFound(){
    return currentCandidates.size() == 1;
}

void undoCandidates(){}
