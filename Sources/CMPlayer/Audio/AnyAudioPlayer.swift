// AudioPlayer.swift
// Created by Kjetil Kr Solberg on 24-09-2024.
// Copyright © 2024 Kjetil Kr Solberg. All rights reserved.
import Foundation
import AVFoundation
/// Local-file audio playback. All mutable playback state is serialized.
/// Retain the instance while playing; call stop() during application shutdown.
internal final class AnyAudioPlayer: CmpAudioPlayerProtocol, @unchecked Sendable {
    // path to file to play
    private let filePath: URL
    // queue for async work
    private let queue = DispatchQueue(label: "CMPlayer.AnyAudioPlayer")
    // player object from AVFoundation
    private var player: AVAudioPlayer?
    // timer
    private var timer: DispatchSourceTimer?
    // are we playing.
    private var m_isPlaying = false
    // are we paused
    private var m_isPaused = false
    // have we played
    private var m_hasPlayed = false
    // elapsed time since playing started
    private var m_timeElapsed: UInt64 = 0
    // duration of filePath media file
    private var m_duration: UInt64 = 0
    // target fade volume [0,1]
    private var m_targetFadeVolume: Float = 1
    // target fade duration ms
    private var m_targetFadeDuration: UInt64 = 0
    // should we do crossfade
    private var m_enableCrossfade = false
    // thread safe get is playing
    var isPlaying: Bool { queue.sync { m_isPlaying } }
    // thread safe get is paused
    var isPaused: Bool { queue.sync { m_isPaused } }
    // thread safe get has played
    var hasPlayed: Bool { queue.sync { m_hasPlayed } }
    // thread safe get time elapsed
    var timeElapsed: UInt64 {
        queue.sync {
            if let player, m_isPlaying {
                return min(Self.milliseconds(player.currentTime), m_duration)
            }
            return m_timeElapsed
        }
    }
    // thread safe get duration
    var duration: UInt64 { queue.sync { m_duration } }
    //
    // constructor
    //
    init(path: URL) 
    { 
        filePath = path 
    }
    //
    // destructor
    //
    deinit {
        // Pending handlers hold only weak references to this object.
        timer?.cancel()
        player?.stop()
    }
    //
    // Starts asynchronously after synchronously opening and preparing the file.
    //
    func play() throws {
        try queue.sync {
            if m_isPaused {
                guard let player, player.play() else {
                    throw CmpError(message: "[AnyAudioPlayer].play(). Could not resume playback.")
                }
                m_isPaused = false
                applyCrossfade()
                return
            }
            guard !m_isPlaying else { return }
            guard filePath.isFileURL else {
                throw CmpError(message: "[AnyAudioPlayer].play(). Expected a local file URL.")
            }

            let nextPlayer: AVAudioPlayer
            do {
                nextPlayer = try AVAudioPlayer(contentsOf: filePath)
            } catch {
                throw CmpError(message: "[AnyAudioPlayer].play(). Could not open \(filePath.path): \(error.localizedDescription)")
            }
            guard nextPlayer.duration.isFinite, nextPlayer.duration > 0,
                  nextPlayer.prepareToPlay() else {
                throw CmpError(message: "[AnyAudioPlayer].play(). Could not prepare audio or determine duration.")
            }
            nextPlayer.numberOfLoops = 0
            nextPlayer.volume = 1
            guard nextPlayer.play() else {
                throw CmpError(message: "[AnyAudioPlayer].play(). Could not start audio output.")
            }
            player = nextPlayer
            m_duration = Self.milliseconds(nextPlayer.duration)
            m_timeElapsed = 0
            m_hasPlayed = false
            m_isPaused = false
            m_isPlaying = true
            applyCrossfade()
            startTimer()
        }
    }
    /// Preserves the original implementation: position is milliseconds REMAINING.
    /// A position equal to duration seeks to the beginning; zero seeks to the end.
    func seekToPos(position: UInt64) {
        queue.sync {
            guard position <= m_duration, let player, m_isPlaying else { return }
            m_timeElapsed = m_duration - position
            player.currentTime = min(Double(m_timeElapsed) / 1000, player.duration)
            applyCrossfade()
            if position == 0 { finishPlayback() }
        }
    }
    /// Retained for interface compatibility. Scales little-endian signed 16-bit PCM.
    /// The buffer need not be aligned; a trailing partial sample is left unchanged.
    func adjustVolume(buffer: UnsafeMutablePointer<Int8>, size: Int, volume: Float) {
        guard size >= 2, volume.isFinite else { return }
        let factor = max(0, min(1, volume))
        for offset in stride(from: 0, to: size - 1, by: 2) {
            let bits = UInt16(UInt8(bitPattern: buffer[offset]))
                | (UInt16(UInt8(bitPattern: buffer[offset + 1])) << 8)
            let sample = Int16(bitPattern: bits)
            let scaled = Int16(max(Float(Int16.min), min(Float(Int16.max), Float(sample) * factor)))
            let result = UInt16(bitPattern: scaled)
            buffer[offset] = Int8(bitPattern: UInt8(truncatingIfNeeded: result))
            buffer[offset + 1] = Int8(bitPattern: UInt8(truncatingIfNeeded: result >> 8))
        }
    }
    /// Fades from full volume to the target during the final fadeDuration milliseconds.
    func setCrossfadeVolume(volume: Float, fadeDuration: UInt64) {
        guard volume.isFinite, volume >= 0, volume <= 1,
              let seconds = Int(exactly: fadeDuration / 1000),
              isCrossfadeTimeValid(seconds: seconds) else { return }
        queue.sync {
            m_targetFadeVolume = volume
            m_targetFadeDuration = fadeDuration
            m_enableCrossfade = true
            applyCrossfade()
        }
    }
    //
    // thread safe stop playback
    //
    func stop() {
        queue.sync {
            guard m_isPlaying else { return }
            finishPlayback()
        }
    }
    // 
    // thread safe pause playback
    //
    func pause() {
        queue.sync {
            guard m_isPlaying, !m_isPaused, let player else { return }
            m_timeElapsed = min(Self.milliseconds(player.currentTime), m_duration)
            player.pause()
            m_isPaused = true
            // isPlaying remains true during pause, matching the original state model.
        }
    }
    //
    // thread safe resume playback
    //
    func resume() {
        queue.sync {
            guard m_isPlaying, m_isPaused, let player else { return }
            if player.play() {
                m_isPaused = false
                applyCrossfade()
            } else {
                finishPlayback()
            }
        }
    }
    //
    // repeatable code to check for completion of playback
    //
    private func startTimer() {
        timer?.cancel()
        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now(), repeating: .milliseconds(20), leeway: .milliseconds(5))
        source.setEventHandler { [weak self] in
            guard let self, self.m_isPlaying, !self.m_isPaused,
                  let player = self.player else { return }
            self.m_timeElapsed = min(Self.milliseconds(player.currentTime), self.m_duration)
            if !player.isPlaying {
                // Polling works in a command-line app without a main run loop.
                self.finishPlayback()
            } else {
                self.applyCrossfade()
            }
        }
        timer = source
        source.resume()
    }
    //
    // apply crossfade
    //
    private func applyCrossfade() {
        guard let player else { return }
        guard m_enableCrossfade, m_targetFadeDuration > 0 else {
            player.volume = 1
            return
        }
        let remaining = max(0, player.duration - player.currentTime)
        let fraction = min(1, remaining / (Double(m_targetFadeDuration) / 1000))
        player.volume = m_targetFadeVolume + (1 - m_targetFadeVolume) * Float(fraction)
    }
    //
    // clean up after playback
    //
    private func finishPlayback() {
        timer?.cancel()
        timer = nil
        player?.stop()
        player = nil
        // Preserve the original terminal state for both stop and natural completion.
        m_timeElapsed = m_duration
        m_hasPlayed = true
        m_isPlaying = false
        m_isPaused = false
    }
    //
    // get time in ms
    //
    private static func milliseconds(_ seconds: Double) -> UInt64 {
        guard seconds.isFinite, seconds > 0 else { return 0 }
        let value = seconds * 1000
        return value < Double(UInt64.max) ? UInt64(value) : UInt64.max
    }
    /// Synchronous interface preserved; AVFoundation loads metadata on a detached task.
    /// This call blocks its caller while loading. For UI applications call it off the UI thread.
    static func gatherMetadata(path: URL) throws -> CmpMetadata {
        guard path.isFileURL else {
            throw CmpError(message: "[AnyAudioPlayer].gatherMetadata(). Expected a local file URL.")
        }
        let box = MetadataResult()
        Task.detached {
            do {
                box.complete(.success(try await loadMetadata(path: path)))
            } catch {
                box.complete(.failure(error))
            }
        }
        let snapshot: MetadataSnapshot
        do {
            snapshot = try box.wait()
        } catch {
            throw CmpError(message: "[AnyAudioPlayer].gatherMetadata(). \(path.path): \(error.localizedDescription)")
        }
        let metadata = CmpMetadata()
        metadata.duration = snapshot.duration
        if let value = snapshot.values["artist"] { metadata.artist = value }
        if let value = snapshot.values["title"] { metadata.title = value }
        if let value = snapshot.values["album"] { metadata.albumName = value }
        if let value = snapshot.values["genre"] { metadata.genre = extractMetadataGenre(text: value) }
        if let value = snapshot.values["track"] { metadata.trackNo = extractMetadataTrackNo(text: value) }
        if let value = snapshot.values["year"] { metadata.recordingYear = extractMetadataYear(text: value) }
        return metadata
    }
    //
    // MetadataSnapshot
    //
    private struct MetadataSnapshot: Sendable {
        let duration: UInt64
        let values: [String: String]
    }
    //
    // MetadataResult
    //
    private final class MetadataResult: @unchecked Sendable {
        private let semaphore = DispatchSemaphore(value: 0)
        private let lock = NSLock()
        private var result: Result<MetadataSnapshot, Error>?

        func complete(_ result: Result<MetadataSnapshot, Error>) {
            lock.lock()
            self.result = result
            lock.unlock()
            semaphore.signal()
        }

        func wait() throws -> MetadataSnapshot {
            semaphore.wait()
            lock.lock()
            defer { lock.unlock() }
            return try result!.get()
        }
    }
    //
    // load metadata from path.
    //
    private static func loadMetadata(path: URL) async throws -> MetadataSnapshot {
        let asset = AVURLAsset(url: path)
        let duration = try await asset.load(.duration).seconds
        guard duration.isFinite, duration > 0 else {
            throw CmpError(message: "Cannot determine audio duration.")
        }
        guard !(try await asset.loadTracks(withMediaType: .audio)).isEmpty else {
            throw CmpError(message: "No audio track found.")
        }
        var items = try await asset.load(.commonMetadata)
        for format in try await asset.load(.availableMetadataFormats) {
            items.append(contentsOf: try await asset.loadMetadata(for: format))
        }
        var values: [String: String] = [:]
        for item in items {
            // Match common metadata and native ID3/iTunes identifiers and keys.
            let identifier = item.identifier?.rawValue.lowercased() ?? ""
            let key = (item.key as? String)?.lowercased() ?? ""
            let common = item.commonKey?.rawValue.lowercased() ?? ""
            let tokens = [common, key, identifier.components(separatedBy: "/").last ?? ""]
            func matches(_ names: [String]) -> Bool { tokens.contains { names.contains($0) } }
            let field: String
            if matches(["artist", "tpe1", "©art"]) { field = "artist" }
            else if matches(["title", "tit2", "©nam"]) { field = "title" }
            else if matches(["albumname", "album", "talb", "©alb"]) { field = "album" }
            else if matches(["type", "genre", "tcon", "©gen", "gnre", "usergenre"]) { field = "genre" }
            else if matches(["track", "tracknumber", "trck", "trkn"]) { field = "track" }
            else if matches(["creationdate", "year", "date", "time", "tyer", "tdrc", "©day", "recordingtime"]) { field = "year" }
            else { continue }
            guard values[field] == nil else { continue }

            // iTunes track and numeric genre tags can contain binary data.
            if field == "track", matches(["trkn", "tracknumber"]),
               let data = try await item.load(.dataValue), data.count >= 4 {
                let bytes = [UInt8](data)
                values[field] = String((UInt16(bytes[2]) << 8) | UInt16(bytes[3]))
            } else if field == "genre", matches(["gnre"]),
                      let data = try await item.load(.dataValue), data.count >= 2 {
                let bytes = [UInt8](data)
                let index = (UInt16(bytes[0]) << 8) | UInt16(bytes[1])
                if index > 0 { values[field] = "(\(index - 1))" }
            } else if let text = try await item.load(.stringValue), !text.isEmpty {
                values[field] = text
            } else if let number = try await item.load(.numberValue) {
                values[field] = number.stringValue
            } else if field == "year", let date = try await item.load(.dateValue) {
                values[field] = String(Calendar(identifier: .gregorian).component(.year, from: date))
            }
        }
        // Untagged files still have a duration and the existing default metadata fields.
        return MetadataSnapshot(duration: milliseconds(duration), values: values)
    }
}
