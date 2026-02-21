//
//  SpeechRecognizer.swift
//  Papaya
//
//  Created by Nicolas Fliegel on 08.10.25.
//

import SwiftUI
import Speech
import AVFoundation
import OSLog

@Observable
class SpeechRecognizer {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    var isRecording = false
    var recognizedText = ""
    var onTranscriptUpdate: ((String) -> Void)?

    func startRecording() {
        reset()
        
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            Logger.data.error("Speech recognizer is not available")
            return
        }

        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            Logger.data.error("Failed to setup audio session: \(error.localizedDescription)")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            Logger.data.error("Unable to create a recognition request")
            return
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                let newText = result.bestTranscription.formattedString
                self.recognizedText = newText
                self.onTranscriptUpdate?(newText)
            }

            if let error = error {
                Logger.data.error("Speech recognition error: \(error.localizedDescription)")
                self.stopRecording()
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            Logger.data.error("Audio engine failed to start: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            
            do {
                try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            } catch {
                Logger.data.error("Failed to deactivate audio session: \(error.localizedDescription)")
            }
        }
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    func reset() {
        self.recognizedText = ""
    }
}
