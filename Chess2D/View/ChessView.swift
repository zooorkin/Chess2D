//
//  ViewController.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 21/09/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import UIKit

protocol IChessViewController {
    
}

class ChessView: UIViewController, IChessViewController, IChessPresenterDelegate {

    
    @IBOutlet weak var boardView: BoardView!
    
    var presenter: ChessPresenter?
    
    override func viewDidLoad() {
        self.widthOfCell = boardView.board.frame.width / 8
    }
    
//    override func viewDidLayoutSubviews() {
//        self.widthOfCell = boardView.frame.width / 8
//    }

    @IBAction func newGame(_ sender: Any) {
        presenter = ChessPresenter()
        let model = ChessModel()
        presenter!.model = model
        model.delegate = presenter
        presenter?.delegate = self
        presenter!.newGame()
    }
    @IBAction func clear(_ sender: Any) {
        //model = nil
        presenter?.removeAll()
    }
    @IBAction func plusAction(_ sender: Any) {
        //model.letComputersPlay()
    }
    

    public var widthOfCell: CGFloat = 0.0
    public var pieceForTag: [Int: ChessFigure] = [:]
    
    private var pieceTag: Int = 1
    
    func presenterDidAddPiece(at point: (x: Int, y: Int), type: ChessPieceType, color: ChessColor) {
        let size = CGSize(width: widthOfCell, height: widthOfCell)
        let piece = ChessFigure(frame: CGRect(origin: getPosition(x: point.x, y: point.y), size: size))
        piece.backgroundColor = UIColor.clear
        piece.presenter = presenter
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
        piece.chessView = self
        piece.isUserInteractionEnabled = false
        piece.color = color
        boardView.board.addSubview(piece)
        print(piece.bounds)
        piece.pieceTag = pieceTag
        pieceForTag[pieceTag] = piece
        pieceTag += 1
    }
    
    func presenterDidFreezeAll() {
        pieceForTag.forEach{
            $0.value.isUserInteractionEnabled = false
        }
    }
    
    func presenterDidFreezeFor(color: ChessColor) {
        pieceForTag.forEach{
            if $0.value.color == color {
                $0.value.isUserInteractionEnabled = false
            } else {
                $0.value.isUserInteractionEnabled = true
            }
        }
    }
    
    func presenterDidFreezeOthers(excluding: Int) {
        pieceForTag.filter{
            $0.value.pieceTag != excluding
            }.forEach{
                $0.value.isUserInteractionEnabled = false
        }
    }
    
    func presenterDidRemoveAll() {
        for (_, eachView) in pieceForTag{
            eachView.removeFromSuperview()
        }
        pieceForTag = [:]
    }
    
    func presenterDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool) {
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
    
    func presenterDidRemovePiece(tag: Int) {
        pieceForTag[tag]?.removeFromSuperview()
        pieceForTag[tag] = nil
    }
    
    private func getPosition(x: Int, y: Int) -> CGPoint{
        let xCoordinate = (CGFloat(x) - 1) * widthOfCell
        let yCoordinate = (8 - CGFloat(y)) * widthOfCell
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }
    
}

protocol IChessFigureSupport {
    func getCoordinatesForPosition(point: CGPoint) -> (x: Int, y: Int)
    func getPositionForSnap(point: CGPoint) -> CGPoint
}

extension ChessView: IChessFigureSupport {
    func getCoordinatesForPosition(point: CGPoint) -> (x: Int, y: Int){
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
    
    func getPositionForSnap(point: CGPoint) -> CGPoint{
        
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
}
