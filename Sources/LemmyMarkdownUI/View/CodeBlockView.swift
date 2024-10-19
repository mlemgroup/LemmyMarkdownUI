//
//  CodeBlockView.swift
//  LemmyMarkdownUI
//
//  Created by Sjmarf on 2024-10-19.
//

import SwiftUI

internal struct CodeBlockView: View {
    let content: String
    let configuration: MarkdownConfiguration
    
    var body: some View {
        Group {
            if configuration.wrapCodeBlockLines {
                contentView
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                ScrollView(.horizontal) { contentView }
            }
        }
        .background(configuration.codeBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    var contentView: some View {
        Text(content.trimmingCharacters(in: .newlines))
            .font(
                Font(
                    configuration.font.withSize(configuration.font.pointSize * configuration.codeFontScaleFactor)
                ).monospaced()
            )
            .padding(10)
    }
}
