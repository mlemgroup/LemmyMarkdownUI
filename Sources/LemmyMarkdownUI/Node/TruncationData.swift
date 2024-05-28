//
//  File.swift
//  
//
//  Created by Sjmarf on 27/05/2024.
//

import Foundation

internal class TruncationData {
    var linesRemaining: Int
    var charactersPerLine: Int
    var hasInsertedTerminator: Bool = false
    
    init(linesRemaining: Int, charactersPerLine: Int) {
        self.linesRemaining = linesRemaining
        self.charactersPerLine = charactersPerLine
    }
}
