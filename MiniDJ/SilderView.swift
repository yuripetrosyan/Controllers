//
//  SilderView.swift
//  Controllers
//
//  Created by Yuri Petrosyan on 15/07/2024.
//

import SwiftUI

struct SliderView: View {
    @Binding var value: Double
    
    @State var lastCoordinateValue: CGFloat = 0.0
    var sliderRange: ClosedRange<Double> = 1...100
    var thumbColor: Color = .yellow
    var minTrackColor: Color = .blue
    var maxTrackColor: Color = .gray
    
    var body: some View {
        GeometryReader { gr in
            let thumbHeight = gr.size.height * 1.1
            let thumbWidth = gr.size.width * 0.03
            let radius = gr.size.height * 0.5
            let minValue = gr.size.width * 0.015
            let maxValue = (gr.size.width * 0.98) - thumbWidth
            
            let scaleFactor = (maxValue - minValue) / (sliderRange.upperBound - sliderRange.lowerBound)
            let lower = sliderRange.lowerBound
            let sliderVal = (self.value - lower) * scaleFactor + minValue
            
            ZStack {
                Rectangle()
                    .foregroundColor(maxTrackColor)
                    .frame(width: gr.size.width, height: gr.size.height * 0.95)
                    .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    Rectangle()
                        .foregroundColor(minTrackColor)
                    .frame(width: sliderVal, height: gr.size.height * 0.95)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: radius))
                HStack {
                    RoundedRectangle(cornerRadius: radius)
                        .foregroundColor(thumbColor)
                        .frame(width: thumbWidth, height: thumbHeight)
                        .offset(x: sliderVal)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { v in
                                    if (abs(v.translation.width) < 0.1) {
                                        self.lastCoordinateValue = sliderVal
                                    }
                                    if v.translation.width > 0 {
                                        let nextCoordinateValue = min(maxValue, self.lastCoordinateValue + v.translation.width)
                                        self.value = ((nextCoordinateValue - minValue) / scaleFactor)  + lower
                                    } else {
                                        let nextCoordinateValue = max(minValue, self.lastCoordinateValue + v.translation.width)
                                        self.value = ((nextCoordinateValue - minValue) / scaleFactor) + lower
                                    }
                               }
                        )
                    Spacer()
                }
            }
        }
    }
}



struct ContentView2: View {
    @State private var currentValue1 = 6.0
    
    var body: some View {
        VStack(spacing:20) {
            Text("Custom Slider")
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(spacing:0) {
                Text("value 1 = \(currentValue1, specifier: "%.2F")")
                SliderView(value: $currentValue1,
                            sliderRange: 4...10)
                    .frame(width:300, height:30)
            }
            
            VStack(spacing:0) {
                Text("value 1 = \(currentValue1, specifier: "%.2F")")
                SliderView(value: $currentValue1,
                            sliderRange: 4...10,
                            thumbColor: .purple,
                            minTrackColor: .red,
                            maxTrackColor: .green)
                    .frame(width:300, height:30)
            }
            
            VStack(spacing:0) {
                Text("value 1 = \(currentValue1, specifier: "%.2F")")
                SliderView(value: $currentValue1,
                            sliderRange: 4...10,
                            thumbColor: .red,
                            minTrackColor: .red,
                            maxTrackColor: .clear)
                    .frame(width:300, height:30)
            }
            
            VStack(spacing:0) {
                Text("value 1 = \(currentValue1, specifier: "%.2F")")
                SliderView(value: $currentValue1,
                            sliderRange: 4...10)
                    .frame(width:300, height:100)
            }

            Spacer()
        }
    }
}


#Preview {
//    SliderView(value: 0.0, lastCoordinateValue: 2.0, sliderRange: 1.0, thumbColor: .green, minTrackColor: .blue, maxTrackColor: .red)
    ContentView2()
}
