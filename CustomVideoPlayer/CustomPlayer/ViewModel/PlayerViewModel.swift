//
//  PlayerViewModel.swift
//  CustomVideoPlayer
//
//  Created by hb on 10/09/25.
//

import Foundation
import AVKit

class PlayerViewModel: ObservableObject {
        
    // Array of PlayerModel instances with multiple videos
    @Published var videos: [PlayerModel] = [
        PlayerModel(
            url: "https://video-previews.elements.envatousercontent.com/h264-video-previews/315b5d0f-cca5-41c0-824f-e99e2dcfbe6d/40108191.mp4",
            timecodes: [
                Timecode(title: "Intro", time: CMTime(seconds: 0, preferredTimescale: 1)),
                Timecode(title: "Chapter - 1", time: CMTime(seconds: 9, preferredTimescale: 1)),
                Timecode(title: "Chapter - 2", time: CMTime(seconds: 30, preferredTimescale: 1)),
                Timecode(title: "Chapter - 3", time: CMTime(seconds: 55, preferredTimescale: 1)),
                Timecode(title: "Chapter - 4", time: CMTime(seconds: 69, preferredTimescale: 1))
            ]
        ),
        
        PlayerModel(
            url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
            timecodes: [
                Timecode(title: "Start", time: CMTime(seconds: 0, preferredTimescale: 1)),
                Timecode(title: "Action Scene", time: CMTime(seconds: 20, preferredTimescale: 1)),
                Timecode(title: "Climax", time: CMTime(seconds: 60, preferredTimescale: 1))
            ]
        ),
        PlayerModel(
            url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            timecodes: [
                Timecode(title: "Opening", time: CMTime(seconds: 0, preferredTimescale: 1)),
                Timecode(title: "Mid Story", time: CMTime(seconds: 45, preferredTimescale: 1)),
                Timecode(title: "Ending", time: CMTime(seconds: 90, preferredTimescale: 1))
            ]
        ),
        PlayerModel(
            url: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
            timecodes: [
                Timecode(title: "Prologue", time: CMTime(seconds: 0, preferredTimescale: 1)),
                Timecode(title: "Adventure Begins", time: CMTime(seconds: 30, preferredTimescale: 1)),
                Timecode(title: "Final Battle", time: CMTime(seconds: 120, preferredTimescale: 1))
            ]
        )
    ]
    
//    init() {
//        if let videoURL = URL(string: url) {
//            player = AVPlayer(url: videoURL)
//        }
//    }
}

class PlayerModel: Identifiable, ObservableObject, Hashable {
    let id: String = UUID().uuidString
    let url: String
    @Published var currentPlayTime: CMTime? = nil
    let timecodes: [Timecode]
    
    init(url: String, currentPlayTime: CMTime? = nil, timecodes: [Timecode]) {
        self.url = url
        self.currentPlayTime = currentPlayTime
        self.timecodes = timecodes
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: PlayerModel, rhs: PlayerModel) -> Bool {
        lhs.id == rhs.id
    }
}



//    @Published var player = AVPlayer()
    
//    let url = "https://video-previews.elements.envatousercontent.com/h264-video-previews/315b5d0f-cca5-41c0-824f-e99e2dcfbe6d/40108191.mp4"
//
//    let timecodes: [Timecode] = [
//        Timecode(title: "Intro", time: CMTime(seconds: 0, preferredTimescale: 1)),
//        Timecode(title: "Chapter - 1", time: CMTime(seconds: 9, preferredTimescale: 1)),
//        Timecode(title: "Chapter - 2", time: CMTime(seconds: 30, preferredTimescale: 1)),
//        Timecode(title: "Chapter - 3", time: CMTime(seconds: 55, preferredTimescale: 1)),
//        Timecode(title: "Chapter - 4", time: CMTime(seconds: 69, preferredTimescale: 1))
//    ]
