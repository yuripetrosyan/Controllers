//
//  AudioModel.swift
//  MiniDJ
//
//  Created by Yuri Petrosyan on 13/06/2024.
//
import Foundation
import AVFoundation

class AudioModel {
    var audioPlayer: AVAudioPlayerNode?
    var audioFile: AVAudioFile?
    var audioEngine: AVAudioEngine?
    var timePitch: AVAudioUnitTimePitch?
    var reverbEffect: AVAudioUnitReverb?

    init() {
        setupAudioSession() // Call setupAudioSession during initialization
        setupAudio()
    }
    
    func setupAudioSession() {
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print("Failed to set audio session category and mode: \(error.localizedDescription)")
            }
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

    func updateAudioSettings(speed: Float, pitch: Float, reverb: Float, volume: Float) {
        timePitch?.rate = speed
        timePitch?.pitch = pitch * 100 // 100 cents is one semitone
        reverbEffect?.wetDryMix = reverb
        audioEngine?.mainMixerNode.outputVolume = volume
    }
}
