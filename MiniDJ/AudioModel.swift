//
//  AudioModel.swift
//  MiniDJ
//
//  Created by Yuri Petrosyan on 13/06/2024.


import Foundation
import AVFoundation
import UIKit
import Combine

class AudioModel: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayerNode?
    var audioFile: AVAudioFile?
    var audioEngine: AVAudioEngine?
    var timePitch: AVAudioUnitTimePitch?
    var reverbEffect: AVAudioUnitReverb?
    
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var isPlaying: Bool = false
    
    private var timer: Timer?

    override init() {
        super.init()
        setupAudioSession()
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

    func loadMP3(url: URL, completion: @escaping (UIImage?, String?) -> Void) {
        do {
            audioFile = try AVAudioFile(forReading: url)
            guard let audioEngine = audioEngine, let audioPlayer = audioPlayer, let audioFile = audioFile else { return }

            // Set the duration based on the file's length
            duration = TimeInterval(audioFile.length) / audioFile.processingFormat.sampleRate

            // Schedule the file for playback
            audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: nil)
            
            try audioEngine.start()
            audioPlayer.play()
            isPlaying = true

            startTimer()

            // Extract metadata (cover art, title, etc.)
            let asset = AVAsset(url: url)
            var coverArt: UIImage?
            var title: String?

            for item in asset.commonMetadata {
                if item.commonKey?.rawValue == "artwork", let data = item.dataValue {
                    coverArt = UIImage(data: data)
                } else if item.commonKey?.rawValue == "title", let stringValue = item.stringValue {
                    title = stringValue
                }
            }

            completion(coverArt, title)
        } catch {
            print("Error loading audio file: \(error.localizedDescription)")
            completion(nil, nil)
        }
    }

    private func startTimer() {
        stopTimer()  // Ensure no duplicate timers
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let nodeTime = self.audioPlayer?.lastRenderTime, let playerTime = self.audioPlayer?.playerTime(forNodeTime: nodeTime) else { return }
            self.currentTime = Double(playerTime.sampleTime) / playerTime.sampleRate
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateAudioSettings(speed: Float, pitch: Float, reverb: Float, volume: Float) {
        timePitch?.rate = speed
        timePitch?.pitch = pitch * 100 // 100 cents is one semitone
        reverbEffect?.wetDryMix = reverb
        audioEngine?.mainMixerNode.outputVolume = volume
    }

    func playPause() {
        guard let audioPlayer = audioPlayer else { return }

        if isPlaying {
            audioPlayer.pause()
            isPlaying = false
            stopTimer()  // Stop updating current time
        } else {
            audioPlayer.play()
            isPlaying = true
            startTimer()  // Resume updating current time
        }
    }

    func seek(to time: TimeInterval) {
        guard let audioPlayer = audioPlayer, let audioFile = audioFile else { return }

        audioPlayer.stop()  // Stop the player
        audioPlayer.scheduleFile(audioFile, at: nil, completionHandler: nil)  // Reschedule file
        audioPlayer.play(at: AVAudioTime(sampleTime: AVAudioFramePosition(time * audioFile.processingFormat.sampleRate), atRate: audioFile.processingFormat.sampleRate))  // Seek and play
        currentTime = time
        startTimer()  // Resume timer after seeking
    }
}
