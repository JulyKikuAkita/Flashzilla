//
//  ContentView.swift
//  Flashzilla
//
//  Created by July on 3/18/22.
//

import SwiftUI

struct checkMarkCircleatBottomView: View {
    var removeCard: () -> Void //callback for func removeCard(at index: Int)
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    removeCard()
                }
            } label: {
                Image(systemName: "xmark.circle")
                    .padding()
                    .background(.black.opacity(0.7))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Wrong")
            .accessibilityHint("Mark your answer as being incorrect.")
           
            Spacer()
            
            Button {
                withAnimation {
                    removeCard()
                }
            } label: {
                Image(systemName: "checkmark.circle")
                    .padding()
                    .background(.black.opacity(0.7))
                    .clipShape(Circle())
            }
            .accessibilityLabel("Correct")
            .accessibilityHint("Mark your answer as being correct.")
        }
        .foregroundColor(.white)
        .font(.largeTitle)
        .padding()
    }
}


/*
 Issues for voice over regarding gestures

 We don’t say that the cards are buttons that can be tapped.
 When the answer is revealed there is no audible notification of what it was.
 Users have no way of swiping left or right to move through the cards.
 
 */
struct ContentView: View {
    @State private var cards = [Card](repeating: Card.example, count: 10)
    @State private var timeRemaining = 100
    @State private var isActive = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .ignoresSafeArea()
            VStack {
                if differentiateWithoutColor || voiceOverEnabled {
                    Spacer()
                    checkMarkCircleatBottomView { removeCard(at: cards.count - 1) }
                }

                ZStack {
                    ForEach(0 ..< cards.count, id: \.self) { index in
                        CardView(card: cards[index]) {
                            withAnimation {
                                removeCard(at: index)
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1) //only tap the top card
                        .accessibilityHidden(index < cards.count - 1) // voice over ignore the other cards
                    }
                }
                .allowsHitTesting(timeRemaining > 0)

                if cards.isEmpty {
                    Button("Start Again", action: resetCards)
                        .padding()
                        .background(.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }

                Text("Time \(timeRemaining)")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 5)
                    .background(.black.opacity(0.75))
                    .clipShape(Capsule())
            }
        }
        .onReceive(timer) { time in
            guard isActive else { return }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if cards.isEmpty == false {
                    isActive = true
                }
            } else {
                isActive = false
            }

        }
    }

    func removeCard(at index: Int) {
        guard index >= 0 else { return }
        cards.remove(at: index)
        if cards.isEmpty {
            isActive = false
        }
    }

    func resetCards() {
        cards = [Card](repeating: Card.example, count: 10)
        timeRemaining = 100
        isActive = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
.previewInterfaceOrientation(.landscapeLeft)
    }
}

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = Double(total - position)
        return self.offset(x: 0, y: offset * 10)
    }
}
