//
//  ChessEngine.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 21/09/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import Foundation
import SwiftChess

protocol IChessModel: class {
    var delegate: IChessModelDelegate? { get set }
    var blackType: Chess2D.PlayerType { get }
    var whiteType: Chess2D.PlayerType { get }
    func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int))
    func newGame(player1: Chess2D.PlayerType, player2: Chess2D.PlayerType, difficulty: Chess2D.Difficulty)
    func endGame()
}

protocol IChessModelDelegate: class {
    func chessModelDidMovePiece(tag: Int, to: (x: Int, y: Int), animating: Bool)
    func chessModelDidRemovePiece(tag: Int)
    func chessModelDidChangePlayer(currentPlayeColor: Chess2D.Color)
    func chessModelGameWonByPlayer(color: Chess2D.Color)
    func chessModelGameEndedInStaleMate()
    func chessModelPromotedTypeForPawn(callback: @escaping (Chess2D.PieceType) -> Void)
    func chessModelDidChangeTypeOfPiece(tag: Int, newType: Chess2D.PieceType)
    func chessModelDidUpdateTimeForPlayer(color: Chess2D.Color, time: TimeInterval)
    func chessModelDidUpdateTotalTimeForPlayer(color: Chess2D.Color, time: TimeInterval)
}

class ChessModel: IChessModel, GameDelegate {
    
    
    private var player1: Player!
    private var player2: Player!
    private var game: Game!

    private var timer: Timer?
    
    private struct ChessTime {
        var movement1: Double
        var movement2: Double
        var totalMovements1: Double
        var totalMovements2: Double
    }
    
    private var chessTime: ChessTime
    private var lastFixedTime: Date?
    
    public weak var delegate: IChessModelDelegate?
    
    public var blackType: Chess2D.PlayerType {
        if game.blackPlayer is Human {
            return .human
        } else {
            return .computer
        }
    }
    public var whiteType: Chess2D.PlayerType {
        if game.whitePlayer is Human {
            return .human
        } else {
            return .computer
        }
    }
    
    init() {
        chessTime = ChessTime(movement1: 0, movement2: 0, totalMovements1: 0, totalMovements2: 0)
    }
    
    func newGame(player1 type1: Chess2D.PlayerType, player2 type2: Chess2D.PlayerType, difficulty: Chess2D.Difficulty){
        endGame()
        switch type1 {
        case .human: player1 = Human(color: .white)
        case .computer:
            switch difficulty {
            case .easy: player1 = AIPlayer(color: .white, configuration: .init(difficulty: .easy))
            case .medium: player1 = AIPlayer(color: .white, configuration: .init(difficulty: .medium))
            case .hard: player1 = AIPlayer(color: .white, configuration: .init(difficulty: .hard))
            case .notSpecified: player1 = AIPlayer(color: .white, configuration: .init(difficulty: .medium))
            }
        }
        switch type2 {
        case .human: player2 = Human(color: .black)
        case .computer:
            switch difficulty {
            case .easy: player2 = AIPlayer(color: .black, configuration: .init(difficulty: .easy))
            case .medium: player2 = AIPlayer(color: .black, configuration: .init(difficulty: .medium))
            case .hard: player2 = AIPlayer(color: .black, configuration: .init(difficulty: .hard))
            case .notSpecified: player2 = AIPlayer(color: .black, configuration: .init(difficulty: .medium))
            }
        }
    
        game = Game(firstPlayer: player1, secondPlayer: player2)
        game.delegate = self
        gameDidChangeCurrentPlayer(game: game)
        chessTime = ChessTime(movement1: 0, movement2: 0, totalMovements1: 0, totalMovements2: 0)
    }
    
    func endGame(){
        delegate?.chessModelDidUpdateTimeForPlayer(color: .white, time: 0)
        delegate?.chessModelDidUpdateTimeForPlayer(color: .black, time: 0)
        delegate?.chessModelDidUpdateTotalTimeForPlayer(color: .white, time: 0)
        delegate?.chessModelDidUpdateTotalTimeForPlayer(color: .black, time: 0)
        player1 = nil
        player2 = nil
        game = nil
        timer = nil
        lastFixedTime = nil
    }
    
    private var blockComputerAsyncNextStep = false
    
