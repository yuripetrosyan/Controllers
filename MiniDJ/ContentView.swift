//
//  ContentView.swift
//  MiniDJ
//
//  Created by Yuri Petrosyan on 13/06/2024.
//
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AudioViewModel()
    @State private var showDocumentPicker = false
    @State private var selectedURL: URL?

    var body: some View {
        ZStack {
            Color("PrimaryColor").ignoresSafeArea()

            VStack {
                Button("Load MP3") {
                    showDocumentPicker = true
                }
                .padding()
                .sheet(isPresented: $showDocumentPicker) {
                    DocumentPicker(url: $selectedURL)
                        .onDisappear {
                            if let url = selectedURL {
                                viewModel.loadMP3(from: url)
                            }
                        }
                }

                HStack {
                    FakeSpeaker()
                    Spacer()
                }
                .padding(.leading, -60)

                HStack(alignment: .bottom) {
                    HStack(alignment: .bottom, spacing: 0) {
                        Text("00:")
                            .font(.title3)
                            .opacity(0.7)
                            .padding(.bottom, 3)

                        Text("00:00")
                            .font(.title)
                            .fontWeight(.semibold)
                    }

                    Spacer()
                    Text("03:33:09")
                        .font(.title3)
                        .opacity(0.7)
                }
                .fontDesign(.rounded)
                .padding()

                HStack {
                    Controller(controllerName: "Speed", value: $viewModel.speed, range: 0.5...2.0, step: 0.1, updateValue: { viewModel.updateSpeed($0) })
                    Controller(controllerName: "Reverb", value: $viewModel.reverb, range: 0.0...1.0, step: 0.1, updateValue: { viewModel.updateReverb($0) })
                }

                HStack {
                    Controller(controllerName: "Pitch", value: $viewModel.pitch, range: -2400.0...2400.0, step: 100, updateValue: { viewModel.updatePitch($0) })
                    Controller(controllerName: "Volume", value: $viewModel.volume, range: 0.0...1.0, step: 0.1, updateValue: { viewModel.updateVolume($0) })
                }
                .padding(.bottom)
            }
            .padding()
        }
    }
}

// MARK: - Controller
struct Controller: View {
    @State var controllerName: String
    @Binding var value: Float
    let range: ClosedRange<Float>
    let step: Float
    let updateValue: (Float) -> Void

    @State private var angle: Double = 0.0

    var body: some View {
        ZStack {
            ZStack(alignment: .center) {
                Rectangle()
                    .cornerRadius(15)
                    .foregroundStyle(.ultraThinMaterial).colorScheme(.dark)
                    .frame(width: 180, height: 180)

                ZStack {
                    Circle()
                        .frame(width: 110, height: 110)
                        .foregroundStyle(.black)

                    Circle()
                        .foregroundStyle(.yellow)
                        .frame(width: 10, height: 10)
                        .offset(x: cos(angle) * 50, y: sin(angle) * 50)
                        .gesture(DragGesture().onChanged { value in
                            let vector = CGVector(dx: value.location.x - 55, dy: value.location.y - 55)
                            let radians = atan2(vector.dy, vector.dx)
                            angle = radians

                            let normalizedValue = mapAngleToValue(radians)
                            updateValue(normalizedValue)
                        })
                }
            }
            
            VStack {
                
                HStack {
                    Spacer()
                    ZStack{
                        Circle()
                            .frame(width: 30, height: 30)
                            .opacity(0)
                        Image(systemName: "xmark")
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                    }
                }
                Spacer()
            }
            .padding(10)
            .frame(width: 180, height: 180)

            VStack {
                Spacer()
                HStack {
                    Text(controllerName)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                    Spacer()
                }
            }
            .padding(10)
            .frame(width: 180, height: 180)
        }
    }

    private func mapAngleToValue(_ angle: Double) -> Float {
        // Map the angle (-π to π) to the value range
        let normalizedValue = (Float(angle) + Float.pi) / (2 * Float.pi) * (range.upperBound - range.lowerBound) + range.lowerBound
        return round(normalizedValue / step) * step
    }
}

// MARK: - Fake Speaker
struct FakeSpeaker: View {
    let columns = [
        GridItem(.fixed(15)),
        GridItem(.fixed(15)),
        GridItem(.fixed(15)),
        GridItem(.fixed(15))
    ]

    var body: some View {
        HStack {
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(0..<40) { _ in
                    Circle()
                        .frame(width: 15, height: 15)
                }
            }
            .frame(width: 200)
        }
        .frame(width: 200)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        FakeSpeaker()
    }
}
