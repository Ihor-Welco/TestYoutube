//
//  MovieCell.swift
//  YoutubeParcer
//
//  Created by Ihor Golia on 02.06.2022.
//

import Foundation
import AVFoundation
import UIKit

class MovieCell: UICollectionViewCell {
    
    var playerLayer: AVPlayerLayer?
    
    func configure(videoURL: URL?) {
        guard let videoURL = videoURL else {
            return
        }
        let player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
        player.play()
    }
    
    override func layoutSubviews() {
        playerLayer?.frame = self.bounds
        super.layoutSubviews()
    }
    
}
