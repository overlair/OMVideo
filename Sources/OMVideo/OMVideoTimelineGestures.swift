//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import Foundation
import SwiftUI

@available(iOS 13.0.0, *)
struct OMVideoTimelineGestures: UIViewRepresentable {
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

enum VideoScanEvent {
    case scrub(Double)
    case start
    case end
}

import Combine
@available(iOS 13.0, *)
struct ScanGestureRepresentable: UIViewRepresentable {
    var event: PassthroughSubject<VideoScanEvent,Never>

    func makeUIView(context: Context) -> some UIView {
        let v = UIView()
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.tap))
        let pan = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.pan))
//        pan.minimumPressDuration = 0.1
//
        v.addGestureRecognizer(pan)
        v.addGestureRecognizer(tap)
        return v
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(event: event)
    }
    
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var event: PassthroughSubject<VideoScanEvent,Never>
        var throttle = PassthroughSubject<Double,Never>()
//        var panLocation = CurrentValueSubject<Double,Never>(0.5)
        var timer: Timer?
        
        var cancellables = Set<AnyCancellable>()
        
        init(event: PassthroughSubject<VideoScanEvent,Never>) {
            self.event = event
            super.init()
            setup()
        }
        
        func setup() {
            throttle
                .throttle(for: 0.1, scheduler: RunLoop.main, latest: true)
                .sink(receiveValue: handleThrottle)
                .store(in: &cancellables)
        }
        
        func handleThrottle(_ scrub: Double) {
            event.send(.scrub(scrub))
        }
        
        
        @objc func tap(gesture: UITapGestureRecognizer) {
            guard let viewWidth = gesture.view?.frame.width else { return }
            let tapWidth = gesture.location(in: gesture.view).x
            event.send(.scrub(tapWidth / viewWidth))
        }
        
        @objc func pan(gesture: UIPanGestureRecognizer) {
            switch gesture.state {
            case .began:
                event.send(.start)
                guard let viewWidth = gesture.view?.frame.width else { return }
                let tapWidth = gesture.location(in: gesture.view).x
                throttle.send(tapWidth / viewWidth)
         
            case .changed:
                guard let viewWidth = gesture.view?.frame.width else { return }
                let tapWidth = gesture.location(in: gesture.view).x
                throttle.send(tapWidth / viewWidth)
            case .ended, .cancelled:
                event.send(.end)

            default: break
                
            }
          
        }
    }
}
