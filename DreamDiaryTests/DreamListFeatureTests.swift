//
//  DreamListFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 16.06.2025.
//

import Foundation
import ComposableArchitecture
import Testing

@testable import DreamDiary

@MainActor
struct DreamListFeatureTests {
  
  private let mockDreams: [Dream] = .mock

  @Test
  func testTask_whenDreamsAreEmpty_loadsDreams() async {
    let store = TestStore(initialState: DreamListFeature.State()) {
      DreamListFeature()
    } withDependencies: {
      $0.database.dreams.fetchAll = { self.mockDreams }
    }
    
    await store.send(.task)
    await store.receive(\.dreamsResponse) {
      $0.dreams = self.mockDreams
    }
  }
  
  @Test
  func testTask_whenDreamsAreAlreadyLoaded_doesNotLoadDreamsAgain() async {
    let store = TestStore(initialState: DreamListFeature.State(dreams: mockDreams)) {
      DreamListFeature()
    }
    
    await store.send(.task)
    await store.finish()
  }

  @Test
  func testAddDreamButtonTapped_navigatesToEditScreen() async {
    let date = Date(timeIntervalSince1970: 1_234_567_890)
    
    let store = TestStore(initialState: DreamListFeature.State()) {
      DreamListFeature()
    } withDependencies: {
      $0.date.now = date
    }
    
    await store.send(.addDreamButtonTapped) {
      $0.path.append(.editDream(EditDreamFeature.State(selectedDate: date)))
    }
  }
  
  @Test
  func testDeleteDreamButtonTapped_showsDeleteConfirmation() async {
    let deletedDream = mockDreams[0]
    let store = TestStore(initialState: DreamListFeature.State()) {
      DreamListFeature()
    }
    
    await store.send(.deleteDreamButtonTapped(deletedDream)) {
      $0.alert = .deleteConfirmation(dream: deletedDream)
    }
  }
  
  @Test
  func testDreamTapped_navigatesToDetail() async {
    let selectedDream = mockDreams[0]
    let store = TestStore(initialState: DreamListFeature.State(dreams: mockDreams)) {
      DreamListFeature()
    }
    
    await store.send(.dreamTapped(selectedDream)) {
      $0.path.append(.detailDream(DreamDetailFeature.State(dream: selectedDream)))
    }
  }
}
