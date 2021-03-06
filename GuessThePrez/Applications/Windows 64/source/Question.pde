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

    int getDifferenceInResults() {
        int numTrue = 0, numFalse = 0;
        for (int i = 0; i < answers.size(); i++) {
            if (answers.get(i))
                numTrue++;
            else
                numFalse++;
        }
        return abs(numTrue - numFalse);
    }

    void resetQuestion() {
        this.answers.clear();
        for (Boolean b : this.masterAnswers)
            answers.add(b);
    }
}

void getNextQuestion() {
    int minDiff = currentCandidates.size() + 1;
    Question[] usedQuestions = (curMode.equals("American"))?questionsUS:questionsCan;
    for (Question q : usedQuestions) {
        minDiff = min(q.getDifferenceInResults(), minDiff);

        if (q.getDifferenceInResults() <= minDiff)
            currentQuestion = q;
    }

    updateGuiQuestion();
}

void respondToQuestion(boolean response) {
    undoCandidateClipboard.clear();
    for (int i = currentCandidates.size() - 1; i >= 0; i--) {
        if (currentQuestion.answers.get(i) != response) {
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
    getNextQuestion();
}
