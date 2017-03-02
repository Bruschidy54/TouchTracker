//
//  DrawView.swift
//  TouchTracker
//
//  Created by Dylan Bruschi on 2/27/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit

class DrawView: UIView, UIGestureRecognizerDelegate {
    
    var currentLines = [NSValue:Line]()
    var currentCircle =  Line()
    var finishedLines = [Line]()
    var moveRecognizer: UIPanGestureRecognizer!
    var selectedLineIndex: Int? {
        didSet {
            if selectedLineIndex == nil {
                let menu = UIMenuController.shared
                menu.setMenuVisible(false, animated: true)
            }
        }
    }
    
    
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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        doubleTapRecognizer.numberOfTapsRequired = 2
        doubleTapRecognizer.delaysTouchesBegan = true
        addGestureRecognizer(doubleTapRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tap))
        tapRecognizer.delaysTouchesBegan = true
        tapRecognizer.require(toFail: doubleTapRecognizer)
        addGestureRecognizer(tapRecognizer)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        addGestureRecognizer(longPressRecognizer)
        
        moveRecognizer = UIPanGestureRecognizer(target: self, action: #selector(moveLine))
        moveRecognizer.delegate = self
        moveRecognizer.cancelsTouchesInView = false
        addGestureRecognizer(moveRecognizer)
    }
    
    func strokeLine(line: Line) {
        
        let isCircle = line.isCircle
        
        if isCircle {
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
        else {
        
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        path.lineCapStyle = CGLineCap.round
        
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
        }
    }
    
    func distance(a: CGPoint, b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    
    
    func getLineAngle(theLine: Line?) -> CGFloat {
        
        if let line = theLine{
        
        let x: CGFloat = line.begin.x
        let y: CGFloat = line.begin.y
        let dx: CGFloat = line.end.x - x
        let dy: CGFloat = line.end.y - y
    
        let radians: CGFloat = atan2(-dx, dy)
        let degrees: CGFloat = radians * (180/3.1415)
        
        return degrees
        }
        else{
            let errorString = "Line is nil"
            print(errorString)
            return CGFloat.abs(0)
        }
        
    }
    
    override func draw(_ rect: CGRect) {
        
        currentLineColor.setStroke()
        for (_, line) in currentLines {
            strokeLine(line: line)
        }
        
        if currentCircle.isCircle != false {
            strokeLine(line: currentCircle)
        }
        
        
        finishedLineColor.setStroke()
        for line in finishedLines {
            strokeLine(line: line)
        }
        
        if let index = selectedLineIndex {
            UIColor.green.setStroke()
            let selectedLine = finishedLines[index]
            strokeLine(line: selectedLine)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
//        print(#function)
        
        
        if touches.count == 2 {
            let beginTouch = touches[touches.startIndex] as UITouch
            let endTouch = touches[touches.index(touches.startIndex, offsetBy: 1)] as UITouch
            
            currentCircle.begin = beginTouch.location(in:self)
            currentCircle.end = endTouch.location(in:self)
            currentCircle.isCircle = true
        }
        else {
        
        for touch in touches {
            let location = touch.location(in: self)
            
            let newLine = Line(begin: location, end: location, isCircle: false)
            
            let key = NSValue(nonretainedObject: touch)
            

            currentLines[key] = newLine
        }
        }
            
        
        
        setNeedsDisplay()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        // Let's put it in a log statement to see the order of events
//        print(#function)
        
            
            if touches.count == 2 {
                let beginTouch = touches[touches.startIndex] as UITouch
                let endTouch = touches[touches.index(touches.startIndex, offsetBy: 1)] as UITouch
                
                currentCircle.begin = beginTouch.location(in:self)
                currentCircle.end = endTouch.location(in:self)
                let lineAngle = getLineAngle(theLine: currentCircle)
                let angleColor = UIColor(red: abs(lineAngle/180), green: 0, blue: 1-abs(lineAngle/180), alpha: 1.0)
                currentLineColor = angleColor
            }
            else {
                
                for touch in touches {
                let key = NSValue(nonretainedObject: touch)
            currentLines[key]?.end = touch.location(in: self)
            
            // Get the line angle
            let line = currentLines[key]
            let lineAngle = getLineAngle(theLine: line)
            
            // Using the line angle to determine color
            let angleColor = UIColor(red: abs(lineAngle/180), green: 0, blue: 1-abs(lineAngle/180), alpha: 1.0)
            currentLineColor = angleColor
            }
        }
        
        setNeedsDisplay()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
       // Let's put in a log statement to see the order of events
//        print(#function)
        
            
            if touches.count == 2 {
                
                let beginTouch = touches[touches.startIndex] as UITouch
                let endTouch = touches[touches.index(touches.startIndex, offsetBy: 1)] as UITouch

                
                currentCircle.begin = beginTouch.location(in:self)
                currentCircle.end = endTouch.location(in:self)
                    
                finishedLines.append(currentCircle)
                currentCircle = Line()
                

                
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
    
    func doubleTap(gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a double tap")
        
        
        selectedLineIndex = nil
        currentCircle = Line()
        currentLines.removeAll()
        finishedLines.removeAll()
        setNeedsDisplay()
    }
    
    func tap(gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a tap")
        
        let point = gestureRecognizer.location(in: self)
        selectedLineIndex = indexOfLineAtPoint(point: point)
        
        // Grab the menu controller
        let menu = UIMenuController.shared
        
        if selectedLineIndex != nil {
            
            // Make DrawView the target of menu item action messages
            becomeFirstResponder()
            
            // Create a new "Delete" UIMenuItem
            let deleteItem = UIMenuItem(title: "Delete", action: #selector(deleteLine))
            menu.menuItems = [deleteItem]
            
            // Tell the menu where it should come from and show it
            menu.setTargetRect(CGRect(x: point.x, y: point.y, width: 2, height: 2), in: self)
            menu.setMenuVisible(true, animated: true)
        }
        else {
            // Hide the menu if no line is selected
            menu.setMenuVisible(false, animated: true)

        }
        
        setNeedsDisplay()
    }
    
    func longPress(gestureRecognizer: UIGestureRecognizer) {
        print("Recognized a long press")
        
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self)
            selectedLineIndex = indexOfLineAtPoint(point: point)
            
            if selectedLineIndex != nil {
                currentLines.removeAll(keepingCapacity: false)
            }
        }
            else if gestureRecognizer.state == .ended {
                selectedLineIndex = nil
            }
        setNeedsDisplay()
        }
    
    func moveLine(gestureRecognizer: UIPanGestureRecognizer) {
        print("Recognized a pan")
        
        
        if let index = selectedLineIndex {
            // When the pan recognizer changes its position...
            if gestureRecognizer.state == .changed {
                // How far has the pan moved?
                let translation = gestureRecognizer.translation(in: self)
                
                // Add the translation to the current beginning and end points of the line
                finishedLines[index].begin.x += translation.x
                finishedLines[index].begin.y += translation.y
                finishedLines[index].end.x += translation.x
                finishedLines[index].end.y += translation.y
                
                gestureRecognizer.setTranslation(CGPoint.zero, in: self)
                
                // Redraw the screen
                setNeedsDisplay()
            }
        }
        else {
            // If no line is selected, do no do anything
            return
        }
    }
    

func deleteLine(sender: AnyObject) {
    
    // Remove the selected line from the list of finishedLines
    if let index = selectedLineIndex {
        finishedLines.remove(at: index)
        selectedLineIndex = nil
        
        // Redraw everything
        setNeedsDisplay()
    }
    
}
    
    override var canBecomeFirstResponder: Bool {
        return true
    }


    
    func indexOfLineAtPoint(point: CGPoint) -> Int? {
        
        // Find a line close to the point
        for (index, line) in finishedLines.enumerated() {
            let begin = line.begin
            let end = line.end
//            let isCircle = line.isCircle
            
            // ----Eventually find a solution to how to select circle----
            
            // Check a few points on the line
            
            
            for t in stride(from: CGFloat(0), to: 1.0, by: 0.05) {
                let x = begin.x + ((end.x - begin.x) * t)
                let y = begin.y + ((end.y - begin.y) * t)
                
                // If the tapped point is within 20 points, let's return this line
                if hypot(x - point.x, y - point.y) < 20.0 {
                    return index
                }
            }
        
        }
         print("No lines selected")
        return nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        print(#function)
        
        currentLines.removeAll()
        
        setNeedsDisplay()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
