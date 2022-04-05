//
//  CardView.swift
//  Flashzilla
//
//  Created by Ifang Lee on 4/2/22.
//

import SwiftUI

struct CardView: View {
    let card: Card
    var removal: (() -> Void)? = nil //for content view callback
    @State private var isShowingAnswer = false
    @State private var offset = CGSize.zero
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor

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
                Text(card.promt)
                    .font(.largeTitle)
                    .foregroundColor(.black)

                if isShowingAnswer {
                    Text(card.answer)
                        .font(.title)
                        .foregroundColor(.gray)
                }
            }
            .padding(20)
            .multilineTextAlignment(.center)
        }
        .frame(width: 450, height: 250) //the smallest iPhones have a landscape width of 480 points, so 450 points is fully visible on all devices.
        .rotationEffect(.degrees(Double(offset.width) / 5)) //the order of rotation, offset matters
        .offset(x: offset.width * 5, y: 0)
        .opacity(2 - Double(abs(offset.width) / 50 )) // beyond 50 points we start to fade out the card, until at 100 points left or right the opacity is 0.
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation //get car moving distance
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        removal?() //That question mark in there means the closure will only be called if it has been set.
                    } else {
                        offset = .zero
                    }

                }
        )
        .onTapGesture {
            isShowingAnswer.toggle()
        }
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView(card: Card.example)
.previewInterfaceOrientation(.landscapeLeft)
    }
}
