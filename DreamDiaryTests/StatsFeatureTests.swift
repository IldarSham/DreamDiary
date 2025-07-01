//
//  StatsFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 01.07.2025.
//

import Foundation
import ComposableArchitecture
import Testing

@testable import DreamDiary

@MainActor
struct StatsFeatureTests {
  private let now = Date()
  private let calendar = Calendar.current
  
  @Test
  func testTask_loadsStatisticsSuccessfully() async {
    let mockDreams = createMockDreams()
    
    let store = TestStore(initialState: StatsFeature.State()) {
      StatsFeature()
    } withDependencies: {
      $0.database.dreams.fetch = { _, _ in mockDreams }
      $0.date.now = now
      $0.calendar = calendar
    }
    
    await store.send(.task) {
      $0.isLoading = true
    }
        
    await store.receive(\.statisticsLoaded) {
      $0.isLoading = false
      $0.statistics = expectedWeeklyStats(from: mockDreams)
      $0.totalLucidCount = 2
      $0.totalNormalCount = 3
      $0.totalNightmareCount = 1
    }
  }
  
  // MARK: - Test Data Helpers
  
  private func createMockDreams() -> [Dream] {
    return [
      createDream(date: now, type: .lucid),
      createDream(date: calendar.date(byAdding: .day, value: -1, to: now)!, type: .normal),
      createDream(date: calendar.date(byAdding: .day, value: -2, to: now)!, type: .nightmare),
      createDream(date: calendar.date(byAdding: .day, value: -3, to: now)!, type: .lucid),
      createDream(date: calendar.date(byAdding: .day, value: -4, to: now)!, type: .normal),
      createDream(date: calendar.date(byAdding: .day, value: -5, to: now)!, type: .normal),
    ]
  }
  
  private func createDream(date: Date, type: DreamType) -> Dream {
    Dream(
      title: "Test Dream",
      date: date,
      timeOfDay: .afternoon,
      content: "Test Description",
      type: type,
    )
  }
  
  private func expectedWeeklyStats(from dreams: [Dream]) -> [DreamStatistic] {
    let dreamsByDay = Dictionary(grouping: dreams) { dream in
      calendar.startOfDay(for: dream.date)
    }
    
    var weeklyStats: [DreamStatistic] = []
    
    for i in 0..<7 {
      guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
      let day = calendar.startOfDay(for: date)
      
      let dayDreams = dreamsByDay[day] ?? []
      
      let lucidCount = dayDreams.filter { $0.type == .lucid }.count
      let normalCount = dayDreams.filter { $0.type == .normal }.count
      let nightmareCount = dayDreams.filter { $0.type == .nightmare }.count
      
      weeklyStats.append(DreamStatistic(
        date: day,
        lucidCount: lucidCount,
        normalCount: normalCount,
        nightmareCount: nightmareCount
      ))
    }
    
    return weeklyStats.reversed()
  }
}
