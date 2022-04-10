//
//  CardView.swift
//  Flashzilla
//
//  Created by Ifang Lee on 4/2/22.
//

/*
 About prepare() UINotificationFeedbackGenerator
 First, it’s OK to call prepare() then never triggering the effect – the system will keep the Taptic Engine ready for a few seconds then just power it down again. If you repeatedly call prepare() and never trigger it the system might start ignoring your prepare() calls until at least one effect has happened.

 Second, it’s perfectly allowable to call prepare() many times before triggering it once – prepare() doesn’t pause your app while the Taptic Engine warms up, and also doesn’t have any real performance cost when the system is already prepared.
 */
import SwiftUI

struct CardView: View {
    let card: Card
    var removal: (() -> Void)? = nil //for content view callback
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    @State private var feedback = UINotificationFeedbackGenerator() // if add this to content view, there's not time to call prepare()
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityVoiceOverEnabled) var voiceOverEnabled
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(
                    differentiateWithoutColor
                    ? .white
                    : .white
                        .opacity(1 - Double(abs(offset.width / 50)))
                )
                .background(
                    differentiateWithoutColor
                    ? nil
                    : RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(offset.width > 0 ? .purple : .pink) //coloring by gesture
                )
                .shadow(radius: 10)

            VStack {
                if voiceOverEnabled { //double tap to reach out the answer
                    Text(isShowingAnswer ? card.answer : card.promt)
                        .font(.largeTitle)
                        .foregroundColor(.black)
                } else {
                    Text(card.promt)
                        .font(.largeTitle)
                        .foregroundColor(.black)

                    if isShowingAnswer {
                        Text(card.answer)
                            .font(.title)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250) //the smallest iPhones have a landscape width of 480 points, so 450 points is fully visible on all devices.
        .rotationEffect(.degrees(Double(offset.width) / 5)) //the order of rotation, offset matters
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width) / 50 )) // beyond 50 points we start to fade out the card, until at 100 points left or right the opacity is 0.
        .accessibilityAddTraits(.isButton) // voice over: card is button
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation //get car moving distance
                    feedback.prepare()
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        if offset.width > 0 {
                            feedback.notificationOccurred(.success) //thought? do we need this? drawbacks for too many haptics
                        } else {
                            feedback.notificationOccurred(.error)
                        }
                        removal?() //That question mark in there means the closure will only be called if it has been set.
                    } else {
                        offset = .zero
                    }

                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
        .animation(.spring(), value: offset)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
