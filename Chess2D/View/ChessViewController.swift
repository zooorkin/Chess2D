//
//  ViewController.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 21/09/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import UIKit

protocol IChessViewController {
    
    init(presenter: IChessPresenter)
    
    var presenter: IChessPresenter {get set}
    
}

class ChessViewController: UIViewController, IChessViewController, IChessPresenterDelegate {
    
    
    @IBOutlet weak var boardView: BoardView!
    
    public var presenter: IChessPresenter
    
    required init(presenter: IChessPresenter){
        self.presenter = presenter
        super.init(nibName: "ChessView", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.widthOfCell = boardView.board.frame.width / 8
    }

    @IBAction func newGame(_ sender: Any) {
        presenter.newGame(whitePlayerType: .human, blackPlayerType: .computer)
    }
    @IBAction func clear(_ sender: Any) {
        presenter.endGame()
    }
    @IBAction func plusAction(_ sender: Any) {
        
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
    
    func presenterDidEndGame() {
        for (_, eachView) in pieceForTag{
            eachView.removeFromSuperview()
        }
        pieceForTag = [:]
        pieceTag = 1
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
    
    func presenterGameWonByPlayer(color: ChessColor) {
        let text = color == .white ? "Победили белые" : "Победили чёрные"
        let alertController = UIAlertController(title: "Шах и мат!",
                                                message: text,
                                                preferredStyle: .alert)
        self.present(alertController, animated: true)
    }
    
    func presenterGameEndedInStaleMate() {
        let alertController = UIAlertController(title: "Пат!",
                                                message: "Победила дружба",
                                                preferredStyle: .alert)
        self.present(alertController, animated: true)
    }
    
    private func getPosition(x: Int, y: Int) -> CGPoint{
        let xCoordinate = (CGFloat(x) - 1) * widthOfCell
        let yCoordinate = (8 - CGFloat(y)) * widthOfCell
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }
    
    
}

extension ChessViewController: IChessFigureSupport {
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
