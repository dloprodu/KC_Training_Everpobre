//
//  NoteMediaElement.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 12/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct NoteMediaDescription {
    var point: CGPoint;
    var relativePoint: CGPoint
    var scale: CGFloat
    var rotation: CGFloat
    
    init(x: Float = 0, y: Float = 0, scale: Float = 1, rotation: Float = 0) {
        self.point = CGPoint(x: CGFloat( x ), y: CGFloat( y ))
        self.relativePoint = CGPoint(x: 0, y: 0)
        self.scale = CGFloat( scale )
        self.rotation = CGFloat( rotation )
    }
    
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
    weak var noteViewController: NoteViewController!
    let top: NSLayoutConstraint
    let left: NSLayoutConstraint
    let object: NSManagedObject!
    
    let constraints: [NSLayoutConstraint]
    var description: NoteMediaDescription
    var transformBeforeMove: CGAffineTransform = CGAffineTransform.identity

    init(_ object: NSManagedObject, viewController: NoteViewController, container: UIView, toItem: UIView) {
        self.item = Element()
        self.toItem = toItem
        self.noteViewController = viewController
        
        self.object = object
        
        if let note = object as? Note {
            self.description = NoteMediaDescription(x: note.locationX, y: note.locationY, scale: 1, rotation: 0)
        } else if let picture = object as? NotePicture {
            self.description = NoteMediaDescription(x: picture.locationX, y: picture.locationY, scale: picture.scale, rotation: picture.rotation)
        } else {
            self.description = NoteMediaDescription()
        }
        
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
    
    deinit {
        self.item.superview?.removeConstraints(constraints)
        self.item.removeFromSuperview()
    }
    
    @objc func moveElement(_ gesture : UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            self.noteViewController.closeKeyboard()
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
                self.noteViewController.viewDidLayoutSubviews()
                //self.viewController.view.layoutIfNeeded()
                //self.viewController.contentTextView.layoutIfNeeded()
            })
            self.updateObject()
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
            self.noteViewController.viewDidLayoutSubviews()
            self.updateObject()
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
            self.noteViewController.viewDidLayoutSubviews()
            self.updateObject()
            break
        default:
            break
        }
    }
    
    func updateObject() {
        if let note = object as? Note {
            note.update(locationX: Float( description.point.x ), y: Float( description.point.y ))
        } else if let picture = object as? NotePicture {
            picture.update(locationX: Float( description.point.x ), y: Float( description.point.y ), scale: Float( description.scale ), rotation: Float( description.rotation ))
        }
    }
}
