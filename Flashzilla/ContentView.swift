//
//  ContentView.swift
//  Flashzilla
//
//  Created by July on 3/18/22.
//
/**
 Test in the simulator: going to the Settings app and choosing
 1. When this setting is enabled, apps should try to make their UI clearer using shapes, icons, and textures rather than colors, which is helpful for the 1 in 12 men who have color blindness
 Accessibility > Display & Text Size > Differentiate Without Color

 2. When this is enabled, apps should limit the amount of animation that causes movement on screen. For example, the iOS app switcher makes views fade in and out rather than scale up and down.
 Accessibility > Motion > Reduce Motion

 3. Reduce Transparency, and when that’s enabled apps should reduce the amount of blur and translucency used in their designs to make doubly sure everything is clear.

 */
import SwiftUI

struct ContentView: View {

    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State private var scale = 1.0

    @Environment(\.accessibilityReduceTransparency) var reduceTransparency

    var body: some View {
        VStack {
            // we use a simple green background for the regular layout, but when Differentiate Without Color is enabled we use a black background and add a checkmark instead
            HStack {
                if differentiateWithoutColor {
                    Image(systemName: "checkmark.circle")
                }
                Text("Differentiate Without Color")
            }
            .padding()
            .background(differentiateWithoutColor ? .black : .green)
            .foregroundColor(.white)
            .clipShape(Capsule())

            // restrict the use of withAnimation() when it involves movement
            Text("Reduce Motion")
                .padding()
                .scaleEffect(scale)
                .onTapGesture {
                    if reduceMotion {
                        scale *= 1.5
                    } else {
                        withAnimation {
                            scale *= 1.5
                        }
                    }
                }

            Text("Reduce Motion with less code")
                .padding()
                .scaleEffect(scale)
                .onTapGesture {
                    withOptionalAnimation {
                        scale *= 1.5
                    }
                }

            // this code uses a solid black background when Reduce Transparency is enabled, otherwise using 50% transparency
            Text("Reduce Transparency")
                .padding()
                .background(reduceTransparency ? .black : .black.opacity(0.5))
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
    }

    func withOptionalAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
        if UIAccessibility.isReduceMotionEnabled {
            return try body()
        } else {
            return try withAnimation(animation, body)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
