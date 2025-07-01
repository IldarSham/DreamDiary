//
//  SeedDataProvider.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 29.05.2025.
//

import Foundation
import SwiftData

public protocol SeedDataProvider: Sendable {
  associatedtype DataType: PersistentModel
  var seedKey: String { get }
  func loadSeedData() async throws -> [DataType]
}
