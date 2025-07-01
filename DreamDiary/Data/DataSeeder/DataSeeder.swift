//
//  DataSeeder.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 06.06.2025.
//

import Foundation

public struct DatabaseSeeder: Sendable {
  private let tracker: SeedDataTracker
  private let providers: [any SeedDataProvider]
  
  public init(tracker: SeedDataTracker = SeedDataTracker(), providers: [any SeedDataProvider]) {
    self.tracker = tracker
    self.providers = providers
  }
  
  public func seedIfNeeded(database: Database) async throws {
    for provider in providers {
      try await seedDataIfNeeded(with: provider, database: database)
    }
  }
  
  private func seedDataIfNeeded<T: SeedDataProvider>(with provider: T, database: Database) async throws {
    guard await !tracker.isSeedCompleted(for: provider.seedKey) else { return }
    
    do {
      let existingCount = try await database.count(for: T.DataType.self)
      
      if existingCount > 0 {
        print("Found \(existingCount) existing records for \(T.DataType.self), marking seed as completed")
        await tracker.markSeedCompleted(for: provider.seedKey)
        return
      }
      
      let seedData = try await provider.loadSeedData()
      
      for item in seedData {
        try await database.insert(item)
      }
      
      await tracker.markSeedCompleted(for: provider.seedKey)
    } catch {
      print("Failed to seed \(T.DataType.self): \(error.localizedDescription)")
      throw error
    }
  }
}

public actor SeedDataTracker: Sendable {
  private let userDefaults = UserDefaults.standard
  
  public init() {}
  
  public func isSeedCompleted(for seedKey: String) -> Bool {
    return userDefaults.bool(forKey: "seed_data_\(seedKey)_completed")
  }
  
  public func markSeedCompleted(for seedKey: String) {
    userDefaults.set(true, forKey: "seed_data_\(seedKey)_completed")
  }
}

public enum SeedDataError: LocalizedError, Sendable {
  case fileNotFound(String)
  case decodingFailed(String)
}
