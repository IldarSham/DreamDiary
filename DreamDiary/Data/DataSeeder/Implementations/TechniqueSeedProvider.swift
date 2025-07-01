//
//  TechniqueSeedProvider.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 12.06.2025.
//

import Foundation
import SFSafeSymbols

private struct TechniqueSeedData: Decodable {
  let title: String
  let content: String
  let symbol: String
}

public struct TechniquesSeedProvider: SeedDataProvider {
  public let seedKey = "techniques"
  
  private let filename = "techniques"
  private let fileExtension = "json"
  
  public func loadSeedData() async throws -> [Technique] {
    guard let url = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
      throw SeedDataError.fileNotFound("\(filename).\(fileExtension)")
    }
    
    do {
      let data = try Data(contentsOf: url)
      let techniques = try JSONDecoder().decode([TechniqueSeedData].self, from: data)
      return techniques.reversed().map {
        Technique(title: $0.title, content: $0.content, symbol: SFSymbol(rawValue: $0.symbol))
      }
    } catch {
      throw SeedDataError.decodingFailed(error.localizedDescription)
    }
  }
}
