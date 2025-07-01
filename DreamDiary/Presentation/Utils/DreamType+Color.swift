//
//  DreamType+Color.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 30.06.2025.
//

import SwiftUI

public extension DreamType {
  var color: Color {
    switch self {
    case .normal:    return Color(red: 150/255, green: 150/255, blue: 160/255)
    case .nightmare: return Color(red: 217/255, green: 83/255, blue: 79/255)
    case .lucid:     return Color(red: 80/255, green: 150/255, blue: 255/255)
    }
  }
}
