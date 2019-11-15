//
//  MusicPlayer.swift
//  HyperCasual
//
//  Created by Yu Wang on 2019/10/23.
//  Copyright © 2019 Yu Wang. All rights reserved.
//

import Foundation
import AVFoundation

class MusicPlayer {
    static let shared = MusicPlayer()
    
    var audioPlayer: AVAudioPlayer?
    
    var soundEffect: AVAudioPlayer?
    
    private init() {}

    func startBackgroundMusic() {
        if !GameController.shared.isSoundOn { return }
        if let bundle = Bundle.main.path(forResource: "background", ofType: "mp3") {
            let backgroundMusic = NSURL(fileURLWithPath: bundle)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                guard let audioPlayer = audioPlayer else { return }
                audioPlayer.numberOfLoops = -1
                audioPlayer.prepareToPlay()
                audioPlayer.play()
            } catch {
                print(error)
            }
        }
    }
    
    func stopBackgroundMusic() {
        guard let audioPlayer = audioPlayer else { return }
        audioPlayer.stop()
    }
    
    func playSoundEffect() {
        if !GameController.shared.isSoundOn { return }
        if let bundle = Bundle.main.path(forResource: "soundEffect", ofType: "wav") {
            let soundEffectUrl = NSURL(fileURLWithPath: bundle)
            do {
                soundEffect = try AVAudioPlayer(contentsOf:soundEffectUrl as URL)
                guard let soundEffect = soundEffect else { return }
                soundEffect.volume = 0.5
                soundEffect.play()
            } catch {
                print(error)
            }
        }
    }
}
