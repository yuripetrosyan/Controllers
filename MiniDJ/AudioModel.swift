//
//  AudioModel.swift
//  MiniDJ
//
//  Created by Yuri Petrosyan on 13/06/2024.

import AVFoundation

class AudioModel {
    private var audioPlayer: AVAudioPlayerNode?
    private var audioFile: AVAudioFile?
    private var audioEngine: AVAudioEngine?
    private var timePitch: AVAudioUnitTimePitch?
    private var reverbEffect: AVAudioUnitReverb?

    init() {
        setupAudio()
    }

    func setupAudio() {
        audioEngine = AVAudioEngine()
        audioPlayer = AVAudioPlayerNode()
        timePitch = AVAudioUnitTimePitch()
        reverbEffect = AVAudioUnitReverb()

        guard let audioEngine = audioEngine, let audioPlayer = audioPlayer, let timePitch = timePitch, let reverbEffect = reverbEffect else { return }

        audioEngine.attach(audioPlayer)
        audioEngine.attach(timePitch)
        audioEngine.attach(reverbEffect)

        audioEngine.connect(audioPlayer, to: timePitch, format: nil)
        audioEngine.connect(timePitch, to: reverbEffect, format: nil)
        audioEngine.connect(reverbEffect, to: audioEngine.mainMixerNode, format: nil)
    }

    func loadMP3(url: URL) {
        do {
            audioFile = try AVAudioFile(forReading: url)
            guard let audioEngine = audioEngine, let audioPlayer = audioPlayer, let audioFile = audioFile else { return }

            audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: nil)
            try audioEngine.start()
            audioPlayer.play()
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
        }
    }

    func updateSpeed(_ value: Float) {
        timePitch?.rate = value
    }

    func updateReverb(_ value: Float) {
        reverbEffect?.wetDryMix = value
    }

    func updatePitch(_ value: Float) {
        timePitch?.pitch = value
    }

    func updateVolume(_ value: Float) {
        audioEngine?.mainMixerNode.outputVolume = value
    }
}
