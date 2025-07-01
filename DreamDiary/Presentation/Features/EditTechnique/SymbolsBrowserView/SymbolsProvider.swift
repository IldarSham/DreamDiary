//
//  SymbolsProvider.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 13.05.2025.
//

import Foundation

protocol SymbolsProvider {
  associatedtype Symbol: RawRepresentable & Hashable where Symbol.RawValue == String
  static var allSymbols: Set<Symbol> { get }
}
