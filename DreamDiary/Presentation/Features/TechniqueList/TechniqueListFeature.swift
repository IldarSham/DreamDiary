//
//  TechniqueListView.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 22.04.2025.
//

import ComposableArchitecture
import SwiftUI
import SFSafeSymbols

@Reducer
struct TechniqueListFeature {
  @ObservableState
  struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
    var path = StackState<Path.State>()
    var techniques: [Technique]?
  }
  
  enum Action {
    case task
    case techniquesResponse(Result<[Technique], Error>)
    case addTechniqueButtonTapped
    case techniqueTapped(Technique)
    case deleteTechniqueButtonTapped(Technique)
    case alert(PresentationAction<Alert>)
    case path(StackActionOf<Path>)
    
    @CasePathable
    enum Alert: Equatable {
      case confirmDeletion(Technique)
    }
  }
  
  @Dependency(\.database.techniques) private var database
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        guard state.techniques == nil
        else { return .none }
        
        return .run { send in
          await send(.techniquesResponse(Result { try await database.fetchAll() }))
        }
        
      case let .techniquesResponse(.success(techniques)):
        state.techniques = techniques
        return .none
        
      case .techniquesResponse(.failure):
        return .none
        
      case .addTechniqueButtonTapped:
        state.path.append(.editTechnique(EditTechniqueFeature.State()))
        return .none
        
      case let .techniqueTapped(technique):
        state.path.append(.detailTechnique(TechniqueDetailFeature.State(technique: technique)))
        return .none
        
      case let .deleteTechniqueButtonTapped(technique):
        state.alert = .deleteConfirmation(technique: technique)
        return .none
        
      case let .alert(.presented(.confirmDeletion(technique))):
        if let index = state.techniques?.firstIndex(of: technique) {
          state.techniques?.remove(at: index)
        }
        return .run { _ in
          try await database.delete(technique)
        }
        
      case let .path(.element(id: _, action: .editTechnique(.delegate(.techniqueAdded(technique))))):
        state.techniques?.insert(technique, at: 0)
        return .none
        
      case let .path(.element(id: _, action: .detailTechnique(.delegate(.editTechnique(technique))))):
        state.path.append(.editTechnique(EditTechniqueFeature.State(editingTechnique: technique)))
        return .none
        
      case .path, .alert:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
    .ifLet(\.$alert, action: \.alert)
  }
  
  @Reducer
  enum Path {
    case editTechnique(EditTechniqueFeature)
    case detailTechnique(TechniqueDetailFeature)
  }
}

extension TechniqueListFeature.Path.State: Equatable {}

struct TechniqueListView: View {
  @Bindable var store: StoreOf<TechniqueListFeature>
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      VStack {
        LargeTitleHeader(title: "Техники") {
          Button {
            store.send(.addTechniqueButtonTapped)
          } label: {
            PlusIcon()
          }
        }
        
        if let techniques = store.state.techniques {
          List {
            ForEach(techniques) { technique in
              Section {
                TechniqueRow(technique: technique)
                  .onTapGesture {
                    store.send(.techniqueTapped(technique))
                  }
                  .contextMenu {
                    Button(role: .destructive) {
                      store.send(.deleteTechniqueButtonTapped(technique))
                    } label: {
                      Label("Удалить", systemSymbol: .trash)
                    }
                  }
              }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
          }
          .contentMargins(.top, 0)
          .listSectionSpacing(15)
        }
      }
      .frame(maxHeight: .infinity, alignment: .top)
      .background(Color.primaryDarkColor)
      .scrollContentBackground(.hidden)
      .task {
        store.send(.task)
      }
    } destination: { store in
      switch store.case {
      case .editTechnique(let store):
        EditTechniqueView(store: store)
      case .detailTechnique(let store):
        TechniqueDetailView(store: store)
      }
    }
    .alert($store.scope(state: \.alert, action: \.alert))
  }
}


extension AlertState where Action == TechniqueListFeature.Action.Alert {
  static func deleteConfirmation(technique: Technique) -> Self {
    Self {
      TextState("Вы действительно хотите удалить эту технику?")
    } actions: {
      ButtonState(role: .destructive, action: .confirmDeletion(technique)) {
        TextState("Удалить")
      }
      ButtonState(role: .cancel) {
        TextState("Отмена")
      }
    }
  }
}

public extension Technique {
  static let mock1 = Technique(
    title: "Метод с дверью",
    content: "За дверью во сне представьте желаемую сцену",
    symbol: .doorLeftHandClosed
  )
  
  static let mock2 = Technique(
    title: "Вращение",
    content: "Вращайтесь во сне на месте, чтобы стабилизировать его",
    symbol: .arrowTrianglehead2Clockwise
  )
}

public extension Array where Element == Technique {
  static let mock: Self = [
    .mock1,
    .mock2
  ]
}

// MARK: - Preview
struct TechniqueListView_Previews: PreviewProvider {
  static var previews: some View {
    TechniqueListView(
      store: Store(initialState: TechniqueListFeature.State(techniques: .mock)) {
        TechniqueListFeature()
      }
    )
  }
}
