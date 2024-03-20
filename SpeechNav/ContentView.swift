//
//  ContentView.swift
//  SpeechNavFinished
//
//  Created by Justin Wong on 3/4/24.
//

import SwiftUI

struct ContentView: View {
    @Binding var commandsHistory: [SpeechControlCommandType]
    var speechControlVM: SpeechControlViewModel
    @State private var navigationPath = NavigationPath()
    @State private var isSheet = false;
    @State private var isAlert = false; 
    
    var body: some View {
        //TASK 3. Implement Navigation and Presentation HERE
        NavigationStack(path: $navigationPath) {
            Color.red.opacity(0.1)
                .ignoresSafeArea(.all)
                .navigationDestination(for: Color.self) {
                    color in
                    color.ignoresSafeArea(.all)
                }
        }
            .onAppear {
                speechControlVM.setCompletionHandler(for: executeVoiceCommand(for:))
            }
            .sheet(isPresented: $isSheet) {
                Color.green.ignoresSafeArea(.all)
            }
            .alert("Show Alert", isPresented: $isAlert) {
                Button(action: {
                    isAlert.toggle()
                }) {
                    Text("OK")
                }
            } message : {
                Text("Showing Alert!")
            }
            
    }
    
    private func executeVoiceCommand(for lastTwoCommands: [String]) {
        //TASK 2A. Implement basic structure for executeVoiceCommand(for:)
        if let command = SpeechControlManager.getCommandTypeFromSpeechTexts(for: lastTwoCommands) {
            if command == .resume && speechControlVM.isSpeechControlPaused {
                speechControlVM.isSpeechControlPaused = false
            }
            
            guard !speechControlVM.isSpeechControlPaused else {
                return
            }
            
            commandsHistory.append(command)
            
            switch command {
                
            case .pushNavigation:
                navigationPath.append(Color.blue)
            case .popNavigation:
                guard !navigationPath.isEmpty else { return }
                navigationPath.removeLast()
            case .showSheet:
                isSheet = true
            case .dismissSheet:
                isSheet = false
            case .showAlert:
                isAlert = true
            case .dismissAlert:
                isAlert = false
            case .resume:
                speechControlVM.isSpeechControlPaused = false
            case .pause:
                speechControlVM.isSpeechControlPaused = true
            case .stop:
                if speechControlVM.isSpeechRecMicEnabled {
                    speechControlVM.isSpeechRecMicEnabled = false
                    speechControlVM.recordButtonTapped()
                }
            }
            
        }
    }
}

