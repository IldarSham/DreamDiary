//
//  AppFeatureTests.swift
//  DreamDiaryTests
//
//  Created by Ildar Shamsullin on 19.06.2025.
//

import ComposableArchitecture
import Testing

@testable import DreamDiary

@MainActor
struct AppFeatureTests {

  @Test
  func testAppDidLaunch_whenOnboardingNotShown_showsOnboardingAndSeedsDatabase() async {
    let seedIfNeededWasCalled = LockIsolated(false)

    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.userDefaults.boolForKey = { _ in false }
      $0.database.seedIfNeeded = {
        seedIfNeededWasCalled.setValue(true)
      }
    }

    await store.send(.appDidLaunch) {
      $0.onboarding = OnboardingFeature.State()
    }
    await store.finish()

    #expect(seedIfNeededWasCalled.value)
  }
  
  @Test
  func testAppDidLaunch_whenAlreadyOnboarded_seedsDatabase() async {
    let seedIfNeededWasCalled = LockIsolated(false)

    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.userDefaults.boolForKey = { _ in true }
      $0.database.seedIfNeeded = {
        seedIfNeededWasCalled.setValue(true)
      }
    }

    await store.send(.appDidLaunch)
    await store.finish()

    #expect(seedIfNeededWasCalled.value)
  }
  
  @Test
  func testOnboardingGetStartedButtonTapped_dismissesOnboarding() async {
    let store = TestStore(initialState: AppFeature.State()) {
      AppFeature()
    } withDependencies: {
      $0.userDefaults.boolForKey = { _ in false }
    }
    
    await store.send(.appDidLaunch) {
      $0.onboarding = OnboardingFeature.State()
    }
    await store.send(.onboarding(.presented(.delegate(.getStarted)))) {
      $0.onboarding = nil
    }
  }
}
