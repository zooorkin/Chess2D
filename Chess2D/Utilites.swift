//
//  Utilites.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 11/10/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import Foundation

final class Utilites {
    
    
    static func syncOnMainThread<T>(execute block: () throws -> T) rethrows -> T {
        if Thread.isMainThread {
            return try block()
        }
        return try DispatchQueue.main.sync(execute: block)
    }
    
}
