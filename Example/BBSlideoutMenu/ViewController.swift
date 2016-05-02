//
//  ViewController.swift
//  BBSlideoutMenu
//
//  Created by Michael Berger on 03/08/2016.
//  Copyright (c) 2016 Michael Berger. All rights reserved.
//

import UIKit
import BBSlideoutMenu

class ViewController: UIViewController, BBSlideoutMenuDelegate {

    
    @IBOutlet var buttonSlideMenu: BBSlideoutMenu!
    override func viewDidAppear(animated: Bool) {
       super.viewDidAppear(animated)
        // Call .setupEdgePan() after the view is done loading and presented to enable edge panning
        buttonSlideMenu.setupEdgePan()
        // Setup the optional delegate to get a call back when the menu did show
        buttonSlideMenu.delegate = self
    }

    
    func updateSettings() {
        buttonSlideMenu.slideTravelPercent = CGFloat(travelSlider.value)
        buttonSlideMenu.shrinkAmount       = CGFloat(Double(shrinkAmountTextField.text!)!)
        buttonSlideMenu.menuOffset         = CGFloat(Double(menuOffsetTextField.text!)!)
        buttonSlideMenu.slideTime          = Double(slideTimeTextField.text!)!
        buttonSlideMenu.zoomFactor         = CGFloat(zoomFactorSlider.value)
        buttonSlideMenu.springEnabled      = springEnabledSwitch.on
        buttonSlideMenu.springDamping      = CGFloat(springDampingSlider.value)
        buttonSlideMenu.backgroundImage    = backgroundSwitch.on ? UIImage(named: "Background") : nil;
    }
    
    @IBAction func onButtonTapped(sender: UIButton) {
        
        updateSettings()
        
        buttonSlideMenu.presentSlideMenu(true) { () -> Void in
            //Runs after menu is presented
        }
    }
    
    @IBAction func onDismissButtonTapped(sender: UIButton) {
        buttonSlideMenu.dismissSlideMenu(animated: true, time: nil)
    }
    
    
    func didStartEdgePanForBBSlideOutMenu(menu: BBSlideoutMenu) {
        updateSettings()
        
        statusBarStyle = .LightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func willPresentBBSlideoutMenu(menu: BBSlideoutMenu) {
        statusBarStyle = .LightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    func willDismissBBSlideoutMenu(menu: BBSlideoutMenu) {
        statusBarStyle = .Default
        setNeedsStatusBarAppearanceUpdate()
    }
    
    //MARK: - Slideout Menu outlets/actions live in the same viewcontroller!
    
    @IBOutlet weak var twitterLabel: UILabel!
    @IBAction func onTwitterTapped(sender: AnyObject) {
        let screenName =  twitterLabel.text!
        let appURL = NSURL(string: "twitter://user?screen_name=\(screenName)")!
        let webURL = NSURL(string: "https://twitter.com/\(screenName)")!
        
        openApp(appURL, webURL: webURL)
    }
    
    
    @IBOutlet weak var linkedinLabel: UILabel!
    @IBAction func onLinkedInTapped(sender: AnyObject) {
        let screenName =  linkedinLabel.text!
        let appURL = NSURL(string: "linkedin://profile?id=\(screenName)")!
        let webURL = NSURL(string: "https://www.linkedin.com/in/\(screenName)")!
        
        openApp(appURL, webURL: webURL)
    }
    
    
    @IBOutlet weak var instagramLabel: UILabel!
    @IBAction func onInstagramTapped(sender: AnyObject) {
        let screenName =  instagramLabel.text!
        let appURL = NSURL(string: "instagram://user?username=\(screenName)")!
        let webURL = NSURL(string: "https://www.instagram.com/\(screenName)")!
        
        openApp(appURL, webURL: webURL)
    }
    
    @IBOutlet weak var youtubeLabel: UILabel!
    @IBAction func onYouTubeTapped(sender: AnyObject) {
        let screenName =  youtubeLabel.text!
        let appURL = NSURL(string: "vnd.youtube://user/\(screenName)")!
        let webURL = NSURL(string: "https://www.youtube.com/\(screenName)")!
        
        openApp(appURL, webURL: webURL)
    }
    
    func openApp(appURL: NSURL, webURL: NSURL) {
        let application = UIApplication.sharedApplication()
        
        if !application.openURL(appURL) {
            application.openURL(webURL)
        }
 
    }
    
    //MARK: - Test app Junk
    
    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var shrinkAmountTextField: UITextField!
    @IBOutlet weak var menuOffsetTextField: UITextField!
    @IBOutlet weak var slideTimeTextField: UITextField!
    
    @IBOutlet weak var zoomFactorSlider: UISlider!
    @IBOutlet weak var zoomFactorReadoutLabel: UILabel!
    @IBAction func onZoomFactorChanged(sender: UISlider) {
        zoomFactorReadoutLabel.text = String.localizedStringWithFormat("%.2f", sender.value)
    }
    @IBOutlet weak var travelSlider: UISlider!
    @IBOutlet weak var travelSliderReadoutLabel: UILabel!
     @IBAction func onTravelSliderChanged(sender: UISlider) {
        travelSliderReadoutLabel.text = String.localizedStringWithFormat("%.2f", sender.value)
    }
    
    @IBOutlet weak var springDampingSlider: UISlider!
    @IBOutlet weak var springDampingReadoutLabel: UILabel!
    @IBAction func onSpringDampingSliderChanged(sender: UISlider) {
        springDampingReadoutLabel.text = String.localizedStringWithFormat("%.2f", sender.value)
    }
    
    
    @IBOutlet weak var leftSwipeImageView: UIImageView!
    @IBOutlet weak var rightSwipeImageView: UIImageView!

    @IBAction func onDirectionSegmentChanged(sender: UISegmentedControl) {
        buttonSlideMenu.slideDirection = sender.selectedSegmentIndex == 0 ? .Left : .Right
        buttonSlideMenu.setupEdgePan()
        
        leftSwipeImageView.hidden  = Bool(sender.selectedSegmentIndex)
        rightSwipeImageView.hidden = !Bool(sender.selectedSegmentIndex)
    }
    
    @IBOutlet weak var springEnabledSwitch: UISwitch!
    @IBOutlet weak var backgroundSwitch: UISwitch!
    
    
    @IBAction func tapHandle(sender: UITapGestureRecognizer) {
        UIApplication.sharedApplication().sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, forEvent:nil)
    }
    
    var statusBarStyle = UIStatusBarStyle.Default
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return statusBarStyle
    }
    
    
}

