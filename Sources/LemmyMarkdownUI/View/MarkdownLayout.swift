//
//  File.swift
//  LemmyMarkdownUI
//
//  Created by Sjmarf on 2025-02-10.
//  

import SwiftUI

// This Layout is basically a VStack
internal struct MarkdownLayout: Layout {
    let spacing: CGFloat = 0
    
    struct Cache {
        var spacings: [CGFloat]
        var sum: CGFloat
        
        init(subviews: Subviews) {
            spacings = []
            spacings.reserveCapacity(subviews.count)
            for (a, b) in zip(subviews.dropLast(), subviews.dropFirst()) {
                spacings.append(max(
                    a[MarkdownLayoutMinimumSpacingKey.self].bottom,
                    b[MarkdownLayoutMinimumSpacingKey.self].top
                ))
            }
            spacings.append(0)
            sum = spacings.reduce(0, +)
        }
    }
    
    func makeCache(subviews: Subviews) -> Cache {
        return .init(subviews: subviews)
    }
    
    func updateCache(_ cache: inout Cache, subviews: Subviews) {
        cache = .init(subviews: subviews)
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) -> CGSize {
        let newProposal: ProposedViewSize = .init(width: proposal.width, height: nil)
        
        let totalHeight = subviews.map { $0.sizeThatFits(newProposal).height }
            .reduce(0, +) + cache.sum
        
        // When `proposal.width` is `nil`, the proper thing to do would be to calculate the "ideal" width of the layout.
        // I don't know how VStack does this, but it causes a major hang for large markdown blocks (https://github.com/mlemgroup/mlem/issues/1447). Returning 0 here seems to fix the issue with no adverse effects.
        return CGSize(width: proposal.width ?? 0, height: totalHeight)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Cache) {
        var yOffset = bounds.minY
        
        for (subview, spacing) in zip(subviews, cache.spacings) {
            let subviewSize = subview.sizeThatFits(.init(width: bounds.width, height: nil))
            subview.place(
                at: CGPoint(x: bounds.minX, y: yOffset), proposal: ProposedViewSize(width: bounds.width, height: nil)
            )
            yOffset += subviewSize.height + spacing
        }
    }
}

internal struct MarkdownLayoutMinimumSpacingKey: LayoutValueKey {
    struct Value {
        let top: CGFloat
        let bottom: CGFloat
    }
    
    static var defaultValue: Value = .init(top: 0, bottom: 0)
}

internal extension View {
    func markdownMinimumSpacing(_ value: CGFloat) -> some View {
        layoutValue(key: MarkdownLayoutMinimumSpacingKey.self, value: .init(top: value, bottom: value))
    }
    
    func markdownMinimumSpacing(top: CGFloat, bottom: CGFloat) -> some View {
        layoutValue(key: MarkdownLayoutMinimumSpacingKey.self, value: .init(top: top, bottom: bottom))
    }
}
