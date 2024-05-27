//
//  [InlineNode].swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

public extension [InlineNode] {
    init(_ markdown: String) {
        let blocks: [BlockNode] = .init(markdown)
        self.init((blocks.first?.children as? [InlineNode]) ?? [])
    }
    
    var links: [LinkData] {
        self.reduce([], { $0 + $1.links })
    }
    
    var stringLiteral: String {
        self.reduce("", { $0 + $1.stringLiteral })
    }
    
    internal func truncate(remainingLines: inout Int, charactersPerLine: Int) -> [InlineNode] {
        var charactersEaten: Int = 0
        remainingLines -= 1
        return truncate(
            remainingLines: &remainingLines,
            charactersEaten: &charactersEaten,
            charactersPerLine: charactersPerLine,
            isLastLine: remainingLines == 0
        )
    }
    
    internal func truncate(
        remainingLines: inout Int,
        charactersEaten: inout Int,
        charactersPerLine: Int,
        shouldTruncate: Bool = true,
        isLastLine: Bool = false
    ) -> [InlineNode] {
        let nodes = self.last == .lineBreak ? self.dropLast() : self
        var ret: [InlineNode] = .init()
        var dropCount: Int? = nil
    
        for node in nodes {
            print(node)
            var shouldCheck: Bool = false
            switch node {
            case .text(let string), .code(let string):
                charactersEaten += string.count
                ret.append(node)
                shouldCheck = true
            case .softBreak:
                charactersEaten += 1
                ret.append(node)
                shouldCheck = true
            case .lineBreak:
                // remainingLines -= 1
                ret.append(node)
            case let .emphasis(children):
                ret.append(.emphasis(children: children.truncate(
                    remainingLines: &remainingLines,
                    charactersEaten: &charactersEaten,
                    charactersPerLine: charactersPerLine,
                    shouldTruncate: shouldTruncate,
                    isLastLine: isLastLine
                )))
            case let .strong(children):
                ret.append(.strong(children: children.truncate(
                    remainingLines: &remainingLines,
                    charactersEaten: &charactersEaten,
                    charactersPerLine: charactersPerLine,
                    shouldTruncate: shouldTruncate,
                    isLastLine: isLastLine
                )))
            case let .superscript(children):
                ret.append(.superscript(children: children.truncate(
                    remainingLines: &remainingLines,
                    charactersEaten: &charactersEaten,
                    charactersPerLine: charactersPerLine,
                    shouldTruncate: shouldTruncate,
                    isLastLine: isLastLine
                )))
            case let .subscript(children):
                ret.append(.subscript(children: children.truncate(
                    remainingLines: &remainingLines,
                    charactersEaten: &charactersEaten,
                    charactersPerLine: charactersPerLine,
                    shouldTruncate: shouldTruncate,
                    isLastLine: isLastLine
                )))
            case let .strikethrough(children):
                ret.append(.strikethrough(children: children.truncate(
                    remainingLines: &remainingLines,
                    charactersEaten: &charactersEaten,
                    charactersPerLine: charactersPerLine,
                    shouldTruncate: shouldTruncate,
                    isLastLine: isLastLine
                )))
            case let .link(destination, children):
                ret.append(.link(destination: destination, children: children.truncate(
                    remainingLines: &remainingLines,
                    charactersEaten: &charactersEaten,
                    charactersPerLine: charactersPerLine,
                    shouldTruncate: false,
                    isLastLine: isLastLine
                )))
            case let .image(source, children):
                ret.append(.image(source: source, children: children))
            }
            
            if shouldCheck, charactersEaten >= charactersPerLine {
                let linesEaten = charactersEaten / charactersPerLine
                print("EAT", charactersEaten, linesEaten, remainingLines)
                remainingLines -= linesEaten
                if remainingLines <= -1 {
                    dropCount = (charactersEaten - charactersPerLine * (remainingLines + linesEaten + 1))
                    charactersEaten -= linesEaten * charactersPerLine
                    break
                }
                charactersEaten -= linesEaten * charactersPerLine
            } else if remainingLines <= -1 {
                break
            }
        }
        
        if shouldTruncate, let dropCount {
            switch ret.last {
            case let .text(string):
                ret.removeLast()
                ret.append(.text(neatlyTruncate(string, count: dropCount)))
            case let .code(string):
                ret.removeLast()
                ret.append(.code(neatlyTruncate(string, count: dropCount)))
            default:
                break
            }
        }
        return ret
    }
}

private func neatlyTruncate(_ string: String, count: Int) -> String {
    var index = count
    while index > 0 {
        if string[string.index(string.endIndex, offsetBy: -index)].isWhitespace {
            print("FOUND SPACE")
            break
        }
        index -= 1
        if count - index > 20 {
            break
        }
    }
    return String(string.dropLast(index))
}
