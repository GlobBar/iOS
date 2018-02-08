//
//  RadioButtonGroup.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/17/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
import RadioButton

class RadioButtonGroup<T : CustomStringConvertible>
    : UIView {
    
    var selectedOption: T? {
        get {
            return pairs.filter { $0.button.isSelected }.first?.option
        }
    }
    
    typealias Pair = (button: RadioButton, option: T)
    fileprivate var pairs : [Pair] = []
    
    
    init() {
        super.init(frame: CGRect.zero)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addOptions
        (_ options: [T]) {
            
            let itemsCount = options.count
            guard itemsCount > 1 else {
                print("Can't add options without at least two options")
                return
            }
            
            
            let rowsCount: Int = (itemsCount + 1) / 2
            
            var rightColumnButtons : [RadioButton] = []
            var leftColumnButtons : [RadioButton] = []
            var spacingViews : [UIView] = []
            
            ///adding left column buttons and spacings between them
            for i in 0...rowsCount - 1
            {
                let spacingView = createSpacingViewBefore(leftColumnButtons.last, heightMasterSpacingView: spacingViews.last)
                spacingViews.append(spacingView)
                
                leftColumnButtons.append(createLeftColumnRadioButtonAfter(spacingView))
                
                if i == rowsCount - 1 {
                    spacingViews.append(createSpacingViewAfter(leftColumnButtons.last, heightMasterSpacingView: spacingView))
                }
            }
            
            ///adding right column buttons
            for i in rowsCount...itemsCount - 1 {
                
                let centerNeighbour = leftColumnButtons[i - rowsCount]
                rightColumnButtons.append(createRightColumnRadioButton(centerNighbour: centerNeighbour, upperNeighbour: rightColumnButtons.last))
                
            }
            
            ///settings raadio group
            rightColumnButtons.first!.groupButtons = rightColumnButtons.suffix(from: 1) + leftColumnButtons
            
            ///setting titles
            zip((leftColumnButtons + rightColumnButtons), options).forEach { input in
                    input.0.setTitle(input.1.description, for: UIControlState())
                    pairs.append(input)
                }
            
//            ///set default selected value
//            rightColumnButtons.first?.setSelected(true)
    }
    
    ///spacing views methods
    
    func createSpacingViewBefore(_ radioButton: RadioButton?, heightMasterSpacingView: UIView?) -> UIView {
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(view)
        
        if let rb = radioButton {
            
            guard let masterView = heightMasterSpacingView else { assert(false, "master View must be passed"); return UIView() }
            
            ///should set top constraint to radio button bottom = 0
            ///should set leading constraint equal to radioButton leading
            ///should set equal heights + equal widths with masterView
            
            let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: rb, attribute: .bottom, multiplier: 1, constant: 0)
            let leadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: rb, attribute: .leading, multiplier: 1, constant: 0)
            let equalWidthsConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: masterView, attribute: .width, multiplier: 1, constant: 0)
            let equalHeightsConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: masterView, attribute: .height, multiplier: 1, constant: 0)
            
            self.addConstraints([topConstraint, leadingConstraint, equalHeightsConstraint, equalWidthsConstraint])
            
        }
        else {
            
            ///it is the very first spacing view
            ///should set up fixed width, spacing to superview leading, zero spacing to superview top
            let widthConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 10)
            let leadingConstraint = NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1, constant: 0)
            let topConstraint = NSLayoutConstraint(item: view, attribute: .top, relatedBy:.equal, toItem: self, attribute: .top, multiplier: 1, constant: 0)
            
            self.addConstraints([leadingConstraint,topConstraint])
            view.addConstraint(widthConstraint)
        }
        
        return view
    }
    
    func createSpacingViewAfter(_ radioButton: RadioButton?, heightMasterSpacingView: UIView) -> UIView {
        
        let view = createSpacingViewBefore(radioButton, heightMasterSpacingView: heightMasterSpacingView)
        
        ///add bottom to superview constraint
        let bottomConstraint = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0)
        
        self.addConstraint(bottomConstraint)
        
        return view
    }
    
    ///radio button methods
    
    func createLeftColumnRadioButtonAfter(_ spacingView: UIView) -> RadioButton {
        let rb = constructRadioButton()
        
        ///set top constraint equal to spacing view
        ///set leading equal to leading of spacing view
        let topConstraint = NSLayoutConstraint(item: rb, attribute: .top, relatedBy: .equal, toItem: spacingView, attribute: .bottom, multiplier: 1, constant: 0)
        let leadingConstraint = NSLayoutConstraint(item: rb, attribute: .leading, relatedBy: .equal, toItem: spacingView, attribute: .leading, multiplier: 1, constant: 0)
        
        self.addConstraints([topConstraint, leadingConstraint])
        
        return rb
    }
    
    func createRightColumnRadioButton(centerNighbour centerNeighbour: RadioButton, upperNeighbour: RadioButton?) -> RadioButton {
        
        let rb = constructRadioButton()
        
        ///center with centerNeighbour
        ///set trailing to superview as GreaterThanOrEqual to constant
        ///set spacing with centerNeighbour as GreaterThanOrEqual to constant
        ///if upper neighbour exist => set equal leadings 
        ///else set trailing constraint with low priority to fixed constant
        
        let centerConstraint = NSLayoutConstraint(item: rb, attribute: .centerY, relatedBy: .equal, toItem: centerNeighbour, attribute: .centerY, multiplier: 1, constant: 0)
        let trailingGreaterConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: rb, attribute: .trailing, multiplier: 1, constant: 8)
        trailingGreaterConstraint.priority = UILayoutPriority(rawValue: 1000)
        let spacingConstrait = NSLayoutConstraint(item: rb, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: centerNeighbour, attribute: .trailing, multiplier: 1, constant: 8)
        
        let equalWidthConstraint = NSLayoutConstraint(item: rb, attribute: .width, relatedBy: .equal, toItem: centerNeighbour, attribute: .width, multiplier: 1, constant: 0)
        equalWidthConstraint.priority = UILayoutPriority(rawValue: 500)
        
        var variableConstraint: NSLayoutConstraint? = nil
        
        if let upper = upperNeighbour {
            
            variableConstraint = NSLayoutConstraint(item: rb, attribute: .leading, relatedBy: .equal, toItem: upper, attribute: .leading, multiplier: 1, constant: 0)
            variableConstraint!.priority = UILayoutPriority(rawValue: 1000)
        }
        else {
            variableConstraint = NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: rb, attribute: .trailing, multiplier: 1, constant: 8)
            variableConstraint!.priority = UILayoutPriority(rawValue: 100)
        }
        
        self.addConstraints([centerConstraint, trailingGreaterConstraint, spacingConstrait, equalWidthConstraint,variableConstraint!])
        
        return rb
    }
    
    func constructRadioButton() -> RadioButton {
        
        let button = DaButton()

        ///TODO: move label font to configuration and adjust it there based on screen size
        
        button.titleLabel?.font = UIConfiguration.appSecondaryFontOfSize(14)
        button.titleLabel?.lineBreakMode = .byWordWrapping
        button.contentHorizontalAlignment = .left
        
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.setTitleColor(UIColor.white, for: .selected)
        
        button.setImage(UIImage(named: "option_off"), for: UIControlState())
        button.setImage(UIImage(named: "option_on"), for: .selected)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(button)
        
        return button
    }
}



class DaButton : RadioButton {
    
    fileprivate var titleEdgeInset : UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.titleEdgeInsets = titleEdgeInset
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize : CGSize {
        var s = super.intrinsicContentSize
        s.width += titleEdgeInset.left
        return s
    }
    
}
 
