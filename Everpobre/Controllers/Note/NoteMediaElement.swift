//
//  NoteMediaElement.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 12/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

// Constraints for UIImageView and MKMapView
class NoteMediaElement<Element> where Element: UIView {
    let item: Element
    weak var toItem: UIView!
    weak var view: NoteViewController!
    let top: NSLayoutConstraint
    let bottom: NSLayoutConstraint
    let left: NSLayoutConstraint
    let right: NSLayoutConstraint
    let constraints: [NSLayoutConstraint]
    
    var relativePoint: CGPoint!
    
    init(_ view: NoteViewController, container: UIView, toItem: UIView) {
        self.item = Element()
        self.toItem = toItem
        self.view = view
        
        container.addSubview(self.item)
        
        self.item.translatesAutoresizingMaskIntoConstraints = false
        
        top = NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: self.toItem, attribute: .top, multiplier: 1, constant: 20)
        
        bottom = NSLayoutConstraint(item: item, attribute: .bottom, relatedBy: .equal, toItem: self.toItem, attribute: .bottom, multiplier: 1, constant: -20)
        
        left = NSLayoutConstraint(item: item, attribute: .left, relatedBy: .equal, toItem: self.toItem, attribute: .left, multiplier: 1, constant: 20)
        
        right = NSLayoutConstraint(item: item, attribute: .right, relatedBy: .equal, toItem: self.toItem, attribute: .right, multiplier: 1, constant: -20)
        
        constraints = [
            NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150),
            NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150),
            top,
            bottom,
            left,
            right
        ]
        
        container.addConstraints(constraints)
        
        NSLayoutConstraint.deactivate([bottom, right])
        
        self.item.isUserInteractionEnabled = true
        self.item.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(moveElement)))
    }
    
    @objc func moveElement(_ gesture : UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.view.closeKeyboard()
            relativePoint = gesture.location(in: gesture.view)
            UIView.animate(withDuration: 0.1, animations: {
                self.item.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
            })
            break
        case .changed:
            let location = gesture.location(in: self.toItem)
            
            left.constant = location.x - relativePoint.x
            top.constant = location.y - relativePoint.y
            break
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
                self.item.transform = CGAffineTransform.init(scaleX: 1, y: 1)
                self.view.viewDidLayoutSubviews()
            })
            break
        default:
            break
        }
    }
    
    @objc func scale() {
        
    }
    
    @objc func rotate() {
        
    }
}
