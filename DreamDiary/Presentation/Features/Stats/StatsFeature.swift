//
//  StatsFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 03.06.2025.
//

import ComposableArchitecture
import SwiftUI
import Charts

@Reducer
struct StatsFeature {
  @ObservableState
  struct State: Equatable {
    var statistics: [DreamStatistic] = []
    var totalLucidCount = 0
    var totalNormalCount = 0
    var totalNightmareCount = 0
    var isLoading = false
  }
  
  enum Action {
    case task
    case statisticsLoaded(
      weeklyStats: [DreamStatistic],
      totalLucid: Int,
      totalNormal: Int,
      totalNightmare: Int
    )
  }
  
  @Dependency(\.database.dreams) var database
  @Dependency(\.calendar) var calendar
  @Dependency(\.date.now) var now
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        state.isLoading = true
        return .run { send in
          let weekAgo = calendar.date(byAdding: .day, value: -7, to: now)!
          let predicate = #Predicate<Dream> { $0.date >= weekAgo }
          
          let dreams = try await database.fetch(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date, order: .reverse)]
          )
          
          let (weeklyStats, totals) = self.calculateStatistics(from: dreams)
          
          await send(.statisticsLoaded(
            weeklyStats: weeklyStats,
            totalLucid: totals.lucid,
            totalNormal: totals.normal,
            totalNightmare: totals.nightmare
          ))
        }
        
      case let .statisticsLoaded(weeklyStats, totalLucid, totalNormal, totalNightmare):
        state.statistics = weeklyStats
        state.totalLucidCount = totalLucid
        state.totalNormalCount = totalNormal
        state.totalNightmareCount = totalNightmare
        state.isLoading = false
        return .none
      }
    }
  }
  
  private func calculateStatistics(from dreams: [Dream]) -> (
    weeklyStats: [DreamStatistic],
    totals: (lucid: Int, normal: Int, nightmare: Int)
  ) {
    let dreamsByDay = Dictionary(grouping: dreams) { dream in
      calendar.startOfDay(for: dream.date)
    }
    
    var weeklyStats: [DreamStatistic] = []
    var totalLucid = 0
    var totalNormal = 0
    var totalNightmare = 0
    
    for i in 0..<7 {
      guard let date = calendar.date(byAdding: .day, value: -i, to: now) else { continue }
      let day = calendar.startOfDay(for: date)
      
      let dayDreams = dreamsByDay[day] ?? []
      
      let lucidCount = dayDreams.filter { $0.type == .lucid }.count
      let normalCount = dayDreams.filter { $0.type == .normal }.count
      let nightmareCount = dayDreams.filter { $0.type == .nightmare }.count
      
      totalLucid += lucidCount
      totalNormal += normalCount
      totalNightmare += nightmareCount
      
      weeklyStats.append(DreamStatistic(
        date: day,
        lucidCount: lucidCount,
        normalCount: normalCount,
        nightmareCount: nightmareCount
      ))
    }
    
    return (weeklyStats.reversed(), (totalLucid, totalNormal, totalNightmare))
  }
}

struct DreamStatistic: Identifiable, Equatable {
  var id: Date { date }
  let date: Date
  let lucidCount: Int
  let normalCount: Int
  let nightmareCount: Int
}

struct StatsView: View {
  let store: StoreOf<StatsFeature>
  
  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: 20) {
          Text("За последние 7 дней")
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.top)
            .foregroundColor(.white)
          
          if store.isLoading {
            ProgressView()
              .tint(.white)
              .frame(maxWidth: .infinity)
          } else {
            chartView(statistics: store.statistics)
          }
          
          Text("Сводка")
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.top)
            .foregroundColor(.white)
          
          summaryView
        }
        .padding(.horizontal, 20)
      }
      .frame(maxWidth: .infinity)
      .background(Color.primaryDarkColor)
      .scrollContentBackground(.hidden)
      .navigationTitle("Статистика")
      .navigationBarTitleDisplayMode(.large)
      .task {
        store.send(.task)
      }
    }
  }
  
  private var summaryView: some View {
    HStack(spacing: 12) {
      summaryItemView(
        type: .normal,
        count: store.totalNormalCount
      )
      summaryItemView(
        type: .lucid,
        count: store.totalLucidCount
      )
      summaryItemView(
        type: .nightmare,
        count: store.totalNightmareCount
      )
    }
  }
  
  private func summaryItemView(type: DreamType, count: Int) -> some View {
    VStack(alignment: .leading, spacing: 13) {
      Text("\(count)")
        .font(.title).bold()
        .foregroundColor(.white)
      
      HStack(spacing: 6) {
        Circle()
          .fill(type.color)
          .frame(width: 8, height: 8)
        Text(type.rawValue)
          .font(.caption)
          .foregroundColor(Color.white.opacity(0.8))
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Color.primaryLightGrayColor)
    .cornerRadius(12)
  }

  private func chartView(statistics: [DreamStatistic]) -> some View {
    VStack(alignment: .leading, spacing: 10) {
      Chart {
        ForEach(statistics) { stat in
          ForEach(DreamType.allCases) { type in
            let count = count(for: type, in: stat)
            BarMark(
              x: .value("День", stat.date, unit: .day),
              y: .value("Количество", count)
            )
            .foregroundStyle(by: .value("Тип", type.rawValue))
            .annotation(position: .overlay) {
              if count > 0 {
                Text("\(count)")
                  .font(.caption)
                  .fontWeight(.bold)
                  .foregroundColor(.white)
              }
            }
          }
        }
      }
      .chartForegroundStyleScale(
        domain: DreamType.allCases.map { $0.rawValue },
        range: DreamType.allCases.map { $0.color }
      )
      .chartLegend(.hidden)
      .frame(height: 200)
      .chartXAxis {
        AxisMarks(values: .stride(by: .day)) { value in
          AxisGridLine().foregroundStyle(Color.gray.opacity(0.5))
          AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            .foregroundStyle(Color.white)
        }
      }
      .chartYAxis {
        AxisMarks { value in
          AxisGridLine().foregroundStyle(Color.gray.opacity(0.5))
          AxisValueLabel().foregroundStyle(Color.white)
        }
      }
      
      HStack(spacing: 16) {
        ForEach(DreamType.allCases) { type in
          legendItem(color: type.color, label: type.rawValue)
        }
      }
    }
  }
  
  private func legendItem(color: Color, label: String) -> some View {
    HStack(spacing: 6) {
      Circle()
        .fill(color)
        .frame(width: 8, height: 8)
      Text(label)
        .font(.caption2)
        .foregroundColor(.white.opacity(0.8))
    }
  }
  
  private func count(for type: DreamType, in stat: DreamStatistic) -> Int {
    switch type {
    case .normal: return stat.normalCount
    case .lucid: return stat.lucidCount
    case .nightmare: return stat.nightmareCount
    }
  }
}

// MARK: - Preview
struct DreamStatisticsView_Previews: PreviewProvider {
  static var previews: some View {
    StatsView(store: Store(initialState: StatsFeature.State()) {
      StatsFeature()
    })
  }
}
