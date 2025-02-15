//
//  SpoilerView.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

internal struct SpoilerView: View {
    @State var isCollapsed: Bool = true
    
    let titleInlines: [InlineNode]
    let blocks: [BlockNode]
    let configuration: MarkdownConfiguration
    
    init(
        title: String?,
        blocks: [BlockNode],
        configuration: MarkdownConfiguration
    ) {
        if let title {
            self.titleInlines = .init(title)
        } else {
            self.titleInlines = [.text(configuration.spoilerLabel)]
        }
        self.blocks = blocks
        self.configuration = configuration
    }
    
    var titleConfiguration: MarkdownConfiguration {
        var configuration = configuration
        configuration.primaryColor = configuration.secondaryColor
        return configuration
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "chevron.right")
                    .imageScale(.small)
                    .rotationEffect(.degrees(isCollapsed ? 0 : 90))
                MarkdownText(
                    titleInlines,
                    configuration: titleConfiguration
                )
            }
            .fontWeight(.bold)
            .foregroundStyle(configuration.secondaryColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(configuration.spoilerHeaderBackgroundColor)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isCollapsed.toggle()
                }
            }
            
            if !isCollapsed {
                Markdown(
                    blocks,
                    configuration: configuration
                )
                .padding(10)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(configuration.spoilerOutlineColor, lineWidth: 1)
        )
    }
}
