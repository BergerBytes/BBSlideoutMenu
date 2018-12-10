//
//  BBSlideoutMenu.swift
//  BergerBytes.co
//
//  Created by Michael Berger on 3/7/16.
//  Copyright © 2016 bergerbytes. All rights reserved.
//

import UIKit

public enum Direction {
    case left
    case right
}

public protocol BBSlideoutMenuDelegate: class {
    func didPresent(slideoutMenu menu: BBSlideoutMenu)
    func willPresent(slideoutMenu menu: BBSlideoutMenu)
    
    func didDismiss(slideoutMenu menu: BBSlideoutMenu)
    func willDismiss(slideoutMenu menu: BBSlideoutMenu)
    
    func didStartEdgePanFor(slideoutMenu menu: BBSlideoutMenu)
}

open class BBSlideoutMenu: UIView  {
    
    //MARK: - Inspectables
    
    @IBInspectable var direction: String = "left" {
        didSet {
            switch direction {
            case "left":
                slideDirection = .left
            case "right":
                slideDirection = .right
            default:
                direction = "left"
                slideDirection = .left
            }
        }
    }
    
    @IBInspectable open var slideTravelPercent: CGFloat = 0.8 {
        didSet {
            if slideTravelPercent > 1 {
                slideTravelPercent = 1
            } else if slideTravelPercent < 0.1 {
                slideTravelPercent = 0.1
            }
        }
    }
    
    @IBInspectable open var shrinkAmount: CGFloat = 60 {
        didSet {
            if shrinkAmount < 0 {
                shrinkAmount = 0
            } else if shrinkAmount > UIScreen.main.bounds.height/2 {
                print("BBSlideoutMenu: ShrinkAmount too high!!")
                shrinkAmount = 60
            }
        }
    }
    
    @IBInspectable open var menuOffset: CGFloat = 150
    @IBInspectable open var slideTime: Double = 0.5
    @IBInspectable open var zoomFactor: CGFloat = 0.8
    @IBInspectable open var springEnabled: Bool = true
    /**
     The damping ratio for the spring animation as it approaches its quiescent state.
     To smoothly decelerate the animation without oscillation, use a value of 1. Employ a damping ratio closer to zero to increase oscillation.
     */
    @IBInspectable open var springDamping: CGFloat = 0.5 {
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
    open var slideDirection: Direction = .left {
        didSet {
            edgePanGesture?.edges = slideDirection == .left ? .right : .left
        }
    }
    
    open var backgroundImage: UIImage? {
        didSet {
            if backgroundImage == nil {
                self.backgroundColor = savedBackgroundColor;
            }
        }
    }
    
    open var delegate: BBSlideoutMenuDelegate?
    
    fileprivate
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
    open func setupEdgePan() {
        
        if savedBackgroundColor == nil {
            savedBackgroundColor = self.backgroundColor;
        }
        
        if keyWindow == nil {
            keyWindow = UIApplication.shared.keyWindow!
        }
        
        if  let epGesture = edgePanGesture,
            let index = self.keyWindow.gestureRecognizers?.index(of: epGesture) {
                self.keyWindow.gestureRecognizers?.remove(at: index)
        }
        
        edgePanGesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(BBSlideoutMenu.edgeHandle(_:)))
        edgePanGesture?.edges = slideDirection == .left ? .right : .left
        keyWindow.gestureRecognizers?.append(edgePanGesture!)
    }
    
