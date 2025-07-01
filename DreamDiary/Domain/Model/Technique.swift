//
//  Technique.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 03.05.2025.
//

import Foundation
import SwiftData
import SFSafeSymbols

@Model
public final class Technique: @unchecked Sendable {
  public var title: String
  public var date: Date
  public var content: String
  
  private var symbolName: String
  
  public var symbol: SFSymbol {
    get {
      SFSymbol(rawValue: symbolName)
    }
    set {
      self.symbolName = newValue.rawValue
    }
  }
  
  public init(title: String, date: Date = .now, content: String, symbol: SFSymbol) {
    self.title = title
    self.date = date
    self.content = content
    self.symbolName = symbol.rawValue
  }
}
