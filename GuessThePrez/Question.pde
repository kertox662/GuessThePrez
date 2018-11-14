class Question{
    String text;

    ArrayList<Boolean> answers;
    
    Question(String t, ArrayList<Boolean> answers){
      this.text=t;
      this.answers = answers;
    
    }
    
    Question fromFile(){
        return null;
    }
    
    void respondToQuestion() {
      //if (displayOutcomes) {
      //}
      //else {
       //if player answers yes to the question
        for (int i = 0; i < currentCandidates.size(); i++) {
          if (buttonPressed == 0) {
            if (!answers.get(i)) {
              currentCandidates.remove(currentCandidates.get(i));
              print(currentCandidates);
            } 
          if (buttonPressed == 1) {
            if (answers.get(i)) {
              currentCandidates.remove(currentCandidates.get(i));
              print(currentCandidates);
            } 
          }
        }    
      } 
      //}
    }     
    
    int getDifferenceInResults(){
        int numTrue = 0, numFalse = 0;
        for(int i = 0; i < answers.size(); i++){
            if(answers.get(i))
                numTrue++;
            else
                numFalse++;
        }
        return abs(numTrue - numFalse);
    }
    
    
}
