//
//  LocalDatabaseClient.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 30.05.2025.
//

import Foundation
import SwiftData
import Dependencies
import DependenciesMacros

@DependencyClient
public struct LocalDatabaseClient: Sendable {
  public var dreams: DreamScope
  public var techniques: TechniqueScope
  public var seedIfNeeded: @Sendable () async throws -> Void
}

public extension LocalDatabaseClient {
  @DependencyClient
  struct DreamScope: Sendable {
    public var fetchAll: @Sendable () async throws -> [Dream]
    public var fetch: @Sendable (
      _ predicate: Predicate<Dream>,
      _ sortBy: [SortDescriptor<Dream>]
    ) async throws -> [Dream]
    public var create: @Sendable (Dream) async throws -> Void
    public var delete: @Sendable (Dream) async throws -> Void
    public var update: @Sendable (Dream) async throws -> Void
  }
  
  @DependencyClient
  struct TechniqueScope: Sendable {
    public var fetchAll: @Sendable () async throws -> [Technique]
    public var create: @Sendable (Technique) async throws -> Void
    public var delete: @Sendable (Technique) async throws -> Void
    public var update: @Sendable (Technique) async throws -> Void
  }
}

@ModelActor
public actor Database {
  public func fetch<T: PersistentModel>(
    _ type: T.Type,
    descriptor: FetchDescriptor<T>
  ) throws -> [T] {
    return try modelContext.fetch(descriptor)
  }
  
  public func insert<T: PersistentModel>(_ model: T) throws {
    modelContext.insert(model)
    try modelContext.save()
  }
  
  public func delete<T: PersistentModel>(_ model: T) throws {
    modelContext.delete(model)
    try modelContext.save()
  }
  
  public func save() throws {
    try modelContext.save()
  }
  
  public func count<T: PersistentModel>(for type: T.Type) async throws -> Int {
    let descriptor = FetchDescriptor<T>()
    let count = try modelContext.fetchCount(descriptor)
    return count
  }
  
  public func executeInContext<T>(_ operation: (ModelContext) throws -> T) throws -> T {
    return try operation(modelContext)
  }
}
