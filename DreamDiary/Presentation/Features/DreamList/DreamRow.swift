//
//  DreamRow.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 11.04.2025.
//

import SwiftUI
import SFSafeSymbols

struct DreamRow: View {
  let dream: Dream
  
  var body: some View {
    ZStack {
      VStack(alignment: .leading) {
        HStack(alignment: .top) {
          Text(dream.title)
            .font(.title2)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.trailing, 10)
          
          Spacer()
          
          Text(dream.type.rawValue)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(dream.type.color)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(dream.type.color.opacity(0.25))
            .clipShape(Capsule())
        }
        Text(dream.formattedDateTime)
          .font(.subheadline)
          .foregroundColor(Color(red: 176/255, green: 178/255, blue: 189/255))
        
        Spacer().frame(height: 18)
        
        Text(dream.content)
          .font(.body)
          .foregroundColor(.white.opacity(0.9))
          .lineLimit(3)
          .padding(.trailing, 15)
      }
      
      Image(systemSymbol: .chevronRight)
        .foregroundColor(.gray)
        .font(.system(size: 14, weight: .semibold))
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
    .padding(22)
    .background(Color.primaryLightGrayColor)
    .cornerRadius(12)
  }
}

// MARK: - Preview
struct DreamRow_Previews: PreviewProvider {
  static var previews: some View {
    DreamRow(dream: .mock1)
  }
}
