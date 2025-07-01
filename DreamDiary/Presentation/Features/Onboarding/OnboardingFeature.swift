//
//  OnboardingFeature.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 10.04.2025.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct OnboardingFeature {
  enum Constants {
    static let getStartedButtonTitle = "Начать"
    static let nextButtonTitle = "Дальше"
  }
  
  enum Tab: CaseIterable {
    case diary, techniques, stats
  }
  
  @ObservableState
  struct State: Equatable {
    var currentTab: Tab = .diary
    
    var isLastTab: Bool {
      currentTab.next == nil
    }
    
    var mainButtonTitle: String {
      isLastTab
        ? Constants.getStartedButtonTitle
        : Constants.nextButtonTitle
    }
  }
  
  enum Action {
    case delegate(Delegate)
    case tabChanged(Tab)
    case mainButtonTapped
    case skipButtonTapped
    
    case finishOnboarding
    
    @CasePathable
    enum Delegate {
      case getStarted
    }
  }
  
  @Dependency(\.userDefaults) var userDefaults
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate(.getStarted):
        return .run { _ in
          await userDefaults.setOnboardingShown(true)
        }
        
      case .finishOnboarding:
        return .send(.delegate(.getStarted))
        
      case let .tabChanged(tab):
        state.currentTab = tab
        return .none
        
      case .skipButtonTapped:
        return .send(.finishOnboarding)
        
      case .mainButtonTapped:
        if let nextTab = state.currentTab.next {
          state.currentTab = nextTab
          return .none
        } else {
          return .send(.finishOnboarding)
        }
      }
    }
  }
}

struct OnboardingView: View {
  @Bindable var store: StoreOf<OnboardingFeature>
  
  var body: some View {
    NavigationStack {
      VStack {
        TabView(selection: $store.currentTab.sending(\.tabChanged)) {
          Group {
            OnboardingPageView(title: "Дневник", imageName: "cloud1", description: "Сохраняйте и анализируйте свои сны в личном дневнике")
              .tag(OnboardingFeature.Tab.diary)
            
            OnboardingPageView(title: "Техники", imageName: "cloud2", description: "Экспериментируйте с техниками и совершенствуйте управление своими снами")
              .tag(OnboardingFeature.Tab.techniques)
            
            OnboardingPageView(title: "Статистика", imageName: "cloud3", description: "Анализируйте прогресс и достижения в мире сновидений")
              .tag(OnboardingFeature.Tab.stats)
          }
          .padding(.bottom, 100)
        }
        .padding(.bottom, 10)
                
        Button(action: {
          store.send(.mainButtonTapped)
        }) {
          Text(store.state.mainButtonTitle)
            .font(.system(size: 15, weight: .regular))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(Color.primaryPurpleColor)
            .cornerRadius(14)
        }
        .padding(.horizontal, 15)
        .padding(.bottom, 20)
      }
      .background(Color.primaryDarkColor)
      .interactiveDismissDisabled()
      .tabViewStyle(.page)
      .toolbar {
        Button("Пропустить") {
          store.send(.skipButtonTapped)
        }
      }
    }
    .onAppear {
      UIPageControl.appearance().currentPageIndicatorTintColor = .white
      UIPageControl.appearance().pageIndicatorTintColor = .systemGray
    }
  }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
  static var previews: some View {
    OnboardingView(
      store: Store(initialState: OnboardingFeature.State()) {
        OnboardingFeature()
      }
    )
  }
}
