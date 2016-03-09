//
//  ViewController.swift
//  BBSlideoutMenu
//
//  Created by Michael Berger on 03/08/2016.
//  Copyright (c) 2016 Michael Berger. All rights reserved.
//

import UIKit
import BBSlideoutMenu

class ViewController: UIViewController {

    
    @IBOutlet var leftSwipeSlideMenu:  BBSlideoutMenu!
    @IBOutlet var buttonSlideMenu:     BBSlideoutMenu!
    @IBOutlet var rightSwipeSlideMenu: BBSlideoutMenu!
    
    override func viewDidAppear(animated: Bool) {
       super.viewDidAppear(animated)
        leftSwipeSlideMenu.setupEdgePan()
        rightSwipeSlideMenu.setupEdgePan()
        
       
    }

    
    @IBAction func onButtonTapped(sender: UIButton) {
        
        
        
    }
    
    
}

