//
//  ColorPickerView.swift
//  TouchTracker
//
//  Created by Dylan Bruschi on 3/2/17.
//  Copyright © 2017 Dylan Bruschi. All rights reserved.
//

import UIKit

protocol ColorChangeMenuDelegate: class {
    func didPickColor(color: UIColor)
}

@IBDesignable class ColorPickerView: UIView {
    
    var view: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadViewFromXibFile() -> UIView {
//        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ColorPickerView", bundle: nil)
        let view = nib.instantiate(withOwner: nil, options:nil)[0] as! UIView
        return view
    }
    
    
    
    var delegate:ColorChangeMenuDelegate?
    
    @IBAction func redButton(_ sender: UIButton) {
        delegate?.didPickColor(color: sender.backgroundColor!)
        self.removeFromSuperview()
        
    }
    
   
    @IBAction func orangeButton(_ sender: UIButton) {
        delegate?.didPickColor(color: sender.backgroundColor!)
        self.removeFromSuperview()
    }
    
    @IBAction func yellowButton(_ sender: UIButton) {
        delegate?.didPickColor(color: sender.backgroundColor!)
        self.removeFromSuperview()
    }
    
    @IBAction func greenButton(_ sender: UIButton) {
        delegate?.didPickColor(color: sender.backgroundColor!)
        self.removeFromSuperview()
    }
    
    
    @IBAction func blueButton(_ sender: UIButton) {
        delegate?.didPickColor(color: sender.backgroundColor!)
        self.removeFromSuperview()
    }
    
    @IBAction func indigoButton(_ sender: UIButton) {
        delegate?.didPickColor(color: sender.backgroundColor!)
        self.removeFromSuperview()
    }
    
    
    @IBAction func violetButton(_ sender: UIButton) {
        delegate?.didPickColor(color: sender.backgroundColor!)
        self.removeFromSuperview()
    }
    
    func setupView() {
    view = loadViewFromXibFile()
    view.frame = bounds
    addSubview(view)
    
    }
    
    
 
}


