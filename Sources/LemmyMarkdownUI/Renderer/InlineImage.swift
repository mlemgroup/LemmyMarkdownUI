//
//  InlineImage.swift
//
//
//  Created by Sjmarf on 25/04/2024.
//

import Foundation
import SwiftUI

@Observable
public class InlineImage {
    public let url: URL
    public let fontSize: CGFloat
    public var image: Image?
    public let truncated: Bool
    public var renderFullWidth: Bool = false
    
    init(url: URL, fontSize: CGFloat, truncated: Bool = false) {
        self.url = url
        self.fontSize = fontSize
        self.truncated = truncated
    }
}
