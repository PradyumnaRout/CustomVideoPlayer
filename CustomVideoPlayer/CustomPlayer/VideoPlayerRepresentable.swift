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
    
    // Binding vaiable for AVPlayer
    @Binding var player: AVPlayer
    
    //create and configure the underlying UIKit View/ViewController
    func makeUIViewController(
        context: UIViewControllerRepresentableContext<VideoPlayer>
    ) -> AVPlayerViewController  {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = false
        return controller
    }
    
    // Keep the UIKit View/ViewController in sync with SwiftUI’s data.
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: UIViewControllerRepresentableContext<VideoPlayer>) {
        
    }
    
}
