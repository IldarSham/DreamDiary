//
//  TechniqueListFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 19.06.2025.
//

import Foundation
import ComposableArchitecture
import Testing
import SFSafeSymbols

@testable import DreamDiary

@MainActor
struct TechniqueListFeatureTests {
  
  private let mockTechniques: [Technique] = .mock
  
  @Test
  func testTask_whenTechniquesAreEmpty_loadsTechniques() async {
    let store = TestStore(initialState: TechniqueListFeature.State()) {
      TechniqueListFeature()
    } withDependencies: {
      $0.database.techniques.fetchAll = { self.mockTechniques }
    }
    
    await store.send(.task)
    await store.receive(\.techniquesResponse) {
      $0.techniques = self.mockTechniques
    }
  }
  
  @Test
  func testTask_whenTechniquesAreAlreadyLoaded_doesNotLoadTechniquesAgain() async {
    let store = TestStore(initialState: TechniqueListFeature.State(techniques: [mockTechniques[0]])) {
      TechniqueListFeature()
    }
    
    await store.send(.task)
    await store.finish()
  }
  
  @Test
  func testAddTechniqueButtonTapped_navigatesToEditScreen() async {
    let store = TestStore(initialState: TechniqueListFeature.State()) {
      TechniqueListFeature()
    }
    
    await store.send(.addTechniqueButtonTapped) {
      $0.path.append(.editTechnique(EditTechniqueFeature.State()))
    }
  }
  
  @Test
  func testDeleteTechniqueButtonTapped_showsDeleteConfirmation() async {
    let deletedTechnique = mockTechniques[0]
    let store = TestStore(initialState: TechniqueListFeature.State()) {
      TechniqueListFeature()
    }
    
    await store.send(.deleteTechniqueButtonTapped(deletedTechnique)) {
      $0.alert = .deleteConfirmation(technique: deletedTechnique)
    }
  }
  
  @Test
  func testTechniqueTapped_navigatesToDetail() async {
    let selectedTechnique = mockTechniques[0]
    let store = TestStore(initialState: TechniqueListFeature.State(techniques: mockTechniques)) {
      TechniqueListFeature()
    }
    
    await store.send(.techniqueTapped(selectedTechnique)) {
      $0.path.append(.detailTechnique(TechniqueDetailFeature.State(technique: selectedTechnique)))
    }
  }
}
