//
//  DreamRepository.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 03.06.2025.
//

import Foundation
import SwiftData

public struct DreamRepository: Sendable {
  private let database: Database
  
  public init(database: Database) {
    self.database = database
  }
  
  public func fetchAll() async throws -> [Dream] {
    let descriptor = FetchDescriptor<Dream>(
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    return try await database.fetch(Dream.self, descriptor: descriptor)
  }
  
  public func fetch(
    predicate: Predicate<Dream>? = nil,
    sortBy: [SortDescriptor<Dream>] = []
  ) async throws -> [Dream] {
    let descriptor = FetchDescriptor<Dream>(
      predicate: predicate,
      sortBy: sortBy
    )
    return try await database.fetch(Dream.self, descriptor: descriptor)
  }
  
  public func create(_ dream: Dream) async throws {
    try await database.insert(dream)
  }
  
  public func delete(_ dream: Dream) async throws {
    try await database.delete(dream)
  }
  
  public func update(_ dream: Dream) async throws {
    try await database.save()
  }
}
