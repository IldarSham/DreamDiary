//
//  SymbolsGridView.swift
//  DreamDiary
//
//  Created by Ildar Shamsullin on 25.04.2025.
//

import SwiftUI

struct SymbolsGridView<Symbol: RawRepresentable & Hashable>: View where Symbol.RawValue == String {
  let symbols: [Symbol]
  @Binding var selectedSymbol: Symbol
  let rowCount: Int
  
  private var gridRows: [GridItem] {
    Array(
      repeating: .init(
        .fixed(SymbolsGridMetrics.fixedRowHeight),
        spacing: SymbolsGridMetrics.rowSpacing
      ),
      count: rowCount
    )
  }
  
  private var totalHeight: CGFloat {
    CGFloat(rowCount) * SymbolsGridMetrics.fixedRowHeight + CGFloat(max(0, rowCount - 1)) * SymbolsGridMetrics.rowSpacing
  }
  
  var body: some View {
    GeometryReader { geometry in
      let width = geometry.size.width
      let cellWidth = SymbolsGridMetrics.cellWidth
      
      let fullCells = floor((width - cellWidth / 2) / cellWidth)
      let spacing = fullCells > 1
      ? (width - cellWidth * (fullCells + 0.5)) / fullCells
      : 0
      
      ScrollViewReader { proxy in
        ScrollView(.horizontal, showsIndicators: false) {
          LazyHGrid(rows: gridRows, spacing: spacing) {
            ForEach(symbols, id: \.self) { symbol in
              SymbolCell(symbol: symbol, isSelected: symbol == selectedSymbol)
                .id(symbol)
                .onTapGesture {
                  withAnimation(.spring()) {
                    selectedSymbol = symbol
                  }
                }
            }
          }
        }
        .onAppear {
          proxy.scrollTo(selectedSymbol, anchor: .leading)
        }
      }
    }
    .frame(height: totalHeight)
  }
  
  init(symbols: [Symbol], selectedSymbol: Binding<Symbol>, rowCount: Int = 3) {
    self.symbols = symbols
    self._selectedSymbol = selectedSymbol
    self.rowCount = rowCount
  }
}
 
// MARK: - SymbolCell
extension SymbolsGridView {
  struct SymbolCell: View {
    let symbol: Symbol
    let isSelected: Bool
    
    var body: some View {
      Image(systemName: symbol.rawValue)
        .resizable()
        .scaledToFit()
        .frame(width: SymbolsGridMetrics.iconSize, height: SymbolsGridMetrics.iconSize)
        .foregroundStyle(Color(UIColor.systemGray2))
        .padding(.vertical, SymbolsGridMetrics.cellVerticalPadding)
        .padding(.horizontal, SymbolsGridMetrics.cellHorizontalPadding)
        .background(
          isSelected
          ? Color(UIColor.systemGray6).opacity(0.1)
          : .clear
        )
        .cornerRadius(8)
    }
  }
}

// MARK: - Grid Metrics
private enum SymbolsGridMetrics {
  static let iconSize: CGFloat = 20
  static let cellHorizontalPadding: CGFloat = 12
  static let cellVerticalPadding: CGFloat = 8
  static let rowSpacing: CGFloat = 16
  static let cornerRadius: CGFloat = 8
  
  static let fixedRowHeight: CGFloat = 36
  
  static var cellWidth: CGFloat { iconSize + cellHorizontalPadding * 2 }
}
