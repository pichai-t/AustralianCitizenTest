//
//  ViewController.swift
//  Australian Citizenship Test
//
//  Created by Pichai Tangtrongsakundee on 7/5/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import UIKit
import RealmSwift
import KYCircularProgress

class MainVC: UIViewController {

    @IBOutlet weak var circularProgress: CircularProgressView!
    @IBOutlet weak var percentageProgress: UILabel!
    @IBOutlet weak var textProgress: UILabel!
    
    var realm = try! Realm()
    var scores : Results<Score>!
    var StatusTable : Results<Status>!
    var currQuestionSet : Int = 1;
    let MAX_QUESTION_SET = 14

    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultPath = Realm.Configuration.defaultConfiguration.fileURL?.path
        let config = Realm.Configuration(fileURL: URL(string: defaultPath!.replacingOccurrences(of: "default", with: "act")), readOnly: false)
        realm = try! Realm(configuration: config)
        loadCurrentQuestionSet()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        drawCircular()
    }
    
    private func loadCurrentQuestionSet() {
        StatusTable = realm.objects(Status.self)
        // Setup "Current Question Set" - if not, 1 is the default.
        if let stat = StatusTable.first {
            currQuestionSet = stat.currQuestionSet
        } else {
            currQuestionSet = 1
        }
    }
    
    // Circular Progress
    private func drawCircular() {
        let myPct  = getPercentageValue()
        circularProgress.trackColor = UIColor.lightGray
        circularProgress.setProgressWithAnimation(duration: Para.AnimatedDuration, value: myPct)
        percentageProgress.text = String(format: "%.0f", myPct * 100)  + "%"
        textProgress.text = getProgressText(value: myPct)
    }
    
    private func getProgressText(value: Float) -> String  {
        return (value < Para.LowerScoreTier) ? "Not ready yet..." : (value < Para.MiddleScoreTier) ? "Almost ready!" : "Ready!!"
    }
    
    private func getPercentageValue() -> Float {
        scores = realm.objects(Score.self)  // Load all Scores into 'scores'
        var totalScore = 0
        let totalQuestionSet = scores.count
            if scores.count > 0 {
            for eachRow in scores {
                totalScore = totalScore + eachRow.score
            }
            return Float(totalScore) / (Float(totalQuestionSet) * Para.QuestionPerSet)
        }
        return 0
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if identifier == "gotoExamVC" {
            // guard currQuestionSet <= MAX_QUESTION_SET, else Alert then terminated.
            if currQuestionSet > MAX_QUESTION_SET  {
                let alert = UIAlertController(title: "You have finished all tests", message: "Click OK to close", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
                return false
            }
        }
        return true
    }
    
    
}



// Constant variables
fileprivate extension MainVC {
    private struct Para {
        static let AnimatedDuration : TimeInterval = 0.5
        static let QuestionPerSet : Float = 20.0
        static let LowerScoreTier : Float = 0.40
        static let MiddleScoreTier : Float = 0.75
    }
    


}

