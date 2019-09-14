//
//  Status.swift
//  Australian Citizenship Test
//
//  Created by Pichai Tangtrongsakundee on 1/6/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import UIKit
import RealmSwift

class Score : Object {
    // Score of each QuestionSet!
    @objc dynamic var questionSet : Int = 1
    @objc dynamic var score : Int = 0
}