    /**
     Shows the slide out menu
     - parameter animate: A Bool that specifies whether to animate the transition
     - parameter didPresentMenu: Calls when the animation is completed, Pass nil to ignore callback
     */
    open func presentSlideMenu(_ animate: Bool?, didPresentMenu: (() -> Void)?) {
        if savedBackgroundColor == nil {
            savedBackgroundColor = self.backgroundColor;
        }
        
        if keyWindow == nil {
            keyWindow = UIApplication.shared.keyWindow!
        }
        
        let size = keyWindow.frame.size
        
        //MARK: Image VIew
        // Create, Configure and add a screenshot of the current view
        viewImage = keyWindow.snapshotView(afterScreenUpdates: false)
        guard (viewImage != nil) else {
            return
        }
        viewImage!.frame = keyWindow.frame
        viewImage!.translatesAutoresizingMaskIntoConstraints = false
        viewImage!.clipsToBounds = true
        
        viTop    = viewImage!.topAnchor.constraint(equalTo: keyWindow.topAnchor, constant: 0)
        viBottom = viewImage!.bottomAnchor.constraint(equalTo: keyWindow.bottomAnchor, constant: 0)
        viSlide  = slideDirection == .left ? viewImage!.trailingAnchor.constraint(equalTo: keyWindow.trailingAnchor, constant: 0) : viewImage!.leadingAnchor.constraint(equalTo: keyWindow.leadingAnchor, constant: 0)
        
        
        
        viRatio = NSLayoutConstraint(
            item: viewImage!,
            attribute: .height,
            relatedBy: .equal,
            toItem: viewImage,
            attribute: .width,
            multiplier: (size.height / size.width),
            constant: 0)
        
        viewImage!.addConstraint(viRatio)
        
        keyWindow.addSubview(viewImage!)
        
        viRatio.isActive  = true
        viTop.isActive    = true
        viBottom.isActive = true
        viSlide.isActive  = true
        
        //MARK: Background View
        coverView = UIImageView(frame: keyWindow.frame)
        
        if let validBackgroundImage = backgroundImage {
            coverView.image = validBackgroundImage
            coverView.contentMode = .scaleAspectFill
            backgroundColor = UIColor.clear
        } else {
            coverView.backgroundColor = self.backgroundColor
        }
        coverView.isHidden = false
        keyWindow.insertSubview(coverView, belowSubview: viewImage!)
        //MARK: Slideout View
        
        keyWindow.insertSubview(self, belowSubview: viewImage!)
        
        self.translatesAutoresizingMaskIntoConstraints = false
                
        self.heightAnchor.constraint(equalToConstant: size.height).isActive                      = true
        self.widthAnchor.constraint(equalToConstant: (size.width * slideTravelPercent)).isActive = true
        self.centerYAnchor.constraint(equalTo: keyWindow.centerYAnchor).isActive           = true
        if slideDirection == .left {
            menuAnchor = self.leadingAnchor.constraint(equalTo: viewImage!.trailingAnchor)
        } else {
            menuAnchor = self.trailingAnchor.constraint(equalTo: viewImage!.leadingAnchor)
        }
        menuAnchor.isActive = true
        
        setupStartingValues()
        
        
        slideAmount = slideDirection == .left ? -(keyWindow.bounds.width * slideTravelPercent) : keyWindow.bounds.width * slideTravelPercent
        
        if let shouldAnimate = animate {
            
            setupDestinationValues()
            
            if shouldAnimate {
                animateSlideOpen { () -> Void in
                    didPresentMenu?()
                }
            } else {
              delegate?.willPresent(slideoutMenu: self)
                self.viewImage!.layer.cornerRadius = 5
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                didPresentMenu?()
              delegate?.didPresent(slideoutMenu: self)
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
    open func dismissSlideMenu(_ animated: Bool, time: Double?) {
        if keyWindow == nil {
            keyWindow = UIApplication.shared.keyWindow!
        }
        
      delegate?.willDismiss(slideoutMenu: self)
        
        viTop.constant    = 0
        viBottom.constant = -viTop.constant
        viSlide.constant  = 0
        menuAnchor.constant = menuOffset * (slideDirection == .right ? 1 : -1)
        
        UIView.animate(
            withDuration: animated ? (time != nil ? time! : slideTime) : 0,
            delay: 0.0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0.0,
            options: UIViewAnimationOptions(),
            
            animations: { () -> Void in
                
                self.keyWindow.layoutIfNeeded()
                self.viewImage!.layer.cornerRadius = 0
                self.self.transform = CGAffineTransform(scaleX: self.zoomFactor, y: self.zoomFactor)
                
            }) { (complete) -> Void in
                
                self.coverView.removeFromSuperview()
                self.removeFromSuperview()
                
                UIView.animate(withDuration: 0.1,
                    animations: { () -> Void in
                        self.viewImage!.alpha = 0
                        
                    }, completion: { (completed) -> Void in
                        self.viewImage!.removeFromSuperview()
                        if let epGesture = self.edgePanGesture {
                            if self.keyWindow.gestureRecognizers!.index(of: epGesture) == nil {
                                self.keyWindow.gestureRecognizers?.append(epGesture)
                            }
                        }
                      self.delegate?.didDismiss(slideoutMenu: self)
                })
                
        }
        
    }
    
    //MARK: Internal Functions
    
    fileprivate func setupDestinationValues() {
        viTop.constant    = shrinkAmount
        viBottom.constant = -viTop.constant
        viSlide.constant  = slideAmount
        menuAnchor.constant = 0
    }
    
    fileprivate func setupStartingValues() {
        menuAnchor.constant = menuOffset * (slideDirection == .right ? 1 : -1)
        self.transform = CGAffineTransform(scaleX: zoomFactor, y: zoomFactor)
        keyWindow.layoutIfNeeded()
    }
    
    fileprivate func animateSlideOpen(_ animationEnd: ( () -> Void )?) {
        
        if keyWindow == nil {
            keyWindow = UIApplication.shared.keyWindow!
        }
        
      delegate?.willPresent(slideoutMenu: self)
        
        if let epGesture = edgePanGesture,
            let index = self.keyWindow.gestureRecognizers?.index(of: epGesture) {
                self.keyWindow.gestureRecognizers?.remove(at: index)
        }
        
        setupDestinationValues()
        
        UIView.animate(withDuration: slideTime,
            delay: 0.0,
            usingSpringWithDamping: springEnabled ? springDamping : 1,
            initialSpringVelocity: 0.0,
            options: .curveLinear,
            
            animations: { () -> Void in
                
                self.keyWindow.layoutIfNeeded()
                self.viewImage!.layer.cornerRadius = 5
                self.transform = CGAffineTransform(scaleX: 1, y: 1)
                
            }) { (complete) -> Void in
              self.delegate?.didPresent(slideoutMenu: self)
                animationEnd?()
        }
        
        UIView.animate(withDuration: slideTime, animations: { () -> Void in
            
            
            
            
            }, completion: { (complete) -> Void in
                
        }) 
        
    }
    
    
    func tapHandle(_ tap: UITapGestureRecognizer) {
        dismissSlideMenu(true, time: nil)
    }
    
    func panHandle(_ pan: UIPanGestureRecognizer) {
        
        if keyWindow == nil {
            keyWindow = UIApplication.shared.keyWindow!
        }
        
        let transition = pan.translation(in: self)
        var percentage = transition.x / self.bounds.width * (slideDirection == .right ? -1 : 1)
        
        switch pan.state {
        case .changed:
            
            if percentage >= 1 { percentage = 1 }
            
            viSlide.constant  = slideAmount - (slideAmount * percentage)
            viTop.constant    = shrinkAmount - (shrinkAmount * percentage)
            viBottom.constant = -viTop.constant
            
            let scale = 1 - ((1 - zoomFactor) * percentage)
            transform = CGAffineTransform(scaleX: scale, y: scale)
            
            let offset = menuOffset * (slideDirection == .right ? 1 : -1)
            menuAnchor.constant = (offset * percentage)
            
            if percentage > 0 {
                viewImage!.layer.cornerRadius = 5 - (5 * percentage)
            }
            
            keyWindow.layoutIfNeeded()
            
        case .ended:
            
            let v = pan.velocity(in: keyWindow).x
            
            if (slideDirection == .left ? v : -v) > 500 || abs(percentage) > 0.8 {
                dismissSlideMenu(true, time: slideTime - abs((slideTime * Double(percentage))))
            } else {
                animateSlideOpen(nil)
            }
            
        default:
            break
        }
        
    }
    
    
    
    func edgeHandle(_ edge: UIScreenEdgePanGestureRecognizer) {
        if keyWindow == nil {
            keyWindow = UIApplication.shared.keyWindow!
        }
        
      delegate?.didStartEdgePanFor(slideoutMenu: self)
        
        var transition = edge.translation(in: self)
        var percentage = (transition.x / self.bounds.width)
        
        switch edge.state {
            
        case .began:
            
            transition = edge.translation(in: self)
            
            presentSlideMenu(nil, didPresentMenu: nil)
            
        case .changed:
            percentage = transition.x / self.bounds.width * (slideDirection == .left ? -1 : 1)
            
            if percentage < 0 { percentage = 0 }
            
            viSlide.constant  = (slideAmount * percentage)
            viTop.constant    = (shrinkAmount * percentage)
            viBottom.constant = -viTop.constant
            
            let offset = menuOffset * (slideDirection == .right ? 1 : -1)
            menuAnchor.constant = offset - (offset * percentage)
            
            viewImage!.layer.cornerRadius = (5 * percentage)
            
            
            let scale = zoomFactor + ((1 - zoomFactor) * percentage)
            transform = CGAffineTransform(scaleX: scale, y: scale)
        case .ended:
            
            let v = edge.velocity(in: keyWindow).x
            
            if (slideDirection == .right ? v : -v) > 500 || abs(percentage) > 0.5 {
                
                animateSlideOpen({ () -> Void in
                    
                })
                
            } else {
                dismissSlideMenu(true, time: 0.1)
            }
            
        default:
            break
        }
        
    }
    
    
    
    //MARK: -
}


public extension BBSlideoutMenuDelegate {
    func didPresent(slideoutMenu menu: BBSlideoutMenu) {}
    func willPresent(slideoutMenu menu: BBSlideoutMenu) {}
    func didDismiss(slideoutMenu menu: BBSlideoutMenu) {}
    func willDismiss(slideoutMenu menu: BBSlideoutMenu) {}
    func didStartEdgePanFor(slideoutMenu menu: BBSlideoutMenu) {}
}
