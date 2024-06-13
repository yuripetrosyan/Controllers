import SwiftUI
import Combine
import AVFoundation

class AudioViewModel: ObservableObject {
    @Published var speed: Float = 1.0
    @Published var reverb: Float = 0.0
    @Published var pitch: Float = 0.0
    @Published var volume: Float = 1.0

    private var audioModel = AudioModel()
    private var cancellables = Set<AnyCancellable>()

    init() {
        setupObservers()
    }

    private func setupObservers() {
        $speed
            .sink { [weak self] newValue in
                self?.audioModel.updateSpeed(newValue)
            }
            .store(in: &cancellables)

        $reverb
            .sink { [weak self] newValue in
                self?.audioModel.updateReverb(newValue)
            }
            .store(in: &cancellables)

        $pitch
            .sink { [weak self] newValue in
                self?.audioModel.updatePitch(newValue)
            }
            .store(in: &cancellables)

        $volume
            .sink { [weak self] newValue in
                self?.audioModel.updateVolume(newValue)
            }
            .store(in: &cancellables)
    }

    func loadMP3(from url: URL) {
        audioModel.loadMP3(url: url)
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
