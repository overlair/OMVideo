//
//  File.swift
//  
//
//  Created by John Knowles on 7/13/24.
//

import SwiftUI
import Combine
import AVFoundation

@available(iOS 13.0.0, *)
struct OMVideoTimelineView: View {
    var body: some View {
        EmptyView()
    }
}




//struct VideoPlayerScanBar: View{
//    let item: AVPlayerItem
//    let scanEvents: PassthroughSubject<VideoScanEvent, Never>
//    let playheadValue: Value<Double>
//
//    // playhead callback
//    
//    
//    struct ThumbnailView: View {
//        let item: AVPlayerItem
//        let size: CGSize
//        @State var thumbnailImages: [ThumbnailImage] = []
//        let thumbnailImageCallback = Message<ThumbnailImage>()
//        
//        let fetchQueue = DispatchQueue(label: "VideoPlayerScanBar", qos: .default)
//        let fetchOperations = OperationQueue()
//        
//        var throttle: AnyPublisher<[ThumbnailImage], Never> {
//            
//            thumbnailImageCallback.handler
//                .collect(4)
//                .eraseToAnyPublisher()
//        }
//
//        struct ThumbnailImage: Identifiable, Equatable {
//            let id = UUID()
//            let image: UIImage
//            let timestamp: CMTime
//        }
//        
//        
//        init(item: AVPlayerItem, size: CGSize) {
//            self.item = item
//            self.size = size
//            
//            fetchOperations.qualityOfService = .default
//            fetchOperations.maxConcurrentOperationCount = 20
//        }
//        
//        var body: some View {
//            Group {
//                if thumbnailImages.isEmpty {
//                    ProgressView()
//                        .opacity(0.5)
//                } else {
//                    H {
//                        ForEach(thumbnailImages) { thumbnail in
//                            Image(uiImage: thumbnail.image)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: (size.width - 8) / CGFloat(thumbnailImages.count))
//                                .frame(height: size.height - 8)
//                            
//                        }
//                    }
//                    .transition(.move(edge: .leading).combined(with: .opacity))
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background {
//                        Color(UIColor.systemGray4).opacity(0.6)
//                    }
//                    .rounded()
//                    .shadow(color: Color(UIColor.systemGray3).opacity(0.5), radius: 2)
//                    .padding(4)
//                }
//            }
//            .task(id: item, priority: .high,  loadThumbnailImages)
//            .onReceive(throttle, perform: handleNewImages)
//        }
//        
//        @Sendable func loadThumbnailImages() async {
//            guard thumbnailImages.isEmpty else { return }
//            let numberImages: CGFloat = 16
//            
//            let imageGenerator = AVAssetImageGenerator(asset: item.asset)
//            imageGenerator.appliesPreferredTrackTransform = true
//            let duration = item.duration.seconds
//            let incrementer = duration / numberImages
//            let times: [CMTime]  = (0...Int(numberImages)).map {
//                CMTime(seconds: incrementer * Double($0),
//                       preferredTimescale: CMTimeScale(NSEC_PER_SEC))
//            }
//            
//            
//            //            let values: [NSValue] = times.map { NSValue(time: $0) }
//            
//            fetchQueue.async {
//                let values: [NSValue] = times.map { NSValue(time: $0) }
//                
//                imageGenerator.generateCGImagesAsynchronously(forTimes: values) { time, image, time2, result, error in
//                    if let cgImage = image {
//                        
//                        fetchOperations.addOperation {
//                            
//                            let image = UIImage(cgImage: cgImage)
//                                .resize(scaledToWidth: CGFloat(cgImage.width / 16))
//                            handleNewImage(ThumbnailImage(image: image, timestamp: time))
//                        }
//                    }
//                }
//                
//            }
//        }
//        
//        
//        func handleNewImages(_ images: [ThumbnailImage]) {
//            guard images.isNotEmpty else { return }
//            var copy = thumbnailImages
//            copy.append(contentsOf: images)
//            copy = copy.sorted(by: { $0.timestamp < $1.timestamp })
//            withAnimation {
//                thumbnailImages = copy
//            }
//        }
//        
//        func handleNewImage(_ image: ThumbnailImage) {
//            DispatchQueue.main.async {
//                thumbnailImageCallback.send(image)
//            }
//        }
//    }
//    
//    
//    struct TimeView: View {
//        let playheadValue: Value<Double>
//        let duration: Double
//        
//        @State var playhead: Double = 0
//
//        var body: some View {
//            let start = (playhead * duration).asString(style: .positional)
//            let end = duration.asString(style: .positional)
//            
//            H {
//                Text(start)
//                    .monospacedDigit()
//                    .font(Font.system(size: 12, weight: .semibold, design: .rounded))
//                Spacer()
//                Text(end)
//                    .monospacedDigit()
//                    .font(Font.system(size: 12, weight: .semibold, design: .rounded))
//                
//            }
//            .foregroundStyle(Color(UIColor.systemGray2))
//            .opacity(0.8)
//            .padding(.horizontal, 10)
//            .offset(y: 20)
//            .onReceive(playheadValue.handler, perform: { value in
//                DispatchQueue.main.async {
//                    playhead = value
//                }
//            })
//        }
//    }
//    struct HandleView: View {
//        let playheadValue: Value<Double>
//        let size: CGSize
//        // playhead callback
//        @State var playhead: Double = 0
//
//        var body: some View {
//
//            Z(alignment: .leading) {
//                Rectangle()
//                    .fill(Color(UIColor.systemGray5))
//                
//                    .scaleEffect(x: playhead, anchor: .leading)
//                    .rounded()
//                
//                    .opacity(0.7)
//                
//                
//                    .overlay(alignment: .leading) {
//                        let offset = min(max(size.width * playhead, 4),  size.width - 8)
//                        Rectangle()
//                            .fill(Color(UIColor.systemGray))
//                            .opacity(0.9)
//                            .frame(width: 8)
//                            .rounded()
//                            .offset(x: offset)
//                            .scaleEffect(y: 1.1)
//                    }
//            }
//            .onReceive(playheadValue.handler, perform: { value in
//                DispatchQueue.main.async {
//                    withAnimation { playhead = value }
//                }
//            })
//
//        }
//    }
//    
//    
//    var body: some View {
//        GeometryReader { geo in
//            Z {
//                
//                RoundedRectangle(cornerRadius: 12, style: .continuous)
//                    .fill(Color(UIColor.systemGray5).opacity(0.6))
//                    .shadow(color: Color(UIColor.systemGray3).opacity(0.8), radius: 4)
//                    .allowsHitTesting(false)
//
//                    ThumbnailView(item: item, size: geo.size)
//                            .id("VideoPlayerScanBarThumbnails")
//                            .allowsHitTesting(false)
//                    HandleView(playheadValue: playheadValue, size: geo.size)
//                            .allowsHitTesting(false)
//                            .id("VideoPlayerScanBarHandle")
//                }
//               
//                .contentShape(Rectangle())
////                .overlay {
////                    ScanGestureRepresentable(event: scanEvents)
////                }
//        }
//        .overlay(alignment: .bottom) {
//            TimeView(playheadValue: playheadValue, duration: item.duration.seconds)
//                .id("VideoPlayerScanBarTime")
//                .allowsHitTesting(false)
//
//        }
//        .background {
//            ScanGestureRepresentable(event: scanEvents)
//                .allowsHitTesting(true)
//        }
//    }
//    
//   
//}
