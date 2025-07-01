//
//  AppFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 08.04.2025.
//

import ComposableArchitecture
import SwiftUI
import SFSafeSymbols

@Reducer
struct AppFeature {
  @ObservableState
  struct State: Equatable {
    @Presents var onboarding: OnboardingFeature.State?
    var dreamList = DreamListFeature.State()
    var techniqueList = TechniqueListFeature.State()
    var stats = StatsFeature.State()
    var settings = SettingsFeature.State()
  }
  
  enum Action {
    case appDidLaunch
    case onboarding(PresentationAction<OnboardingFeature.Action>)
    case dreamList(DreamListFeature.Action)
    case techniqueList(TechniqueListFeature.Action)
    case stats(StatsFeature.Action)
    case settings(SettingsFeature.Action)
  }
  
  @Dependency(\.userDefaults) var userDefaults
  @Dependency(\.database.seedIfNeeded) var seedIfNeeded
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .appDidLaunch:
        if !userDefaults.wasOnboardingShown {
          state.onboarding = OnboardingFeature.State()
        }
        return .run { _ in
          try await seedIfNeeded()
        }
        
      case .onboarding(.presented(.delegate(.getStarted))):
        state.onboarding = nil
        return .run { _ in
          await userDefaults.setOnboardingShown(true)
        }
        
      case .onboarding, .dreamList, .techniqueList, .stats, .settings:
        return .none
      }
    }
    .ifLet(\.$onboarding, action: \.onboarding) {
      OnboardingFeature()
    }
    
    Scope(state: \.dreamList, action: \.dreamList) {
      DreamListFeature()
    }
    Scope(state: \.techniqueList, action: \.techniqueList) {
      TechniqueListFeature()
    }
    Scope(state: \.stats, action: \.stats) {
      StatsFeature()
    }
    Scope(state: \.settings, action: \.settings) {
      SettingsFeature()
    }
  }
}

struct AppView: View {
  @Bindable var store: StoreOf<AppFeature>
  
  var body: some View {
    TabView {
      DreamListView(store: store.scope(state: \.dreamList, action: \.dreamList))
        .tabItem {
          Label("Дневник", systemSymbol: .book)
        }
      
      TechniqueListView(store: store.scope(state: \.techniqueList, action: \.techniqueList))
        .tabItem {
          Label("Техники", systemSymbol: .doorLeftHandOpen)
        }
      
      StatsView(store: store.scope(state: \.stats, action: \.stats))
        .tabItem {
          Label("Статистика", systemSymbol: .chartBarXaxis)
        }
      
      SettingsView(store: store.scope(state: \.settings, action: \.settings))
        .tabItem {
          Label("Настройки", systemSymbol: .gearshape)
        }
    }
    .fullScreenCover(item: $store.scope(state: \.onboarding, action: \.onboarding)) { store in
      OnboardingView(store: store)
    }
  }
}
