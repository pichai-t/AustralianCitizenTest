//
//  ChartView.swift
//  Macaw1
//
//  Created by Pichai Tangtrongsakundee on 17/8/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import Foundation
import Macaw
import RealmSwift

class ChartView : MacawView {
    
    static var barData = ChartView.createData()
    static var dataDivisor = Double(maxValue)/Double(maxValueLineHeight)   // How many pixel per score
    static var adjustedData: [Double] = barData.map( { Double(($0.score)) / dataDivisor } ) // How long for that Score
    static var animations: [Animation] = []
    
    static var items = adjustedData.map { _ in Group() }
    
    // TODO: To keep in Para
    static let maxValue = 20
    static let maxValueLineHeight = 300
    static let lineWidth: Double = 275
    // -----
    
    static var defaultPath = Realm.Configuration.defaultConfiguration.fileURL?.path.replacingOccurrences(of: "default", with: "act")
    static var config = Realm.Configuration(fileURL: URL(string: defaultPath!), readOnly: false)
    static var realm = try! Realm(configuration: config)
    
    // Initialize 
    required init?(coder aDecoder: NSCoder) {
        super.init(node: ChartView.createChart(), coder: aDecoder)
        backgroundColor = .clear
    }
    
//    override func setNeedsDisplay() {
//        print("Test me Pichai")
//    }
    

    // the first method called!!
    private static func createChart() -> Group {
        // Add Items on X-Axis and Items on Y-Axis
        var items: [Node] = addXAxisItems() + addYAxisItems()
        // Append Bars
        items.append(createBars())
        return Group(contents: items, place: .identity) // return 'Group' and eventually go to super.int for Macaw Framework to create.
    }
    
    // Items on Y
    private static func addYAxisItems() -> [Node] {
        let maxLines     = 10
        let lineInterval = Int(maxValue/maxLines)
        let yAxisHeight: Double = 300
        let lineSpacing: Double = 30
        // Passing Line(75%) = 2.5 lines (25% from top)
        let passLineYPosition : Double =  (yAxisHeight/Double(maxLines)) * (2.5)
        
        var newNodes: [Node]    = []
        
        for i in 1...maxLines {
            let y = yAxisHeight - (Double(i) * lineSpacing)
            let valueLine = Line(x1: -4, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.black.with(a: 0.10))  // Line across
            let valueText = Text(text: "\(i*lineInterval)", align: .max, baseline: .mid, place: .move(dx: -10, dy: y))
            valueText.fill = Color.green
            newNodes.append(valueLine)
            newNodes.append(valueText)
        }
        
        let passLineOnyAxis = Line(x1: 0, y1: passLineYPosition, x2: lineWidth, y2: passLineYPosition).stroke(fill: Color.green.with(a: 0.45))
        newNodes.append(passLineOnyAxis)
        
        let yAxis = Line(x1: 0, y1: 0, x2: 0, y2: yAxisHeight).stroke(fill: Color.black.with(a: 0.45))
        newNodes.append(yAxis)
        return newNodes
    }
    
    // Items on X
    private static func addXAxisItems() -> [Node] {
        
        let chartBaseY: Double = 300
        var newNodes: [Node]   = []
        
        // Jump out if no data for xAxis
        guard adjustedData.count > 0 else { return newNodes }
        
        for i in 1...adjustedData.count {
            let x = (Double(i) * 20) - 3  // go to left by 3
            let valueText = Text(text: String(barData[i-1].questionSet), align: .max, baseline: .mid, place: .move(dx: x, dy: chartBaseY + 10))
            valueText.fill = Color.green
            newNodes.append(valueText)
        }
        
        let xAxis = Line(x1: 0, y1: chartBaseY, x2: lineWidth, y2: chartBaseY).stroke(fill: Color.black.with(a: 0.45))
        newNodes.append(xAxis)
        
        return newNodes
    }
    
    // Bars
    private static func createBars() -> Group {
        return items.group();
    }
    
    static func playAnimations() {
        prepBarData()
        animations.combine().play()
    }
    
    static func prepBarData() {
        barData = createData()
        dataDivisor = Double(maxValue)/Double(maxValueLineHeight)   // How many pixel per score
        adjustedData = barData.map( { Double(($0.score)) / dataDivisor } ) // How long for that Score
        
        let fill = LinearGradient(degree: 90, from: Color(val: 0x008000), to: Color(val: 0xffff00))
        items = adjustedData.map { _ in Group() }
        
        // prepare Animation object
        animations = items.enumerated().map { (i: Int, item: Group)  in
            item.contentsVar.animation(delay: Double(i) * 0.01) { t in
                let height = adjustedData[i] * t
                let rect = Rect(x: (Double(i)*20 + 10), y: Double(self.maxValueLineHeight)-height, w: 8, h: height)// Rect(x: (Double(i)*20 + 15), y: 100-height, w: 5, h: height)
                return [rect.fill(with: fill)]
            }
        }
    }
    
    
    //MARK: Data
    private static func createData() -> [ScoreData] {
        var returnedArray: [ScoreData] = []
        
        var ScoreTable : Results<Score>!
        ScoreTable = realm.objects(Score.self)
        guard ScoreTable.count > 0 else { return [] }

        for eachScore in ScoreTable {
            let eachScoreData = ScoreData(questionSet: eachScore.questionSet, score: eachScore.score)
            returnedArray.append(eachScoreData)
        }
        
        for i in (ScoreTable.count+1)...14 {
            let eachScoreData = ScoreData(questionSet: i, score: 0)
            returnedArray.append(eachScoreData)
        }
        
        return returnedArray
    }
    
}
