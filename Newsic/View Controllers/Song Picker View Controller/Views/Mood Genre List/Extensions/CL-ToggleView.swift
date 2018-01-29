//
//  CL-ToggleView.swift
//  Nusic
//
//  Created by Miguel Alcantara on 20/12/2017.
//  Copyright © 2017 Miguel Alcantara. All rights reserved.
//

import Foundation

extension ChoiceListView {
    
    func setupToggleView() {
        toggleView.backgroundColor = UIColor.clear
        
        var containsBlurEffect = false
        for toggleViewSubview in toggleView.subviews {
            if toggleViewSubview.tag == 1 {
                containsBlurEffect = true
                break;
            }
        }
        
        if !containsBlurEffect {
            toggleView.addBlurEffect(style: .dark, alpha: 0.7)
        }
        
        toggleViewHeight = toggleView.frame.height
        setupArrow()
        
        setupOpenBezierPaths()
    }
    
    func manageToggleView() {
        toggleArrow()
        toggleBezierPaths()
    }
    
    func setupArrow() {
        if toggleView.subviews.contains(arrowImageView) {
            arrowImageView.removeFromSuperview()
        }
        let image = UIImage(named: "Arrow")
        arrowImageView = UIImageView(frame: CGRect(x: toggleView.bounds.origin.x, y: toggleView.bounds.origin.y, width: self.bounds.width, height: toggleViewHeight))
        arrowImageView.image = image!
        arrowImageView.contentMode = .scaleAspectFit
        toggleView.addSubview(arrowImageView)
        showOpenArrow()
    }
    
    func toggleArrow() {
//        setupArrow()
        if isOpen {
            showCloseArrow()
        } else {
            showOpenArrow()
        }
    }
    
    func showOpenArrow() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.arrowImageView.transform = CGAffineTransform(rotationAngle: .pi)
        }, completion: nil)
    }
    
    func showCloseArrow() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
            self.arrowImageView.transform = CGAffineTransform.identity
        }, completion: nil)
        
    }
    
    func removeBezierPaths() {
        leftLayer.removeFromSuperlayer()
        rightLayer.removeFromSuperlayer()
    }
    
    func toggleBezierPaths() {
        removeBezierPaths()
        if isOpen {
            setupCloseBezierPaths()
        } else {
            setupOpenBezierPaths()
        }
    }
    
    func setupOpenBezierPaths() {
        var initialX:CGFloat = 8
        var initialY:CGFloat = 0
        
        let leftPath = UIBezierPath();
        let endpointLeft = self.frame.width/2 - (arrowImageView.image?.size.width)!
        leftPath.move(to: CGPoint(x: initialX, y: initialY))
        leftPath.addLine(to: CGPoint(x: initialX, y: toggleView.bounds.height/4))
        let radius = toggleView.bounds.height/2 - toggleView.bounds.height/4
        leftPath.addArc(withCenter: CGPoint(x: initialX + radius, y: toggleView.bounds.height/4), radius: radius, startAngle: .pi, endAngle: .pi*0.5, clockwise: false)
        leftPath.addLine(to: CGPoint(x: endpointLeft, y: toggleView.bounds.height/2))
        
        leftLayer = CAShapeLayer()
        leftLayer.path = leftPath.cgPath
        leftLayer.fillColor = UIColor.clear.cgColor
        leftLayer.strokeColor = NusicDefaults.greenColor.cgColor
        leftLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(leftLayer)
        
        initialX = self.frame.width - 8
        
        let rightPath = UIBezierPath();
        let endpointRight = self.frame.width/2 + (arrowImageView.image?.size.width)!
        rightPath.move(to: CGPoint(x: initialX, y: 0))
        rightPath.addLine(to: CGPoint(x: initialX, y: toggleView.bounds.height/4))
//        rightPath.addLine(to: CGPoint(x: initialX-8, y: toggleView.bounds.height/2))
        
        rightPath.addArc(withCenter: CGPoint(x: initialX - radius, y: toggleView.bounds.height/4), radius: radius, startAngle: 0, endAngle: .pi*0.5, clockwise: true)
        rightPath.addLine(to: CGPoint(x: endpointRight, y: toggleView.bounds.height/2))
        
        rightLayer = CAShapeLayer()
        rightLayer.path = rightPath.cgPath
        rightLayer.fillColor = UIColor.clear.cgColor
        rightLayer.strokeColor = NusicDefaults.greenColor.cgColor
        rightLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(rightLayer)
    }
    
    func setupCloseBezierPaths() {
        var initialX:CGFloat = 8
        var initialY:CGFloat = toggleView.bounds.height
        
        let leftPath = UIBezierPath();
        let endpointLeft = self.frame.width/2 - (arrowImageView.image?.size.width)!
        leftPath.move(to: CGPoint(x: initialX, y: initialY))
        leftPath.addLine(to: CGPoint(x: initialX, y: initialY-toggleView.bounds.height/4))
//        leftPath.addLine(to: CGPoint(x: initialX + 8, y: toggleView.bounds.height/2))
        let radius = toggleView.bounds.height/2 - toggleView.bounds.height/4
        leftPath.addArc(withCenter: CGPoint(x: initialX + radius, y: 3*toggleView.bounds.height/4), radius: radius, startAngle: .pi, endAngle: .pi*1.5, clockwise: true)
        leftPath.addLine(to: CGPoint(x: endpointLeft, y: toggleView.bounds.height/2))
        
        leftLayer = CAShapeLayer()
        leftLayer.path = leftPath.cgPath
        leftLayer.fillColor = UIColor.clear.cgColor
        leftLayer.strokeColor = NusicDefaults.greenColor.cgColor
        leftLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(leftLayer)
        
        initialX = self.frame.width - 8
        
        let rightPath = UIBezierPath();
        let endpointRight = self.frame.width/2 + (arrowImageView.image?.size.width)!
        rightPath.move(to: CGPoint(x: initialX, y: initialY))
        rightPath.addLine(to: CGPoint(x: initialX, y: initialY-toggleView.bounds.height/4))
//        rightPath.addLine(to: CGPoint(x: initialX-8, y: toggleView.bounds.height/2))
        
        rightPath.addArc(withCenter: CGPoint(x: initialX - radius, y: 3*toggleView.bounds.height/4), radius: radius, startAngle: 0, endAngle: .pi*1.5, clockwise: false)
        rightPath.addLine(to: CGPoint(x: endpointRight, y: toggleView.bounds.height/2))
        
        rightLayer = CAShapeLayer()
        rightLayer.path = rightPath.cgPath
        rightLayer.fillColor = UIColor.clear.cgColor
        rightLayer.strokeColor = NusicDefaults.greenColor.cgColor
        rightLayer.lineWidth = lineWidth
        
        self.layer.addSublayer(rightLayer)
    }
    
}
