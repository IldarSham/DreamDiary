//
//  Dream+Formatting.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 30.06.2025.
//

import Foundation

private let dateFormatter: DateFormatter = {
  let formatter = DateFormatter()
  formatter.dateFormat = "d MMM yyyy"
  formatter.locale = Locale(identifier: "ru_RU")
  return formatter
}()

public extension Dream {
  var formattedDateTime: String {
    let calendar = Calendar.current
    let dateString: String
    
    if calendar.isDateInToday(self.date) {
      dateString = "Сегодня"
    } else if calendar.isDateInYesterday(self.date) {
      dateString = "Вчера"
    } else {
      dateString = dateFormatter.string(from: self.date)
    }
    
    return "\(dateString) • \(self.timeOfDay.rawValue)"
  }
}
