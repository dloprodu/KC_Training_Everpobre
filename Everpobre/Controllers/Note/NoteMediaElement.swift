//
//  NoteMediaElement.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 12/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit

struct NoteMediaDescription {
    var point: CGPoint = CGPoint(x: 0, y: 15)
    var relativePoint: CGPoint = CGPoint(x: 0, y: 0)
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    
    mutating func relativePointAt(_ point: CGPoint) {
        relativePoint = point
    }
    
    mutating func move(toPoint target: CGPoint) {
        point.x = target.x - relativePoint.x
        point.y = target.y - relativePoint.x
    }
    
    mutating func scale(value: CGFloat) {
        scale += value
    }
    
    mutating func rotate(value: CGFloat) {
        rotation += value
    }
}

class NoteMediaElement<Element> where Element: UIView {
    let item: Element
    weak var toItem: UIView!
    weak var viewController: NoteViewController!
    let top: NSLayoutConstraint
    let left: NSLayoutConstraint
    
    let constraints: [NSLayoutConstraint]
    var description: NoteMediaDescription
    var transformBeforeMove: CGAffineTransform = CGAffineTransform.identity

    init(_ viewController: NoteViewController, container: UIView, toItem: UIView) {
        self.item = Element()
        self.toItem = toItem
        self.viewController = viewController
        self.description = NoteMediaDescription()
        
        container.addSubview(self.item)
        
        self.item.translatesAutoresizingMaskIntoConstraints = false
        
        top = NSLayoutConstraint(item: item, attribute: .top, relatedBy: .equal, toItem: self.toItem, attribute: .top, multiplier: 1, constant: description.point.y)
        
        left = NSLayoutConstraint(item: item, attribute: .left, relatedBy: .equal, toItem: self.toItem, attribute: .left, multiplier: 1, constant: description.point.x)

        constraints = [
            NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150),
            NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0, constant: 150),
            top,
            left
        ]
        
        container.addConstraints(constraints)
        
        self.item.transform = self.item.transform.scaledBy(x: description.scale, y: description.scale)
        self.item.transform = self.item.transform.rotated(by: description.rotation)
        
        self.item.isUserInteractionEnabled = true
        self.item.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(moveElement)))
        self.item.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scaleElement)))
        self.item.addGestureRecognizer(UIRotationGestureRecognizer(target: self, action: #selector(rotateElement)))
    }
    
    @objc func moveElement(_ gesture : UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.viewController.closeKeyboard()
            description.relativePointAt( gesture.location(in: gesture.view) )
            UIView.animate(withDuration: 0.1, animations: {
                self.transformBeforeMove = self.item.transform
                self.item.transform = self.item.transform.scaledBy(x: 1.2, y: 1.2)
            })
            break
        case .changed:
            description.move(toPoint: gesture.location(in: self.toItem))
            left.constant = description.point.x
            top.constant = description.point.y
            break
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1, animations: {
                self.item.transform = self.transformBeforeMove
                self.viewController.viewDidLayoutSubviews()
                //self.viewController.view.layoutIfNeeded()
                //self.viewController.contentTextView.layoutIfNeeded()
            })
            break
        default:
            break
        }
    }
    
    @objc func scaleElement(_ gesture: UIPinchGestureRecognizer) {
        switch gesture.state {
        case .began:
            break
        case .changed:
            if description.scale > 1.5 && gesture.scale > 1 {
                break
            }
            
            if description.scale < 0.7 && gesture.scale < 1 {
                break
            }
 
            description.scale(value: gesture.scale - 1)
            
            self.item.transform = self.item.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1
            break
            
        case .ended, .cancelled:
            self.viewController.viewDidLayoutSubviews()
            break
        default:
            break
        }
    }
    
    @objc func rotateElement(_ gesture : UIRotationGestureRecognizer) {
        switch gesture.state {
        case .began, .changed:
            description.rotate(value: gesture.rotation)
            
            self.item.transform = self.item.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
            break
        case .ended, .cancelled:
            self.viewController.viewDidLayoutSubviews()
            break
        default:
            break
        }
    }
}
