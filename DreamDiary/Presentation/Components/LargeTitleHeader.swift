//
//  LargeTitleHeader.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 06.05.2025.
//

import SwiftUI

struct LargeTitleHeader<Trailing: View>: View {
  let title: String
  let trailing: Trailing
  
  init(
    title: String,
    @ViewBuilder trailing: () -> Trailing = { EmptyView() }
  ) {
    self.title = title
    self.trailing = trailing()
  }
  
  var body: some View {
    HStack {
      Text(title)
        .foregroundColor(.white)
        .font(.largeTitle)
        .fontWeight(.bold)
      Spacer()
      trailing
    }
    .padding(.horizontal)
    .padding(.top, 30)
  }
}
