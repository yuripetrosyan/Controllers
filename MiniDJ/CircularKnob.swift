//
//  CircularKnob.swift
//  MiniDJ
//
//  Created by Yuri Petrosyan on 13/06/2024.
//

import SwiftUI

struct CircularKnob: View {
   @Binding var value: Float
    //@State private var value: Float = 1.0
    let range: ClosedRange<Float>
    let step: Float
    let label: String
    @State var angleValue: Double = 0.0
    
    // Customize colors
    let trackColor = Color.gray
    let progressColor = Color.white
    let knobColor = Color.yellow

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .foregroundStyle(.ultraThinMaterial).colorScheme(.dark)
                .frame(width: 185, height: 185)
            
            ZStack {
                
                Circle()
                    .foregroundStyle(.black)
                    .frame(width: 120, height: 120)

                
                Circle() // Background track
                
                    .stroke(trackColor,
                            style: StrokeStyle(lineWidth: 3, lineCap: .butt, dash: [3, 23.18]))
                    .frame(width: 125, height: 125)
                    .scaleEffect(1.2)
                

                Circle() // Progress indicator
                    .trim(from: 0.0, to: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)))
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 150, height: 150)
                    .rotationEffect(.degrees(-90))

                Circle() // Knob
                    .fill(knobColor)
                    .frame(width: 15, height: 15)
                    .padding(5)
                    .offset(y: -75)
                    .rotationEffect(Angle.degrees(angleValue))
                    .gesture(DragGesture(minimumDistance: 0.0)
                        .onChanged({ value in
                            change(location: value.location)
                        }))

                VStack { // Label and value display
                    Text(label)
                        .font(.headline)
                        .foregroundColor(.white)
                    Text(String(format: "%.1f", value))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
    }

    private func change(location: CGPoint) {
        let vector = CGVector(dx: location.x - 125, dy: location.y - 125) // Center is at (125, 125)
        var radians = atan2(vector.dy, vector.dx) + .pi / 2.0
        
        // Ensure angle is within 0 to 2π range
        if radians < 0 { radians += 2 * .pi }
        
        // Calculate new value based on angle
        let normalizedValue = Float(radians / (2 * .pi)) * (range.upperBound - range.lowerBound) + range.lowerBound
        let newValue = round(normalizedValue / step) * step

        // Update if within valid range
        if range.contains(newValue) {
            angleValue = radians * 180 / .pi // Convert to degrees
            value = newValue
        }
    }
}



struct CircularKnobPreview: View {
    @State private var speedValue: Float = 1.0
    @State private var reverbValue: Float = 0.5
    @State private var pitchValue: Float = 0.0
    @State private var volumeValue: Float = 0.8

    var body: some View {
        LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())]) {
            CircularKnob(value: $speedValue, range: 0.5...2.0, step: 0.1, label: "Speed")
            CircularKnob(value: $reverbValue, range: 0.0...1.0, step: 0.1, label: "Reverb")
            CircularKnob(value: $pitchValue, range: -10.0...10.0, step: 0.1, label: "Pitch")
            CircularKnob(value: $volumeValue, range: 0.0...1.5, step: 0.1, label: "Volume")
        }
        .padding()
    }
}

struct CircularKnobPreview_Previews: PreviewProvider {
    static var previews: some View {
        CircularKnobPreview()
    }
}
