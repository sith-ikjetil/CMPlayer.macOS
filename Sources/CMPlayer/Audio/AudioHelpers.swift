//
//  AudioHelpers.swift
//
//  (i): Helper functions/etc. that is used in audio decoding or playback.
//
//  Created by Kjetil Kr Solberg on 27-09-2024.
//  Copyright © 2024 Kjetil Kr Solberg. All rights reserved.
//
import Foundation
///
/// Validates if crossfade time is a valid crossfade time.
///
/// parameter ctis: Crossfade time in seconds.
///
/// returns: True if crossfade time is valid. False otherwise.
///
internal func isCrossfadeTimeValid(seconds: Int) -> Bool {    
    // if time (parameter seconds) is valid
    if seconds >= g_crossfadeMinTime && seconds <= g_crossfadeMaxTime {
        // return true
        return true
    }
    // time is invalid
    // return false
    return false
}
///
/// audio player protocol
/// 
protocol CmpAudioPlayerProtocol {
    var isPlaying: Bool { get }
    var isPaused: Bool { get }
    var hasPlayed: Bool { get }
    var timeElapsed: UInt64 { get }
    var duration: UInt64 { get }
    init(path: URL)
    func play() throws
    func stop()
    func pause()
    func resume()
    func seekToPos(position: UInt64)
    func setCrossfadeVolume(volume: Float, fadeDuration: UInt64)
    static func gatherMetadata(path: URL) throws -> CmpMetadata
}