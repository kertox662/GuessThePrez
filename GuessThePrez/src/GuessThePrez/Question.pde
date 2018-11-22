class Question {
    String text;
    Boolean[] masterAnswers;
    ArrayList<Boolean> answers;

    Question(String t, ArrayList<Boolean> answers) {
        this.text=t;
        this.answers = answers;
        masterAnswers = new Boolean[answers.size()];
        for (int i = 0; i < masterAnswers.length; i++) {
            masterAnswers[i] = answers.get(i);
        }
    }     

    int getDifferenceInResults() { //Counts how many trues and falses there are in the answers and return the absolute difference.
        int numTrue = 0, numFalse = 0;
        for (int i = 0; i < answers.size(); i++) {
            if (answers.get(i))
                numTrue++;
            else
                numFalse++;
        }
        return abs(numTrue - numFalse);
    }

    void resetQuestion() { //Sets all of the questions to the questions in master array
        this.answers.clear();
        for (Boolean b : this.masterAnswers)
            answers.add(b);
    }
}

void getNextQuestion() { //Finds the best next question based on differences in trues and falses
    int minDiff = currentCandidates.size() + 1; //This will always be bigger than any of the difference in the question 
                                 //because it will never have a higher number than the size of current candidates array
    Question[] usedQuestions = (curMode.equals("American"))?questionsUS:questionsCan;
    for (Question q : usedQuestions) {
        minDiff = min(q.getDifferenceInResults(), minDiff);

        if (q.getDifferenceInResults() <= minDiff) //If question is better or just as good, then sets it to the new question
            currentQuestion = q;
    }

    updateGuiQuestion();
}

void respondToQuestion(boolean response) { //Removes the candidates from possibilities
    undoCandidateClipboard.clear();
    for (int i = currentCandidates.size() - 1; i >= 0; i--) {
        if (currentQuestion.answers.get(i) != response) { //If the candidate does not match the response, all questions will remove their
                                                          //Answers, and the candidate will be placed in undo
            undoCandidateClipboard.add(currentCandidates.get(i));
            currentCandidates.remove(i);
            if (curMode.equals("American")) {
                for (int j = 0; j < questionsUS.length; j++)
                    questionsUS[j].answers.remove(i);
            }
            else{
                for (int j = 0; j < questionsCan.length; j++)
                    questionsCan[j].answers.remove(i);
            }
        }
    }
    getNextQuestion(); //The next best question is gotten
}
