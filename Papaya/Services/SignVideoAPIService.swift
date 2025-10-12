//
//  SignVideoAPIService.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import Foundation

class SignVideoAPIService {
    private let videoSources = [
        "aslsearch",
        "signschool",
        "startasl",
        "aslsignbank",
        "aslbricks",
        "signlanguagestudent",
        "aslstudy",
    ]
    
    func fetchVideoURL(for word: String) async -> URL? {
        guard let cleanedWord = word.lowercased()
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }
        
        for source in videoSources {
            let urlString = "https://media.signbsl.com/videos/asl/\(source)/mp4/\(cleanedWord).mp4"
            
            guard let potentialURL = URL(string: urlString) else {
                continue
            }
            
            if await urlExists(potentialURL) {
                return potentialURL
            }
        }
        return nil
    }
        
    private func urlExists(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            }
        } catch {
            print("HEAD request failed for \(url): \(error.localizedDescription)")
        }
        
        return false
    }
}
