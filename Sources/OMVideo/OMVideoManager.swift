// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import AVFoundation
import Combine

public enum OMVideoError: Error {
    case playerNotInitialized
}

public struct OMVideoState: Equatable {
    var isPlaying:Bool = false
    
    
    
    
}

public struct OMVideoPlayhead: Equatable {
    public var duration: CMTime = .zero
    public var playhead: CMTime = .zero
    public var percentage: Double { playhead.seconds / duration.seconds }
}

public class OMVideoManager: NSObject {

    public let isPlaying = CurrentValueSubject<Bool, Never>(false)
    public let playhead = CurrentValueSubject<OMVideoPlayhead, Never>(.init())
        
    public lazy var view = OMVideoPlayerView(player: queuePlayer)
    
    public var player: AVPlayer {
        queuePlayer
    }
    
    private var snapshotQueue = DispatchQueue(label: "videoPlayerSnapshots", qos: .userInteractive)
    private var videoQueue = DispatchQueue(label: "videoPlayerVideo", qos: .userInteractive)

//    private var queuePlayer = AVQueuePlayer(playerItem: nil)
    private var queuePlayer = AVPlayer(playerItem: nil)
    lazy var queueSeeker = AVPlayerSeeker(player: queuePlayer)
    
    private var looper: AVPlayerLooper? = nil
    
    private var playheadTimer: Timer?
    
    public var hasItem: Bool {
        queuePlayer.currentItem != nil
    }
    
    public func load(_ item: AVPlayerItem, at time: Double? = nil) {
        pause()
//        view.isHidden = true
        if let time {
            let seek = CMTime(seconds: time,
                              preferredTimescale: item.duration.timescale)
            item.seek(to: seek, completionHandler: nil)
        }
        queuePlayer.addObserver(self, forKeyPath:"status", options: [.old, .new], context: nil)
        queuePlayer.replaceCurrentItem(with: item)
//        self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item)
//        looper
//        if let time {
//            seek(toTime: time)
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            self.view.isHidden = false
//        }

    }
    
    public override class func observeValue(forKeyPath keyPath: String?,
                                            of object: Any?,
                                            change: [NSKeyValueChangeKey : Any]?,
                                            context: UnsafeMutableRawPointer?) {
        if let player = object as? AVPlayer, keyPath == "status" {
            switch player.status {
            case .unknown:
                print("unknown")
            case .failed:
                print("failed")
            case .readyToPlay:
                print("readyToPlay")
            default:
                break
            }
        }
    }
    
    public func play()  {
        
        queuePlayer.playImmediately(atRate: 1)
        isPlaying.value = true
        playheadTimer = Timer.scheduledTimer(withTimeInterval: 0.1,
                                             repeats: true,
                                             block: { _ in self.updatePlayhead() })
    }
    
    public func pause()  {

        queuePlayer.pause()
        isPlaying.value = false
        playheadTimer?.invalidate()
    }

    
    public func step(by count: Int = 1)   {
        
        pause()
        queuePlayer.currentItem?.step(byCount: count)
        
        updatePlayhead()
    }

    public func seek(to percentage: Double)  {
        guard let duration = queuePlayer.currentItem?.duration else { return }
        
        let newTime = duration.seconds * percentage
        let seek = CMTime(seconds: newTime,
                          preferredTimescale: duration.timescale)
        let tolerance = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        queueSeeker.seekSmoothly(to: seek, completion: { [weak self] in
            self?.updatePlayhead()
        })
    }
    
    public func seek(toTime time: Double)  {
        guard let duration = queuePlayer.currentItem?.duration else { return }
        
        let seek = CMTime(seconds: time,
                          preferredTimescale: duration.timescale)
        let tolerance = CMTime(seconds: 0, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        queueSeeker.seekSmoothly(to: seek, completion: { [weak self] in
            self?.updatePlayhead()
        })
        
    }

    
    public func speed(_ rate: Float)   {
        
        queuePlayer.rate = rate
        
        if !isPlaying.value {
             pause()
        }
        
    }
    
    
    private func updatePlayhead() {
        let duration = queuePlayer.currentItem?.duration ?? .zero
        let time = queuePlayer.currentTime()
        playhead.value = OMVideoPlayhead(duration: duration, playhead: time)
    }
}






extension OMVideoManager {
    public func nextFrame()  {
         step(by: 1)
    }
    
