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
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
