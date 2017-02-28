//
//  DrawView.swift
//  TouchTracker
//
//  Created by Dylan Bruschi on 2/27/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var currentLines = [NSValue:Line]()
    var currentCircle =  Line()
    var finishedCircles = [Line]()
    var finishedLines = [Line]()
    
    
    @IBInspectable var finishedLineColor: UIColor = UIColor.black  {
        didSet {
            setNeedsDisplay()
        }
    }
    
    
    @IBInspectable var currentLineColor: UIColor = UIColor.red {
        didSet {
            setNeedsDisplay()
        }
    }
    @IBInspectable var lineThickness: CGFloat = 10 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func strokeLine(line: Line) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
    }
    
    func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func strokeCircle(line: Line) {
        
        print(line)
        
        // Center of the circle is midpoint of the line
        let centerX = (line.begin.x + line.end.x)/2
        let centerY = (line.begin.y + line.end.y)/2
        
        
        // Radius of circle is length of the line divided by sqrt2 * 2
        let circum: CGFloat = distance(a: line.begin, b: line.end)/sqrt(2)
        let radius: CGFloat = circum/2
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX,y: centerY), radius: radius, startAngle: CGFloat(0), endAngle: CGFloat(M_PI*2), clockwise: true)
        
        circlePath.lineWidth = lineThickness
        
        circlePath.stroke()

    }
    
    
    func getLineAngle(line: Line) -> CGFloat {
        
        let x: CGFloat = line.begin.x
        let y: CGFloat = line.begin.y
        let dx: CGFloat = line.end.x - x
        let dy: CGFloat = line.end.y - y
    
        let radians: CGFloat = atan2(-dx, dy)
        let degrees: CGFloat = radians * (180/3.1415)
        
        return degrees
        
    }
    
    override func draw(_ rect: CGRect) {
        
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            strokeLine(line: line)
        }
        
        strokeCircle(line: currentCircle)
        
        finishedLineColor.setStroke()
        for line in finishedLines {
            strokeLine(line: line)
        }
        
        for line in finishedCircles {
            strokeCircle(line: line)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(#function)
        
        
        if touches.count == 2 {
            let beginTouch = touches[touches.startIndex] as UITouch
            let endTouch = touches[touches.index(touches.startIndex, offsetBy: 1)] as UITouch
            
            currentCircle.begin = beginTouch.location(in:self)
            currentCircle.end = endTouch.location(in:self)
        }
        else {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location)
            
            let key = NSValue(nonretainedObject: touch)
            

            currentLines[key] = newLine
        }
        }
            
        
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put it in a log statement to see the order of events
        print(#function)
        
            
            if touches.count == 2 {
                let beginTouch = touches[touches.startIndex] as UITouch
                let endTouch = touches[touches.index(touches.startIndex, offsetBy: 1)] as UITouch
                
                currentCircle.begin = beginTouch.location(in:self)
                currentCircle.end = endTouch.location(in:self)
            }
            else {
                
                for touch in touches {
                let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
            
            // Get the line angle
            let line = currentLines[key]
            let lineAngle = getLineAngle(line: line!)
            
            // Using the line angle to determine color
            let angleColor = UIColor(red: abs(lineAngle/180), green: 0, blue: 1-abs(lineAngle/180), alpha: 1.0)
            currentLineColor = angleColor
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       // Let's put in a log statement to see the order of events
        print(#function)
        
            
            if touches.count == 2 {
                
                let beginTouch = touches[touches.startIndex] as UITouch
                let endTouch = touches[touches.index(touches.startIndex, offsetBy: 1)] as UITouch

                
                currentCircle.begin = beginTouch.location(in:self)
                currentCircle.end = endTouch.location(in:self)
                    
                    finishedCircles.append(currentCircle)
                

                
            }
            else {
                 for touch in touches {
                    
                let key = NSValue(nonretainedObject: touch)
                
                if var line = currentLines[key] {
                line.end = touch.location(in: self)
                
                finishedLines.append(line)
                currentLines.removeValue(forKey: key)
                }
            }
            }
        
        
        setNeedsDisplay()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
}
