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

struct EditCardView: View {
    @Binding var showingEditScreen: Bool  //pass parent state var to child view
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button {
                    showingEditScreen = true
                } label: {
                    Image(systemName: "plus.circle")
                        .padding()
                        .background(.black.opacity(0.7))
                        .clipShape(Circle())
                }
            }
            Spacer()
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
    @State private var cards =  [Card]() // [Card](repeating: Card.example, count: 10) // if need examples
    @State private var timeRemaining = 100
    @State private var isActive = true
    @State private var showingEditScreen = false

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
                EditCardView(showingEditScreen: $showingEditScreen)
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
        .onAppear(perform: resetCards)
        //rather than creating a closure that calls the EditCards initializer,
        // we can actually pass the EditCards initializer directly to the sheet, like this:
        //.sheet(isPresented: $showingEditScreen, onDismiss: resetCards, content: EditCards.init)
        // Important: This approach only works because EditCards has an initializer that accepts no parameters.
        // If you need to pass in specific values you need to use the closure-based approach instead.
        .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
            EditCards() // syntactic sugar: actually calling EditCards.init()
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
//        cards = [Card](repeating: Card.example, count: 10) //if need examples
        timeRemaining = 100
        isActive = true
        loadData()
    }
    
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
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
