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
    var videoPlayer: AVPlayer?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    convenience init(videoPlayer:AVPlayer!, reuseIdentifier:String?) {
        self.init(style: .value1, reuseIdentifier: reuseIdentifier)
        self.videoPlayer = videoPlayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
