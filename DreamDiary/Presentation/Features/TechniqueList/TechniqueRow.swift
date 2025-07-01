//
//  TechniqueRow.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 24.04.2025.
//

import SwiftUI

struct TechniqueRow: View {
  let technique: Technique
  
  var body: some View {
    HStack(spacing: 20) {
      HStack(alignment: .top, spacing: 15) {
        Image(systemSymbol: technique.symbol)
          .font(.system(size: 35, weight: .semibold))
          .foregroundColor(Color.primaryPurpleColor)
          .padding(.top, 2)
        
        VStack(alignment: .leading, spacing: 5) {
          Text(technique.title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
          
          Text(technique.content)
            .lineLimit(3)
            .font(.body)
            .foregroundColor(Color(UIColor.systemGray2))
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
            
      Image(systemSymbol: .chevronRight)
        .foregroundColor(.gray)
        .font(.system(size: 14, weight: .semibold))
    }
    .padding(18)
    .background(Color.primaryLightGrayColor)
    .cornerRadius(12)
  }
}

// MARK: - Preview
struct TechniqueRow_Previews: PreviewProvider {
  static var previews: some View {
    TechniqueRow(technique: .mock1)
  }
}
