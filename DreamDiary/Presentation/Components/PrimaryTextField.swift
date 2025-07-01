//
//  PrimaryTextField.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 22.04.2025.
//

import SwiftUI

struct PrimaryTextField: View {
  let placeholder: String
  @Binding var text: String
  
  var axis: Axis = .horizontal
  var lineLimit: Int? = nil
  
  var body: some View {
    ZStack(alignment: .leading) {
      TextField("", text: $text, axis: axis)
        .lineLimit(axis == .vertical ? lineLimit : 1)
        .foregroundColor(.white)
      
      if text.isEmpty {
        Text(placeholder)
          .font(.system(size: 16))
          .foregroundColor(Color.gray.opacity(0.7))
      }
    }
  }
}
