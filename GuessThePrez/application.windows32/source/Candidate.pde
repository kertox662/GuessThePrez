class Candidate {
    
    String name;
    PImage portrait;
    PImage portraitL;
    
    Candidate(String name) {
      this.name = name;
      this.portrait = null;
    }  
    
    void setPortrait(PImage portrait, boolean doLarge){
      if(doLarge)
        this.portraitL = portrait;
      else
        this.portrait = portrait;
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

void undoCandidates(){
    Candidate[] undoArray = (curMode.equals("American"))?masterCandidatesUS:masterCandidatesCan;
    Question[] questionArray = (curMode.equals("American"))?questionsUS:questionsCan;
    for(int i = undoCandidateClipboard.size() - 1; i >= 0; i--){
        
        int undoInd = getMasterIndex(undoArray, undoCandidateClipboard.get(i));
        for(int j = 0; j < currentCandidates.size(); j++){
            
            if(getMasterIndex(undoArray, currentCandidates.get(j)) > undoInd){
                currentCandidates.add(j, undoCandidateClipboard.get(i));
                for(Question q : questionArray){
                    q.answers.add(j, q.masterAnswers[undoInd]);
                }
                break;
            }
            if(j == currentCandidates.size() - 1){
                currentCandidates.add(undoCandidateClipboard.get(i));
                for(Question q : questionArray){
                    q.answers.add(q.masterAnswers[undoInd]);
                }
                break;
            }
        }
        
    }
    undoCandidateClipboard.clear();
}

int getMasterIndex(Candidate[] cs, Candidate c){
    for(int i = 0; i < cs.length; i++){
        if(cs[i] == c)
            return i;
    }
    return -1;
}
