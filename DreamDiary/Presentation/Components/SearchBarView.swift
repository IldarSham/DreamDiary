//
//  SearchBarView.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 29.04.2025.
//

import SwiftUI
import SFSafeSymbols

struct SearchBarView: View {
  @Binding var text: String

  var body: some View {
    HStack {
      Image(systemSymbol: .magnifyingglass)
        .foregroundStyle(.gray)
      
      ZStack(alignment: .leading) {
        TextField("", text: $text)
          .foregroundColor(.white)
        
        if text.isEmpty {
          Text("Поиск")
            .font(.system(size: 16))
            .foregroundStyle(.gray)
        }
      }
    }
    .padding(.horizontal)
    .padding(.vertical, 6)
    .background(Color.white.opacity(0.1))
    .cornerRadius(20)
  }
}
