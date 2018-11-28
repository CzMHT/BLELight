//
//  SpeechReport.swift
//  BLELight
//
//  Created by Enjoy on 2018/10/24.
//  Copyright © 2018 YuanGu. All rights reserved.
//

import UIKit
import AudioToolbox
import AVFoundation

class SpeechReport: NSObject {

    static let shared = SpeechReport()
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()

    override init() {
        
        let path = Bundle.main.path(forResource: "Yinyue", ofType: "mp3")
        let soundUrl = URL(fileURLWithPath: path!)
        
        //在音频播放前首先创建一个异常捕捉语句
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord,
                                                            mode: AVAudioSessionModeDefault,
                                                            options: [.defaultToSpeaker,
                                                                      .allowBluetoothA2DP,
                                                                      .allowBluetooth,
                                                                      .mixWithOthers])
            //对音频播放对象进行初始化，并加载指定的音频播放对象
            try audioPlayer = AVAudioPlayer(contentsOf:soundUrl)
            //设置音频对象播放的音量的大小
            audioPlayer.volume = 1.0
            //设置音频播放的次数，-1为无限循环播放
            audioPlayer.numberOfLoops = -1
        } catch {
            print(error)
        }
    }
    deinit {
        print(#function)
        print("release ok")
    }
    
    public func playAudio() {
        if !audioPlayer.isPlaying {
            audioPlayer.play()
        }
    }
    public func stopPlay() {
        if audioPlayer.isPlaying {
            audioPlayer.pause()
        }
    }
}
