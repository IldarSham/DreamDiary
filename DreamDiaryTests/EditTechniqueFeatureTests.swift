//
//  EditTechniqueFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 21.06.2025.
//

import Foundation
import ComposableArchitecture
import Testing
import SFSafeSymbols

@testable import DreamDiary

@MainActor
struct EditTechniqueFeatureTests {
  
  @Test
  func testInitForNewTechnique() {
    let state = EditTechniqueFeature.State()
    #expect(state.title == "")
    #expect(state.description == "")
    #expect(state.selectedSymbol == .allSymbols.first!)
    #expect(state.editingTechnique == nil)
  }
  
  @Test
  func testInitForEditingTechnique() {
    let technique = Technique.mock1
    
    let state = EditTechniqueFeature.State(editingTechnique: technique)
    #expect(state.title == technique.title)
    #expect(state.description == technique.content)
    #expect(state.selectedSymbol == technique.symbol)
    #expect(state.editingTechnique == technique)
  }
  
  @Test
  func testIsEditing_whenNewTechnique_isFalse() {
    let state = EditTechniqueFeature.State()
    #expect(state.isEditing == false)
  }
  
  @Test
  func testIsEditing_whenEditingTechnique_isTrue() {
    let state = EditTechniqueFeature.State(editingTechnique: .mock1)
    #expect(state.isEditing)
  }
  
  @Test
  func testNavigationTitle_whenNewTechnique_isCorrect() {
    let state = EditTechniqueFeature.State()
    #expect(state.navigationTitle == EditTechniqueFeature.Constants.newTechniqueNavTitle)
  }
  
  @Test
  func testNavigationTitle_whenEditingTechnique_isCorrect() {
    let state = EditTechniqueFeature.State(editingTechnique: .mock1)
    #expect(state.navigationTitle == EditTechniqueFeature.Constants.editingTechniqueNavTitle)
  }
  
  @Test
  func testSaveButtonTapped_whenCreatingNewTechnique_callsCreateAndDismiss() async {
    let newTechnique = Technique.mock1
    
    let createWasCalled = LockIsolated(false)
    let dismissWasCalled = LockIsolated(false)
    
    let store = TestStore(
      initialState: .init(
        title: newTechnique.title,
        description: newTechnique.content,
        selectedSymbol: newTechnique.symbol
      ),
      reducer: EditTechniqueFeature.init
    ) {
      $0.database.techniques.create = { technique in
        createWasCalled.setValue(true)
        
        #expect(technique.title == newTechnique.title)
        #expect(technique.content == newTechnique.content)
        #expect(technique.symbol == newTechnique.symbol)
      }
      $0.dismiss = DismissEffect {
        dismissWasCalled.setValue(true)
      }
    }
    
    await store.send(.saveButtonTapped)
    await store.receive(\.delegate.techniqueAdded)
    
    #expect(createWasCalled.value)
    #expect(dismissWasCalled.value)
  }
  
  @Test
  func testSaveButtonTapped_whenEditingTechnique_callsUpdateAndDismiss() async {
    let editingTechnique = Technique.mock1
    let updatedTitle = "Обновленный заголовок"
    let updatedDescription = "Обновленное описание"
    let updatedSymbol = SFSymbol.moon
    
    let updateWasCalled = LockIsolated(false)
    let dismissWasCalled = LockIsolated(false)
    
    let store = TestStore(
      initialState: .init(editingTechnique: editingTechnique),
      reducer: EditTechniqueFeature.init
    ) {
      $0.database.techniques.update = { technique in
        updateWasCalled.setValue(true)
        
        #expect(technique.id == editingTechnique.id)
        #expect(technique.title == updatedTitle)
        #expect(technique.content == updatedDescription)
        #expect(technique.symbol == updatedSymbol)
      }
      $0.dismiss = DismissEffect {
        dismissWasCalled.setValue(true)
      }
    }
    
    await store.send(.set(\.title, updatedTitle)) {
      $0.title = updatedTitle
    }
    await store.send(.set(\.description, updatedDescription)) {
      $0.description = updatedDescription
    }
    await store.send(.set(\.selectedSymbol, updatedSymbol)) {
      $0.selectedSymbol = updatedSymbol
    }
    
    await store.send(.saveButtonTapped)
    
    #expect(updateWasCalled.value)
    #expect(dismissWasCalled.value)
    
    await store.finish()
  }
}
