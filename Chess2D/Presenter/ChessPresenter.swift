//
//  piece.swift
//  Chess
//
//  Created by Андрей Зорькин on 22.07.17.
//  Copyright © 2017 Андрей Зорькин. All rights reserved.
//

import UIKit

protocol IChessPresenter {
    var delegate: IChessPresenterDelegate? {get set}
    func newGame()
    func newGame(whitePlayerType: Chess2D.PlayerType, blackPlayerType: Chess2D.PlayerType, difficulty: Chess2D.Difficulty)
    func endGame()
    func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int))
    func freezeOthers(excluding: Int)
    func freezeFor(color: Chess2D.Color)
}

protocol IChessPresenterDelegate: class {
    func presenterDidAddPiece(at point: (x: Int, y: Int), type: Chess2D.PieceType, color: Chess2D.Color)
    func presenterDidFreezeAll()
    func presenterDidFreezeFor(color: Chess2D.Color)
    func presenterDidFreezeOthers(excluding: Int)
    func presenterDidEndGame()
    func presenterDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool)
    func presenterDidRemovePiece(tag: Int)
    func presenterDidChangeTypeOfPiece(tag: Int, newType: Chess2D.PieceType)
    func presenterDidSuggestActions(withLabel: String, actions: [Chess2D.Action])
    func presenterDidUpdateTimeLabelForPlayer1(label: String)
    func presenterDidUpdateTimeLabelForPlayer2(label: String)
    func presenterDidUpdateTotalTimeLabelForPlayer1(label: String)
    func presenterDidUpdateTotalTimeLabelForPlayer2(label: String)
}

class ChessPresenter: IChessPresenter{
    
    
    public weak var delegate: IChessPresenterDelegate?
    
    public var model: IChessModel
    
    var whitePlayerType: Chess2D.PlayerType!
    var blackPlayerType: Chess2D.PlayerType!
    
    init(model: IChessModel) {
        self.model = model
        self.model.delegate = self
    }
    
    private var started = false
    
