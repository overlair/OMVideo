//
//  File 2.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import SwiftUI
import AVFoundation

@available(iOS 13.0.0, *)
struct OMVideoPlayerRepresentable: UIViewRepresentable{
                
        let view: OMVideoPlayerView
    
        func makeUIView(context: Context) -> OMVideoPlayerView {
            view
        }
        
    func updateUIView(_ uiView: OMVideoPlayerView, context: Context) { }
}

