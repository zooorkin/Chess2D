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
    
    func presenterDidSuggestActions(withLabel: String, actions: [Chess2D.Action]) {
        // FIXME: Использовать метод c message
        let alert = UIAlertController(title: withLabel, message: nil, preferredStyle: .alert)
        for action in actions {
            let title = action.title
            let style = action.type.alertActionStyle
            let action = { (_: UIAlertAction) in action.action() }
            let alertAction = UIAlertAction(title: title, style: style, handler: action)
            alert.addAction(alertAction)
        }
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func newGame(_ sender: Any) {
        self.presenter.newGame()
    }
    
    @IBAction func clear(_ sender: Any) {
        self.presenter.endGame()
    }
    @IBAction func plusAction(_ sender: Any) {
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
        pieceForTag.forEach{ $0.value.isUserInteractionEnabled = false }
    }
    
    func presenterDidFreezeFor(color: Chess2D.Color) {
        pieceForTag.forEach{ $0.value.isUserInteractionEnabled = $0.value.color == color ? false : true }
    }
    
    func presenterDidFreezeOthers(excluding: Int) {
        pieceForTag.filter{ $0.value.pieceTag != excluding }.forEach{ $0.value.isUserInteractionEnabled = false }
    }
    
    func presenterDidEndGame() {
        pieceForTag.forEach{ $0.value.removeFromSuperview() }
        pieceForTag.removeAll()
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
    
    func presenterDidChangeTypeOfPiece(tag: Int, newType: Chess2D.PieceType) {
        DispatchQueue.main.async {
            let piece = self.pieceForTag[tag]
            if tag >= 1 && tag <= 16 {
                piece?.image = UIImage(named: newType.imageName(color: .white))
            } else if tag >= 17 && tag <= 32 {
                piece?.image = UIImage(named: newType.imageName(color: .black))
            } else {
                fatalError("Встречена фигура с неизвестным тегом")
            }
        }
    }
    
    private func getPosition(x: Int, y: Int) -> CGPoint{
        let xCoordinate = (CGFloat(x) - 1) * widthOfCell
        let yCoordinate = (8 - CGFloat(y)) * widthOfCell
        return CGPoint(x: xCoordinate, y: yCoordinate)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
