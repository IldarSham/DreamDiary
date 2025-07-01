//
//  DreamDetailFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 21.04.2025.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct DreamDetailFeature {
  @ObservableState
  struct State: Equatable {
    let dream: Dream
  }
  
  enum Action {
    case delegate(Delegate)
    case editButtonTapped
    
    enum Delegate {
      case editDream(Dream)
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none
        
      case .editButtonTapped:
        return .send(.delegate(.editDream(state.dream)))
      }
    }
  }
}

struct DreamDetailView: View {
  var store: StoreOf<DreamDetailFeature>
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text(store.dream.title)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundColor(.white)
          .padding(.bottom, 1)
        
        Text(store.dream.formattedDateTime)
          .font(.subheadline)
          .foregroundColor(Color(red: 176/255, green: 178/255, blue: 189/255))
        
        Spacer().frame(height: 18)
        
        Text(store.dream.content)
          .font(.body)
          .foregroundColor(.white.opacity(0.9))
          .textSelection(.enabled)
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      .padding(.horizontal, 22)
      .padding(.vertical)
    }
    .toolbar {
      Button("Править") {
        store.send(.editButtonTapped)
      }
    }
    .background(Color.primaryDarkColor)
  }
}

// MARK: - Preview
struct DreamDetailView_Previews: PreviewProvider {
  static var previews: some View {
    DreamDetailView(
      store: Store(initialState: DreamDetailFeature.State(dream: .mock1)) {
        DreamDetailFeature()
      }
    )
  }
}
