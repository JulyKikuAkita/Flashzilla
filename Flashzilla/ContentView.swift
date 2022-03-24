//
//  ContentView.swift
//  Flashzilla
//
//  Created by July on 3/18/22.
//

import SwiftUI

struct TapGestureView: View {
    var body: some View {
        VStack {
            Text("Tap Gesture")
                .padding()
                .onTapGesture(count: 2) {
                    print("Double Tapped")
                }

            Text("Long Press Gesture")
                .padding()
                .onLongPressGesture(minimumDuration: 1) {
                    print("Long Pressed")
                } onPressingChanged: { inProgress in
                    print("In progress: \(inProgress)!")
                }// the boolean value changed before long pressed triggered

            VStack {
                Text("Child View Tap Gesture")
                    .padding()
                    .onTapGesture {
                        print("Text tapped") //child view gets priority
                    }
            }
            .onTapGesture {
                print("VStack tapped")
            }

        }
    }
}
struct MagnigicationView: View {
    @State private var currentAmount = 0.0
    @State private var finalAmount = 1.0

    var body: some View {
        Text("Magnigication Gesture; press option at simulator to pinch")
            .font(.headline)
            .padding()
            .scaleEffect(finalAmount + currentAmount)
            .gesture(
                MagnificationGesture()
                    .onChanged { amount in
                        currentAmount = amount - 1
                    }
                    .onEnded { amount in
                        finalAmount += currentAmount
                        currentAmount = 0
                    }
            )
    }
}

struct RotationGestureView : View {
    @State private var currentAngle = Angle.zero
    @State private var finalAngle = Angle.zero

    var body: some View {
        Text("Rotation Gesture; press option at simulator to pinch")
            .font(.headline)
            .padding()
            .rotationEffect(currentAngle + finalAngle)
            .gesture(
                RotationGesture()
                    .onChanged { angle in
                        currentAngle = angle
                    }
                    .onEnded { angle in
                        finalAngle += currentAngle
                        currentAngle = .zero
                    }
            )
    }
}

struct ClashGestureView: View {
    var body: some View {
        HStack {
            VStack {
                Text("highPriorityGesture")
                    .onTapGesture {
                        print("Text tapped")
                    }
            }
            .highPriorityGesture(
                TapGesture()
                    .onEnded { _ in
                        print("VStack tapped")
                    }
            )

            Spacer()

            VStack {
                Text("simultaneousGesture")
                    .onTapGesture {
                        print("Text tapped")
                    }
            }
            .simultaneousGesture(
                TapGesture()
                    .onEnded { _ in
                        print("VStack tapped")
                    }
            )
        }
        .padding()
    }
}

struct GestureSequenceView: View {
    // how far the circle has been dragged
    @State private var offset = CGSize.zero

    // whether it is currently being dragged or not
    @State private var isDragging = false

    var body: some View {
        // a drag gesture that updates offset and isDragging as it moves around
        let dragGesture = DragGesture()
            .onChanged { value in
                offset = value.translation
            }
            .onEnded { _ in
                withAnimation {
                    offset = .zero
                    isDragging = false
                }
            }

        // a long press gesture that enables isDragging
        let pressGesture = LongPressGesture()
            .onEnded { value in
                withAnimation {
                    isDragging = true
                }
            }

        // a combined gesture that forces the user to long press then drag
        let combined = pressGesture.sequenced(before: dragGesture)

        // a 64x64 circle that scales up when it's dragged, sets its offset to whatever we had back from the drag gesture, and uses our combined gesture
        Circle()
            .fill(.orange)
            .frame(width: 64, height: 64)
            .scaleEffect(isDragging ? 1.5 : 1)
            .offset(offset)
            .gesture(combined)
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            TapGestureView()
                .tabItem {
                    Label("tap", systemImage: "star")
                }

            MagnigicationView()
                .tabItem {
                    Label("Mag", systemImage: "cloud")
                }

            RotationGestureView()
                .tabItem {
                    Label("Rotate", systemImage: "circle")
                }

            ClashGestureView()
                .tabItem {
                    Label("Clash", systemImage: "wind")
                }

            GestureSequenceView()
                .tabItem {
                    Label("Sequence", systemImage: "sunset")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
