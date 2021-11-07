//
//  SoundManager.swift
//  iRetro
//
//  Created by Max Nabokow on 2/19/21.
//

import AVFoundation

private let VLADUKHA_PLAY_SOUND = false

class SoundManager {
    static let shared = SoundManager()
    private init() {}

    func playTick() {
        var soundID: SystemSoundID = 0
        let fileURL = URL(fileURLWithPath: "/System/Library/Audio/UISounds/nano/TimerWheelMinutesDetent_Haptic.caf") as CFURL
        AudioServicesCreateSystemSoundID(fileURL, &soundID)
        DispatchQueue.main.debounced(target: self, after: 0.025) {
			if VLADUKHA_PLAY_SOUND{ AudioServicesPlaySystemSound(soundID)}
        }
    }

	func playTock() {
		if VLADUKHA_PLAY_SOUND{ AudioServicesPlaySystemSound(1104)}
	}
}
