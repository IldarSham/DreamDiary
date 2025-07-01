//
//  DreamDiaryApp.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 08.04.2025.
//

import ComposableArchitecture
import SwiftUI

@main
struct DreamDiaryApp: App {
  let store = Store(initialState: AppFeature.State()) {
    AppFeature()
  }
  
  init() {
    AppearanceConfigurator.setupGlobalAppearance()
  }
  
  var body: some Scene {
    WindowGroup {
      AppView(store: store)
        .onAppear {
          store.send(.appDidLaunch)
        }
    }
  }
}
