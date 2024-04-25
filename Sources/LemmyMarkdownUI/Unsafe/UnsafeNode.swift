//
//  UnsafeNode.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import cmark_lemmy

internal typealias UnsafeNode = UnsafeMutablePointer<cmark_node>

extension UnsafeNode {
    var nodeType: NodeType {
        let typeString = String(cString: cmark_node_get_type_string(self))
        guard let nodeType = NodeType(rawValue: typeString) else {
            fatalError("Unknown node type '\(typeString)' found.")
        }
        return nodeType
    }
    
    var children: UnsafeNodeSequence {
        .init(cmark_node_first_child(self))
    }
    
    var literal: String? {
        cmark_node_get_literal(self).map(String.init(cString:))
    }
    
    var url: String? {
        cmark_node_get_url(self).map(String.init(cString:))
    }
    
    var fenceInfo: String? {
        cmark_node_get_fence_info(self).map(String.init(cString:))
    }

    var headingLevel: Int {
        Int(cmark_node_get_heading_level(self))
    }
    
    var title: String? {
        cmark_node_get_title(self).map(String.init(cString:))
    }
    
    var listType: cmark_list_type {
        cmark_node_get_list_type(self)
    }

    var listStart: Int {
        Int(cmark_node_get_list_start(self))
    }
    
    var isTightList: Bool {
        cmark_node_get_list_tight(self) != 0
    }
}

extension UnsafeNode {
    static func parseMarkdown(markdown: String) -> [BlockNode]? {
        let parser = cmark_parser_new(CMARK_OPT_DEFAULT)
        defer { cmark_parser_free(parser) }
        
        cmark_parser_feed(parser, markdown, markdown.utf8.count)
        guard let document = cmark_parser_finish(parser) else { return nil }
        defer { cmark_node_free(document) }
        
        return document.children.compactMap(BlockNode.init(unsafeNode:))
    }
}
