//
//  OnboardingFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 20.06.2025.
//

import ComposableArchitecture
import Testing

@testable import DreamDiary

@MainActor
struct OnboardingFeatureTests {
  
  @Test
  func testInitialState() {
    let store = TestStore(initialState: OnboardingFeature.State()) {
      OnboardingFeature()
    }

    #expect(store.state.currentTab == .diary)
    #expect(store.state.isLastTab == false)
    #expect(store.state.mainButtonTitle == OnboardingFeature.Constants.nextButtonTitle)
  }
  
  @Test
  func testMainButtonTapped_advancesTab() async {
    let store = TestStore(initialState: OnboardingFeature.State()) {
      OnboardingFeature()
    }

    await store.send(.mainButtonTapped) {
      $0.currentTab = .techniques
    }
    #expect(store.state.mainButtonTitle == OnboardingFeature.Constants.nextButtonTitle)

    await store.send(.mainButtonTapped) {
      $0.currentTab = .stats
    }
    
    #expect(store.state.isLastTab)
    #expect(store.state.mainButtonTitle == OnboardingFeature.Constants.getStartedButtonTitle)
  }
  
  @Test
  func testMainButtonTapped_onLastTab_finishesOnboarding() async {
    let onboardingWasShown = LockIsolated(false)

    let store = TestStore(
      initialState: OnboardingFeature.State(currentTab: .stats)
    ) {
      OnboardingFeature()
    } withDependencies: {
      $0.userDefaults.setBool = { state, _ in
        onboardingWasShown.setValue(true)
      }
    }
    
    #expect(store.state.isLastTab)

    await store.send(.mainButtonTapped)
    
    await store.receive(\.finishOnboarding)
    await store.receive(\.delegate.getStarted)

    #expect(onboardingWasShown.value)
  }
  
  @Test
  func testSkipButtonTapped_finishesOnboarding() async {
    let onboardingWasShown = LockIsolated(false)
    
    let store = TestStore(initialState: OnboardingFeature.State()) {
      OnboardingFeature()
    } withDependencies: {
      $0.userDefaults.setBool = { state, _ in
        onboardingWasShown.setValue(true)
      }
    }
    
    await store.send(.skipButtonTapped)
    
    await store.receive(\.finishOnboarding)
    await store.receive(\.delegate.getStarted)
    
    #expect(onboardingWasShown.value)
  }
  
  @Test
  func testTabChanged() async {
    let store = TestStore(initialState: OnboardingFeature.State()) {
      OnboardingFeature()
    }
    
    await store.send(.tabChanged(.stats)) {
      $0.currentTab = .stats
    }
    
    #expect(store.state.isLastTab)
  }
}
