//
//  Button.swift
//  ImageCardCarousel
//
//  Created by Charles Martin Reed on 12/30/18.
//  Copyright © 2018 Charles Martin Reed. All rights reserved.
//

import UIKit

class VisitSiteButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupVisitSiteButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupVisitSiteButton()
    }
    
    private func setupVisitSiteButton(){
        backgroundColor = UIColor.highlightColor
        layer.cornerRadius = 12
        titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        setTitle("Visit Site", for: .normal)
        setTitleColor(.white, for: .normal)
    }
    
}
