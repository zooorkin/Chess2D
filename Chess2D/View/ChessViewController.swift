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
        let alert = UIAlertController(title: "Новая игра",
                                      message: "Выберете тип игры",
                                      preferredStyle: .alert)
        
        let type0 = (white: Chess2D.PlayerType.human,
                     black: Chess2D.PlayerType.human,
                     level: Chess2D.Difficulty.notSpecified,
                     description: "С человеком")
        
        let type1 = (white: Chess2D.PlayerType.human,
                     black: Chess2D.PlayerType.computer,
                     level: Chess2D.Difficulty.easy,
                     description: "С компьютером (легкий)")
        let type2 = (white: Chess2D.PlayerType.human,
                     black: Chess2D.PlayerType.computer,
                     level: Chess2D.Difficulty.medium,
                     description: "С компьютером (средний)")
        let type3 = (white: Chess2D.PlayerType.human,
                     black: Chess2D.PlayerType.computer,
                     level: Chess2D.Difficulty.hard,
                     description: "С компьютером (сложный)")
        
        for gameType in [type0, type1, type2, type3] {
            let gameTypeName = gameType.description
            
            let pieceTypeAlertAction = UIAlertAction(title: gameTypeName, style: .default) {
                (action) in
                self.presenter.newGame(whitePlayerType: gameType.white, blackPlayerType: gameType.black, difficulty: gameType.level)
            }
            alert.addAction(pieceTypeAlertAction)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (action) in }
        alert.addAction(cancelAction)
        self.present(alert, animated: true) { }
    
    }
    @IBAction func clear(_ sender: Any) {
        presenter.endGame()
    }
    @IBAction func plusAction(_ sender: Any) {
        presenterPromotedTypeForPawn { (pieceType) in
            
        }
    }
    
    public var widthOfCell: CGFloat = 0.0
    public var pieceForTag: [Int: ChessFigure] = [:]
    
    private var pieceTag: Int = 1
    
    func presenterDidAddPiece(at point: (x: Int, y: Int), type: Chess2D.PieceType, color: Chess2D.Color) {
        let size = CGSize(width: widthOfCell, height: widthOfCell)
        let piece = ChessFigure(frame: CGRect(origin: getPosition(x: point.x, y: point.y), size: size))
        piece.backgroundColor = UIColor.clear
        piece.presenter = presenter
        piece.image = UIImage(named: type.imageName(color: color))
        if type == .pawn {
            piece.isPawn = true
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
    
    func presenterDidFreezeFor(color: Chess2D.Color) {
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
    
    func presenterGameWonByPlayer(color: Chess2D.Color) {
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
    
    func presenterPromotedTypeForPawn(callback: @escaping (Chess2D.PieceType) -> Void) {
        let alert = UIAlertController(title: "Пешка повышена!",
                                      message: "Выберите фигуру",
                                      preferredStyle: .alert)
        
        for pieceType in [Chess2D.PieceType.bishop, .knight, .queen, .rook] {
            let pieceTypeAlertAction = UIAlertAction(title: pieceType.name, style: .default) {
                (action) in
                callback(pieceType)
            }
            alert.addAction(pieceTypeAlertAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true) { }
    }
    
    func presenterDidChangeTypeOfPiece(tag: Int, newType: Chess2D.PieceType) {
        DispatchQueue.main.async {
            let piece = self.pieceForTag[tag]
            if tag >= 1 && tag <= 16 {
                piece?.image = UIImage(named: newType.imageName(color: .white))
            } else if tag >= 17 && tag <= 32 {
                piece?.image = UIImage(named: newType.imageName(color: .black))
            }
        }
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
