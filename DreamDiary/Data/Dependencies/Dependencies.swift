//
//  Dependencies.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 23.05.2025.
//

import Dependencies

extension DependencyValues {
  public var database: LocalDatabaseClient {
    get { self[LocalDatabaseClient.self] }
    set { self[LocalDatabaseClient.self] = newValue }
  }
  
  public var userDefaults: UserDefaultsClient {
    get { self[UserDefaultsClient.self] }
    set { self[UserDefaultsClient.self] = newValue }
  }
}
