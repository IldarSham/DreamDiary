//
//  LabeledSection.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 22.04.2025.
//

import SwiftUI

struct LabeledSection<Content: View>: View {
  let title: String
  let content: () -> Content
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(title)
        .font(.headline)
        .foregroundColor(Color(UIColor.systemGray2))
        .padding(.horizontal, 8)
      
      content()
        .padding()
        .background(Color.primaryLightGrayColor)
        .cornerRadius(12)
    }
  }
}
