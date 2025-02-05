//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import UIKit
import AVFoundation

public class OMVideoPlayerView: UIView {
    
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
 
    public init(player: AVPlayer) {
        super.init(frame: .zero)
        self.player = player
        self.backgroundColor = .black
        setup()

    }
    
    func setup() {
        playerLayer.contentsGravity = .center
        playerLayer.videoGravity = .resizeAspect
//        playerLayer.cornerCurve = .continuous
//        playerLayer.cornerRadius = 12
    }
        
    public required init?(coder: NSCoder) {
        fatalError("init coder was not implemented")
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    public override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
