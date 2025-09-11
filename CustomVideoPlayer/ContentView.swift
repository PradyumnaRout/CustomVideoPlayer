//
//  ContentView.swift
//  CustomVideoPlayer
//
//  Created by hb on 10/09/25.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject var viewModel = PlayerViewModel()
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 10) {
                ForEach(viewModel.videos) { video in
                    Text("Video: \(video.currentPlayTime)")
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding(.all, 15)
                        .background(Color.gray)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.all, 10)
                        .onTapGesture {
                            path.append(video)
                        }
                }
                Spacer()
            }
            .navigationTitle("Play Video")
            .navigationDestination(for: PlayerModel.self) { model in
                VideoHome(model: model)
            }
        }
    }
}

#Preview {
    ContentView()
}


struct VideoHome: View {
    @ObservedObject var model: PlayerModel
    @State private var player: AVPlayer
    
    init(model: PlayerModel) {
        self.model = model
        _player = State(initialValue: AVPlayer(url: URL(string: model.url)!))
    }
    
    var body: some View {
        VStack {
            VideoPlayerView(player: player, currentPlayTime: $model.currentPlayTime, timecodes: model.timecodes)
            TimecodeListView(player: player, timecodes: model.timecodes)
            Text("Current Time : \(model.currentPlayTime)")
        }
        .padding()
        .navigationTitle("Video Player")
        .onDisappear {
            player.pause()
        }
    }
}
