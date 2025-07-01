//
//  EditTechniqueFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 25.04.2025.
//

import ComposableArchitecture
import SwiftUI
import SFSafeSymbols

@Reducer
struct EditTechniqueFeature {
  enum Constants {
    static let newTechniqueNavTitle = "Новая техника"
    static let editingTechniqueNavTitle = "Редактирование техники"
  }
  
  @ObservableState
  struct State: Equatable {
    var title: String = ""
    var description: String = ""
    var selectedSymbol: SFSymbol = .allSymbols.first!
    var editingTechnique: Technique?
    
    var isEditing: Bool {
      editingTechnique != nil
    }
    
    var navigationTitle: String {
      isEditing
        ? Constants.editingTechniqueNavTitle
        : Constants.newTechniqueNavTitle
    }
  }
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case saveButtonTapped
    
    @CasePathable
    enum Delegate {
      case techniqueAdded(Technique)
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.database.techniques) var database
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .delegate:
        return .none
        
      case .saveButtonTapped:
        let techniqueToSave: Technique
        
        if let editingTechnique = state.editingTechnique {
          editingTechnique.title = state.title
          editingTechnique.content = state.description
          editingTechnique.symbol = state.selectedSymbol
          techniqueToSave = editingTechnique
        } else {
          techniqueToSave = Technique(
            title: state.title,
            content: state.description,
            symbol: state.selectedSymbol
          )
        }
        
        return .run { [state] send in
          if state.isEditing {
            try await self.database.update(techniqueToSave)
          } else {
            try await self.database.create(techniqueToSave)
            await send(.delegate(.techniqueAdded(techniqueToSave)))
          }
          await self.dismiss()
        }
      }
    }
  }
}

extension EditTechniqueFeature.State {
  init(editingTechnique: Technique) {
    self.editingTechnique = editingTechnique
    self.title = editingTechnique.title
    self.description = editingTechnique.content
    self.selectedSymbol = editingTechnique.symbol
  }
}

struct EditTechniqueView: View {
  @State var store: StoreOf<EditTechniqueFeature>
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        LabeledSection(title: "Заголовок") {
          PrimaryTextField(
            placeholder: "Название техники",
            text: $store.title
          )
        }
        
        LabeledSection(title: "Описание") {
          PrimaryTextField(
            placeholder: "Опишите вашу технику подробно...",
            text: $store.description,
            axis: .vertical,
            lineLimit: 8
          )
        }
        
        LabeledSection(title: "Символ") {
          SymbolsBrowserView<SFSymbol>(
            selectedSymbol: $store.selectedSymbol
          )
        }
      }
      .padding()
    }
    .toolbar {
      Button("Готово") {
        store.send(.saveButtonTapped)
      }
    }
    .background(Color.primaryDarkColor)
    .navigationTitle(store.state.navigationTitle)
    .navigationBarTitleDisplayMode(.large)
  }
}

// MARK: - Preview
struct EditTechniqueView_Previews: PreviewProvider {
  static var previews: some View {
    EditTechniqueView(
      store: Store(initialState: EditTechniqueFeature.State()) {
        EditTechniqueFeature()
      }
    )
  }
}
