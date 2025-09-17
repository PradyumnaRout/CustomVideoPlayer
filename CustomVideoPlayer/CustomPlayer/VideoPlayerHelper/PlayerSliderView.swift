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
    @Binding var isEditingSlider: Bool
    
    @Binding var playFromPausePoint: Bool
    @Binding var currentTimeText: String
    @Binding var isPlayerFullScreen: Bool
    
    let timecodes: [Timecode]
        
    private var smallThumbImage: UIImage {
        createThumbImage(size: CGSize(width: 16, height: 16), color: .white)
    }
    
    func makeUIView(context: UIViewRepresentableContext<PlayerSliderView>) -> UISlider {
        
        let dashedSlider = DashedSliderView()
        dashedSlider.totalDuration = CMTimeGetSeconds(avPlayer.currentItem?.asset.duration ?? CMTime(seconds: 0, preferredTimescale: 1))
        dashedSlider.timecodes =  timecodes
        dashedSlider.viewedProgress = CGFloat(avPlayer.currentTime().seconds / dashedSlider.totalDuration)
        dashedSlider.maximumTrackTintColor = .clear
        dashedSlider.minimumTrackTintColor = .clear
        dashedSlider.setThumbImage(smallThumbImage, for: .normal)
        dashedSlider.value = value
        dashedSlider.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.changed(slider:)),
            for: .valueChanged
        )
        
        // Detect when user starts dragging
        dashedSlider.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.sliderTouchBegan),
            for: .touchDown
        )
        
        // Detect when user finishes dragging
        dashedSlider.addTarget(
            context.coordinator,
            action: #selector(context.coordinator.sliderTouchEnded),
            for: [.touchUpInside, .touchUpOutside, .touchCancel]
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
        if !isEditingSlider {
            uiView.value = value
            uiView.setNeedsDisplay()
        }
    }
    
    func updateSliderValue() {
        let currentTime = avPlayer.currentTime()
        let duration = avPlayer.currentItem?.duration ?? CMTime.zero
        self.currentPlayTime = currentTime
//        debugPrint("Target Time: \(currentTime)")
//        print(" Value: \(value)")
        if !duration.isIndefinite {
            let value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            self.value = value
        }
        
        
        
        if self.playFromPausePoint {
            print("Inside Current Time")
            if let currentPlayTime = self.currentPlayTime,
               currentPlayTime != .zero,
               let duration = self.avPlayer.currentItem?.duration.seconds,
               !self.isPlayerFullScreen,
               duration > 0 {
                let currentTimeInSeconds = currentPlayTime.seconds
                self.currentTimeText = formatTime(currentTimeInSeconds)
            }
        } else if let duration = self.avPlayer.currentItem?.duration.seconds {
            let currentTimeInSeconds = Double(self.value) * duration
            self.currentTimeText = formatTime(currentTimeInSeconds)
        } else {
            self.currentTimeText = "00.00"
        }

    }
    
    private func createThumbImage(size: CGSize, color: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { context in
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.fillEllipse(in: rect)
        }
    }
    
    private func formatTime(_ timeInSeconds: Double) -> String {
        if timeInSeconds.isFinite {
            let hours = Int(timeInSeconds) / 3600
            let minutes = (Int(timeInSeconds) % 3600) / 60
            let seconds = Int(timeInSeconds) % 60
            
            if hours > 0 {
                return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
            } else {
                return String(format: "%02d:%02d", minutes, seconds)
            }
        } else {
            return "00:00"
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
            debugPrint("Target Time slider change: \(targetTime)")
            parent.avPlayer.seek(to: targetTime)
            
            // Instead of calling updateSliderValue() which updates `value`, only update currentTimeText
            if parent.isEditingSlider {
                if let duration = parent.avPlayer.currentItem?.duration.seconds {
                    let currentTimeInSeconds = Double(slider.value) * duration
                    parent.currentTimeText = parent.formatTime(currentTimeInSeconds)
                }
            }
        }
        
        @objc func sliderTouchBegan(slider: UISlider) {
            parent.isEditingSlider = true
        }
        
        @objc func sliderTouchEnded(slider: UISlider) {
            parent.isEditingSlider = false
            
            let duration = parent.avPlayer.currentItem?.duration.seconds ?? 0
            let targetTime = CMTime(seconds: Double(slider.value) * duration, preferredTimescale: 1)
            parent.avPlayer.seek(to: targetTime)
            self.parent.updateSliderValue()
        }
        

        func addSliderValueTimeObserver(player: AVPlayer) {
            if sliderTimeObserver == nil {
                sliderTimeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1), queue: .main) { [weak self] time in
                    guard let self = self else { return }
                    if self.parent.isEditingSlider == false {
                        self.parent.updateSliderValue()
                    }
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
