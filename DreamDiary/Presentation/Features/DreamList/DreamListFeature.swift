//
//  DreamListFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 10.04.2025.
//

import ComposableArchitecture
import SwiftUI
import SFSafeSymbols

@Reducer
struct DreamListFeature {
  @ObservableState
  struct State: Equatable {
    @Presents var alert: AlertState<Action.Alert>?
    var path = StackState<Path.State>()
    var dreams: [Dream]?
  }
  
  enum Action {
    case task
    case dreamsResponse(Result<[Dream], Error>)
    case addDreamButtonTapped
    case dreamTapped(Dream)
    case deleteDreamButtonTapped(Dream)
    case alert(PresentationAction<Alert>)
    case path(StackActionOf<Path>)
    
    @CasePathable
    enum Alert: Equatable {
      case confirmDeletion(Dream)
    }
  }
  
  @Dependency(\.database.dreams) private var database
  @Dependency(\.date.now) private var now
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .task:
        guard state.dreams == nil
        else { return .none }
        
        return .run { send in
          await send(.dreamsResponse(Result { try await database.fetchAll() } ))
        }
        
      case let .dreamsResponse(.success(dreams)):
        state.dreams = dreams
        return .none
        
      case .dreamsResponse(.failure):
        return .none
        
      case .addDreamButtonTapped:
        state.path.append(.editDream(EditDreamFeature.State(selectedDate: now)))
        return .none
        
      case let .dreamTapped(dream):
        state.path.append(.detailDream(DreamDetailFeature.State(dream: dream)))
        return .none
        
      case let .deleteDreamButtonTapped(dream):
        state.alert = .deleteConfirmation(dream: dream)
        return .none
        
      case let .alert(.presented(.confirmDeletion(dream))):
        if let index = state.dreams?.firstIndex(of: dream) {
          state.dreams?.remove(at: index)
        }
        return .run { _ in
          try await database.delete(dream)
        }
        
      case let .path(.element(_, action: .editDream(.delegate(.dreamAdded(dream))))):
        state.dreams?.insert(dream, at: 0)
        return .none
        
      case let .path(.element(id: _, action: .detailDream(.delegate(.editDream(dream))))):
        state.path.append(.editDream(EditDreamFeature.State(editingDream: dream)))
        return .none
        
      case .alert, .path:
        return .none
      }
    }
    .forEach(\.path, action: \.path)
    .ifLet(\.$alert, action: \.alert)
  }
  
  @Reducer
  enum Path {
    case editDream(EditDreamFeature)
    case detailDream(DreamDetailFeature)
  }
}

extension DreamListFeature.Path.State: Equatable {}

struct DreamListView: View {
  @Bindable var store: StoreOf<DreamListFeature>
  
  var body: some View {
    NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
      VStack {
        LargeTitleHeader(title: "Дневник") {
          Button {
            store.send(.addDreamButtonTapped)
          } label: {
            PlusIcon()
          }
        }
        
        if let dreams = store.dreams {
          List {
            ForEach(dreams) { dream in
              Section {
                DreamRow(dream: dream)
                  .onTapGesture {
                    store.send(.dreamTapped(dream))
                  }
                  .contextMenu {
                    Button(role: .destructive) {
                      store.send(.deleteDreamButtonTapped(dream))
                    } label: {
                      Label("Удалить", systemSymbol: .trash)
                    }
                  }
              }
            }
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.primaryLightGrayColor)
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
      case .editDream(let store):
        EditDreamView(store: store)
      case .detailDream(let store):
        DreamDetailView(store: store)
      }
    }
    .alert($store.scope(state: \.alert, action: \.alert))
  }
}

extension AlertState where Action == DreamListFeature.Action.Alert {
  static func deleteConfirmation(dream: Dream) -> Self {
    Self {
      TextState("Вы действительно хотите удалить эту запись о сне?")
    } actions: {
      ButtonState(role: .destructive, action: .confirmDeletion(dream)) {
        TextState("Удалить")
      }
      ButtonState(role: .cancel) {
        TextState("Отмена")
      }
    }
  }
}
let calender = Calendar.current
public extension Dream {
  static let mock1 = Dream(
    title: "Заблудился в чужом городе",
    date: .now,
    timeOfDay: .night,
    content: "Я оказался в огромном незнакомом городе. Улицы были извилистыми, и я не мог найти дорогу...",
    type: .normal
  )
  
  static let mock2 = Dream(
    title: "Бесконечные коридоры",
    date: .now,
    timeOfDay: .morning,
    content: "Я был заперт в здании с бесконечными коридорами. Неважно, куда я шел...",
    type: .lucid
  )
}

public extension Array where Element == Dream {
  static let mock: Self = [
    .mock1,
    .mock2
  ]
}

// MARK: - Preview
struct DreamListView_Previews: PreviewProvider {
  static var previews: some View {
    DreamListView(
      store: Store(initialState: DreamListFeature.State(dreams: .mock)) {
        DreamListFeature()
      }
    )
  }
}
