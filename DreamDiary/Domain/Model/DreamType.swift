//
//  DreamType.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 22.04.2025.
//

import SwiftUI

public enum DreamType: String, CaseIterable, Identifiable, Codable, Sendable {
  case normal = "Обычный"
  case lucid = "Осознанный"
  case nightmare = "Кошмар"

  public var id: String { rawValue }
}
