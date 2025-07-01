//
//  OnboardingPageView.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 07.05.2025.
//

import SwiftUI

struct OnboardingPageView: View {
  var title: String
  var imageName: String
  var description: String
  
  var body: some View {
    VStack {
      Image(imageName)
        .resizable()
        .scaledToFit()
        .frame(height: 210)
        .foregroundColor(.primaryPurpleColor)
      
      Spacer().frame(height: 70)
            
      Text(title)
        .font(.title)
        .foregroundColor(.white)
        .bold()
      
      Spacer().frame(height: 10)
      
      Text(description)
        .font(.body)
        .foregroundColor(.white.opacity(0.8))
        .multilineTextAlignment(.center)
        .padding(.horizontal)
    }
    .padding()
  }
}