    public func makeMove(from: (x: Int, y: Int), to: (x: Int, y: Int)){
        if let player = game.currentPlayer as? Human {
            let currentLocation = BoardLocation(x: from.x, y: from.y)
            guard player.occupiesSquare(at: currentLocation) else{
                print("Игроку эта фигура недоступна")
                return
            }
            let newLocation = BoardLocation(x: to.x, y: to.y)
            let piece = game.board.getPiece(at: currentLocation)!
            var possibleLocations = game.board.possibleMoveLocationsForPiece(atLocation: currentLocation)
            switch player.color! {
            case .white:
                if game.board.canColorCastle(color: .white, side: .kingSide){
                    possibleLocations += [BoardLocation(gridPosition: .g1)]
                }
                if game.board.canColorCastle(color: .white, side: .queenSide){
                    possibleLocations += [BoardLocation(gridPosition: .c1)]
                }
                break
            case .black:
                if game.board.canColorCastle(color: .black, side: .kingSide){
                    possibleLocations += [BoardLocation(gridPosition: .g8)]
                }
                if game.board.canColorCastle(color: .black, side: .queenSide){
                    possibleLocations += [BoardLocation(gridPosition: .c8)]
                }
                break
            }
            
            guard possibleLocations.contains(newLocation) else {
                print("Not possible movement")
                delegate?.chessModelDidMovePiece(tag: piece.tag, to: from, animating: true)
                return
            }
            
            // FIXME: текущая позиция соответствует начальной
            if (piece.tag == 5 || piece.tag == 21){
                switch newLocation.gridPosition {
                case .g1, .g8: player.performCastleMove(side: .kingSide)
                case .c1, .c8: player.performCastleMove(side: .queenSide)
                default:
                    // FIXME: скопировано ниже
                    do {
                        try player.movePiece(from: currentLocation, to: newLocation)
                    } catch {
                        // Когда при шахе в possibleLocations есть неверные возможные ходы
                        delegate?.chessModelDidMovePiece(tag: piece.tag, to: from, animating: true)
                    }
                }
            } else {
                // FIXME: есть копия (выше)
                do {
                    try player.movePiece(from: currentLocation, to: newLocation)
                } catch {
                    // Когда при шахе в possibleLocations есть неверные возможные ходы
                    delegate?.chessModelDidMovePiece(tag: piece.tag, to: from, animating: true)
                }
            }
        }
        
        if let player =  game.currentPlayer as? AIPlayer {
            player.makeMoveAsync()
        }
    }
    
    func gameWillBeginUpdates(game: Game) {
        print("--gameWillBeginUpdates")
    }
    
    func gameDidAddPiece(game: Game) {
        print("--gameDidAddPiece")
    }
    
    func gameDidEndUpdates(game: Game) {
        print("--gameDidEndUpdates")
    }
    
    func promotedTypeForPawn(location: BoardLocation, player: Human, possiblePromotions: [Piece.PieceType], callback: @escaping (Piece.PieceType) -> Void) {
        let adapatedCallback = { (pieceType: Chess2D.PieceType) -> Void in
            switch pieceType {
            case .bishop: callback(.bishop)
            case .king: callback(.king)
            case .knight: callback(.knight)
            case .pawn: callback(.pawn)
            case .queen: callback(.queen)
            case .rook: callback(.rook)
            }
        }
        delegate?.chessModelPromotedTypeForPawn(callback: adapatedCallback)
        print("A pawn was promoted!")
    }
    
    func gameDidMovePiece(game: Game, piece: Piece, toLocation: BoardLocation) {
        if game.currentPlayer is AIPlayer {
            delegate?.chessModelDidMovePiece(tag: piece.tag, to: (x: toLocation.x, y: toLocation.y), animating: true)
        }else{
            delegate?.chessModelDidMovePiece(tag: piece.tag, to: (x: toLocation.x, y: toLocation.y), animating: countOfMovements > 0)
        }
        countOfMovements += 1
        print("to \(toLocation.gridPosition)")
    }
    
    func gameDidRemovePiece(game: Game, piece: Piece, location: BoardLocation) {
        delegate?.chessModelDidRemovePiece(tag: piece.tag)
        print("From \(location) ", terminator: "")
    }
    
    func gameDidTransformPiece(game: Game, piece: Piece, location: BoardLocation) {
        var type = Chess2D.PieceType.pawn
        switch piece.type {
        case .bishop: type = .bishop
        case .knight: type = .knight
        case .queen: type = .queen
        case .rook: type = .rook
        default: fatalError()
        }
        delegate?.chessModelDidChangeTypeOfPiece(tag: piece.tag, newType: type)
        print("A pawn was promoted!")
    }
    
    func gameWonByPlayer(game: Game, player: Player) {
        let color = player.color == .black ? Chess2D.Color.black : .white
        delegate?.chessModelGameWonByPlayer(color: color)
        print("Checkmate!")
    }
    
    func gameEndedInStaleMate(game: Game) {
        delegate?.chessModelGameEndedInStaleMate()
        print("Stalemate!")
    }
    
    private var countOfMovements = 0
    
    func gameDidChangeCurrentPlayer(game: Game) {
        countOfMovements = 0
        blockComputerAsyncNextStep = false
        switch game.currentPlayer.color! {
        case Color.black:
            delegate?.chessModelDidChangePlayer(currentPlayeColor: .black)
            print("Ходят чёрные")
        case Color.white:
            delegate?.chessModelDidChangePlayer(currentPlayeColor: .white)
            print("Ходят белые")
        }
        toggleTiming()
    }
    
    private func observeTiming(){
        if let lastFixedTime = lastFixedTime {
            let interval = DateInterval(start: lastFixedTime, end: .init()).duration
            let color = game.currentPlayer.color! == .white ? Chess2D.Color.white : .black
            let time = interval + (color == .white ? chessTime.movement1 : chessTime.movement1)
            let totalTime = interval + (color == .white ? chessTime.totalMovements1 : chessTime.totalMovements2)
            delegate?.chessModelDidUpdateTimeForPlayer(color: color, time: time)
            delegate?.chessModelDidUpdateTotalTimeForPlayer(color: color, time: totalTime)
        }
    }
    
    private func toggleTiming(){
        if let lastFixedTime = lastFixedTime {
            let interval = DateInterval(start: lastFixedTime, end: .init()).duration
            switch game.currentPlayer.color! {
            case Color.white:
                chessTime.totalMovements1 += interval
            case Color.black:
                chessTime.totalMovements2 += interval
            }
        } else {
            timer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true){ timer in
                self.observeTiming()
            }
        }
        lastFixedTime = Date()
        print(chessTime)
    }
    
}
