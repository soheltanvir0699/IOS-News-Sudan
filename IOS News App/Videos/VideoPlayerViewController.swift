//
//  VideoPlayerViewController.swift
//  IOS News App
//
//  Created by GajoDev on 26/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import UIKit
import YouTubeiOSPlayerHelper
import AVKit

class VideoPlayerViewController: UIViewController {
        
    @IBOutlet var playerView: WKYTPlayerView!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var currentTimeButton: UIButton!
    @IBOutlet var durationButton: UIButton!
    
    var video : News = News()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if (video.content_type == "youtube") {
            playerView.load(withVideoId: video.video_id!)
        } else {
            let videoURL = URL(string: video.video_url!)
            let player = AVPlayer(url: videoURL!)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player

            present(playerViewController, animated: true) {
              player.play()
            }
        }

    }
    
    @IBAction func play(sender: UIButton) {
/*        if playerView. ready {
            if playerView.playerState != YouTubePlayerState.Playing {
                playerView.play()
                playButton.setTitle("Pause", for: .normal)
            } else {
                playerView.pause()
                playButton.setTitle("Play", for: .normal)
            }
        }*/
    }
    
    @IBAction func prev(sender: UIButton) {
        playerView.previousVideo()
    }
    
    @IBAction func next(sender: UIButton) {
        playerView.nextVideo()
    }
    
    @IBAction func currentTime(sender: UIButton) {
/*        let title = String(format: "Current Time %@", playerView.getCurrentTime() ?? "0")
        currentTimeButton.setTitle(title, for: .normal)*/
    }
    
    @IBAction func duration(sender: UIButton) {
/*        let title = String(format: "Duration %@", playerView.getDuration() ?? "0")
        durationButton.setTitle(title, for: .normal)*/
    }
    
    func showAlert(message: String) {
        self.present(alertWithMessage(message: message), animated: true, completion: nil)
    }
    
    func alertWithMessage(message: String) -> UIAlertController {
        let alertController =  UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        
        return alertController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
