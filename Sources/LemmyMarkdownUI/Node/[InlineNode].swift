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
    
    internal func truncate(data: TruncationData) -> [InlineNode] {
        var charactersEaten: Int = 0
        data.linesRemaining -= 1
        let ret = truncate(
            data: data,
            charactersEaten: &charactersEaten,
            isRoot: true
        )
        return ret
    }
    
    internal func truncate(
        data: TruncationData,
        charactersEaten: inout Int,
        shouldTruncate: Bool = true,
        isRoot: Bool = false
    ) -> [InlineNode] {
        let nodes = self.last == .lineBreak ? self.dropLast() : self
        var ret: [InlineNode] = .init()
        var dropCount: Int? = nil
        
        var isSingleImage: Bool? = nil
    
        for node in nodes {
            var shouldCheck: Bool = false
            switch node {
            case .text(let string), .code(let string):
                charactersEaten += string.count
                ret.append(node)
                shouldCheck = true
                if string.trimmingCharacters(in: .whitespaces).count != 0 {
                    isSingleImage = false
                }
            case .softBreak:
                charactersEaten += 1
                ret.append(node)
                shouldCheck = true
            case let .emphasis(children):
                ret.append(.emphasis(children: children.truncate(
                    data: data,
                    charactersEaten: &charactersEaten,
                    shouldTruncate: shouldTruncate
                )))
                isSingleImage = false
            case let .strong(children):
                ret.append(.strong(children: children.truncate(
                    data: data,
                    charactersEaten: &charactersEaten,
                    shouldTruncate: shouldTruncate
                )))
                isSingleImage = false
            case let .superscript(children):
                ret.append(.superscript(children: children.truncate(
                    data: data,
                    charactersEaten: &charactersEaten,
                    shouldTruncate: shouldTruncate
                )))
                isSingleImage = false
            case let .subscript(children):
                ret.append(.subscript(children: children.truncate(
                    data: data,
                    charactersEaten: &charactersEaten,
                    shouldTruncate: shouldTruncate
                )))
                isSingleImage = false
            case let .strikethrough(children):
                ret.append(.strikethrough(children: children.truncate(
                    data: data,
                    charactersEaten: &charactersEaten,
                    shouldTruncate: shouldTruncate
                )))
                isSingleImage = false
            case let .link(destination, children):
                ret.append(.link(destination: destination, children: children.truncate(
                    data: data,
                    charactersEaten: &charactersEaten,
                    shouldTruncate: false
                )))
                isSingleImage = false
            case let .image(source, children, _):
                if isSingleImage == nil {
                    isSingleImage = true
                }
                ret.append(.image(source: source, children: children))
            default:
                isSingleImage = false
                ret.append(node)
            }
            
            if shouldCheck, charactersEaten >= data.charactersPerLine {
                let linesEaten = charactersEaten / data.charactersPerLine
                data.linesRemaining -= linesEaten
                if data.linesRemaining <= -1 {
                    dropCount = (charactersEaten - data.charactersPerLine * (data.linesRemaining + linesEaten + 1))
                    charactersEaten -= linesEaten * data.charactersPerLine
                    break
                }
                charactersEaten -= linesEaten * data.charactersPerLine
            } else if data.linesRemaining <= -1 {
                break
            }
        }
        
        if isSingleImage ?? false {
            data.linesRemaining = 0
            return ret.map { node in
                switch node {
                case let .image(source, children, _):
                    return .image(source: source, children: children, truncated: true)
                default:
                    return node
                }
            }
        } else if shouldTruncate {
            // `dropCount < 20` stops it from truncating the text if it was close to the end anyway
            var shouldDrop = ret.count != nodes.count || (dropCount ?? 0) > 20
            if shouldDrop, let dropCount {
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
            if isRoot, ret.count != nodes.count || shouldDrop {
                data.hasInsertedTerminator = true
                return ret + [.truncationTerminator]
            }
        }
        return ret
    }
}

private func neatlyTruncate(_ string: String, count: Int) -> String {
    var index = count
    while index > 0 {
        let char = string[string.index(string.endIndex, offsetBy: -index)]
        if char.isWhitespace || char.isPunctuation {
            break
        }
        index -= 1
        if count - index > 20 {
            break
        }
    }
    return String(string.dropLast(index))
}
