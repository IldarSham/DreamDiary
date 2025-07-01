//
//  CaseIterable+Extension.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 26.06.2025.
//

import Foundation

extension CaseIterable where Self: Equatable {
  var next: Self? {
    let cases = Self.allCases
    guard
      let idx = cases.firstIndex(of: self),
      cases.index(after: idx) < cases.endIndex
    else {
      return nil
    }
    return cases[cases.index(after: idx)]
  }
}
