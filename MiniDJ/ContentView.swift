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
    @State private var backgroundColor: Color = .blue
    @State var isAdded = true
    @State private var isCoverTapped = false
    
    
    var body: some View {
        GeometryReader{ geometry in
            ZStack {
                VStack{
                    Rectangle()
                        .fill(
                            LinearGradient(colors: [backgroundColor,
                                                    colorScheme == .dark ? .black : .white], startPoint: .top, endPoint: .bottom)
                            
                        )
                    
                    Spacer()
                    
                    RadialGradient(gradient: Gradient(colors: [backgroundColor, colorScheme == .dark ? .black : .white]), center: .bottom , startRadius: 25, endRadius: 250)
                        .ignoresSafeArea()
                    
                    
                }
                .ignoresSafeArea()
                
                ScrollView{
                    VStack {
                        HStack{
                            Spacer()
                            //Upload a song button
                            Button{
                                showDocumentPicker = true
                            }
                        label: {
                            
                            Image(systemName: "waveform.path.badge.plus")
                                .font(.title2)
                                .padding()
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.orange, .white)
                                .fontWeight(.semibold)
                            
                        }
                        .sheet(isPresented: $showDocumentPicker) {
                            DocumentPicker(url: $selectedURL)
                                .ignoresSafeArea(edges: .bottom)
                                .onDisappear {
                                    if let url = selectedURL {
                                        viewModel.loadMP3(from: url)
                                        
                                        
                                    }
                                    
                                }
                        }
                            
                            ColorPicker(selection: $backgroundColor, label: {
                                
                            }).padding(.trailing)
                            
                        }.padding(.top, 30)
                        
                        
                        HStack (spacing: 20){
                            
                            //                                if viewModel.coverArt == nil {
                            //
                            //                                    HStack{
                            //                                        FakeSpeaker()
                            //                                        .frame(width: geometry.size.width / 6)
                            //                                            .padding(.leading)
                            //                                            .padding()
                            //
                            //                                        Spacer()
                            //                                    }
                            //                                }
                            //Spacer()
                            VStack{
                                //Cover Art
                                if let coverArt = viewModel.coverArt {
                                    ZStack{
                                        Image(uiImage: coverArt)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: isCoverTapped ? geometry.size.width : 200)
                                            .transition(.movingParts.boing)
                                            .cornerRadius(isCoverTapped ? 0 : 10)
                                        
                                        Rectangle()
                                            .foregroundStyle(.primary)
                                            .colorInvert()
                                            .opacity(isCoverTapped ? 0.8 : 0)
                                            .offset(y: geometry.size.width * 0.5)
                                            .blur(radius: 10)
                                            .frame(width: geometry.size.width, height: 20)
                                    }
                                    
                                    .onTapGesture {
                                        withAnimation {
                                            //isAdded.toggle()
                                            isCoverTapped.toggle()
                                        }
                                    }
                                }
                                //Song Title
                                if let title = viewModel.title {
                                    Text(title)
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding(isCoverTapped ? -50 : 20)
                                }
                            }.padding(.top, -25)
                        }
                        
                        HStack {
                            
                            Button(action: {
                                viewModel.playPause()
                            }) {
                                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(backgroundColor)
                            }
                            
                            Slider(value: $viewModel.currentTime, in: 0...viewModel.duration, onEditingChanged: { editing in
                                if
                                    !editing {
                                    viewModel.seek(to: viewModel.currentTime)
                                }
                            })
                            .tint(backgroundColor)
                            .padding(.horizontal)
                         
                                
                        }.padding(.horizontal)
                        
                        
                        HStack(alignment: .bottom) {
                            HStack(alignment: .bottom, spacing: 0) {
                                Text("00:")
                                    .font(.title3)
                                    .opacity(0.7)
                                    .padding(.bottom, 3)
                                
                                //Text("00:00")
                                Text(formatTime(viewModel.currentTime))
                                    .font(.title)
                                    .fontWeight(.semibold)
                            }
                            
                            Spacer()
                            //Text("03:33:09")
                            Text("-" + formatTime(viewModel.duration - viewModel.currentTime))
                            
                                .font(.title3)
                                .opacity(0.7)
                        }
                        .fontDesign(.rounded)
                        .padding()
                        .padding(.top, isCoverTapped ? -20 : 0)
                        
                        
                        
                        
                        
                        
                        
                        VStack(spacing: 10){
                            HStack {
                                CircularKnob(value: $viewModel.speed, range: 0.5...2.0, step: 0.1, label: "Speed")
                                CircularKnob(value: $viewModel.reverb, range: 1.0...100.0, step: 1.0, label: "Reverb")
                            }
                            HStack {
                                CircularKnob(value: $viewModel.pitch, range: -10.0...10.0, step: 0.2, label: "Pitch")
                                CircularKnob(value: $viewModel.volume, range: 0.0...1.0, step: 0.1, label: "Volume")
                            }
                        }
                    }.offset(y: isCoverTapped ? -105 : 0)
                    
                    
                    // }
                    
                    
                }
                
                .ignoresSafeArea()
            }.onAppear{
                viewModel.loadMockMP3()
            }
        }
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
            //.frame(width: 200)
        }
        //.frame(width: 200)
    }
}



private func formatTime(_ time: TimeInterval) -> String {
    let minutes = Int(time) / 60
    let seconds = Int(time) % 60
    return String(format: "%02d:%02d", minutes, seconds)
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
        FakeSpeaker()
    }
}

