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
    
    var body: some View {
        //TASK 3. Implement Navigation and Presentation HERE
        EmptyView()
            //DO NOT DELETE this .onAppear MODIFIER
            .onAppear {
                speechControlVM.setCompletionHandler(for: executeVoiceCommand(for:))
            }
    }
    
    private func executeVoiceCommand(for lastTwoCommands: [String]) {
        //TASK 2A. Implement basic structure for executeVoiceCommand(for:)
    }
}

