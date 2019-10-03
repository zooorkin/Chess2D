//
//  piece.swift
//  Chess
//
//  Created by Андрей Зорькин on 22.07.17.
//  Copyright © 2017 Андрей Зорькин. All rights reserved.
//

import UIKit

enum ChessPieceType {
    case pawn
    case king
    case rook
    case bishop
    case queen
    case knight
    case doughnut
}

enum ChessColor{
    case white
    case black
}

enum PlayerType{
    case human
    case computer
}

class ChessGame{

    public weak var engine: IChessEngine?
    
    public var started = false
    //private var pieces: [UIImageView] = []
    
    public var pieceForTag: [Int: ChessFigure] = [:]
    
    public let widthOfCell: CGFloat
    public weak var superView: UIView?
    
    var whitePlayerType: PlayerType!
    var blackPlayerType: PlayerType!
    
    init(view: UIView){
        self.widthOfCell = view.frame.width / 8
        superView = view
    }

    
    public func removePiece(tag: Int){
        pieceForTag[tag]?.removeFromSuperview()
        pieceForTag[tag] = nil
    }
    
    public func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int)){
        engine?.makeMove(from: (x: from.x - 1, y: from.y - 1), to: (x: to.x - 1, y: to.y - 1))
    }
    
    public func movePiece(tag: Int, to: (x: Int, y: Int), animating: Bool = false){
        if let piece = pieceForTag[tag] {
            if animating {
                UIView.animate(withDuration: 0.3){
                    piece.frame.origin = self.getPosition(x: to.x + 1, y: to.y + 1)
                }
            } else {
                piece.frame.origin = self.getPosition(x: to.x + 1, y: to.y + 1)
            }
            
            print("piece for tag \(tag) moved to (\(to.x),\(to.y))")
        } else {
            fatalError("Erorr piece movement (public func movePiece(tag: Int, to: (x: Int, y: Int)))")
        }
    }
    
    public func getPosition(x: Int, y: Int) -> CGPoint{
        let xCoordinate = (CGFloat(x) - 1) * widthOfCell
        let yCoordinate = (8 - CGFloat(y)) * widthOfCell
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }
    
    public func getCoordinatesForPosition(point: CGPoint) -> (x: Int, y: Int){
        var newPoint = point
        var x = 0
        var y = 0
        while newPoint.x >= 0{
            newPoint.x -= widthOfCell
            x += 1
        }
        while newPoint.y >= 0{
            newPoint.y -= widthOfCell
            y += 1
        }
        y = 8 - y + 1
        return (x: x, y: y)
    }
    
    public func getPositionForSnap(point: CGPoint) -> CGPoint{
        
        if point.x < 0 || point.x >= widthOfCell * 8 ||
            point.y < 0 || point.y >= widthOfCell * 8 {
            return point
        }
        let (x, y) = getCoordinatesForPosition(point: point)
        var point = getPosition(x: x, y: y)
        point.x += 0.5 * widthOfCell
        point.y += 0.5 * widthOfCell
        return point
    }
    
    private var pieceTag: Int = 1
    
    public func addPiece(at point: (x: Int, y: Int), type: ChessPieceType, color: ChessColor, in view: UIView){
        let size = CGSize(width: widthOfCell, height: widthOfCell)
        let piece = ChessFigure(frame: CGRect(origin: getPosition(x: point.x, y: point.y), size: size))
        piece.backgroundColor = UIColor.clear
        piece.game = self
        switch (color, type) {
        case (.white, .pawn): piece.image = UIImage(named: "w-pawn"); piece.isPawn = true
        case (.white, .knight): piece.image = UIImage(named: "w-knight")
        case (.white, .bishop): piece.image = UIImage(named: "w-bishop")
        case (.white, .rook): piece.image = UIImage(named: "w-rook")
        case (.white, .queen): piece.image = UIImage(named: "w-queen")
        case (.white, .king): piece.image = UIImage(named: "w-king")
            
        case (.black, .pawn): piece.image = UIImage(named: "b-pawn"); piece.isPawn = true
        case (.black, .knight): piece.image = UIImage(named: "b-knight")
        case (.black, .bishop): piece.image = UIImage(named: "b-bishop")
        case (.black, .rook): piece.image = UIImage(named: "b-rook")
        case (.black, .queen): piece.image = UIImage(named: "b-queen")
        case (.black, .king): piece.image = UIImage(named: "b-king")
            
        case (.black, .doughnut): piece.image = UIImage(named: "doughnut")
        case (.white, .doughnut): piece.image = UIImage(named: "doughnut")
        }

        piece.isUserInteractionEnabled = false
        piece.color = color
        view.addSubview(piece)
        started = true
        print(piece.bounds)
        piece.pieceTag = pieceTag
        pieceForTag[pieceTag] = piece
        pieceTag += 1
    }
    
    public func freezeAll(){
        pieceForTag.forEach{
            $0.value.isUserInteractionEnabled = false
        }
    }
    
    public func freezeFor(color: ChessColor){
        pieceForTag.forEach{
            if $0.value.color == color {
                $0.value.isUserInteractionEnabled = false
            } else {
                $0.value.isUserInteractionEnabled = true
            }
        }
    }
    
    public func freezeOthers(excluding: Int){
        pieceForTag.filter{
            $0.value.pieceTag != excluding
            }.forEach{
                $0.value.isUserInteractionEnabled = false
            }
    }
    
    public func currentPlayerIs(color: ChessColor){
        switch color {
        case .black:
            if blackPlayerType == .computer {
                freezeAll()
            }else{
                freezeFor(color: .white)
            }
        case .white:
            if whitePlayerType == .computer {
                freezeAll()
            }else{
                freezeFor(color: .black)
            }
        }
    }
    
    public func newGame(whitePlayerType: PlayerType = .human, blackPlayerType: PlayerType = .computer){
        if started == false{
            self.whitePlayerType = engine!.whiteType
            self.blackPlayerType = engine!.blackType
            let FiguresPosition: [ChessPieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
            for (i, FigureType) in FiguresPosition.enumerated(){
                addPiece(at: (x: i + 1, y: 1), type: FigureType, color: .white, in: superView!)
            }
            for i in 1...8{
                addPiece(at: (x: i, y: 2), type: .pawn, color: .white, in: superView!)
            }
            for (i, FigureType) in FiguresPosition.enumerated(){
                addPiece(at: (x: i + 1, y: 8), type: FigureType, color: .black, in: superView!)
            }
            for i in 1...8{
                addPiece(at: (x: i, y: 7), type: .pawn, color: .black, in: superView!)
            }
            currentPlayerIs(color: .white)
            print("added")
            started = true
        }
    }
    public func removeAll(){
        for (_, eachView) in pieceForTag{
            eachView.removeFromSuperview()
        }
        pieceForTag = [:]
    }
}


