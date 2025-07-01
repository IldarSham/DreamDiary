//
//  EditDreamFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 20.06.2025.
//

import Foundation
import ComposableArchitecture
import Testing

@testable import DreamDiary

@MainActor
struct EditDreamFeatureTests {
  
  @Test
  func testInitForNewDream() {
    let creationDate = Date()
    
    let state = EditDreamFeature.State(selectedDate: creationDate)
    
    #expect(state.title == "")
    #expect(state.description == "")
    #expect(state.selectedDate == creationDate)
    #expect(state.isDatePickerExpanded == false)
    #expect(state.selectedTimeOfDay == .morning)
    #expect(state.selectedDreamType == .normal)
    #expect(state.editingDream == nil)
  }
  
  @Test
  func testInitForEditingDream() {
    let existingDream = Dream.mock1
    
    let state = EditDreamFeature.State(editingDream: existingDream)
    
    #expect(state.title == existingDream.title)
    #expect(state.description == existingDream.content)
    #expect(state.selectedDate == existingDream.date)
    #expect(state.selectedTimeOfDay == existingDream.timeOfDay)
    #expect(state.selectedDreamType == existingDream.type)
    #expect(state.isDatePickerExpanded == false)
    #expect(state.editingDream == existingDream)
  }
  
  @Test
  func testIsEditing_whenNewDream_isFalse() {
    let state = EditDreamFeature.State(selectedDate: Date())
    #expect(state.isEditing == false)
  }
  
  @Test
  func testIsEditing_whenEditingDream_isTrue() {
    let state = EditDreamFeature.State(editingDream: .mock1)
    #expect(state.isEditing)
  }

  @Test
  func testNavigationTitle_whenNewDream_isCorrect() {
    let state = EditDreamFeature.State(selectedDate: Date())
    #expect(state.navigationTitle == EditDreamFeature.Constants.newDreamNavTitle)
  }
  
  @Test
  func testNavigationTitle_whenEditingDream_isCorrect() {
    let state = EditDreamFeature.State(editingDream: .mock1)
    #expect(state.navigationTitle == EditDreamFeature.Constants.editingDreamNavTitle)
  }
  
  @Test
  func testSaveButtonTapped_whenCreatingNewDream_callsCreateAndDismiss() async {
    let newDream = Dream.mock1
    
    let createWasCalled = LockIsolated(false)
    let dismissWasCalled = LockIsolated(false)
    
    let store = TestStore(
      initialState: .init(
        title: newDream.title,
        description: newDream.content,
        selectedDate: newDream.date,
        selectedTimeOfDay: newDream.timeOfDay,
        selectedDreamType: newDream.type
      ),
      reducer: EditDreamFeature.init
    ) {
      $0.database.dreams.create = { dream in
        createWasCalled.setValue(true)
        
        #expect(dream.title == newDream.title)
        #expect(dream.content == newDream.content)
        #expect(dream.date == newDream.date)
        #expect(dream.timeOfDay == newDream.timeOfDay)
        #expect(dream.type == newDream.type)
      }
      $0.dismiss = DismissEffect {
        dismissWasCalled.setValue(true)
      }
    }
    
    await store.send(.saveButtonTapped)
    await store.receive(\.delegate.dreamAdded)
    
    #expect(createWasCalled.value)
    #expect(dismissWasCalled.value)
  }
  
  @Test
  func testSaveButtonTapped_whenEditingDream_callsUpdateAndDismiss() async {
    let editingDream = Dream.mock1
    let updatedTitle = "Обновленный заголовок"
    let updatedDescription = "Обновленное описание"
    
    let updateWasCalled = LockIsolated(false)
    let dismissWasCalled = LockIsolated(false)
    
    let store = TestStore(
      initialState: .init(editingDream: editingDream),
      reducer: EditDreamFeature.init
    ) {
      $0.database.dreams.update = { dream in
        updateWasCalled.setValue(true)
        
        #expect(dream.id == editingDream.id)
        #expect(dream.title == updatedTitle)
        #expect(dream.content == updatedDescription)
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
    
    await store.send(.saveButtonTapped)
    
    #expect(updateWasCalled.value)
    #expect(dismissWasCalled.value)
    
    await store.finish()
  }
}
