//
//  SpoilerView.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

internal struct SpoilerView<ImageView: View>: View {
    @State var isCollapsed: Bool = true
    
    let titleInlines: [InlineNode]
    let blocks: [BlockNode]
    let inlineImageLoader: (InlineImage) async -> Void
    @ViewBuilder var imageBlockView: (_ image: InlineImage) -> ImageView
    
    init(
        title: String?,
        blocks: [BlockNode],
        inlineImageLoader: @escaping (InlineImage) async -> Void,
        @ViewBuilder imageBlockView: @escaping (_ image: InlineImage) -> ImageView
    ) {
        if let title {
            self.titleInlines = .init(title)
        } else {
            self.titleInlines = [.text("Spoiler")]
        }
        self.blocks = blocks
        self.inlineImageLoader = inlineImageLoader
        self.imageBlockView = imageBlockView
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                InlineMarkdown(
                    titleInlines,
                    inlineImageLoader:
                        inlineImageLoader,
                    imageBlockView: imageBlockView
                )
            }
            .fontWeight(.bold)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color(uiColor: .secondarySystemBackground))
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isCollapsed.toggle()
                }
            }
            
            if !isCollapsed {
                Markdown(
                    blocks,
                    inlineImageLoader: inlineImageLoader,
                    imageBlockView: imageBlockView
                )
                    .padding(10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(uiColor: .tertiaryLabel), lineWidth: 1)
        )
    }
}
