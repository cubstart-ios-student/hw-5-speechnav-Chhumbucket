//
//  SpeechControlManager.swift
//  SpeechNav
//
//  Created by Justin Wong on 3/6/24.
//

import Foundation

enum SpeechControlCommandType: String, CaseIterable {
    case pushNavigation = "Push"
    case popNavigation = "Pop"
    case showSheet = "Show Sheet"
    case dismissSheet = "Dismiss Sheet"
    case showAlert = "Show Alert"
    case dismissAlert = "Dismiss Alert"
    case resume = "Resume"
    case pause = "Pause"
    case stop = "Stop"
}

struct SpeechControlCommand: Identifiable {
    let id = UUID()
    var imageSystemName: String
    var voiceCommand: String
    var description: String
}

struct SpeechControlManager {
    static func getCommandTypeFromSpeechTexts(for speechTextArray: [String]) -> SpeechControlCommandType? {
        let receivedCommand = speechTextArray.map{ $0.replacingOccurrences(of: " ", with: "")}.joined(separator: "").lowercased()
        let allCommandTypes = SpeechControlCommandType.allCases.map{ $0.rawValue.replacingOccurrences(of: " ", with: "").lowercased() }
        print("Recieved Command: \(receivedCommand)")
        if let index = allCommandTypes.firstIndex(of: receivedCommand) {
            return SpeechControlCommandType.allCases[index]
        }
        return nil
    }
}
