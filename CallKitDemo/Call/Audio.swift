//
//  Audio.swift
//  CallKitDemo
//
//  Created by Quang Tuan NGO on 2024-05-21.
//

import AVFoundation

func configureAudioSession() {
    print("Configuring audio session")
    let session = AVAudioSession.sharedInstance()
    do {
        try session.setCategory(.playAndRecord, mode: .voiceChat, options: [])
    } catch (let error) {
        print("Error while configuring audio session: \(error)")
    }
}

func startAudio() {
    print("Starting audio")
}

func stopAudio() {
    print("Stopping audio")
}
