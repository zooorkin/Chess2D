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

protocol IChessPresenter {
    func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int))
    func freezeOthers(excluding: Int)
}

protocol IChessPresenterDelegate: class {
    func presenterDidAddPiece(at point: (x: Int, y: Int), type: ChessPieceType, color: ChessColor)
    func presenterDidFreezeAll()
    func presenterDidFreezeFor(color: ChessColor)
    func presenterDidFreezeOthers(excluding: Int)
    func presenterDidRemoveAll()
    func presenterDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool)
    func presenterDidRemovePiece(tag: Int)
}

class ChessPresenter: IChessPresenter{

    public weak var delegate: IChessPresenterDelegate?
    
    public var model: IChessModel?

    var whitePlayerType: PlayerType!
    var blackPlayerType: PlayerType!
    
    private var started = false
    
    public func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int)){
        model?.makeMove(from: (x: from.x - 1, y: from.y - 1), to: (x: to.x - 1, y: to.y - 1))
    }
    
    public func freezeOthers(excluding: Int){
        delegate?.presenterDidFreezeOthers(excluding: excluding)
    }
    
    public func addPiece(at point: (x: Int, y: Int), type: ChessPieceType, color: ChessColor){
       delegate?.presenterDidAddPiece(at: point, type: type, color: color)
    }
    
    public func freezeAll(){
        delegate?.presenterDidFreezeAll()
    }
    
    public func freezeFor(color: ChessColor){
        delegate?.presenterDidFreezeFor(color: color)
    }
    
    public func newGame(whitePlayerType: PlayerType = .human, blackPlayerType: PlayerType = .computer){
        if started == false{
            self.whitePlayerType = model!.whiteType
            self.blackPlayerType = model!.blackType
            let FiguresPosition: [ChessPieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
            for (i, FigureType) in FiguresPosition.enumerated(){
                delegate?.presenterDidAddPiece(at: (x: i + 1, y: 1), type: FigureType, color: .white)
            }
            for i in 1...8{
                delegate?.presenterDidAddPiece(at: (x: i, y: 2), type: .pawn, color: .white)
            }
            for (i, FigureType) in FiguresPosition.enumerated(){
                delegate?.presenterDidAddPiece(at: (x: i + 1, y: 8), type: FigureType, color: .black)
            }
            for i in 1...8{
                delegate?.presenterDidAddPiece(at: (x: i, y: 7), type: .pawn, color: .black)
            }
            setCurrentPlayerColor(color: .white)
            print("added")
            started = true
        }
    }
    
    private func setCurrentPlayerColor(color: ChessColor){
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
    
    public func removeAll(){
        delegate?.presenterDidRemoveAll()
    }
}

extension ChessPresenter: IChessModelDelegate {
    func chessModelDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool) {
        delegate?.presenterDidMovePiece(tag: tag, to: to, animating: animating)
    }
    
    func chessModelDidRemovePiece(tag: Int) {
        delegate?.presenterDidRemovePiece(tag: tag)
    }
    
    func chessModelDidChangePlayer(currentPlayeColor: ChessColor) {
        setCurrentPlayerColor(color: currentPlayeColor)
    }
    
}

