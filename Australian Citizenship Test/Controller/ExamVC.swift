//
//  ExamVC.swift
//  Australian Citizenship Test
//
//  Created by Pichai Tangtrongsakundee on 7/5/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
import ChameleonFramework

class ExamVC: UIViewController {

    var realm = try! Realm()

    // 1. ExamBank Table
    var questions : Results<ExamBank>!
    var questionCount : Int?
    var questionSet : Int? {
        willSet {
            lblExam.text = "Exam: \(newValue ?? 1)"
        }
    }
    
    var questionIndex : Int?
    var correctAnswer : Int?
    var selectedAnswer : Int? // We can add DidSet here to update Score in Score table
    var readOnlyMode : Bool?
    
    // 2. Score Table
    var ScoreTable : Results<Score>!
    var currScore : Int = 0  // We can update lblScore.txt when currScore has changed.
    {
        willSet {
            lblScore.text = "Score: \(newValue)"
        }
    }
    
    // 3. Score Table
    var StatusTable : Results<Status>!
    var currQuestionSet : Int = 1
    
    // View Did Load function
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaultPath = Realm.Configuration.defaultConfiguration.fileURL?.path.replacingOccurrences(of: "default", with: "act")
        let config = Realm.Configuration(fileURL: URL(string: defaultPath!), readOnly: false)
        realm = try! Realm(configuration: config)
        
