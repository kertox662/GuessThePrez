class Question{
    String text;
    Boolean[] masterAnswers;
    ArrayList<Boolean> answers;
    
    Question(String t, ArrayList<Boolean> answers){
      this.text=t;
      this.answers = answers;
      masterAnswers = new Boolean[answers.size()];
      for(int i = 0; i < masterAnswers.length; i++){
          masterAnswers[i] = answers.get(i);
      }
    
    }
    
    Question fromFile(){
        return null;
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
    
    void resetQuestion(){
        this.answers.clear();
        for(Boolean b: this.masterAnswers)
            answers.add(b);
    }
    
    
    
}

void getNextQuestion(){
    int minDiff = masterCandidates.length + 1;
    for(Question q : questions){
        minDiff = min(q.getDifferenceInResults(), minDiff);
        //println(q.getDifferenceInResults());
    }
    
    for(Question q: questions){
        if(q.getDifferenceInResults() == minDiff){
            currentQuestion = q;
            break;}
    }
    updateGuiQuestion();
    return;
}

void respondToQuestion(boolean response){
    undoCandidateClipboard.clear();
    for(int i = currentCandidates.size() - 1; i >= 0; i--){
        if(currentQuestion.answers.get(i) != response){
            undoCandidateClipboard.add(currentCandidates.get(i));
            currentCandidates.remove(i);
            for(int j = 0; j < questions.length; j++)
                questions[j].answers.remove(i);
        }
    }
    getNextQuestion();
    println(isAnswerFound());
}
