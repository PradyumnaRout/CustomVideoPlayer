//
//  PlayerSliderView.swift
//  CustomVideoPlayer
//
//  Created by hb on 10/09/25.
//

import SwiftUI
import AVKit

struct PlayerSliderView: UIViewRepresentable {
    
    @Binding var value: Float
    @Binding var avPlayer: AVPlayer
    @Binding var isPlaying: Bool
    @Binding var currentPlayTime: CMTime?
    
    let timecodes: [Timecode]
        
    private var smallThumbImage: UIImage {
        createThumbImage(size: CGSize(width: 16, height: 16), color: .white)
    }
    
    func makeUIView(context: UIViewRepresentableContext<PlayerSliderView>) -> UISlider {
        let dashedSlider = DashedSlider(
            avPlayer: self.avPlayer, timecodes: timecodes
        )
        dashedSlider.maximumTrackTintColor = .clear
        dashedSlider.minimumTrackTintColor = .clear
        dashedSlider.setThumbImage(smallThumbImage, for: .normal)
        dashedSlider.value = value
        dashedSlider.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.changed(slider:)),
            for: .valueChanged
        )
        
        context.coordinator.addSliderValueTimeObserver(
            player: avPlayer
        )
        
        
        return dashedSlider
    }
    
    func updateUIView(
        _ uiView: UISlider,
        context: UIViewRepresentableContext<PlayerSliderView>
    ) {
        uiView.value = value
        // This line takes charge of refreshing the slider's visual representation.
        uiView.setNeedsDisplay()
    }
    
    func updateSliderValue() {
        let currentTime = avPlayer.currentTime()
        let duration = avPlayer.currentItem?.duration ?? CMTime.zero
        self.currentPlayTime = currentTime
        debugPrint("Target Time: \(currentTime)")
        print(" Value: \(value)")
        if !duration.isIndefinite {
            let value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            self.value = value
        }
    }
    
    private func createThumbImage(size: CGSize, color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
    }
    
    func makeCoordinator() -> Coordinator {
//        PlayerSliderView.Coordinator(parent1: self)
        Coordinator(parent1: self)
    }
    
    class Coordinator: NSObject {
        var parent: PlayerSliderView

        private var sliderTimeObserver: Any?
        
        init(parent1: PlayerSliderView) {
            parent = parent1
        }

        @objc func changed(slider: UISlider) {
            let duration = parent.avPlayer.currentItem?.duration.seconds ?? 0
            let targetTime = CMTime(seconds: Double(slider.value) * duration, preferredTimescale: 1)
//            debugPrint("Target Time: \(targetTime)")
            parent.avPlayer.seek(to: targetTime)
        }

        func addSliderValueTimeObserver(player: AVPlayer) {
            if sliderTimeObserver == nil {
                sliderTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { time in
                    self.parent.updateSliderValue()
                }
            }
        }
        
        func detachSliderValueTimeObserver() {
            if let observer = sliderTimeObserver {
                parent.avPlayer.removeTimeObserver(observer)
                sliderTimeObserver = nil
            }
        }
        
        deinit {
            detachSliderValueTimeObserver()
        }
    }
}
