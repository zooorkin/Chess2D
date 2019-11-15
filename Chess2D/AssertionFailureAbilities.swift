//
//  AssertionFailureAbilities.swift
//  Chess2D
//
//  Created by Андрей Зорькин on 15/11/2019.
//  Copyright © 2019 Андрей Зорькин. All rights reserved.
//

import Foundation

protocol AssertionFailureAbilities {
    @inline(__always) func assertionFailureObjectIsNil(withName objectName: String)
}

extension AssertionFailureAbilities {
    @inline(__always) func assertionFailureObjectIsNil(withName objectName: String){
        let selfClassName = String(describing: self)
        assertionFailure("[\(selfClassName)]: \(objectName)")
    }
}
