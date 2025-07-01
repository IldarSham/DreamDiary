//
//  LiveLocalDatabaseClient.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 30.05.2025.
//

import SwiftData
import Dependencies

extension LocalDatabaseClient: DependencyKey {
  public static var liveValue: Self {
    let modelContainer: ModelContainer = {
      do {
        let config = ModelConfiguration(
          for: Dream.self, Technique.self,
          isStoredInMemoryOnly: false
        )
        
        return try ModelContainer(
          for: Dream.self, Technique.self,
          configurations: config
        )
      } catch {
        fatalError("Failed to initialize ModelContainer: \(error)")
      }
    }()
    
    let database = Database(modelContainer: modelContainer)
    
    let dreamRepository = DreamRepository(database: database)
    let techniqueRepository = TechniqueRepository(database: database)
    
    let seeder = DatabaseSeeder(providers: [TechniquesSeedProvider()])
    
    return Self(
      dreams: .init(
        fetchAll: {
          try await dreamRepository.fetchAll()
        },
        fetch: { predicate, sortBy in
          try await dreamRepository.fetch(predicate: predicate, sortBy: sortBy)
        },
        create: { dream in
          try await dreamRepository.create(dream)
        },
        delete: { dream in
          try await dreamRepository.delete(dream)
        },
        update: { dream in
          try await dreamRepository.update(dream)
        }
      ),
      techniques: .init(
        fetchAll: {
          try await techniqueRepository.fetchAll()
        },
        create: { technique in
          try await techniqueRepository.create(technique)
        },
        delete: { technique in
          try await techniqueRepository.delete(technique)
        },
        update: { technique in
          try await techniqueRepository.update(technique)
        }
      ),
      seedIfNeeded: {
        try await seeder.seedIfNeeded(database: database)
      }
    )
  }
  
  public static let testValue = Self(
    dreams: .init(
      fetchAll: { [] },
      fetch: { _, _ in [] },
      create: { _ in },
      delete: { _ in },
      update: { _ in}
    ),
    techniques: .init(
      fetchAll: { [] },
      create: { _ in },
      delete: { _ in },
      update: { _ in }
    ),
    seedIfNeeded: {}
  )
}
