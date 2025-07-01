//
//  TechniqueDetailView.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 29.04.2025.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct TechniqueDetailFeature {
  @ObservableState
  struct State: Equatable {
    let technique: Technique
  }
  
  enum Action {
    case delegate(Delegate)
    case editButtonTapped

    enum Delegate {
      case editTechnique(Technique)
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
        
      case .editButtonTapped:
        return .send(.delegate(.editTechnique(state.technique)))
      }
    }
  }
}

struct TechniqueDetailView: View {
  var store: StoreOf<TechniqueDetailFeature>
  
  var body: some View {
    ScrollView {
      VStack(spacing: 20) {
        Image(systemSymbol: store.technique.symbol)
          .font(.system(size: 60, weight: .semibold))
          .foregroundColor(Color.primaryPurpleColor)
          .frame(width: 120, height: 120)
          .background(Color(red: 32/255, green: 37/255, blue: 46/255))
          .cornerRadius(20)
        
        VStack(alignment: .leading, spacing: 5) {
          Text(store.technique.title)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.white)
          
          Text(store.technique.content)
            .font(.body)
            .foregroundColor(Color(UIColor.systemGray2))
            .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
      }
    }
    .toolbar {
      Button("Править") {
        store.send(.editButtonTapped)
      }
    }
    .padding(.vertical)
    .navigationTitle("Техника")
    .background(Color.primaryDarkColor)
  }
}

// MARK: - Preview
struct TechniqueDetailView_Previews: PreviewProvider {
  static var previews: some View {
    TechniqueDetailView(
      store: Store(initialState: TechniqueDetailFeature.State(technique: .mock1)) {
        TechniqueDetailFeature()
      }
    )
  }
}
