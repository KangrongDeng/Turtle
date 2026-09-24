//
//  MusicManager.swift
//  Turtle
//
//  Created by Heyya on 2/27/26.
//

import AVFoundation
import Combine

final class MusicManager: ObservableObject {
    static let shared = MusicManager()

    private var player: AVAudioPlayer?

    func startLoop(filename: String, volume: Float = 0.7) {
        if player?.isPlaying == true { return }

        guard let url = Bundle.main.url(forResource: filename, withExtension: nil) else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)

            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = volume
            p.prepareToPlay()
            p.play()
            player = p
        } catch {
            print("BGM error:", error)
        }
    }

    func stop() {
        player?.stop()
        player = nil
    }

    func setVolume(_ v: Float) {
        player?.volume = v
    }
}
