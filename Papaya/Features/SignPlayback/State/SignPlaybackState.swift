//
//  SignPlaybackState.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 10.10.25.
//

import Foundation
import AVKit
import Combine

@Observable
class SignPlaybackState {
    var player = AVQueuePlayer()
    var isPlaying = false
    var currentIndex = 0
    var playbackRate: Float = 1.0
    
    private var playerItems: [AVPlayerItem] = []
    private var signWordsForQueue: [SignWord] = []
    private var cancellables = Set<AnyCancellable>()

    /// Configures the player with a sequence of sign words.
    func setup(with words: [SignWord]) {
        // Only rebuild the queue if the list of words has changed.
        guard self.signWordsForQueue != words else {
            return
        }
        
        self.signWordsForQueue = words
        self.player.removeAllItems()
        self.playerItems = words.compactMap { signWord in
            guard let fileName = signWord.videoFileName,
                  let url = VideoURLManager.getVideoURL(for: fileName) else {
                return nil
            }
            return AVPlayerItem(url: url)
        }
        
        guard !playerItems.isEmpty else {
            return
        }
        
        // Load all items into the queue for seamless playback.
        playerItems.forEach { player.insert($0, after: nil) }
        
        currentIndex = 0
        setPlaybackRate(rate: playbackRate)
        
        // Observe player state to keep the UI in sync.
        setupObservers()
        
        player.play()
    }
    
    // MARK: - Intents (User Actions)
    
    func playPause() {
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            // If the queue is finished, replay it from the start.
            if player.currentItem == nil && !playerItems.isEmpty {
                replay()
            }
            player.rate = playbackRate // Ensure correct speed on play
        }
    }
    
    func replay() {
        player.removeAllItems()
        playerItems.forEach {
            $0.seek(to: .zero, completionHandler: nil)
            player.insert($0, after: nil)
        }
        if isPlaying {
            player.rate = playbackRate
        }
    }
    
    func nextTrack() {
        guard currentIndex < playerItems.count - 1 else {
            return
        }
        player.advanceToNextItem()
    }
    
    func previousTrack() {
        // Seeking to the beginning of the current item is a simple "go back".
        // If we're more than 2 seconds in, we go to the start of the current video.
        // Otherwise, we go to the previous video.
        let currentTime = player.currentTime().seconds
        if currentTime > 2 && currentIndex > 0 {
            player.seek(to: .zero)
            return
        }

        guard currentIndex > 0 else {
            player.seek(to: .zero)
            return
        }
        
        // Rebuild the queue starting from the previous item.
        let targetIndex = currentIndex - 1
        let wasPlaying = self.isPlaying
        player.removeAllItems()
        
        let itemsToQueue = Array(playerItems[targetIndex...])
        itemsToQueue.forEach {
            $0.seek(to: .zero, completionHandler: nil)
            player.insert($0, after: nil)
        }
        
        if wasPlaying {
            player.rate = playbackRate
        }
    }
    
    func setPlaybackRate(rate: Float) {
        self.playbackRate = rate
        if isPlaying {
            player.rate = rate
        }
    }
    
    // MARK: - Private Helpers
    
    private func setupObservers() {
        cancellables.removeAll()
        
        // Observe playing status.
        player.publisher(for: \.timeControlStatus)
            .map { $0 == .playing }
            .sink { [weak self] isNowPlaying in
                // Directly assign the received value
                self?.isPlaying = isNowPlaying
            }
            .store(in: &cancellables)
            
        // Observe the current video to update the index.
        player.publisher(for: \.currentItem)
            .sink { [weak self] item in
                guard let self = self, let currentItem = item else {
                    return
                }
                if let index = self.playerItems.firstIndex(of: currentItem) {
                    self.currentIndex = index
                }
            }
            .store(in: &cancellables)
            
        // Observe when the last item finishes to reset the UI.
        NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime)
            .sink { [weak self] notification in
                guard let self = self,
                      let item = notification.object as? AVPlayerItem,
                      item == self.playerItems.last else { return }
                
                DispatchQueue.main.async {
                    self.replay()
                    self.player.pause()
                }
            }
            .store(in: &cancellables)
    }
}
