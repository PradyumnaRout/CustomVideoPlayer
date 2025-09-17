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
        didSet { setNeedsDisplay() }
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
        
        let viewedX = rect.size.width * viewedProgress
        
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
