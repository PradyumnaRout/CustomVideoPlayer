//
//  PlayerControlButtons.swift
//  CustomVideoPlayer
//
//  Created by hb on 10/09/25.
//

import SwiftUI
import AVKit

struct PlayerControlButtons: View {
    
    // MARK: - State Properties
    
    // on/off sound
    @State private var soundOff = false
    // Slider value
    @State private var sliderValue: Float = 0
    
    // Binding Properties
    @Binding var isPlaying: Bool
    @Binding var timer: Timer?
    // show/hide controll buttons.
    @Binding var showPlayerControlButtons: Bool
    // Enable/Disable full screen player mode
    @Binding var isPlayerFullScreen: Bool
    @Binding var avPlayer: AVPlayer
    @Binding var currentPlayTime: CMTime?
    @Binding var showPIP: Bool
    @Binding var playFromPausePoint: Bool
    
    // Other Properties
    let timecodes: [Timecode]
    private var currentTimeText: String {
        if playFromPausePoint {
            print("Inside Current Time")
            if let currentPlayTime = currentPlayTime,
               currentPlayTime != .zero,
               let duration = avPlayer.currentItem?.duration.seconds,
               !isPlayerFullScreen,
               duration > 0 {
                let currentTimeInSeconds = currentPlayTime.seconds
                return formatTime(currentTimeInSeconds)
            }
        } else if let duration = avPlayer.currentItem?.duration.seconds {
            let currentTimeInSeconds = Double(sliderValue) * duration
            return formatTime(currentTimeInSeconds)
        }
        return "00.00"
    }
    
    private var timeLeftText: String {
        if let duration = avPlayer.currentItem?.duration.seconds {
            let totalTimeInSeconds = duration
            let remainingTimeInSeconds = totalTimeInSeconds - (Double(sliderValue) * totalTimeInSeconds)
            return formatTime(remainingTimeInSeconds)
        }
        return "00.00"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            
            VStack {
                HStack {
                    // Enable/Disable full screen mode.
                    Button {
                        isPlayerFullScreen.toggle()
                        startTimer(timeInterval: 0)
                    } label: {
                        Image(systemName: isPlayerFullScreen ? "xmark" : "arrow.up.left.and.arrow.down.right")
                            .frame(height: 20)
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    }
                    
                    if showPIP {
                        Button {
//                            enablePIP.toggle()
//                            print("PIP enable: \(enablePIP)")
                        } label: {
                            Image(systemName: "pip.enter")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        .padding()
                    }
                    
                    Spacer()
                    // On/Off Sound.
                    Button {
                        soundOff.toggle()
                        avPlayer.isMuted = soundOff
                        startTimer(timeInterval: 0)
                    } label: {
                        Image(systemName: soundOff ? "speaker.slash.fill" : "speaker.wave.2.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                    }
                }
                .padding(.vertical, screenWidth * 0.01)
                Spacer()
                HStack {
                    Button {
                        seekBackward()
                        startTimer(timeInterval: 0)
                    } label: {
                        Image(systemName: "gobackward.10")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        if isPlaying {
                            isPlaying = false
                            avPlayer.pause()
                            timer?.invalidate()
                        } else {
                            isPlaying = true
                            avPlayer.play()
                            startTimer(timeInterval: 0)
                        }
                    } label: {
                        Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 38).bold())
                            .foregroundColor(.white)
                    }
                    Spacer()
                    Button {
                        seekForward()
                        startTimer(timeInterval: 0)
                    } label: {
                        Image(systemName: "goforward.10")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, screenWidth * 0.1)
                
                Spacer()
                VStack(spacing: 5) {
                    PlayerSliderView(
                        value: $sliderValue,
                        avPlayer: $avPlayer,
                        isPlaying: $isPlaying,
                        currentPlayTime: $currentPlayTime,
                        timecodes: timecodes
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { _ in
                                startTimer(timeInterval: 0)
                            }
                    )
                    HStack {
                        Text("\(currentTimeText) \\ \(timeLeftText)")
                            .foregroundColor(.white)
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, screenWidth * 0.03)
            .padding(.vertical, screenHeight * 0.03)
            .background(Color.black.opacity(0.4))
            .onAppear {
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, options: [.mixWithOthers])
                    try AVAudioSession.sharedInstance().setActive(true)
                    print("Audio session configured successfully")
                } catch {
                    print("Audio session configuration failed: \(error)")
                }
                if playFromPausePoint {
                    print("Inside OnAppear.")
                    if currentPlayTime != nil && currentPlayTime != .zero {
                        let duration = avPlayer.currentItem?.duration ?? CMTime.zero
                        sliderValue = Float(CMTimeGetSeconds(currentPlayTime!) / CMTimeGetSeconds(duration))
                    }
                    
                    seekToPreviousTime()
                    playFromPausePoint = false
                }
                
                if isPlaying {
                    avPlayer.play()
                }
                
                // Observe when video ends
                NotificationCenter.default.addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: avPlayer.currentItem,
                    queue: .main
                ) { _ in
                    isPlaying = false
                    avPlayer.seek(to: .zero)  // Optional: reset player to beginning
                }
            }
            
        }
    }
    
    private func startTimer(timeInterval: Double) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { timer in
            withAnimation {
                showPlayerControlButtons = false
            }
        })
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
    
    // Forward video with 10 second interval
    private func seekForward() {
        let currentTime = avPlayer.currentTime()
        let newTime = CMTimeAdd(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        avPlayer.seek(to: newTime)
    }
    
    // Backward video with 10 second interval
    private func seekBackward() {
        let currentTime = avPlayer.currentTime()
        let newTime = CMTimeSubtract(currentTime, CMTime(seconds: 10, preferredTimescale: 1))
        avPlayer.seek(to: newTime)
    }
    
    private func seekToPreviousTime() {
        if currentPlayTime != nil && currentPlayTime != .zero {
            let newTime = CMTimeSubtract(currentPlayTime!, CMTime(seconds: 0, preferredTimescale: 1))
            avPlayer.seek(to: newTime)
        }
    }
}


