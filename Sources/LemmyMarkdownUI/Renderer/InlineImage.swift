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
    
    init(url: URL, fontSize: CGFloat) {
        self.url = url
        self.fontSize = fontSize
    }
}
