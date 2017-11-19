//
//  DragToTransportCell.swift
//  DragAndDropResearch
//
//  Created by 胡翔 on 2017/10/25.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit
import AVKit

class DragToTransportCell: UITableViewCell {
    var videoPlayer: AVPlayer?{
        didSet{
            self.reloadInterface()
        }
    }
    var videoPlayerLayer : AVPlayerLayer?
    var videoPlayView : UIView?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(videoPlayer:AVPlayer!, reuseIdentifier:String?) {
        self.init(style: .value1, reuseIdentifier: reuseIdentifier)
        setupGesture()
        self.videoPlayer = videoPlayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupInterface() {
        videoPlayerLayer = AVPlayerLayer.init(player: videoPlayer)
        let frame = CGRect.init(x: 0, y: 0, width: contentView.frame.size.width/2, height: contentView.frame.size.height)
        videoPlayerLayer?.frame = frame
        videoPlayView = UIView.init(frame: frame)
        videoPlayView!.layer .addSublayer(videoPlayerLayer!)
        contentView.addSubview(videoPlayView!)
    }
    
    private func reloadInterface() {
        videoPlayerLayer?.removeFromSuperlayer()
        videoPlayView?.removeFromSuperview()
        setupInterface()
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer.init(target: self, action:#selector(self.handleTapGesture))
        contentView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTapGesture() {
        videoPlayer?.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPlayerLayer?.frame = CGRect.init(x: 0, y: 0, width: contentView.bounds.size.width/2, height: contentView.bounds.size.height)
        videoPlayView?.frame = (videoPlayerLayer?.frame)!
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
