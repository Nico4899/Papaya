//
//  SignVideoAPIService.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 10.10.25.
//

import Foundation
import OSLog

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

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 5
        config.timeoutIntervalForResource = 10
        return URLSession(configuration: config)
    }()

    func fetchVideoURL(for word: String) async -> URL? {
        guard let cleanedWord = word.lowercased()
            .addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else {
            return nil
        }

        let candidateURLs = videoSources.compactMap { source in
            URL(string: "https://media.signbsl.com/videos/asl/\(source)/mp4/\(cleanedWord).mp4")
        }

        return await withTaskGroup(of: URL?.self) { group in
            for url in candidateURLs {
                group.addTask {
                    await self.urlExists(url) ? url : nil
                }
            }

            for await result in group {
                if let url = result {
                    group.cancelAll()
                    return url
                }
            }

            return nil
        }
    }

    private func urlExists(_ url: URL) async -> Bool {
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"

        do {
            let (_, response) = try await Self.session.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            }
        } catch {
            Logger.data.error("HEAD request failed for \(url): \(error.localizedDescription)")
        }

        return false
    }
}
