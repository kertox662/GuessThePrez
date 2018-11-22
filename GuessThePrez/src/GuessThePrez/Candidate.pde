class Candidate {
    
    String name;
    PImage portrait;  //Small protrait
    PImage portraitL; //Large portrait
    
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

void setCurrentCandidates(Candidate[] candidates) { //Sets candidates from passed in array to the candidates in the arraylist
    currentCandidates.clear();
    for (Candidate c : candidates)
        currentCandidates.add(c);
}

boolean isAnswerFound(){ //Returns true if only 1 candidate remains
    return currentCandidates.size() == 1;
}

void undoCandidates(){ //puts back all of the candidates in the undo arraylist into the current candidates arraylist, as well as questions
    Candidate[] undoArray = (curMode.equals("American"))?masterCandidatesUS:masterCandidatesCan;
    Question[] questionArray = (curMode.equals("American"))?questionsUS:questionsCan;
    for(int i = undoCandidateClipboard.size() - 1; i >= 0; i--){ //for each undoed candidate, going backwards
        
        int undoInd = getMasterIndex(undoArray, undoCandidateClipboard.get(i)); //Index to look out for
        for(int j = 0; j < currentCandidates.size(); j++){
            
            if(getMasterIndex(undoArray, currentCandidates.get(j)) > undoInd){ //If a candidate currently in currentCandidates
                currentCandidates.add(j, undoCandidateClipboard.get(i));       //has a higher index, then insert it in front
                for(Question q : questionArray){
                    q.answers.add(j, q.masterAnswers[undoInd]);
                }
                break;
            }
            if(j == currentCandidates.size() - 1){ //If the candidate was not inserted, append it to the end
                currentCandidates.add(undoCandidateClipboard.get(i));
                for(Question q : questionArray){
                    q.answers.add(q.masterAnswers[undoInd]);
                }
                break;
            }
        }
        
    }
    undoCandidateClipboard.clear(); //Empties the undoable candidate
}

int getMasterIndex(Candidate[] cs, Candidate c){ //Gets the index of the candidate in the array, otherwise returns -1
    for(int i = 0; i < cs.length; i++){
        if(cs[i] == c)
            return i;
    }
    return -1;
}
