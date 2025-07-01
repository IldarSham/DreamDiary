//
//  Dream.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 01.05.2025.
//

import Foundation
import SwiftData

@Model
public final class Dream: Equatable, @unchecked Sendable {
  public var title: String
  public var date: Date
  public var timeOfDay: TimeOfDay
  public var content: String
  public var type: DreamType
  
  public init(title: String, date: Date = .now, timeOfDay: TimeOfDay, content: String, type: DreamType) {
    self.title = title
    self.date = date
    self.timeOfDay = timeOfDay
    self.content = content
    self.type = type
  }
}