        setupUiPara()      // Setup UI and Parameters
        loadQuestions()    // Load questions into cache
        loadScore()        // Load initial score
        showNextUnanswerQuestion() // Show the first question
    }
    
    
    // M E T H O D S
    private func setupUiPara() {
        // SETUP UI
        // Set Background color (gradient)
        let colors:[UIColor] = [UIColor.flatYellow, UIColor.flatGreen]
        view.backgroundColor = GradientColor(.topToBottom, frame: view.frame, colors: colors)
        
        // Question Set
        if let nav = self.navigationController?.navigationBar {
           let qSetFrame = CGRect(x: (nav.frame.width)-120, y: 0, width: (nav.frame.width/2), height: (nav.frame.height))
           let txtQuestionSet = UILabel(frame: qSetFrame)
           txtQuestionSet.text = "Set 1"
           /// nav.addSubview(txtQuestionSet)
        }
        
        // Questions
        lblQuestion.lineBreakMode = .byWordWrapping
        
        // Choices
        let intRadius = 10
        var choice : UIButton?
        for i in 1...4 {
            choice = self.view.viewWithTag(i) as? UIButton
            choice!.layer.masksToBounds = true
            choice!.layer.cornerRadius = CGFloat(intRadius)
            choice!.titleLabel?.lineBreakMode = .byWordWrapping
            choice!.titleLabel?.textAlignment = NSTextAlignment.center
        }
        
        // SETUP Parameters
        StatusTable = realm.objects(Status.self)
        // Setup "Current Question Set" - if not, 1 is the default.
        if let stat = StatusTable.first {
            currQuestionSet = stat.currQuestionSet
        } else {
            currQuestionSet = 1
        }
        
        // SET SVProgressHUD
        SVProgressHUD.setDefaultStyle(.custom)
        SVProgressHUD.setBackgroundColor(UIColor.flatSand)
    }
    
    private func loadQuestions() {
        questions = realm.objects(ExamBank.self).filter("questionSet = \(currQuestionSet)").sorted(byKeyPath: "id", ascending: true)
        guard questions.count > 0 else { fatalError("No Questions in Database for this question Set: \(currQuestionSet)" ) }
        questionCount = questions.count
        questionIndex = questions[0].id - 1
        questionSet = questions[0].questionSet
    }
    
    private func loadScore() {
        if let stat = StatusTable.first {
            currQuestionSet = stat.currQuestionSet
        }
        
        ScoreTable = realm.objects(Score.self).filter("questionSet = \(currQuestionSet)")
        if let sc = ScoreTable.first {
            currScore = sc.score
        } else { currScore = 0 }
    }
    
    private func showNextQuestion() {
        showTargetedQuestion(targetedID: questionIndex! + 1)
    }
    
    private func showNextUnanswerQuestion() {
        // Find the next Question to load.
        let nextQuestionToLoad = getNextUnanswered()
        // If not found?
        showTargetedQuestion(targetedID: nextQuestionToLoad)
    }
    
    private func getNextUnanswered() -> Int {
        questions = realm.objects(ExamBank.self).filter("questionSet = \(currQuestionSet)").sorted(byKeyPath: "id", ascending: true)
        var intReturn = questionCount;  // Default value is the last question (aka questionCount)
        for n in 0..<questions.count {
            if (questions[n].selectedAns == 0) {
                intReturn = n
                break
            }
        }
        return intReturn!;
    }
    
    private func showTargetedQuestion(targetedID : Int) {
        if targetedID < questionCount! {
            questionIndex = targetedID
            loadAQuestion(targetedID)
        } else {
            //Alert to go back
            let alert = UIAlertController(title: "End of Exam", message: "Back to Main Menu?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                self.navigationController?.popViewController(animated: true)
                self.finishCurrQuestionSet()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    private func showPrevQuestion() {
        guard questionIndex! > 0 else {
            print ("Alert!! - Question is out of range: YYY ")
            return }
        questionIndex = questionIndex! - 1
        loadAQuestion(questionIndex!)
    }
    
    private func loadAQuestion(_ ind : Int)  {
        // Set header text
        navigationItem.title = "Q: \(ind+1)/\(questionCount!)"
 
        lblQuestion.text = questions![ind].question
        answer1.setTitle(questions![ind].answer1, for: .normal)
        answer2.setTitle(questions![ind].answer2, for: .normal)
        answer3.setTitle(questions![ind].answer3, for: .normal)
        answer4.setTitle(questions![ind].answer4, for: .normal)
        correctAnswer = questions![ind].correctAns
        selectedAnswer = questions![ind].selectedAns
        
        // set All choices' colour anyway
        resetAllChoicesColor()
        
        if selectedAnswer != 0 {
            // Case: Already selected
            readOnlyMode = true
            // To show correct answer - as always
            let correctChoice = self.view.viewWithTag(correctAnswer!) as? UIButton
            correctChoice!.backgroundColor = .green
            
            // To show selected answer (SUB-CASE: in case of not correct)
            if (selectedAnswer != correctAnswer) {
                let inCorrectChoice = self.view.viewWithTag(selectedAnswer!) as? UIButton
                inCorrectChoice!.backgroundColor = .red
            }
        } else {
            readOnlyMode = false
        }
    }
    
    // I B - O U T L E T S
    @IBOutlet weak var lblQuestion: UILabel!
    @IBOutlet weak var answer1: UIButton!
    @IBOutlet weak var answer2: UIButton!
    @IBOutlet weak var answer3: UIButton!
    @IBOutlet weak var answer4: UIButton!
    @IBOutlet weak var lblExam: UILabel!
    @IBOutlet weak var lblScore: UILabel!
    
    // I B - A C T I O N S
    @IBAction func answer1(_ sender: UIButton) {
        guard readOnlyMode == false else { return }
        checkAnswer(sender)
        saveAnswer(sender)
        readOnlyMode = true // Answer only once per question loaded.
    }
    @IBAction func btnNext(_ sender: UIButton) {
        showNextQuestion()
    }
    @IBAction func btnPrevious(_ sender: UIButton) {
        showPrevQuestion()
    }
    
    @IBAction func btnNextUnanswered(_ sender: UIButton) {
        showNextUnanswerQuestion()
    }
    
    func finishCurrQuestionSet() {
        // Check if all question in currentSet have been answered
        if areAllQuestionAnswerred() == true {
            // Status table
            let statusTable = realm.objects(Status.self)
                try! realm.write {
                    if let statusT = statusTable.first {
                       statusT.currQuestionSet = statusT.currQuestionSet + 1
                    }
                }
        } else {
            print ("Not all questions answered!")
        }
    }
    
    func areAllQuestionAnswerred() -> Bool {
        questions = realm.objects(ExamBank.self).filter("questionSet = \(currQuestionSet)").sorted(byKeyPath: "id", ascending: true)
        var boolReturn = true
        for n in 0..<questions.count {
            if (questions[n].selectedAns == 0) {
                boolReturn = false
                break
            }
        }
        return boolReturn;
    }
    
    func saveAnswer (_ sd : UIButton) {
        // ExamBank Table - to save answer
        let currQuestion = realm.objects(ExamBank.self).filter("questionSet = %@", questionSet!).filter("id = %@", questionIndex!)
        if let currQ = currQuestion.first {
            try! realm.write {
                currQ.selectedAns = sd.tag
            }
        }
        
        // Score Table - to save score
        let scoreTable = realm.objects(Score.self).filter("questionSet = %@", questionSet!)
        try! realm.write {
            if let scoreT = scoreTable.first {
                scoreT.score = currScore
            } else {
                let sc = Score()
                sc.questionSet = questionSet!
                sc.score = currScore
                realm.add(sc)
            }
        }
    }
    
    // set Color Red or Green for Incorrect or Correct choice
    func checkAnswer(_ sd : UIButton) {
        
        if (sd.tag == correctAnswer) {
            // CORRECT ANSWER !!
            SVProgressHUD.showSuccess(withStatus: "Correct!")
            
            if sd.backgroundColor != .green {
                // Reset all previous color
                resetAllChoicesColor()
                // Set the new correct answer to Green (only choice to have a color)
                sd.backgroundColor = .green
                // Add Score
                updateScore(with: 1);
            }
            // wait 0.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Change `0.5` to the desired wait seconds.
                // Show next question
                self.showNextQuestion()
            }
        } else {
            // WRONG ANSWER !!
            SVProgressHUD.showError(withStatus: "Incorrect")
            // Reset all previous color
            resetAllChoicesColor()
            // Set the wrong answer - to Red
            sd.backgroundColor = .red
            // Also Set the correct answer - to Green
            let correctChoice = self.view.viewWithTag(correctAnswer!) as? UIButton
            correctChoice!.backgroundColor = .green
        }
        SVProgressHUD.dismiss(withDelay: 1)
    }

    func resetAChoicesColor(_ btn : UIButton, selectedCol : UIColor?) {
        btn.backgroundColor = .white // selectedCol 
    }
    
    func resetAllChoicesColor() {
        var choice : UIButton?
        for i in 1...4 {
            choice = self.view.viewWithTag(i) as? UIButton
            choice?.backgroundColor = .white
        }
    }
    
    func updateScore(with score2Add : Int) {
        currScore = currScore + score2Add;
        lblScore.text = "Score: \(currScore)"
    }
// =============================================================================================================
// Assisting Function -- TESTING PICHAI
    @IBAction func btnTest(_ sender: Any) {
        
        print("Test me to Add Questions xx")
        
        let url = URL(fileURLWithPath: "/Users/Temp/Book6.csv") //Book2.csv")
        guard let data = readFileFrom(url) else {
            print("can't read")
            return }
        print(data)
        
        print("data.Count = \(data.count)")

        for i in 0..<data.count {
            print( "line = \(i)")
            // ===================================
            let eb = ExamBank()
            eb.questionSet = Int(data[i][0])!
            eb.id = Int(data[i][1])!
            eb.section = Int(data[i][2])!
            eb.question = String(data[i][3]).replacingOccurrences(of: "(c)", with: ",").replacingOccurrences(of: "(a)", with: "'")
            eb.answer1 = data[i][4].replacingOccurrences(of: "(c)", with: ",").replacingOccurrences(of: "(a)", with: "'")
            eb.answer2 = data[i][5].replacingOccurrences(of: "(c)", with: ",").replacingOccurrences(of: "(a)", with: "'")
            eb.answer3 = data[i][6].replacingOccurrences(of: "(c)", with: ",").replacingOccurrences(of: "(a)", with: "'")
            eb.answer4 = data[i][7].replacingOccurrences(of: "(c)", with: ",").replacingOccurrences(of: "(a)", with: "'")
            eb.correctAns = Int(data[i][8])!
            eb.selectedAns = 0 //Int(data[i][9])!
            eb.passedOrFailed = 0 // Int(data[i][10])!

            try! realm.write {
                realm.add(eb)
            }
            // ======================================
        
        }

    }
    
    func readFileFrom(_ fileURL: URL) -> [[String]]? {
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let data: [[String]] = content.components(separatedBy: "\n").map { $0.components(separatedBy: ",") }
            return data
        } catch {
            // nothing
        }
        return nil
    }

}  // Used to be Line 429

// Uncomment the following line to preserve selection between presentations
// self.clearsSelectionOnViewWillAppear = false

// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
// self.navigationItem.rightBarButtonItem = self.editButtonItem
