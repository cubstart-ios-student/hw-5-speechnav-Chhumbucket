//
//  SquishyButton.swift
//  SpeechNav
//
//  Created by Justin Wong on 3/6/24.
//

import SwiftUI

struct SquishyButton<Content: View>: View {
    @State private var scale = 1.0
    var action: () -> Void
    var content: () -> Content
    var body: some View {
        Button(action: {
            withAnimation {
                scale += 0.2
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    scale -= 0.2
                }
                action()
            }
        }) {
            content()
        }
        .scaleEffect(scale)
        .animation(.bouncy(duration: 0.4), value: scale)
    }
}

#Preview("Circle Squishy Button") {
    SquishyButton {
        
    } content: {
        Circle()
            .fill(.red)
            .frame(width: 70, height: 70)
    }
}
