//
//  RatingControl.swift
//  RockDock
//
//  Created by Stephen Buck on 9/1/16.
//  Copyright © 2016 Stephen Buck. All rights reserved.
//

import UIKit

class RatingControl: UIView {
    
    // MARK: Properties
    
    var rating = 0{
        didSet {
            print("in call didSet")
            setNeedsLayout()
        }
    }
    
    let spacing = 5
    let starCount = 5
    var ratingButtons = [UIButton]()
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    // MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let selectedRock = UIImage(named: "selectedRock")
        let unselectedRock = UIImage(named: "unselectedRock")
        for _ in 0..<starCount {
            print ("RatingControl.init rating: \(rating)")
            let button = UIButton(type: UIButtonType.custom)
            button.setImage(unselectedRock, for: .normal)
            button.setImage(selectedRock, for: .selected)
            button.setImage(selectedRock, for: [.highlighted, .selected])
            button.adjustsImageWhenHighlighted = false
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchDown)
            ratingButtons += [button]
            addSubview(button)
        }
        updateButtonSelectionStates()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize * starCount) + (spacing * (starCount - 1))
        
        return CGSize(width: width, height: buttonSize)
    
    }
    
    
    
    override func layoutSubviews() {
        // Set the button's width and height to a square the size of the frame's height.
        let buttonSize = Int(frame.size.height);
        
        
        var buttonFrame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        
        // Offset each button's origin by the length of the button plus spacing.
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (buttonSize + spacing))
            button.frame = buttonFrame
        }
        
        
    }
    
 
    // MARK: Button Action
    func ratingButtonTapped(button: UIButton) {
        rating = ratingButtons.index(of: button)! + 1
        print("Rating Button Tapped \(rating)")
        updateButtonSelectionStates()
    }
    
    func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            // If the index of a button is less than the rating, that button should be selected.
            button.isSelected = index < rating
            print("index:\(index)  button.isSelected:\(button.isSelected) rating:\(rating)")
        }
    }
    

}
