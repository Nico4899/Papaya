//
//  VideoURLManager.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 12.10.25.
//

import Foundation

struct VideoURLManager {
    static func getVideoURL(for fileName: String) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return documentsDirectory.appendingPathComponent(fileName)
    }
}
