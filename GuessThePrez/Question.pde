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
    
    
    //static Question getNextQuestion(){}
    
    
}