    public func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int)){
        model.makeMove(from: (x: from.x - 1, y: from.y - 1), to: (x: to.x - 1, y: to.y - 1))
    }
    
    public func freezeOthers(excluding: Int){
        if let delegate = delegate {
            delegate.presenterDidFreezeOthers(excluding: excluding)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    public func addPiece(at point: (x: Int, y: Int), type: Chess2D.PieceType, color: Chess2D.Color){
        if let delegate = delegate {
            delegate.presenterDidAddPiece(at: point, type: type, color: color)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    public func freezeAll(){
        if let delegate = delegate {
            delegate.presenterDidFreezeAll()
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    public func freezeFor(color: Chess2D.Color){
        if let delegate = delegate {
            delegate.presenterDidFreezeFor(color: color)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    public func newGame(whitePlayerType: Chess2D.PlayerType = .human, blackPlayerType: Chess2D.PlayerType = .computer, difficulty: Chess2D.Difficulty = .notSpecified){
        model.newGame(player1: whitePlayerType, player2: blackPlayerType, difficulty: difficulty)
        if started == false{
            self.whitePlayerType = model.whiteType
            self.blackPlayerType = model.blackType
            arrangeThePieces()
            started = true
        }
    }
    
    private func arrangeThePieces() {
        if let delegate = delegate {
            let FiguresPosition: [Chess2D.PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]
            for (i, FigureType) in FiguresPosition.enumerated(){
                delegate.presenterDidAddPiece(at: (x: i + 1, y: 1), type: FigureType, color: .white)
            }
            for i in 1...8{
                delegate.presenterDidAddPiece(at: (x: i, y: 2), type: .pawn, color: .white)
            }
            for (i, FigureType) in FiguresPosition.enumerated(){
                delegate.presenterDidAddPiece(at: (x: i + 1, y: 8), type: FigureType, color: .black)
            }
            for i in 1...8{
                delegate.presenterDidAddPiece(at: (x: i, y: 7), type: .pawn, color: .black)
            }
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    public func newGame() {
        let type0 = Chess2D.GameType(white: .human, black: .human, level: .notSpecified, description: "С человеком")
        let type1 = Chess2D.GameType(white: .human, black: .computer, level: .easy, description: "С компьютером (легкий)")
        let type2 = Chess2D.GameType(white: .human, black: .computer, level: .medium, description: "С компьютером (средний)")
        let type3 = Chess2D.GameType(white: .human, black: .computer, level: .hard, description: "С компьютером (сложный)")
        let types = [type0, type1, type2, type3]
        
        let actions: [Chess2D.Action]  = types.map{
            (type: Chess2D.GameType) in
            let action = {
                self.endGameExactly()
                self.newGame(whitePlayerType: type.white, blackPlayerType: type.black, difficulty: type.level)
                self.chessModelDidChangePlayer(currentPlayeColor: .white)
            }
            return Chess2D.Action(title: type.description, type: .default, action: action)
        }
        if let delegate = delegate {
            delegate.presenterDidSuggestActions(withLabel: "Выберите тип игры", actions: actions + [.cancel])
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    public func endGame(){
        let actionEndGame = Chess2D.Action(title: "Завершить игру",
                                           type: .destructive,
                                           action: { self.endGameExactly() })
        let actions = [actionEndGame, .cancel]
        if let delegate = delegate {
            delegate.presenterDidSuggestActions(withLabel: "Завершить игру", actions: actions)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    private func endGameExactly() {
        self.started = false
        self.model.endGame()
        if let delegate = delegate {
            delegate.presenterDidEndGame()
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    private func setCurrentPlayerColor(color: Chess2D.Color){
        assert(Chess2D.Color.AllCases().count != 2, "Цветов стало больше, код ниже необходимо обработать с помощью switch")
        color == .black
            ? blackPlayerType == .computer ? freezeAll() : freezeFor(color: .white)
            : whitePlayerType == .computer ? freezeAll() : freezeFor(color: .black)
    }
    
}


extension ChessPresenter: IChessModelDelegate {
    func chessModelDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool) {
        if let delegate = delegate {
            delegate.presenterDidMovePiece(tag: tag, to: to, animating: animating)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    func chessModelDidRemovePiece(tag: Int) {
        if let delegate = delegate {
            delegate.presenterDidRemovePiece(tag: tag)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    func chessModelDidChangePlayer(currentPlayeColor: Chess2D.Color) {
        setCurrentPlayerColor(color: currentPlayeColor)
    }
    
    func chessModelGameWonByPlayer(color: Chess2D.Color) {
        // FIXME: Добавить сообщение Шах и Мат
        let title = color == .white ? "Победили белые" : "Победили чёрные"
        let actionOK = Chess2D.Action(title: "OK", type: .default, action: {} )
        if let delegate = delegate {
            delegate.presenterDidSuggestActions(withLabel: title, actions: [actionOK])
            delegate.presenterDidFreezeAll()
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    func chessModelGameEndedInStaleMate() {
        let title = "Пат"
        let actionOK = Chess2D.Action(title: "OK", type: .default, action: {} )
        if let delegate = delegate {
            delegate.presenterDidSuggestActions(withLabel: title, actions: [actionOK])
            delegate.presenterDidFreezeAll()
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    func chessModelPromotedTypeForPawn(callback: @escaping (Chess2D.PieceType) -> Void) {
        let title = "Пешка повышена! Выберите фигуру"
        let figures = [Chess2D.PieceType.bishop, .knight, .queen, .rook]
        let actions: [Chess2D.Action] = figures.map{
            (pieceType) in
            let title = pieceType.name
            let type = Chess2D.ActionType.default
            let action = { callback(pieceType) }
            return Chess2D.Action(title: title, type: type, action: action)
        }
        if let delegate = delegate {
            delegate.presenterDidSuggestActions(withLabel: title, actions: actions)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
        
    }
    
    func chessModelDidChangeTypeOfPiece(tag: Int, newType: Chess2D.PieceType) {
        if let delegate = delegate {
            delegate.presenterDidChangeTypeOfPiece(tag: tag, newType: newType)
        } else {
            assertionFailureObjectIsNil(withName: "delegate")
        }
    }
    
    private func totalTimeLabelFromInterval(_ interval: TimeInterval) -> String {
        let hours = Int(interval / 3600)
        let minutes = Int((interval - TimeInterval(hours) * 60) / 60)
        let seconds = Int(interval - TimeInterval(hours) * 3600 - TimeInterval(minutes) * 60)
        return String(format: "%01d", hours) + ":" + String(format: "%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
    
    private func timeLabelFromInterval(_ interval: TimeInterval) -> String {
        let minutes = Int(interval / 60)
        let seconds = Int(interval - TimeInterval(minutes) * 60)
        let mseconds = Int(100 * (interval - TimeInterval(minutes) * 60 - TimeInterval(seconds)))
        return String(format: "%01d", minutes) + ":" + String(format: "%02d", seconds) + ":" + String(format: "%02d", mseconds)
    }
    
    func chessModelDidUpdateTimeForPlayer(color: Chess2D.Color, time: TimeInterval) {
        let timeLabel = timeLabelFromInterval(time)
        switch color {
        case .white:
            delegate?.presenterDidUpdateTimeLabelForPlayer1(label: timeLabel)
        case .black:
            delegate?.presenterDidUpdateTimeLabelForPlayer2(label: timeLabel)
        }
    }
    
    func chessModelDidUpdateTotalTimeForPlayer(color: Chess2D.Color, time: TimeInterval) {
        let timeLabel = totalTimeLabelFromInterval(time)
        switch color {
        case .white:
            delegate?.presenterDidUpdateTotalTimeLabelForPlayer1(label: timeLabel)
        case .black:
            delegate?.presenterDidUpdateTotalTimeLabelForPlayer2(label: timeLabel)
        }
    }
}

extension ChessPresenter: AssertionFailureAbilities {
    
}
