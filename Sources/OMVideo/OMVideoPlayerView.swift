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
 
    init(player: AVPlayer) {
        super.init(frame: .zero)
        self.player = player
        self.backgroundColor = .black
        setup()

    }
    
    func setup() {
        playerLayer.contentsGravity = .resizeAspect
        playerLayer.videoGravity = .resizeAspect
//        playerLayer.cornerCurve = .continuous
//        playerLayer.cornerRadius = 12
    }
        
    required init?(coder: NSCoder) {
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
