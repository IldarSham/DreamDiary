//
//  UserDefaultsClient.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 30.05.2025.
//

import Foundation
import Dependencies
import DependenciesMacros

@DependencyClient
public struct UserDefaultsClient {
  public var boolForKey: @Sendable (String) -> Bool = { _ in false }
  public var dataForKey: @Sendable (String) -> Data?
  public var doubleForKey: @Sendable (String) -> Double = { _ in 0 }
  public var integerForKey: @Sendable (String) -> Int = { _ in 0 }
  public var remove: @Sendable (String) async -> Void
  public var setBool: @Sendable (Bool, String) async -> Void
  public var setData: @Sendable (Data?, String) async -> Void
  public var setDouble: @Sendable (Double, String) async -> Void
  public var setInteger: @Sendable (Int, String) async -> Void
  
  public var wasOnboardingShown: Bool {
    self.boolForKey(onboardingShownKey)
  }

  public func setOnboardingShown(_ shown: Bool) async {
    await self.setBool(shown, onboardingShownKey)
  }
  
  public var isSynchronizationEnabled: Bool {
    self.boolForKey(synchronizationEnabledKey)
  }
  
  public func setSynchronizationEnabled(_ enabled: Bool) async {
    await self.setBool(enabled, synchronizationEnabledKey)
  }
}

private let onboardingShownKey = "onboardingShown"
private let synchronizationEnabledKey = "isSynchronizationEnabled"
