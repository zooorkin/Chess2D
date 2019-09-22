//
//  ChessFigure.swift
//  Chess
//
//  Created by Андрей Зорькин on 23.07.17.
//  Copyright © 2017 Андрей Зорькин. All rights reserved.
//

import Foundation
import UIKit

class ChessFigure: UIImageView{
    var type: ChessPieceType?
    var game: ChessGame?
    
    var animator: UIDynamicAnimator?
    var attachment: UIAttachmentBehavior?
    var snap: UISnapBehavior?
    
    var lastTouch: CGPoint?
    var loastTouchSuperView: CGPoint?
    var pieceTag: Int!
    var color: ChessColor!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.yellow
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 1.5
        self.clipsToBounds = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.superview?.bringSubviewToFront(self)
        game?.freezeOthers(excluding: pieceTag)
        lastTouch = touches.first?.location(in: self)
        loastTouchSuperView = touches.first?.location(in: self.superview)
        if animator != nil, snap != nil{
            animator!.removeBehavior(snap!)
        }
        animator = UIDynamicAnimator(referenceView: self.superview!)
        
        attachment = UIAttachmentBehavior(item: self, attachedToAnchor: self.center)
        attachment?.length = 0
        attachment?.damping = 1
        animator?.addBehavior(attachment!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let currentTouch = touches.first!.location(in: self.superview)
        
        let x = self.frame.width / 2 - lastTouch!.x
        let y = self.frame.height / 2 - lastTouch!.y
        
        attachment?.anchorPoint = CGPoint(x: currentTouch.x + x, y: currentTouch.y + y)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        animator!.removeBehavior(attachment!)
        game?.freezeFor(color: color == .white ? .black : .white)
        let currentTouch = touches.first!.location(in: self.superview)
        let x = self.frame.width / 2 - lastTouch!.x
        let y = self.frame.height / 2 - lastTouch!.y
        
        snap = UISnapBehavior(item: self, snapTo: self.center)
        snap?.damping = 1
        let newPoint = CGPoint(x: currentTouch.x + x, y: currentTouch.y + y)
        
        snap?.snapPoint = game!.getPositionForSnap(point: newPoint)
        animator?.addBehavior(snap!)
        let from_location = game!.getCoordinatesForPosition(point: loastTouchSuperView!)
        let to_location = game!.getCoordinatesForPosition(point: newPoint)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000)){
            self.animator?.removeAllBehaviors()
            self.game?.makeMove(from: from_location, to: to_location)
        }
    }
    
}
