//
//  AppearanceConfigurator.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 30.05.2025.
//

import Foundation
import SwiftUI

@MainActor
struct AppearanceConfigurator {
  
  static func setupGlobalAppearance() {
    configureTabBar()
    configureNavigationBar()
  }
  
  // MARK: - Tab Bar Configuration
  
  private static func configureTabBar() {
    let appearance = UITabBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(Color.primaryDarkColor)
    appearance.shadowColor = UIColor(white: 1, alpha: 0.5)
    
    let normalColor = UIColor.lightGray
    let selectedColor = UIColor(Color.primaryPurpleColor)
    
    // Normal state
    appearance.stackedLayoutAppearance.normal.iconColor = normalColor
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
      .foregroundColor: normalColor
    ]
    
    // Selected state
    appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
      .foregroundColor: selectedColor
    ]
    
    UITabBar.appearance().standardAppearance = appearance
    UITabBar.appearance().scrollEdgeAppearance = appearance
  }
  
  // MARK: - Navigation Bar Configuration
  
  private static func configureNavigationBar() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithOpaqueBackground()
    appearance.backgroundColor = UIColor(Color.primaryDarkColor)
    
    let textColor = UIColor.white
    appearance.titleTextAttributes = [.foregroundColor: textColor]
    appearance.largeTitleTextAttributes = [.foregroundColor: textColor]
    
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().compactAppearance = appearance
  }
}
