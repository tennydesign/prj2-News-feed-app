//
//  UIDelegation.swift
//  project2_NewsFeed
//
//  Created by Tennyson Pinheiro on 10/19/17.
//  Copyright © 2017 Tenny. All rights reserved.
//

import Foundation

// NOT IN USE.

protocol UIObjectsDelegationProtocol{
    func fadeOutControls()
    func fadeInControls()
    func fadeInArrow()
    func fadeOutArrow()
    func resizeArrow()
}

class animationSingleton {
    static let sharedInstance = animationSingleton()
    var delegate: UIObjectsDelegationProtocol?

    private init() {
        
    }
    
    func startAnimationOnSliderItems() {
        delegate?.fadeInControls()
        delegate?.fadeOutControls()
    }
    
    func prepareArrowForScroll(){
        delegate?.fadeOutArrow()
    //    delegate?.resizeArrow()
    }
    
    func fadeInArrowEndofScroll(){
        delegate?.fadeInArrow()
    }
    
    func resizeArrowOnStopScrolling(){
        //delegate?.resizeArrow()
    }
}

// YET
