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
    @State private var isCoverTapped = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    BackgroundView(viewModel: viewModel, colorScheme: colorScheme)
                    
                    ScrollView {
                        VStack {
                            CoverArtView(viewModel: viewModel, geometry: geometry, isCoverTapped: $isCoverTapped)
                            
                            PlaybackControlsView(viewModel: viewModel)
                            
                            TimeLabelsView(viewModel: viewModel, isCoverTapped: isCoverTapped)
                            
                            KnobsView(viewModel: viewModel)
                        }
                        
                        .offset(y: isCoverTapped ? 0 : 70)
                    }
                    .scrollIndicators(.hidden)
                    .ignoresSafeArea()
                }
                
                .toolbar(content: {
                    ToolbarItems(viewModel: viewModel, showDocumentPicker: $showDocumentPicker, selectedURL: $selectedURL, isCoverTapped: isCoverTapped)
                })
                .toolbarBackground(.hidden, for: .navigationBar)
                .onAppear {
                    viewModel.loadMockMP3()
                }
            }
        }
    }
}

// BackgroundView
struct BackgroundView: View {
    @ObservedObject var viewModel: AudioViewModel
    var colorScheme: ColorScheme
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(
                    LinearGradient(colors: [viewModel.backgroundColor,
                                            colorScheme == .dark ? .black : .white], startPoint: .top, endPoint: .bottom)
                )
            
            Spacer()
            
            RadialGradient(gradient: Gradient(colors: [viewModel.backgroundColor, colorScheme == .dark ? .black : .white]), center: .bottom, startRadius: 25, endRadius: 250)
                .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
}

// CoverArtView
struct CoverArtView: View {
    @ObservedObject var viewModel: AudioViewModel
    var geometry: GeometryProxy
    @Binding var isCoverTapped: Bool
    
    var body: some View {
        VStack {
            if let coverArt = viewModel.coverArt {
                ZStack {
                    Image(uiImage: coverArt)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: isCoverTapped ? geometry.size.width : 200)
                        .transition(.movingParts.boing)
                        .cornerRadius(isCoverTapped ? 0 : 10)
                    
                    Rectangle()
                        .foregroundStyle(.primary)
                        .colorInvert()
                        .opacity(isCoverTapped ? 1 : 0)
                        .offset(y: geometry.size.width * 0.5)
                        .blur(radius: 5)
                        .frame(width: geometry.size.width, height: 20)
                }
                .onTapGesture {
                    withAnimation {
                        isCoverTapped.toggle()
                    }
                }
            } else{
                Spacer(minLength: 240)
            }
            if let title = viewModel.title {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(isCoverTapped ? -50 : 20)
            }
        }
    }
}

// PlaybackControlsView
struct PlaybackControlsView: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        HStack {
            Button(action: {
                viewModel.playPause()
            }) {
                Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(viewModel.backgroundColor)
            }
            
            Slider(value: $viewModel.currentTime, in: 0...viewModel.duration, onEditingChanged: { editing in
                if !editing {
                    viewModel.seek(to: viewModel.currentTime)
                    print(viewModel.currentTime)
                }
            })
            .tint(viewModel.backgroundColor)
            .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}

// TimeLabelsView


struct TimeLabelsView: View {
    @ObservedObject var viewModel: AudioViewModel
    var isCoverTapped: Bool
    
    var body: some View {
        HStack(alignment: .bottom) {
            HStack(alignment: .bottom, spacing: 0) {
                Text("00:")
                    .font(.title3)
                    .opacity(0.7)
                    .padding(.bottom, 3)
                
                Text(formatTime(viewModel.currentTime))
                    .font(.title)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            Text("-" + formatTime(viewModel.duration - viewModel.currentTime))
                .font(.title3)
                .opacity(0.7)
        }
        .fontDesign(.rounded)
        .padding()
        .padding(.top, isCoverTapped ? -20 : 0)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// KnobsView
struct KnobsView: View {
    @ObservedObject var viewModel: AudioViewModel
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                CircularKnob(value: $viewModel.speed, range: 0.5...2.0, step: 0.1, label: "Speed")
                CircularKnob(value: $viewModel.reverb, range: 1.0...100.0, step: 1.0, label: "Reverb")
            }
            HStack {
                CircularKnob(value: $viewModel.pitch, range: -10.0...10.0, step: 0.2, label: "Pitch")
                CircularKnob(value: $viewModel.volume, range: 0.0...1.0, step: 0.1, label: "Volume")
            }
        }
    }
}


// ToolbarItems
struct ToolbarItems: ToolbarContent {
    @ObservedObject var viewModel: AudioViewModel
    @Binding var showDocumentPicker: Bool
    @Binding var selectedURL: URL?
    var isCoverTapped: Bool
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showDocumentPicker = true
            } label: {
                Image(systemName: "waveform.path.badge.plus")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.orange, .white)
                    .fontWeight(.semibold)
            }
            .opacity(isCoverTapped ? 0 : 1)
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker(url: $selectedURL)
                    .ignoresSafeArea(edges: .bottom)
                    .onDisappear {
                        if let url = selectedURL {
                            viewModel.loadMP3(from: url)
                        }
                    }
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            ColorPicker(selection: $viewModel.backgroundColor, label: { })
                .opacity(isCoverTapped ? 0 : 1)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
