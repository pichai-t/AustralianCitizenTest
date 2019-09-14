//
//  ExamBank.swift
//  Australian Citizenship Test
//
//  Created by Pichai Tangtrongsakundee on 11/5/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import UIKit
import RealmSwift

class ExamBank: Object {
    // Question ID and From which section
    // Primary Keys are questionSet+id (Unique)
    @objc dynamic var questionSet : Int = 0
    @objc dynamic var id : Int = 0
    
    // Question and Answers
    @objc dynamic var section : Int = 0
    @objc dynamic var question: String?
    @objc dynamic var answer1: String?
    @objc dynamic var answer2: String?
    @objc dynamic var answer3: String?
    @objc dynamic var answer4: String?
    
    @objc dynamic var correctAns: Int = 0
    @objc dynamic var selectedAns: Int = 0 // 0 = never tried,
    
    // History
    @objc dynamic var passedOrFailed: Int = 0
    // 1 = pass, 2 = fail, 0 = never tried
    
}
