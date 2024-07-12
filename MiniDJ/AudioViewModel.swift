import SwiftUI
import Combine

class AudioViewModel: ObservableObject {
    @Published var speed: Float = 1.0
    @Published var reverb: Float = 0.0
    @Published var pitch: Float = 0.0
    @Published var volume: Float = 1.0
    @Published var coverArt: UIImage?
    @Published var title: String?
    
    private let audioModel = AudioModel()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $speed
            .sink { [weak self] newValue in
                self?.audioModel.updateAudioSettings(speed: newValue, pitch: self?.pitch ?? 0, reverb: self?.reverb ?? 0, volume: self?.volume ?? 1)
            }
            .store(in: &cancellables)
        
        $reverb
            .sink { [weak self] newValue in
                self?.audioModel.updateAudioSettings(speed: self?.speed ?? 1, pitch: self?.pitch ?? 0, reverb: newValue, volume: self?.volume ?? 1)
            }
            .store(in: &cancellables)
        
        $pitch
            .sink { [weak self] newValue in
                self?.audioModel.updateAudioSettings(speed: self?.speed ?? 1, pitch: newValue, reverb: self?.reverb ?? 0, volume: self?.volume ?? 1)
            }
            .store(in: &cancellables)
        
        $volume
            .sink { [weak self] newValue in
                self?.audioModel.updateAudioSettings(speed: self?.speed ?? 1, pitch: self?.pitch ?? 0, reverb: self?.reverb ?? 0, volume: newValue)
            }
            .store(in: &cancellables)
    }
    
    func resetSpeed() {
        speed = 1.0
    }
    
    func resetReverb() {
        reverb = 0.0
    }
    
    func resetPitch() {
        pitch = 0.0
    }
    
    func resetVolume() {
        volume = 1.0
    }
    
  
    
    func loadMP3(from url: URL) {
        audioModel.loadMP3(url: url) { [weak self] coverArt, title in
            DispatchQueue.main.async {
                self?.coverArt = coverArt
                self?.title = title
                
            }
        }
    }
    
    func loadMockMP3() {
         if let url = Bundle.main.url(forResource: "CHIHIRO", withExtension: "mp3") {
             loadMP3(from: url)
         }
     }
     
    
    
    func updateSpeed(_ value: Float) {
        speed = value
    }
    
    func updateReverb(_ value: Float) {
        reverb = value
    }
    
    func updatePitch(_ value: Float) {
        pitch = value
    }
    
    func updateVolume(_ value: Float) {
        volume = value
    }
}
