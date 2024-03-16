//
//  SpeechControlButton.swift
//  SpeechNavFinished
//
//  Created by Justin Wong on 3/4/24.
//

import SwiftUI

struct SpeechControlButton: View {
    var speechControlVM: SpeechControlViewModel
  
    var body: some View {
        SquishyButton {
            speechControlVM.currentSpeechControlCommand = nil
            speechControlVM.isSpeechRecMicEnabled.toggle()
          
            if speechControlVM.isSpeechRecMicEnabled {
                speechControlVM.makeSpeechRecognizerAuthRequest()
            }

            speechControlVM.recordButtonTapped()
                
        } content: {
            HStack(spacing: 10) {
                infoTextView
                systemImageView
            }
            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            .background(getSpeechControlButtonBackgroundColor())
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .disabled(speechControlVM.isRecordButtonEnabled ? false : true)

    }
    
    private func getSpeechControlButtonBackgroundColor() -> Color {
        if !speechControlVM.isSpeechRecMicEnabled {
            return .red
        }
        
        if speechControlVM.isSpeechControlPaused {
            return .yellow
        }
        
        return .green
    }
    
    private var infoTextView: some View {
        Group {
            if speechControlVM.isSpeechRecMicEnabled {
                if speechControlVM.isSpeechControlPaused {
                    Text("Paused")
                } else if speechControlVM.isProcessingVoiceCommand {
                    ProgressView()
                        .transition(.scale)
                } else if let currentSpeechControlCommand = speechControlVM.currentSpeechControlCommand {
                    Text(currentSpeechControlCommand.rawValue.capitalized)
                        .transition(.scale)
                        .foregroundStyle(.white)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    self.speechControlVM.currentSpeechControlCommand = nil
                                }
                            }
                        }
                } else {
                    Text("Listening ...")
                }
            } else {
                Text("SpeechControl")
            }
        }
        .foregroundStyle(.white)
        .bold()
    }
    
    private var systemImageView: some View {
        Group {
            if speechControlVM.isSpeechControlPaused {
                Image(systemName: "pause.circle.fill")
                    .font(.system(size: 15))
            } else {
                Image(systemName: speechControlVM.isSpeechRecMicEnabled ? "mic" : "mic.slash")

            }
        }
        .foregroundStyle(.white)
    }
}


