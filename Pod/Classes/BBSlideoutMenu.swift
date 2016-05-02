//
//  BBSlideoutMenu.swift
//  BergerBytes.co
//
//  Created by Michael Berger on 3/7/16.
//  Copyright © 2016 bergerbytes. All rights reserved.
//

import UIKit

public enum Direction {
    case Left
    case Right
}

public protocol BBSlideoutMenuDelegate: class {
    func didPresentBBSlideoutMenu(menu: BBSlideoutMenu)
    func willPresentBBSlideoutMenu(menu: BBSlideoutMenu)
    
    func didDismissBBSlideoutMenu(menu: BBSlideoutMenu)
    func willDismissBBSlideoutMenu(menu: BBSlideoutMenu)
    
    func didStartEdgePanForBBSlideOutMenu(menu: BBSlideoutMenu)
}

public class BBSlideoutMenu: UIView  {
    
    //MARK: - Inspectables
    
    @IBInspectable var direction: String = "left" {
        didSet {
            switch direction {
            case "left":
                slideDirection = .Left
            case "right":
                slideDirection = .Right
            default:
                direction = "left"
                slideDirection = .Left
            }
        }
    }
    
    @IBInspectable public var slideTravelPercent: CGFloat = 0.8 {
        didSet {
            if slideTravelPercent > 1 {
                slideTravelPercent = 1
            } else if slideTravelPercent < 0.1 {
                slideTravelPercent = 0.1
            }
        }
    }
    
    @IBInspectable public var shrinkAmount: CGFloat = 60 {
        didSet {
            if shrinkAmount < 0 {
                shrinkAmount = 0
            } else if shrinkAmount > UIScreen.mainScreen().bounds.height/2 {
                print("BBSlideoutMenu: ShrinkAmount too high!!")
                shrinkAmount = 60
            }
        }
    }
    
    @IBInspectable public var menuOffset: CGFloat = 150
    @IBInspectable public var slideTime: Double = 0.5
    @IBInspectable public var zoomFactor: CGFloat = 0.8
    @IBInspectable public var springEnabled: Bool = true
    /**
     The damping ratio for the spring animation as it approaches its quiescent state.
     To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
     */
    @IBInspectable public var springDamping: CGFloat = 0.5 {
        didSet {
            if springDamping < 0 {
                springDamping = 0
            } else if springDamping > 1 {
                springDamping = 1
            }
        }
    }
    
    //MARK: - Properties
    ///The direction the view will travel to make room for the menu. Uses .Left or .Right
    public var slideDirection: Direction = .Left {
        didSet {
            edgePanGesture?.edges = slideDirection == .Left ? .Right : .Left
        }
    }
    
    public var backgroundImage: UIImage? {
        didSet {
            if backgroundImage == nil {
                self.backgroundColor = savedBackgroundColor;
            }
        }
    }
    
    public var delegate: BBSlideoutMenuDelegate?
    
    private
    var menuAnchor: NSLayoutConstraint!
    var viewImage: UIView?
    var viTop: NSLayoutConstraint!
    var viBottom: NSLayoutConstraint!
    var viSlide: NSLayoutConstraint!
    var viRatio: NSLayoutConstraint!
    var coverView: UIImageView!
    var keyWindow: UIWindow!
    var slideAmount: CGFloat!
    var edgePanGesture: UIScreenEdgePanGestureRecognizer?
    var savedBackgroundColor: UIColor!
    //MARK: - Functions
    
    /**
    Sets up a EdgePan gesture to open the Slide Menu. Must be called again if the slideDirection has been changed
    */
    public func setupEdgePan() {
        
        if savedBackgroundColor == nil {
            savedBackgroundColor = self.backgroundColor;
        }
        
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().keyWindow!
        }
        
        if  let epGesture = edgePanGesture,
            let index = self.keyWindow.gestureRecognizers?.indexOf(epGesture) {
                self.keyWindow.gestureRecognizers?.removeAtIndex(index)
        }
        
        edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(BBSlideoutMenu.edgeHandle(_:)))
        edgePanGesture?.edges = slideDirection == .Left ? .Right : .Left
        keyWindow.gestureRecognizers?.append(edgePanGesture!)
    }
    
    /**
     Shows the slide out menu
     - parameter animate: A Bool that specifies whether to animate the transition
     - parameter didPresentMenu: Calls when the animation is completed, Pass nil to ignore callback
     */
    public func presentSlideMenu(animate: Bool?, didPresentMenu: (() -> Void)?) {
        
        if savedBackgroundColor == nil {
            savedBackgroundColor = self.backgroundColor;
        }
        
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().keyWindow!
        }
        
        let size = keyWindow.frame.size
        
        //MARK: Image VIew
        // Create, Configure and add a screenshot of the current view
        viewImage = keyWindow.snapshotViewAfterScreenUpdates(false)
        guard (viewImage != nil) else {
            return
        }
        viewImage!.frame = keyWindow.frame
        viewImage!.translatesAutoresizingMaskIntoConstraints = false
        viewImage!.clipsToBounds = true
        
        viTop    = viewImage!.topAnchor.constraintEqualToAnchor(keyWindow.topAnchor, constant: 0)
        viBottom = viewImage!.bottomAnchor.constraintEqualToAnchor(keyWindow.bottomAnchor, constant: 0)
        viSlide  = slideDirection == .Left ? viewImage!.trailingAnchor.constraintEqualToAnchor(keyWindow.trailingAnchor, constant: 0) : viewImage!.leadingAnchor.constraintEqualToAnchor(keyWindow.leadingAnchor, constant: 0)
        
        
        
        viRatio = NSLayoutConstraint(
            item: viewImage!,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: viewImage,
            attribute: .Width,
            multiplier: (size.height / size.width),
            constant: 0)
        
        viewImage!.addConstraint(viRatio)
        
        keyWindow.addSubview(viewImage!)
        
        viRatio.active  = true
        viTop.active    = true
        viBottom.active = true
        viSlide.active  = true
        
        //MARK: Background View
        coverView = UIImageView(frame: keyWindow.frame)
        
        if let validBackgroundImage = backgroundImage {
            coverView.image = validBackgroundImage
            coverView.contentMode = .ScaleAspectFill
            backgroundColor = UIColor.clearColor()
        } else {
            coverView.backgroundColor = self.backgroundColor
        }
        coverView.hidden = false
        keyWindow.insertSubview(coverView, belowSubview: viewImage!)
        //MARK: Slideout View
        
        keyWindow.insertSubview(self, belowSubview: viewImage!)
        
        self.translatesAutoresizingMaskIntoConstraints = false
                
        self.heightAnchor.constraintEqualToConstant(size.height).active                      = true
        self.widthAnchor.constraintEqualToConstant((size.width * slideTravelPercent)).active = true
        self.centerYAnchor.constraintEqualToAnchor(keyWindow.centerYAnchor).active           = true
        if slideDirection == .Left {
            menuAnchor = self.leadingAnchor.constraintEqualToAnchor(viewImage!.trailingAnchor)
        } else {
            menuAnchor = self.trailingAnchor.constraintEqualToAnchor(viewImage!.leadingAnchor)
        }
        menuAnchor.active = true
        
        setupStartingValues()
        
        
        slideAmount = slideDirection == .Left ? -(keyWindow.bounds.width * slideTravelPercent) : keyWindow.bounds.width * slideTravelPercent
        
        if let shouldAnimate = animate {
            
            setupDestinationValues()
            
            if shouldAnimate {
                animateSlideOpen { () -> Void in
                    didPresentMenu?()
                }
            } else {
                delegate?.willPresentBBSlideoutMenu(self)
                self.viewImage!.layer.cornerRadius = 5
                self.transform = CGAffineTransformMakeScale(1, 1)
                didPresentMenu?()
                delegate?.didPresentBBSlideoutMenu(self)
            }
            
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(BBSlideoutMenu.panHandle(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(BBSlideoutMenu.tapHandle(_:)))
        self.viewImage!.gestureRecognizers = [panGesture, tapGesture]
        
    }
    
    
    /**
     Dismisses the slide menu
     
     - parameter animated: A Bool that specifies whether to animate the transition
     - parameter time: Time in seconds the animation will take. Pass nil to use default value setup in storyboard
     */
    public func dismissSlideMenu(animated animated: Bool, time: Double?) {
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().keyWindow!
        }
        
        delegate?.willDismissBBSlideoutMenu(self)
        
        viTop.constant    = 0
        viBottom.constant = -viTop.constant
        viSlide.constant  = 0
        menuAnchor.constant = menuOffset * (slideDirection == .Right ? 1 : -1)
        
        UIView.animateWithDuration(
            animated ? (time != nil ? time! : slideTime) : 0,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: .CurveEaseInOut,
            
            animations: { () -> Void in
                
                self.keyWindow.layoutIfNeeded()
                self.viewImage!.layer.cornerRadius = 0
                self.self.transform = CGAffineTransformMakeScale(self.zoomFactor, self.zoomFactor)
                
            }) { (complete) -> Void in
                
                self.coverView.removeFromSuperview()
                self.removeFromSuperview()
                
                UIView.animateWithDuration(0.1,
                    animations: { () -> Void in
                        self.viewImage!.alpha = 0
                        
                    }, completion: { (completed) -> Void in
                        self.viewImage!.removeFromSuperview()
                        if let epGesture = self.edgePanGesture {
                            if self.keyWindow.gestureRecognizers!.indexOf(epGesture) == nil {
                                self.keyWindow.gestureRecognizers?.append(epGesture)
                            }
                        }
                        self.delegate?.didDismissBBSlideoutMenu(self)
                })
                
        }
        
    }
    
    //MARK: Internal Functions
    
    private func setupDestinationValues() {
        viTop.constant    = shrinkAmount
        viBottom.constant = -viTop.constant
        viSlide.constant  = slideAmount
        menuAnchor.constant = 0
    }
    
    private func setupStartingValues() {
        menuAnchor.constant = menuOffset * (slideDirection == .Right ? 1 : -1)
        self.transform = CGAffineTransformMakeScale(zoomFactor, zoomFactor)
        keyWindow.layoutIfNeeded()
    }
    
    private func animateSlideOpen(animationEnd: ( () -> Void )?) {
        
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().keyWindow!
        }
        
        delegate?.willPresentBBSlideoutMenu(self)
        
        if let epGesture = edgePanGesture,
            let index = self.keyWindow.gestureRecognizers?.indexOf(epGesture) {
                self.keyWindow.gestureRecognizers?.removeAtIndex(index)
        }
        
        setupDestinationValues()
        
        UIView.animateWithDuration(slideTime,
            delay: 0.0,
            usingSpringWithDamping: springEnabled ? springDamping : 1,
            initialSpringVelocity: 0.0,
            options: .CurveLinear,
            
            animations: { () -> Void in
                
                self.keyWindow.layoutIfNeeded()
                self.viewImage!.layer.cornerRadius = 5
                self.transform = CGAffineTransformMakeScale(1, 1)
                
            }) { (complete) -> Void in
                self.delegate?.didPresentBBSlideoutMenu(self)
                animationEnd?()
        }
        
        UIView.animateWithDuration(slideTime, animations: { () -> Void in
            
            
            
            
            }) { (complete) -> Void in
                
        }
        
    }
    
    
    func tapHandle(tap: UITapGestureRecognizer) {
        dismissSlideMenu(animated: true, time: nil)
    }
    
    func panHandle(pan: UIPanGestureRecognizer) {
        
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().keyWindow!
        }
        
        let transition = pan.translationInView(self)
        var percentage = transition.x / self.bounds.width * (slideDirection == .Right ? -1 : 1)
        
        switch pan.state {
        case .Changed:
            
            if percentage >= 1 { percentage = 1 }
            
            viSlide.constant  = slideAmount - (slideAmount * percentage)
            viTop.constant    = shrinkAmount - (shrinkAmount * percentage)
            viBottom.constant = -viTop.constant
            
            let scale = 1 - ((1 - zoomFactor) * percentage)
            transform = CGAffineTransformMakeScale(scale, scale)
            
            let offset = menuOffset * (slideDirection == .Right ? 1 : -1)
            menuAnchor.constant = (offset * percentage)
            
            if percentage > 0 {
                viewImage!.layer.cornerRadius = 5 - (5 * percentage)
            }
            
            keyWindow.layoutIfNeeded()
            
        case .Ended:
            
            let v = pan.velocityInView(keyWindow).x
            
            if (slideDirection == .Left ? v : -v) > 500 || abs(percentage) > 0.8 {
                dismissSlideMenu(animated: true, time: slideTime - abs((slideTime * Double(percentage))))
            } else {
                animateSlideOpen(nil)
            }
            
        default:
            break
        }
        
    }
    
    
    
    func edgeHandle(edge: UIScreenEdgePanGestureRecognizer) {
        if keyWindow == nil {
            keyWindow = UIApplication.sharedApplication().keyWindow!
        }
        
        delegate?.didStartEdgePanForBBSlideOutMenu(self)
        
        var transition = edge.translationInView(self)
        var percentage = (transition.x / self.bounds.width)
        
        switch edge.state {
            
        case .Began:
            
            transition = edge.translationInView(self)
            
            presentSlideMenu(nil, didPresentMenu: nil)
            
        case .Changed:
            percentage = transition.x / self.bounds.width * (slideDirection == .Left ? -1 : 1)
            
            if percentage < 0 { percentage = 0 }
            
            viSlide.constant  = (slideAmount * percentage)
            viTop.constant    = (shrinkAmount * percentage)
            viBottom.constant = -viTop.constant
            
            let offset = menuOffset * (slideDirection == .Right ? 1 : -1)
            menuAnchor.constant = offset - (offset * percentage)
            
            viewImage!.layer.cornerRadius = (5 * percentage)
            
            
            let scale = zoomFactor + ((1 - zoomFactor) * percentage)
            transform = CGAffineTransformMakeScale(scale, scale)
        case .Ended:
            
            let v = edge.velocityInView(keyWindow).x
            
            if (slideDirection == .Right ? v : -v) > 500 || abs(percentage) > 0.5 {
                
                animateSlideOpen({ () -> Void in
                    
                })
                
            } else {
                dismissSlideMenu(animated: true, time: 0.1)
            }
            
        default:
            break
        }
        
    }
    
    
    
    //MARK: -
}


public extension BBSlideoutMenuDelegate {
    func didPresentBBSlideoutMenu(menu: BBSlideoutMenu) {}
    func willPresentBBSlideoutMenu(menu: BBSlideoutMenu) {}
    func didDismissBBSlideoutMenu(menu: BBSlideoutMenu) {}
    func willDismissBBSlideoutMenu(menu: BBSlideoutMenu) {}
    func didStartEdgePanForBBSlideOutMenu(menu: BBSlideoutMenu) {}
}
