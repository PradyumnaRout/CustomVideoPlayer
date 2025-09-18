//
//  DashedSlider.swift
//  CustomVideoPlayer
//
//  Created by hb on 10/09/25.
//

import SwiftUI
import Foundation
import AVKit

class DashedSliderView: UISlider {
    
    // Timecodes to show dashed markers
    var timecodes: [Timecode] = []
    
    // Current progress (0.0 - 1.0)
    var viewedProgress: CGFloat = 0.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Total Duration in seconds
    var totalDuration: Double = 1.0 {
        didSet { setNeedsDisplay() }
    }
    
    let dashHeight: CGFloat = 4.0
    let timeCodeColor = UIColor.black.cgColor
    let trackLineColor = UIColor.gray.cgColor
    let viewedColor = UIColor.white.cgColor
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let progress = CGFloat((self.value - self.minimumValue) / (self.maximumValue - self.minimumValue))
        let viewedX = rect.size.width * progress
        
        // Base Track
        context.setFillColor(trackLineColor)
        let trackLineRect = CGRect(x: 0, y: (rect.size.height - dashHeight) / 2, width: rect.size.width, height: dashHeight)
        context.fill(trackLineRect)
        
        // Viewed Progress Track
        context.setFillColor(viewedColor)
        let viewedLineRect = CGRect(x: 0, y: (rect.size.height - dashHeight) / 2, width: viewedX, height: dashHeight)
        context.fill(viewedLineRect)
        
        // Timecode Markers
        for timecode in timecodes {
            guard totalDuration > 0 else { continue }
            let x = CGFloat(timecode.time.seconds / totalDuration) * rect.size.width
            let dashRect = CGRect(x: x, y: (rect.size.height - dashHeight) / 2, width: 3, height: dashHeight)
            context.setFillColor(timeCodeColor)
            context.fill(dashRect)
        }
    }
}


//class DashedSlider: UISlider {
//    
//    var avPlayer: AVPlayer
//    let timecodes: [Timecode]
//    
//    init(avPlayer: AVPlayer, timecodes: [Timecode]) {
//        self.avPlayer = avPlayer
//        self.timecodes = timecodes
//        super.init(frame: .zero)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    let dashHeight: CGFloat = 4.0
//    let timeCodeColor = UIColor(.black).cgColor
//    let trackLine = UIColor.gray.cgColor
//    let viewedColor = UIColor.white.cgColor
//    
//    override func draw(_ rect: CGRect) {
//        let context = UIGraphicsGetCurrentContext()
//        
//        let viewedX = rect.size.width * CGFloat(value)
//        
//        // Slider Color
//        context?.setFillColor(trackLine)
//        let trackLine = CGRect(x: 0, y: (rect.size.height - dashHeight) / 2, width: rect.size.width, height: dashHeight)
//        context?.fill(trackLine)
//        
//        // Viewed slider color
//        context?.setFillColor(viewedColor)
//        let viewedLine = CGRect(x: 0, y: (rect.size.height - dashHeight) / 2, width: viewedX, height: dashHeight)
//        context?.fill(viewedLine)
//        
//        let totalDuration = CMTimeGetSeconds(
//            avPlayer.currentItem?.asset.duration ?? CMTime(seconds: 0, preferredTimescale: 1)
//        )
//        
//        for timecode in timecodes {
//            let x = CGFloat(timecode.time.seconds / totalDuration) * rect.size.width
//            let dashRect = CGRect(x: x, y: (rect.size.height - dashHeight) / 2, width: 4, height: dashHeight)
//            context?.setFillColor(timeCodeColor)
//            context?.fill(dashRect)
//        }
//    }
//}