    public func previousFrame()  {
         step(by: -1)
    }
}





import AVFoundation

private var seekerKey = ""

public typealias SeekerCompletion = ()->Void
public extension AVPlayer {
    
    public func fl_seekSmoothly(to newChaseTime: CMTime, completion: (SeekerCompletion)? = nil) {
        guard newChaseTime.isValid, newChaseTime >= CMTime.zero else { return }
        var seeker = objc_getAssociatedObject(self, &seekerKey) as? AVPlayerSeeker
        if seeker == nil {
            seeker = AVPlayerSeeker(player: self)
            objc_setAssociatedObject(self, &seekerKey, seeker, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        seeker?.seekSmoothly(to: newChaseTime, completion: completion)
    }
    
    public func fl_currentTime() -> CMTime {
        if let seeker = objc_getAssociatedObject(self, &seekerKey) as? AVPlayerSeeker {
            if seeker.isSeekInProgress {
                return seeker.chaseTime
            }
        }
        return currentTime()
    }
    
}

open class AVPlayerSeeker {
    
    open weak var player: AVPlayer?
    fileprivate var isSeekInProgress = false
    fileprivate var chaseTime = CMTime.zero
    fileprivate var completions: [SeekerCompletion] = []
    
    public init(player: AVPlayer) {
        self.player = player
    }
    
    open func seekSmoothly(to newChaseTime: CMTime, completion: (SeekerCompletion)? = nil) {
        guard let player = player, let item = player.currentItem else {
            return
        }
        if newChaseTime > item.duration {
            return
        }
        if player.currentTime() != newChaseTime {
            chaseTime = newChaseTime
            if let c = completion {
                completions.append(c)
            }
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        } else {
            completion?()
        }
    }
    
    fileprivate var readyObservable: ReadyObservable?
    fileprivate func trySeekToChaseTime() {
        guard let player = player else {
            return
        }
        readyObservable?.cancel()
        readyObservable = nil
        if player.status == .readyToPlay {
            actuallySeekToTime()
        } else {
            readyObservable = ReadyObservable(player, { [weak self] in
                guard let s = self else { return }
                s.readyObservable = nil
                s.actuallySeekToTime()
            })
        }
    }
    
    fileprivate func actuallySeekToTime() {
        guard let player = player else {
            return
        }
        isSeekInProgress = true
        player.seek(to: chaseTime, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { [weak self] isFinished in
            guard let s = self, let player = s.player else { return }
            DispatchQueue.main.async {
                if abs(CMTimeSubtract(player.currentTime(), s.chaseTime).seconds) < 0.001 {
                    s.seekComplete()
                } else {
                    s.trySeekToChaseTime()
                }
            }
        })
    }
    
    fileprivate func seekComplete() {
        isSeekInProgress = false
        for c in self.completions {
            c()
        }
        self.completions.removeAll()
    }
}

private class ReadyObservable: NSObject {
    fileprivate var block: (() -> Void)
    fileprivate var player: AVPlayer
    fileprivate var isCancel: Bool = false
    init(_ player: AVPlayer, _ block: @escaping (() -> Void)) {
        self.block = block
        self.player = player
        super.init()
        player.addObserver(self, forKeyPath: "status", options: .new, context: nil)
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if isCancel {
            return
        }
        if keyPath == "status" {
            if player.status == .readyToPlay {
                block()
            }
        }
    }
    func cancel() {
        if isCancel {
            return
        }
        isCancel = true
    }
    deinit {
        player.removeObserver(self, forKeyPath: "status")
    }
}
