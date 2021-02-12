//
//  FavoritePlayViewController.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2020/06/18.
//  Copyright © 2020 葛西　翔太. All rights reserved.
//

import UIKit
import AVFoundation
import SPStorkController

class FavoritePlayViewController: UIViewController,AVAudioPlayerDelegate {
    @IBOutlet weak var artistImageView: UIImageView!
    @IBOutlet weak var musicNameLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var volume: UISlider!
    var player: AVAudioPlayer?
    var artistName = ""
    var musicName = ""
    var previewURL = ""
    var imageString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.overrideUserInterfaceStyle = .dark
        
        artistImageView.sd_setImage(with: URL(string: imageString), placeholderImage: UIImage(named: "noimage"), options: .continueInBackground, context: nil, progress: nil, completed: nil)
        musicNameLabel.text = musicName
        artistNameLabel.text = artistName
        
        player?.delegate = self
        
        let url = URL(string: previewURL)
        downLoadMusicURL(url: url!)
    }
    
    @IBAction func volumeSlider(_ sender: Any) {
        if player != nil{
            player!.volume = volume.value
        }
    }
    
    @IBAction func playButton(_ sender: Any) {
        if(player!.isPlaying){
            player!.stop()
        }else{
            let url = URL(string: previewURL)
            downLoadMusicURL(url: url!)
        }
    }
    
    func downLoadMusicURL(url: URL){
        var downloadTask:URLSessionDownloadTask
        downloadTask = URLSession.shared.downloadTask(with: url, completionHandler: { (url, response, error) in
            //再生
            self.play(url: url!)
        })
        downloadTask.resume()
    }
    
    func play(url:URL){
        do {
            self.player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
            player?.volume = 1.0
            player?.play()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
