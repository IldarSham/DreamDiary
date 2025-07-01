//
//  EditDreamFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 15.04.2025.
//

import ComposableArchitecture
import SwiftUI
import SFSafeSymbols

@Reducer
struct EditDreamFeature {
  enum Constants {
    static let newDreamNavTitle = "Новая запись сна"
    static let editingDreamNavTitle = "Редактирование сна"
  }
  
  @ObservableState
  struct State: Equatable {
    var title: String = ""
    var description: String = ""
    var selectedDate: Date = .now
    var isDatePickerExpanded: Bool = false
    var selectedTimeOfDay: TimeOfDay = .morning
    var selectedDreamType: DreamType = .normal
    var editingDream: Dream? = nil
    
    var isEditing: Bool {
      editingDream != nil
    }
    
    var navigationTitle: String {
      isEditing
        ? Constants.editingDreamNavTitle
        : Constants.newDreamNavTitle
    }
  }
  
  enum Action: BindableAction {
    case binding(BindingAction<State>)
    case delegate(Delegate)
    case saveButtonTapped
    
    @CasePathable
    enum Delegate {
      case dreamAdded(Dream)
    }
  }
  
  @Dependency(\.dismiss) var dismiss
  @Dependency(\.database.dreams) var database
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .binding:
        return .none
        
      case .delegate:
        return .none
        
      case .saveButtonTapped:
        let dreamToSave: Dream
        
        if let editingDream = state.editingDream {
          editingDream.title = state.title
          editingDream.content = state.description
          editingDream.date = state.selectedDate
          editingDream.timeOfDay = state.selectedTimeOfDay
          editingDream.type = state.selectedDreamType
          dreamToSave = editingDream
        } else {
          dreamToSave = Dream(
            title: state.title,
            date: state.selectedDate,
            timeOfDay: state.selectedTimeOfDay,
            content: state.description,
            type: state.selectedDreamType
          )
        }
        
        return .run { [state] send in
          if state.isEditing {
            try await database.update(dreamToSave)
          } else {
            try await database.create(dreamToSave)
            await send(.delegate(.dreamAdded(dreamToSave)))
          }
          await self.dismiss()
        }
      }
    }
  }
}

extension EditDreamFeature.State {
  init(editingDream: Dream) {
    self.title = editingDream.title
    self.description = editingDream.content
    self.selectedDate = editingDream.date
    self.selectedTimeOfDay = editingDream.timeOfDay
    self.selectedDreamType = editingDream.type
    self.editingDream = editingDream
  }
}

struct EditDreamView: View {
  @State var store: StoreOf<EditDreamFeature>
  
  var body: some View {
    ScrollView {
      VStack(spacing: 24) {
        LabeledSection(title: "Заголовок") {
          PrimaryTextField(
            placeholder: "Название сна",
            text: $store.title
          )
        }
        
        LabeledSection(title: "Описание") {
          PrimaryTextField(
            placeholder: "Опишите ваш сон подробно...",
            text: $store.description,
            axis: .vertical,
            lineLimit: 8
          )
        }
        
        LabeledSection(title: "Время начала сна") {
          Group {
            datePickerView
            timeOfDaySelector
          }
        }
        
        LabeledSection(title: "Тип сна") {
          dreamTypeSelector
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
  
  // MARK: - Components
  
  var datePickerView: some View {
    VStack {
      Button {
        withAnimation { store.isDatePickerExpanded.toggle() }
      } label: {
        HStack {
          Text(
            store.selectedDate.formatted(
              Date.FormatStyle()
                .day(.defaultDigits)
                .month(.wide)
                .year()
            )
          )
          .foregroundColor(.white)
          Spacer()
          
          Image(systemSymbol: store.isDatePickerExpanded ? .chevronUp : .chevronDown)
            .foregroundColor(.gray)
        }
      }
      
      if store.isDatePickerExpanded {
        DatePicker(
          "",
          selection: $store.selectedDate,
          displayedComponents: .date
        )
        .colorScheme(.dark)
        .datePickerStyle(.graphical)
        .labelsHidden()
      }
    }
  }
  
  var timeOfDaySelector: some View {
    HStack(spacing: 25) {
      ForEach(TimeOfDay.allCases) { time in
        VStack(spacing: 10) {
          Image(systemSymbol: time.symbol)
            .resizable()
            .frame(width: 25, height: 25)
            .foregroundColor(.white)
          Text(time.rawValue)
            .lineLimit(1)
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.9))
            .cornerRadius(8)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
          store.selectedTimeOfDay == time
          ? Color(UIColor.systemGray6.withAlphaComponent(0.1))
          : .clear
        )
        .cornerRadius(8)
        .onTapGesture { store.selectedTimeOfDay = time }
      }
    }
    .frame(maxWidth: .infinity)
  }
  
  var dreamTypeSelector: some View {
    HStack(spacing: 20) {
      ForEach(DreamType.allCases) { type in
        VStack(spacing: 10) {
          Circle()
            .foregroundStyle(type.color.opacity(0.9))
            .frame(width: 17, height: 17)
          
          Text(type.rawValue)
            .lineLimit(1)
            .font(.system(size: 14))
            .foregroundColor(.white.opacity(0.9))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
          store.selectedDreamType == type
          ? Color(UIColor.systemGray6.withAlphaComponent(0.1))
          : .clear
        )
        .cornerRadius(8)
        .onTapGesture { store.selectedDreamType = type }
      }
    }
    .frame(maxWidth: .infinity)
  }
}

// MARK: - Symbol
extension TimeOfDay {
  public var symbol: SFSymbol {
    switch self {
    case .morning:
      return .sunriseFill
    case .afternoon:
      return .sunMaxFill
    case .evening:
      return .sunHazeFill
    case .night:
      return .moonFill
    }
  }
}

// MARK: - Preview
struct NewDreamView_Previews: PreviewProvider {
  static var previews: some View {
    EditDreamView(
      store: Store(initialState: EditDreamFeature.State()) {
        EditDreamFeature()
      }
    )
  }
}
