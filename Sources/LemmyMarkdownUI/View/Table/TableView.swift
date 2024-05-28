//
//  TableView.swift
//
//
//  Created by Sjmarf on 26/04/2024.
//

import SwiftUI

public struct TableView: View {
    let columnAlignments: [RawTableColumnAlignment]
    let rows: [TableRowNode]
    let configuration: MarkdownConfiguration
    
    let borderWidth: CGFloat = 1
    
    @State private var scrollViewContentSize: CGSize = .zero
    
    public var body: some View {
        ScrollView(.horizontal) {
            Grid(horizontalSpacing: borderWidth, verticalSpacing: borderWidth) {
                ForEach(0..<self.rowCount, id: \.self) { row in
                    GridRow {
                        ForEach(0..<self.columnCount, id: \.self) { column in
                            InlineMarkdown(self.rows[row].cells[column].content, configuration: configuration)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 2)
                                .gridColumnAlignment(.init(self.columnAlignments[column]))
                                .anchorPreference(key: TableCellBoundsPreference.self, value: .bounds) { anchor in
                                    [TableCellIndex(row: row, column: column): anchor]
                                }
                        }
                    }
                }
            }
            .padding(borderWidth)
            .backgroundPreferenceValue(TableCellBoundsPreference.self) { anchors in
                GeometryReader { proxy in
                    backgroundView(
                        tableBounds: .init(
                            rowCount: rowCount,
                            columnCount: columnCount,
                            anchors: anchors,
                            proxy: proxy
                        )
                    )
                }
            }
            .background(
                GeometryReader { geo in
                    geometryReaderBackground(geoSize: geo.size)
                }
            )
        }
        .frame(maxWidth: scrollViewContentSize.width)
        .scrollIndicators(.hidden)
        .scrollBounceBehavior(.basedOnSize)
    }
    
    func geometryReaderBackground(geoSize: CGSize) -> some View {
        Task { @MainActor in
            scrollViewContentSize = geoSize
        }
        return Color.clear
    }
    
    @ViewBuilder
    func backgroundView(tableBounds: TableBounds) -> some View {
        ZStack(alignment: .topLeading) {
            let rectangles = TableBorderSelector.allBorders.rectangles(
                tableBounds, self.borderWidth
            )
            ForEach(Array(rectangles.enumerated()), id: \.offset) { _, rectangle in
                Rectangle()
                    .strokeBorder(Color(uiColor: .systemGray5), lineWidth: borderWidth)
                    .offset(x: rectangle.minX, y: rectangle.minY)
                    .frame(width: rectangle.width, height: rectangle.height)
            }
        }
    }
    
    private var rowCount: Int {
      self.rows.count
    }

    private var columnCount: Int {
      self.columnAlignments.count
    }
}

extension HorizontalAlignment {
        fileprivate init(_ tableColumnAlignment: RawTableColumnAlignment) {
        switch tableColumnAlignment {
        case .none, .left:
          self = .leading
        case .center:
          self = .center
        case .right:
          self = .trailing
        }
    }
}

