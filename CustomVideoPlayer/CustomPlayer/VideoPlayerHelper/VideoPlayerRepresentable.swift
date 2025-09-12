//
//  VideoPlayerRepresentable.swift
//  CustomVideoPlayer
//
//  Created by hb on 10/09/25.
//

// Briding SwiftUI and UIKit with UIViewRepresentable

import SwiftUI
import AVKit

struct VideoPlayer: UIViewControllerRepresentable {
    
    @Binding var player: AVPlayer
    
    func makeUIViewController(context:
                              UIViewControllerRepresentableContext<VideoPlayer>) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    func updateUIViewController(
        _ uiViewController: AVPlayerViewController,
        context: UIViewControllerRepresentableContext<VideoPlayer>
    ) {
    }
}
