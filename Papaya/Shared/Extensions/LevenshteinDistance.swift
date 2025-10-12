//
//  LebenshteinDistance.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 12.10.25.
//

import Foundation

extension String {
    // Calculates the Levenshtein distance to another string.
    func levenshteinDistance(to other: String) -> Int {
        let empty = [Int](repeating: 0, count: other.count)
        var last = [Int](0...other.count)

        for (i, selfChar) in self.enumerated() {
            var cur = [i + 1] + empty
            for (j, otherChar) in other.enumerated() {
                cur[j + 1] = selfChar == otherChar ? last[j] : Swift.min(last[j], last[j + 1], cur[j]) + 1
            }
            last = cur
        }
        return last.last!
    }
}
