//
//  CodeBlockView.swift
//  LemmyMarkdownUI
//
//  Created by Sjmarf on 2024-10-19.
//

import SwiftUI
import HighlightSwift

internal struct CodeBlockView: View {
    let content: String
    let language: String?
    let configuration: MarkdownConfiguration

    @State private var highlightedText: AttributedString?
    @State private var isHighlighting = false
    @State private var highlightTask: Task<Void, Never>?

    @Environment(\.colorScheme) var colorScheme

    init(content: String, language: String? = nil, configuration: MarkdownConfiguration) {
        self.content = content
        self.language = language
        self.configuration = configuration
    }

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
        .task(id: colorScheme) {
            await performHighlighting()
        }
        .onDisappear {
            highlightTask?.cancel()
        }
    }

    @ViewBuilder
    var contentView: some View {
        if let highlighted = highlightedText,
           configuration.enableSyntaxHighlighting {
            Text(highlighted)
                .font(codeFont)
                .padding(10)
        } else {
            Text(content.trimmingCharacters(in: .newlines))
                .font(codeFont)
                .foregroundColor(configuration.primaryColor)
                .padding(10)
        }
    }

    var codeFont: Font {
        Font(
            configuration.font.withSize(configuration.font.pointSize * configuration.codeFontScaleFactor)
        ).monospaced()
    }

    func performHighlighting() async {
        guard configuration.enableSyntaxHighlighting else { return }
        guard !isHighlighting else { return }

        isHighlighting = true
        highlightTask = Task.detached {
            do {
                let highlight = Highlight()
                let colors: HighlightColors = colorScheme == .dark ? .dark(.github) : .light(.github)

                if let lang = language, !lang.isEmpty {
                    let highlighted = try await highlight.attributedText(content, language: lang, colors: colors)
                    await MainActor.run {
                        self.highlightedText = highlighted
                    }
                } else {
                    let highlighted = try await highlight.attributedText(content, colors: colors)
                    await MainActor.run {
                        self.highlightedText = highlighted
                    }
                }
            } catch {
                print("Syntax highlighting failed: \(error)")
            }
            isHighlighting = false
        }
    }
}
