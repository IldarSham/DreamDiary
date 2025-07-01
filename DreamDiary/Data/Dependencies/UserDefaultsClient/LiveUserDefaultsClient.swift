//
//  LiveUserDefaultsClient.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 30.05.2025.
//

import Foundation
import Dependencies

extension UserDefaultsClient: DependencyKey {
  public static let liveValue: Self = {
    let defaults = { UserDefaults.standard }
    return Self(
      boolForKey: { defaults().bool(forKey: $0) },
      dataForKey: { defaults().data(forKey: $0) },
      doubleForKey: { defaults().double(forKey: $0) },
      integerForKey: { defaults().integer(forKey: $0) },
      remove: { defaults().removeObject(forKey: $0) },
      setBool: { defaults().set($0, forKey: $1) },
      setData: { defaults().set($0, forKey: $1) },
      setDouble: { defaults().set($0, forKey: $1) },
      setInteger: { defaults().set($0, forKey: $1) }
    )
  }()
}
