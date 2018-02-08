//
//  ReviewReportCollectionCell.swift
//  Night Life
//
//  Created by Vlad Soroka on 2/19/16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class ReviewReportCollectionCell : UICollectionViewCell {
    
    enum UIUserInterfaceIdiom : Int
    {
        case unspecified
        case phone
        case pad
    }
    
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
    }
    
    let suitableFontSizeMin: CGFloat = (DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P) ? 7.0 : 6.0
    let suitableFontSizeMax: CGFloat = (DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P) ? 10.0 : 8.0
    
    fileprivate var stampImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named: "stamp"))
        return view
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 217, green: 217, blue: 217)
        label.font = UIFont(name: "Roboto-Light", size: 9.0)
        label.textAlignment = NSTextAlignment.center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    ///////////////////////////////////////////////////////////////////////////
    var partyContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    var genderContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    var coverChargeContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    var queueContainer: UIView = {
        let container = UIView()
        return container
    }()
    
    var recommendsIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "recommends"))
        return icon
    }()
    
    var partyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor(red: 217, green: 217, blue: 217)
        label.text = "test"
        
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    ///////
    var genderIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "gender"))
        return icon
    }()
    
    var genderLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor(red: 217, green: 217, blue: 217)
        
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    ///////////
    var coverChargeIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "cover_chardge"))
        return icon
    }()
    
    var coverChargeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor(red: 217, green: 217, blue: 217)
        
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    /////////////
    var queueIcon: UIImageView = {
        let icon = UIImageView(image: UIImage(named: "queue"))
        return icon
    }()
    
    var queueLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textColor = UIColor(red: 217, green: 217, blue: 217)
        
        label.textAlignment = NSTextAlignment.center
        return label
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        partyLabel.font = UIFont(name: "Roboto-Light", size: suitableFontSizeMax)
        genderLabel.font = UIFont(name: "Roboto-Light", size: suitableFontSizeMax)
        coverChargeLabel.font = UIFont(name: "Roboto-Light", size: suitableFontSizeMax)
        queueLabel.font = UIFont(name: "Roboto-Light", size: suitableFontSizeMax)
        
        
        
        let ratio = CGFloat(167/24)
        stampImageView.frame = CGRect(x: self.contentView.frame.origin.x + 2,
                                      y: self.contentView.frame.origin.y + 2,
                                      width: self.contentView.frame.size.width - 4,
                                      height:((self.contentView.frame.size.width - 4) / ratio))
        
        let dateLabelNewWidth = self.stampImageView.frame.size.width-10
        dateLabel.frame = CGRect(x: 0,
                                 y: 0,
                                 width: dateLabelNewWidth,
                                 height: 21)
        
        dateLabel.center = stampImageView.center
        
        ////////////////////////////////////////////////////////
        let frameFor4Containers = CGRect(x: 0, y: stampImageView.frame.size.height+2, width: self.contentView.frame.size.width, height: self.contentView.frame.size.height - stampImageView.frame.size.height)
        
        // top left
        partyContainer.frame = CGRect(x: 0, y: frameFor4Containers.origin.y, width: frameFor4Containers.size.width/2, height: frameFor4Containers.size.height/2)
        
        
        // top right
        queueContainer.frame = CGRect(x: frameFor4Containers.size.width/2, y: frameFor4Containers.origin.y, width: frameFor4Containers.size.width/2, height: frameFor4Containers.size.height/2)
        
        // bottom left
        coverChargeContainer.frame = CGRect(x: 0, y: frameFor4Containers.origin.y + frameFor4Containers.size.height/2, width: frameFor4Containers.size.width/2, height: frameFor4Containers.size.height/2)
        // bottom right
        genderContainer.frame = CGRect(x: frameFor4Containers.size.width/2, y: frameFor4Containers.origin.y + (frameFor4Containers.size.height/2), width: frameFor4Containers.size.width/2, height: frameFor4Containers.size.height/2)
        
        //////////////////
        recommendsIcon.frame = CGRect(x: 0, y: 0, width: recommendsIcon.frame.size.width, height: recommendsIcon.frame.size.height)
        
        recommendsIcon.center = CGPoint(x: partyContainer.center.x, y: 17)
        
        partyLabel.frame = CGRect(x: 0,
                                  y: recommendsIcon.frame.origin.y + recommendsIcon.frame.size.height + 2,
                                  width: partyContainer.frame.size.width,
                                  height: partyContainer.frame.size.height - (recommendsIcon.frame.origin.y + recommendsIcon.frame.size.height + 2))
        
        ///////////////////
        queueIcon.frame = CGRect(x: 5, y: 5, width: queueIcon.frame.size.width, height: queueIcon.frame.size.height)
        
        queueIcon.center = CGPoint(x: queueContainer.frame.width/2, y: 17)
        
        queueLabel.frame = CGRect(x:0,
                                  y: queueIcon.frame.origin.y + queueIcon.frame.size.height + 2,
                                  width: queueContainer.frame.size.width,
                                  height: queueContainer.frame.size.height - (queueIcon.frame.origin.y + queueIcon.frame.size.height + 2))
        
        var fontSize : CGFloat = 0.0
        
        if (DeviceType.IS_IPHONE_6 || DeviceType.IS_IPHONE_6P) {
            
            if (queueLabel.text?.lengthOfBytes(using: .utf8) > 12) {
                
                fontSize = suitableFontSizeMin
            }
            else
            {
                fontSize = suitableFontSizeMax
            }
        }
        else {
            queueLabel.font = UIFont(name: "Roboto-Light", size: CGFloat(suitableFontSizeMin))
            
            ////////
            let textSize = CGSize(width: queueLabel.frame.size.width, height: CGFloat(MAXFLOAT))
            
            let sizeThatFits = queueLabel.sizeThatFits(textSize)
            let rHeight = lroundf(Float(sizeThatFits.height))
            
            let charSize = lroundf(Float(queueLabel.font.lineHeight));
            
            let lineCount = rHeight/charSize;
            
            if (lineCount == 1) {
                
                fontSize = suitableFontSizeMax
            }
            else
            {
                fontSize = suitableFontSizeMin
            }
        }
        queueLabel.font = UIFont(name: "Roboto-Light", size: CGFloat(fontSize))
        
        
        ///////////////////
        coverChargeIcon.frame = CGRect(x: 0, y: 0, width: coverChargeIcon.frame.size.width, height: coverChargeIcon.frame.size.height)
        
        coverChargeIcon.center = CGPoint(x: coverChargeContainer.center.x, y: 17)
        
        coverChargeLabel.frame = CGRect(x: 0,
                                        y: coverChargeIcon.frame.origin.y + coverChargeIcon.frame.size.height + 2,
                                        width: coverChargeContainer.frame.size.width,
                                        height: coverChargeContainer.frame.size.height - (coverChargeIcon.frame.origin.y + coverChargeIcon.frame.size.height + 2))
        ///////////////////
        genderIcon.frame = CGRect(x: 5, y: 5, width: genderIcon.frame.size.width, height: genderIcon.frame.size.height)
        
        genderIcon.center = CGPoint(x: genderContainer.frame.width/2, y: 17)
        
        genderLabel.frame = CGRect(x:0,
                                   y: genderIcon.frame.origin.y + genderIcon.frame.size.height + 2,
                                   width: genderContainer.frame.size.width,
                                   height: genderContainer.frame.size.height - (genderIcon.frame.origin.y + genderIcon.frame.size.height + 2))
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.addSubview(stampImageView)
        self.contentView.addSubview(dateLabel)
        
        self.contentView.addSubview(partyContainer)
        self.contentView.addSubview(genderContainer)
        self.contentView.addSubview(coverChargeContainer)
        self.contentView.addSubview(queueContainer)
        
        partyContainer.addSubview(recommendsIcon)
        partyContainer.addSubview(partyLabel)
        
        queueContainer.addSubview(queueIcon)
        queueContainer.addSubview(queueLabel)
        
        coverChargeContainer.addSubview(coverChargeIcon)
        coverChargeContainer.addSubview(coverChargeLabel)
        
        genderContainer.addSubview(genderIcon)
        genderContainer.addSubview(genderLabel)
        
    }
    
    func setReport(_ report: Report) {
        
        dateLabel.text = UIConfiguration.stringFromDate((report.createdDate)!)
        
        if let party = report.partyOnStatus {
            partyContainer.isHidden = false
            partyLabel.text = party.description
        }
        else {
            partyContainer.isHidden = true
        }
        
        if let charge = report.coverCharge {
            coverChargeContainer.isHidden = false
            coverChargeLabel.text = charge.description
        }
        else {
            coverChargeContainer.isHidden = true
        }
        
        if let queue = report.queue {
            queueContainer.isHidden = false
            queueLabel.text = queue.description
        }
        else {
            queueContainer.isHidden = true
        }
        
        if let gender = report.genderRatio {
            genderContainer.isHidden = false
            genderLabel.text = gender.description
        }
        else {
            genderContainer.isHidden = true
        }
    }
    
}
