// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import AVFoundation

class OMVideoManager: NSObject {
    var snapshotQueue = DispatchQueue(label: "videoPlayerSnapshots", qos: .userInteractive)
    var videoQueue = DispatchQueue(label: "videoPlayerVideo", qos: .userInteractive)

    var queuePlayer: AVQueuePlayer? = nil
    var looper: AVPlayerLooper? = nil

    var state: OMVideoState = OMVideoState()
    
    
    var isPlaying = false
    var rate: Float = 1
    var duration: Double = 0
    var playhead: Double = 0
    var playheadTimer: Timer?
    
    
    func load(_ item: AVPlayerItem) {
        let queuePlayer = AVQueuePlayer(playerItem: item)
        self.queuePlayer = queuePlayer
        self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        self.duration = item.duration.seconds
    }
    
    func play() {
        queuePlayer?.playImmediately(atRate: rate)
        isPlaying = true
        playheadTimer = Timer.scheduledTimer(withTimeInterval: 0.1,
                                             repeats: true,
                                             block: { _ in self.updatePlayhead() })
    }
    
    func pause() {
        self.queuePlayer?.pause()
        isPlaying = false
        playheadTimer?.invalidate()
    }

    
    func stepBy(_ count: Int = 1) {
        pause()
        queuePlayer?.currentItem?.step(byCount: count)
        updatePlayhead()
    }

    private func updatePlayhead() {
        
    }
    func speed(_ rate: Float) {
        self.rate = rate
        queuePlayer?.rate = rate
        
        if !isPlaying {
            pause()
        }
    }
}






extension OMVideoManager {
    func nextFrame() {
        stepBy(1)
    }
    
    func previousFrame() {
        stepBy(-1)
    }
}
