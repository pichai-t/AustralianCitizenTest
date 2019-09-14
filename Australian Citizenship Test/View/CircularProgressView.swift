//
//  CircularProgressView.swift
//  CircularProgressBar
//
//  Created by Pichai Tangtrongsakundee on 21/7/19.
//  Copyright © 2019 Pichai Tangtrongsakundee. All rights reserved.
//

import UIKit

class CircularProgressView: UIView {
    // Variables
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    var progressColor = UIColor.white {
        didSet {
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet {
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    // Constructors
    override init(frame: CGRect) {
        super.init(frame: frame)
        createCircularPath()
    }
    // required Constructor for Sub-Class
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createCircularPath()
    }
    
    // function to create TrackLayer(background) and ProgressLayer(Foreground)
    fileprivate func createCircularPath() {
        self.backgroundColor = UIColor.white
        self.layer.cornerRadius = self.frame.size.width/2
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width-1.5)/2, startAngle: CGFloat(-1.0 * .pi), endAngle: CGFloat(0.0 * .pi), clockwise: true)
        
        // TrackLayer
        trackLayer.path = circlePath.cgPath
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.strokeColor = trackColor.cgColor
        trackLayer.lineWidth = 18.0
        trackLayer.strokeEnd = 1.0  // 100%
        layer.addSublayer(trackLayer)
        
        // ProgressLayer
        progressLayer.path = circlePath.cgPath
        progressLayer.fillColor = UIColor.clear.cgColor
        progressLayer.strokeColor = progressColor.cgColor
        progressLayer.lineWidth = 16.0
        progressLayer.strokeEnd = 0.02 // just a spot
        progressLayer.strokeStart = 0.005 // a little space
        layer.addSublayer(progressLayer)
    }
    
    // Drawing ProgressLayer to 'strokeEnd' value
    func setProgressWithAnimation(duration: TimeInterval, value: Float) {
        // Create Animation object
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        animation.fromValue = 0
        animation.toValue = value
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        
        if (value < 0.40) {
            progressColor = UIColor.red
        } else if (value < 0.75 ){
            progressColor = UIColor.yellow
        } else {
            progressColor = UIColor.green
        }
        
        progressLayer.strokeEnd = CGFloat(value)
        progressLayer.add(animation, forKey: "animateprogress")

    }
    
}


// Constant variables
fileprivate extension CircularProgressView {
    
    // To improve
    private struct Parameters {
        
        static let percentage : Float = 0.0
        
    }
    
    private var scorePercentage : Float {
        return 0.0
    }
    
    
}

