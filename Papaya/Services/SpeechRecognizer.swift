//
//  SpeechRecognizer.swift
//  Papaya
//
//  Created by Hans-Peter Fliegel on 08.10.25.
//

import SwiftUI
import Speech
import AVFoundation

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
            print("Speech recognizer is not available")
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create a recognition request")
        }

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, _ in
            if let result = result {
                let newText = result.bestTranscription.formattedString
                self.recognizedText = newText
                self.onTranscriptUpdate?(newText)
            }
        }

        let recordingFormat = AVAudioFormat(standardFormatWithSampleRate: 16000, channels: 1)
        guard let recordingFormat = recordingFormat else {
            print("Failed to create the required audio format.")
            return
        }
        
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        audioEngine.prepare()

        do {
            try audioEngine.start()
            isRecording = true
        } catch {
            print("Audio engine failed to start: \(error.localizedDescription)")
        }
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        isRecording = false
    }
    
    func reset() {
        self.recognizedText = ""
    }
}
