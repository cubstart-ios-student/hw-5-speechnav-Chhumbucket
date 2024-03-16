//
//  SpeechControlViewModel.swift
//  SpeechNavFinished
//
//  Created by Justin Wong on 3/4/24.
//

import SwiftUI
import Speech

enum RecordButtonStatus {
    case recording
    case stopped
}

@Observable class SpeechControlViewModel: NSObject {
    var isProcessingVoiceCommand = false
    var isRecordButtonEnabled = false
    var authStatusText = ""
    var latestRecognizedVoiceCommand = [String]()
    var isSpeechRecMicEnabled = false
    var isSpeechControlPaused = false
    var currentSpeechControlCommand: SpeechControlCommandType?
    
    private var completionHandler: (([String]) -> Void)?
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    override init() {
        super.init()
        speechRecognizer.delegate = self
    }
    
    func setCompletionHandler(for completionHandler: @escaping([String]) -> Void) {
        self.completionHandler = completionHandler
    }
    
    func makeSpeechRecognizerAuthRequest() {
        guard speechRecognizer.supportsOnDeviceRecognition else {
            authStatusText = "Speech Recognizer Does Not Support On Device Recognition"
            return
        }
        
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.isRecordButtonEnabled = true
                    break
                case .notDetermined:
                    self.isRecordButtonEnabled = false
                    self.authStatusText = "Speech recognition not yet authorized"
                case .denied:
                    self.isRecordButtonEnabled = false
                    self.authStatusText = "User denied access to speech recognition"
                case .restricted:
                    self.isRecordButtonEnabled = false
                    self.authStatusText = "Speech recognition restricted on this device"
                default:
                    self.isRecordButtonEnabled = false
                }
            }
        }
    }
    
    func recordButtonTapped() {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            do {
                try startRecording()
            } catch {
                authStatusText = "Recording Not Available"
            }
        }
    }
    
    func startRecording() throws {
        //Cancel previous task if it's running
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        //Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        //Create and configure the speech recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to created a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = false
        
        recognitionRequest.requiresOnDeviceRecognition = true
        
        //Create a recognition task for the speech recognition session with delegate
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, delegate: self)

        audioEngine.inputNode.removeTap(onBus: 0)
        //Configure microphone input
        let recordingFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        audioEngine.inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
    }
    
    private func stopRecording() {
        audioEngine.inputNode.removeTap(onBus: 0)
        audioEngine.stop()
        
        recognitionRequest = nil
        recognitionTask = nil
        
        isRecordButtonEnabled = true
    }
}

//MARK: - SFSpeechRecognizerDelegate
extension SpeechControlViewModel: SFSpeechRecognizerDelegate {
    public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            isRecordButtonEnabled = true
        } else {
            isRecordButtonEnabled = false
            self.authStatusText = "Recognition Not Available"
        }
    }
}

//MARK: - SFSpeechRecognizerTaskDelegate
extension SpeechControlViewModel: SFSpeechRecognitionTaskDelegate {
    func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
        isProcessingVoiceCommand = true
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
        isProcessingVoiceCommand = false
        
        var isFinal = false
  
        let mostRecentTwoCommands =
        Array(recognitionResult.bestTranscription.segments.map { $0.substring }.suffix(2))
        self.completionHandler?(mostRecentTwoCommands)
        isFinal = recognitionResult.isFinal

        if isFinal {
            //Stop recognizing speech if there is a problem
            self.stopRecording()
        }
    }
    
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        isProcessingVoiceCommand = false
        if !successfully {
            self.stopRecording()
        }
    }
    
    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        isProcessingVoiceCommand = false
    }
}

