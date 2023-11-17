//
//  DotLoadingView.swift
//  XCAChatGPT
//
//  Created by Khoi Nguyen on 02/02/23.
//

import SwiftUI

// MARK: - DotLoadingView
// A view that displays a loading animation with three dots.
struct DotLoadingView: View {
    
    // State variables to control the visibility of each dot.
    @State private var showCircle1 = false
    @State private var showCircle2 = false
    @State private var showCircle3 = false
    
    var body: some View {
        // Horizontal stack of circles.
        HStack {
            Circle()
                .opacity(showCircle1 ? 1 : 0) // First dot visibility.
            Circle()
                .opacity(showCircle2 ? 1 : 0) // Second dot visibility.
            Circle()
                .opacity(showCircle3 ? 1 : 0) // Third dot visibility.
        }
        .foregroundColor(.gray.opacity(0.5)) // Set the color of the dots.
        .onAppear { performAnimation() } // Start the animation when the view appears.
    }
    
    // Function to perform the dot animation.
    func performAnimation() {
        let animation = Animation.easeInOut(duration: 0.4)
        
        // Animate the first dot.
        withAnimation(animation) {
            self.showCircle1 = true
            self.showCircle3 = false
        }
        
        // Animate the second dot after a delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(animation) {
                self.showCircle2 = true
                self.showCircle1 = false
            }
        }
        
        // Animate the third dot after a delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(animation) {
                self.showCircle2 = false
                self.showCircle3 = true
            }
        }
        
        // Repeat the animation sequence.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.performAnimation()
        }
    }
}

// MARK: - DotLoadingView_Previews
// Preview provider for DotLoadingView.
struct DotLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        DotLoadingView()
    }
}
