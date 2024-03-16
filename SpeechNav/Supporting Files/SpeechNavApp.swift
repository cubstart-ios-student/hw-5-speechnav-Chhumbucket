//
//  SpeechNavApp.swift
//  SpeechNav
//
//  Created by Justin Wong on 3/6/24.
//
import SwiftUI

@main
struct SpeechNavFinishedApp: App {
    @State private var speechControlVM = SpeechControlViewModel()
    @State private var commandsHistory: [SpeechControlCommandType] = []
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                commandsHistory: $commandsHistory,
                speechControlVM: speechControlVM
            )
            .overlay (
                speechControlOverlayView
            )
        }
    }
    
    private var speechControlOverlayView: some View {
        GeometryReader { geo in
            ZStack {
                Color.clear
                VStack(spacing: 20) {
                    Spacer()
                    SpeechControlButton(speechControlVM: speechControlVM)
                    Spacer()
                    if !commandsHistory.isEmpty {
                        List(commandsHistory, id: \.self) { command in
                            Text(command.rawValue)
                                .bold()
                                .foregroundStyle(.secondary)
                        }
                        .frame(height: geo.size.height * 0.4)
                        .scrollContentBackground(.hidden)
                        Spacer()
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity)
                .background(Color.clear)
            }
            .ignoresSafeArea(.all)
        }
    }
}

