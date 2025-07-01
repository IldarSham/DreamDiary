//
//  TimeOfDay.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 22.04.2025.
//

import SwiftUI

public enum TimeOfDay: String, CaseIterable, Identifiable, Codable, Sendable {
  case morning = "Утро"
  case afternoon = "День"
  case evening = "Вечер"
  case night = "Ночь"
  
  public var id: String { rawValue }
}
