//
//  ContentView.swift
//  MiniDJ
//
//  Created by Yuri Petrosyan on 13/06/2024.
//
import SwiftUI
import Pow

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme
    @State var t: Float = 0.0
    @State var timer: Timer?
    @StateObject private var viewModel = AudioViewModel()
    @State private var showDocumentPicker = false
    @State private var selectedURL: URL?
    @State private var backgroundColor: Color = .pink
    @State var isAdded = true

    
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                // ScrollView{
                VStack{
                    ZStack{
                        
                        Rectangle()
                            .fill(
                                LinearGradient(colors: [backgroundColor,
                                                        colorScheme == .dark ? .black : .white], startPoint: .top, endPoint: .bottom)
                                
                            )
                        
                            .ignoresSafeArea()
                        
                        VStack {
                            ColorPicker(selection: $backgroundColor, label: {
                                
                            }).padding(.top, -20)
                                .padding(.trailing)
                            Button("Upload a song") {
                                showDocumentPicker = true
                            }
                            .padding(.top, -40)
                            .foregroundStyle(.primary)
                            .font(.headline)
                            .fontDesign(.rounded)
                            .fontWeight(.semibold)
                            .padding()
                            .sheet(isPresented: $showDocumentPicker) {
                                DocumentPicker(url: $selectedURL)
                                    .ignoresSafeArea(edges: .bottom)
                                    .onDisappear {
                                        if let url = selectedURL {
                                            viewModel.loadMP3(from: url)
                                        }
                                    }
                            }
                            
                            HStack (spacing: 20){
                                
                                if viewModel.coverArt == nil {
                                    FakeSpeaker()
                                    
                                        .frame(width: geometry.size.width / 6)
                                        .padding(.leading)
                                    
                                }
                                
                                
                                
                                //Spacer()
                                
                                ZStack{
                                    if isAdded {
                                        
                                        if let coverArt = viewModel.coverArt {
                                            Image(uiImage: coverArt)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(height: 200)
                                                .cornerRadius(10)
                                                .transition(.movingParts.anvil)
                                            //.transition(.movingParts.flip)
                                        }
                                    }
                                }
                            
                                  
                            }
                            if let title = viewModel.title {
                                Text(title)
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                   // .padding()
                            }
                            
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
                            
                            
                        }
                    }
                    ZStack{
                        
                        //Logo()
                        
                        RadialGradient(gradient: Gradient(colors: [backgroundColor, colorScheme == .dark ? .black : .white]), center: .bottom , startRadius: 25, endRadius: 250)
                            .ignoresSafeArea()
                        
                        
                        VStack{
                            HStack {
                                CircularKnob(value: $viewModel.speed, range: 0.5...2.0, step: 0.1, label: "Speed")
                                CircularKnob(value: $viewModel.reverb, range: 0.0...1.0, step: 0.1, label: "Reverb")
                            }
                            HStack {
                                CircularKnob(value: $viewModel.pitch, range: -10.0...10.0, step: 0.2, label: "Pitch")
                                CircularKnob(value: $viewModel.volume, range: 0.0...1.0, step: 0.1, label: "Volume")
                            }
                        }
                    }
                    
                    
                    
                    
                }
            }
        }
    }
    
}

//// MARK: - Controller
//struct Controller: View {
//    @State var controllerName: String
//    @Binding var value: Float
//    let range: ClosedRange<Float>
//    let step: Float
//    let updateValue: (Float) -> Void
//    let resetValue: () -> Void
//
//    @State private var angle: Double = 0.0
//
//    var body: some View {
//        ZStack {
//            ZStack(alignment: .center) {
//                Rectangle()
//                    .cornerRadius(15)
//                    .foregroundStyle(.ultraThinMaterial).colorScheme(.dark)
//                    .frame(width: 180, height: 180)
//
//                ZStack {
//                    Circle()
//                        .frame(width: 110, height: 110)
//                        .foregroundStyle(.black)
//
//                    Circle()
//                        .foregroundStyle(.yellow)
//                        .frame(width: 10, height: 10)
//                        .offset(x: cos(angle) * 50, y: sin(angle) * 50)
//                        .gesture(DragGesture().onChanged { value in
//                            let vector = CGVector(dx: value.location.x - 55, dy: value.location.y - 55)
//                            let radians = atan2(vector.dy, vector.dx)
//                            angle = radians
//
//                            let normalizedValue = mapAngleToValue(radians)
//                            updateValue(normalizedValue)
//                        })
//                }
//            }
//
//            VStack {
//                HStack {
//                    Spacer()
//                    Button(action: {
//                        resetValue()
//                    }) {
//                        ZStack {
//                            Circle()
//                                .frame(width: 30, height: 30)
//                                .opacity(0)
//                                .onTapGesture {
//                                    resetValue()
//                                }
//                            Image(systemName: "xmark")
//                                .fontWeight(.semibold)
//                                .fontDesign(.rounded)
//
//                        }
//                    }
//                }
//                Spacer()
//            }
//            .padding(10)
//            .frame(width: 180, height: 180)
//
//            VStack {
//                Spacer()
//                HStack {
//                    Text(controllerName)
//                        .fontWeight(.semibold)
//                        .fontDesign(.rounded)
//                    Spacer()
//                }
//            }
//            .padding(10)
//            .frame(width: 180, height: 180)
//        }
//    }
//
//    private func mapAngleToValue(_ angle: Double) -> Float {
//        // Map the angle (-π to π) to the value range
//        let normalizedValue = (Float(angle) + Float.pi) / (2 * Float.pi) * (range.upperBound - range.lowerBound) + range.lowerBound
//        return round(normalizedValue / step) * step
//    }
//}

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
