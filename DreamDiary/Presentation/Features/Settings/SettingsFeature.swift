//
//  SettingsFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 14.04.2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SettingsFeature {
  @ObservableState
  struct State: Equatable {
    var isSynchronizationEnabled: Bool = false
  }
  
  enum Action {
    case onAppear
    case isSynchronizationEnabledChanged(Bool)
  }
  
  @Dependency(\.userDefaults) var userDefaults
  
  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        state.isSynchronizationEnabled = userDefaults.isSynchronizationEnabled
        return .none
      
      case let .isSynchronizationEnabledChanged(isEnabled):
        state.isSynchronizationEnabled = isEnabled
        return .run { _ in
          await userDefaults.setSynchronizationEnabled(isEnabled)
        }
      }
    }
  }
}

struct SettingsView: View {
  @Bindable var store: StoreOf<SettingsFeature>
  
  var body: some View {
    NavigationStack {
      List {
        HStack {
          Text("Синхронизация с iCloud")
            .foregroundColor(.white)
          Spacer()
          Toggle("", isOn: $store.isSynchronizationEnabled.sending(\.isSynchronizationEnabledChanged))
            .fixedSize()
        }
        .listRowBackground(Color.primaryLightGrayColor)
      }
      .background(Color.primaryDarkColor)
      .scrollContentBackground(.hidden)
      .navigationTitle("Настройки")
      .navigationBarTitleDisplayMode(.large)
      .onAppear {
        store.send(.onAppear)
      }
    }
  }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(
      store: Store(initialState: SettingsFeature.State()) {
        SettingsFeature()
      }
    )
  }
}
