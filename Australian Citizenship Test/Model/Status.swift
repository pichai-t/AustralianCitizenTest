//
//  Status.swift
//  Australian Citizenship Test
//
//  Created by Pichai Tangtrongsakundee on 7/7/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import UIKit
import RealmSwift

class Status : Object {
    // Status table is "a table with one row as always"
    
    // Latest Question Set and ID
    @objc dynamic var currQuestionSet : Int = 1
    @objc dynamic var currID : Int = 0 //currID is NOT REALLY USED YET!!
    
    // Total Scores?  Correct, Failed?
    
}
