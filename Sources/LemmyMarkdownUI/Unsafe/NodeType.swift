//
//  NodeType.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation

internal enum NodeType: String {
    case document
    case blockquote = "block_quote"
    case list
    case item
    case codeBlock = "code_block"
    case customBlock = "custom_block"
    case paragraph
    case heading
    case thematicBreak = "thematic_break"
    case text
    case softBreak = "softbreak"
    case lineBreak = "linebreak"
    case code
    case customInline = "custom_inline"
    case emphasis = "emph"
    case strong
    case link
    case image
    case spoiler
    case superscript = "super"
    case `subscript` = "sub"
    case strikethrough = "strike"
    case inlineAttributes = "attribute"
    case none = "NONE"
    case unknown = "<unknown>"
}
