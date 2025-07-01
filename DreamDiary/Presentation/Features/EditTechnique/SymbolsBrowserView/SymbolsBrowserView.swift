//
//  SymbolsBrowserView.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 29.04.2025.
//

import SwiftUI

struct SymbolsBrowserView<Provider: SymbolsProvider>: View {
  @State private var searchText = ""
  @Binding var selectedSymbol: Provider.Symbol
  private let allSymbols = Provider.allSymbols
  
  private var filteredSymbols: [Provider.Symbol] {
    allSymbols.filter {
      searchText.isEmpty ||
      $0.rawValue.localizedCaseInsensitiveContains(searchText)
    }
  }
  
  var body: some View {
    VStack(spacing: 14) {
      SearchBarView(text: $searchText)
      SymbolsGridView(
        symbols: filteredSymbols,
        selectedSymbol: $selectedSymbol
      )
    }
  }
}
