//
//  ContentView.swift
//  Flashzilla
//
//  Created by July on 3/18/22.
//
/**
 Core Haptics lets us create hugely customizable haptics by combining taps, continuous vibrations, parameter curves, and more
 */
import SwiftUI

struct ContentView: View {
    // (Run loops lets iOS handle running code while the user is actively doing something, such as scrolling in a list.)
    // timer coalescing: it can push back your timer just a little so that it fires at the same time as one or more other timers, which means it can keep the CPU idling more and save battery power.
    let timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    @State private var counter = 0

    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        VStack {
            Text("Publish timer")
                .padding()
                .onReceive(timer) { time in
                    if counter == 5 {
                        timer.upstream.connect().cancel()
                    } else {
                        print("The time is now \(time)")
                    }
                    counter += 1
                }

            /**
             Active scenes are running right now, which on iOS means they are visible to the user. On macOS an app’s window might be wholly hidden by another app’s window, but that’s okay – it’s still considered to be active.
             Inactive scenes are running and might be visible to the user, but they user isn’t able to access them. For example, if you’re swiping down to partially reveal the control center then the app underneath is considered inactive.
             Background scenes are not visible to the user, which on iOS means they might be terminated at some point in the future.
             */
            Text("Show scenePhase")
                .padding()
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        print("Active")
                    } else if newPhase == .inactive {
                        print("Inactive")
                    } else if newPhase == .background {
                        print("Background")
                    }
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
