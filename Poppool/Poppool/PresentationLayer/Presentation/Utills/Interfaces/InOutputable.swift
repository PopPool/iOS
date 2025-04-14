//
//  InOutputable.swift
//  MomsVillage
//
//  Created by SeoJunYoung on 8/29/24.
//

import UIKit

protocol InOutputable: Inputable, Outputable { }

protocol Inputable {
    associatedtype Input
    func injection(with input: Input)
}

protocol Outputable {
    associatedtype Output
}
