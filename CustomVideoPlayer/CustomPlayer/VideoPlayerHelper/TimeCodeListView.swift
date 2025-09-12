//
//  TimeCodeListView.swift
//  CustomVideoPlayer
//
//  Created by hb on 11/09/25.
//

import SwiftUI
import AVKit

struct TimecodeListView: View {
    
    let player: AVPlayer
    let timecodes: [Timecode]
    
    var body: some View {
        GeometryReader { _ in
            VStack (alignment: .leading, spacing: 5) {
                Text("Timecodes:")
                    .foregroundColor(.white)
                ForEach(timecodes, id: \.title) { timecode in
                    Button(action: {
                        seekToTimecode(timecode.time)
                    }) {
                        Text(String(format: "%02d:%02d", Int(timecode.time.seconds / 60), Int(timecode.time.seconds.truncatingRemainder(dividingBy: 60))))
                            .foregroundColor(.blue)

                        Text(timecode.title)
                            .foregroundColor(.white)
                    }
                }
            }
            .padding()
           
        }

    }
    private func seekToTimecode(_ time: CMTime) {
        let toleranceBefore: CMTime = CMTime(seconds: 0.01, preferredTimescale: 1)
        let toleranceAfter: CMTime = CMTime(seconds: 0.01, preferredTimescale: 1)
        
        player.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

}
