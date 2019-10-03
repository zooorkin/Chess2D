//
//  ChessFigure.swift
//  Chess
//
//  Created by Андрей Зорькин on 23.07.17.
//  Copyright © 2017 Андрей Зорькин. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable

class ChessFigure: UIView{
    
    var typeOfPiece: ChessPieceType?
    var presenter: IChessPresenter?
    
    var chessView: IChessFigureSupport!
    
    var animator: UIDynamicAnimator?
    var attachment: UIAttachmentBehavior?
    var snap: UISnapBehavior?
    
    var lastTouch: CGPoint?
    var loastTouchSuperView: CGPoint?
    var pieceTag: Int!
    var color: ChessColor!
    
    @IBOutlet weak var imageView: UIImageView!
    public var image: UIImage? {
        get {
            return imageView.image
        }
        set {
            imageView.image = newValue
        }
    }
    
    public var isPawn: Bool {
        get {
            return false
        }
        set {
            if newValue {
                let r = self.frame.width / 2
                path = circlePathWithCenter(center: CGPoint(x: r, y: r), radius: 0.5*r)
                setNeedsDisplay()
            } else {
                let r = self.frame.width / 2
                path = circlePathWithCenter(center: CGPoint(x: r, y: r), radius: 0.8*r)
                setNeedsDisplay()
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func loadFromXib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "ChessFigure", bundle: bundle)
        return nib.instantiate(withOwner: self, options: nil).first! as! UIView
    }
    
    func setupView(){
        let xibView = loadFromXib()
        xibView.backgroundColor = .clear
        xibView.frame = self.bounds
        xibView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(xibView)
        
        self.backgroundColor = UIColor.yellow
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.layer.shadowOpacity = 0.8
        self.layer.shadowRadius = 1.5
        self.clipsToBounds = false
        isPawn = false
        setNeedsDisplay()
    }
    
    var path: UIBezierPath?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        UIColor.red.set()
        path?.stroke()
        path?.lineWidth = 2.0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.superview?.bringSubviewToFront(self)
        let hit = touches.contains { (touch) -> Bool in
            let touchPoint = touch.location(in: self)
            return path!.contains(touchPoint)
        }
        if !hit {
            return
        }
        //presenter?.freezeOthers(excluding: pieceTag)
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
        super.touchesMoved(touches, with: event)
        if let attachment = attachment {
            let currentTouch = touches.first!.location(in: self.superview)
            let x = self.frame.width / 2 - lastTouch!.x
            let y = self.frame.height / 2 - lastTouch!.y
            attachment.anchorPoint = CGPoint(x: currentTouch.x + x, y: currentTouch.y + y)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchesEnded(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if let animator = animator, let presenter = presenter {
            animator.removeBehavior(attachment!)
            // Вроде не нужно
            //presenter.freezeFor(color: color == .white ? .black : .white)
            let currentTouch = touches.first!.location(in: self.superview)
            let x = self.frame.width / 2 - lastTouch!.x
            let y = self.frame.height / 2 - lastTouch!.y
            
            snap = UISnapBehavior(item: self, snapTo: self.center)
            snap!.damping = 1
            let newPoint = CGPoint(x: currentTouch.x + x, y: currentTouch.y + y)
            
            snap!.snapPoint = chessView.getPositionForSnap(point: newPoint)
            animator.addBehavior(snap!)
            let from_location = chessView.getCoordinatesForPosition(point: loastTouchSuperView!)
            let to_location = chessView.getCoordinatesForPosition(point: newPoint)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: 500000000)){
                self.animator?.removeAllBehaviors()
                self.presenter?.makeMove(from: from_location, to: to_location)
            }
        }
    }
    
    func circlePathWithCenter(center: CGPoint, radius: CGFloat) -> UIBezierPath {
        let circlePath = UIBezierPath()
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat(Double.pi), endAngle: -CGFloat(Double.pi/2), clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: -CGFloat(Double.pi/2), endAngle: 0, clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(Double.pi/2), clockwise: true)
        circlePath.addArc(withCenter: center, radius: radius, startAngle: CGFloat(Double.pi/2), endAngle: CGFloat(Double.pi), clockwise: true)
        circlePath.close()
        circlePath.fill()
        return circlePath
    }
    
}
