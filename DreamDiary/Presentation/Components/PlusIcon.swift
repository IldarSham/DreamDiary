//
//  PlusIcon.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 06.05.2025.
//

import SwiftUI
import SFSafeSymbols

struct PlusIcon: View {
  var body: some View {
    Image(systemSymbol: .plus)
      .font(.system(size: 20, weight: .semibold))
      .foregroundColor(.white)
      .padding(10)
      .background(Color.primaryPurpleColor)
      .clipShape(Circle())
  }
}
