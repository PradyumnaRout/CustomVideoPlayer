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
    @State private var playFromPausePoint: Bool = false
    
    let publisher = StringPublisher(inputValue: "hello world")
    let subscriber = StringSubscriber()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 10) {
                ForEach(viewModel.videos) { video in
                    PlayerRowView(model: video)
                        .onTapGesture {
                            playFromPausePoint = (video.currentPlayTime?.seconds ?? 0.0) > 0.0
                            path.append(video)
                        }
                }
                Spacer()
            }
            .navigationTitle("Play Video")
            .navigationDestination(for: PlayerModel.self) { model in
                VideoHome(model: model, path: $path, playFromPausePoint: $playFromPausePoint)
            }
            .onAppear {
                publisher.subscribe(subscriber)
            }
        }
    }
}

struct PlayerRowView: View {
    @ObservedObject var model: PlayerModel

    var body: some View {
        Text("Video: \(model.currentPlayTime?.seconds ?? 0, specifier: "%.1f") sec")
            .frame(maxWidth: .infinity)
            .frame(height: 30)
            .padding()
            .background(Color.gray)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding()
    }
}


#Preview {
    ContentView()
}


struct VideoHome: View {
    @ObservedObject var model: PlayerModel
    @Binding var path: NavigationPath
    @Binding var playFromPausePoint: Bool
    
    // Your AVPlayer setup as before
    @State private var player: AVPlayer
    
    init(model: PlayerModel, path: Binding<NavigationPath>, playFromPausePoint: Binding<Bool>) {
        self.model = model
        self._path = path
        self._playFromPausePoint = playFromPausePoint
        _player = State(initialValue: AVPlayer(url: URL(string: model.url)!))
    }
    
    var body: some View {
        VStack {
            // Your custom VideoPlayerView as before
            VideoPlayerView(
                player: player,
                currentPlayTime: $model.currentPlayTime,
                playFromPausePoint: $playFromPausePoint,
                timecodes: model.timecodes
            )
            TimecodeListView(player: player, timecodes: model.timecodes)

        }
        .padding()
        .navigationTitle("Video Player")
        .onDisappear {
            player.pause()
        }
    }
}
