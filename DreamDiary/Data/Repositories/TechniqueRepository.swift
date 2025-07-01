//
//  TechniqueRepository.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 03.06.2025.
//

import Foundation
import SwiftData

public struct TechniqueRepository: Sendable {
  private let database: Database
  
  public init(database: Database) {
    self.database = database
  }
  
  public func fetchAll() async throws -> [Technique] {
    let descriptor = FetchDescriptor<Technique>(
      sortBy: [SortDescriptor(\.date, order: .reverse)]
    )
    return try await database.fetch(Technique.self, descriptor: descriptor)
  }
  
  public func create(_ technique: Technique) async throws {
    try await database.insert(technique)
  }
  
  public func delete(_ technique: Technique) async throws {
    try await database.delete(technique)
  }
  
  public func update(_ technique: Technique) async throws {
    try await database.save()
  }
}
