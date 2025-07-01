//
//  SettingsFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 25.06.2025.
//

import ComposableArchitecture
import Testing

@testable import DreamDiary

@MainActor
struct SettingsFeatureTests {
  
  @Test
  func testOnAppear_whenSyncIsEnabledInUserDefaults_setsStateToTrue() async {
    let store = TestStore(initialState: SettingsFeature.State()) {
      SettingsFeature()
    } withDependencies: {
      $0.userDefaults.boolForKey = { _ in true }
    }
    
    #expect(store.state.isSynchronizationEnabled == false)
    
    await store.send(.onAppear) {
      $0.isSynchronizationEnabled = true
    }
  }
  
  @Test
  func testOnAppear_whenSyncIsDisabledInUserDefaults_stateRemainsFalse() async {
    let store = TestStore(initialState: SettingsFeature.State()) {
      SettingsFeature()
    } withDependencies: {
      $0.userDefaults.boolForKey = { _ in false }
    }
    
    await store.send(.onAppear)
  }
  
  @Test
  func testToggleSynchronization_fromFalseToTrue_updatesState() async {
    let setEnabledCalled = LockIsolated(false)
    
    let store = TestStore(initialState: SettingsFeature.State(isSynchronizationEnabled: false)) {
      SettingsFeature()
    } withDependencies: {
      $0.userDefaults.setBool = { state, _ in
        #expect(state == true)
        setEnabledCalled.setValue(true)
      }
    }
    
    await store.send(.isSynchronizationEnabledChanged(true)) {
      $0.isSynchronizationEnabled = true
    }
    
    #expect(setEnabledCalled.value)
  }
  
  @Test
  func testToggleSynchronization_fromTrueToFalse_updatesStateAndCallsDependency() async {
    let setEnabledCalled = LockIsolated(false)
    
    let store = TestStore(initialState: SettingsFeature.State(isSynchronizationEnabled: true)) {
      SettingsFeature()
    } withDependencies: {
      $0.userDefaults.setBool = { state, _ in
        #expect(state == false)
        setEnabledCalled.setValue(true)
      }
    }
    
    await store.send(.isSynchronizationEnabledChanged(false)) {
      $0.isSynchronizationEnabled = false
    }
    
    #expect(setEnabledCalled.value)
  }
}
