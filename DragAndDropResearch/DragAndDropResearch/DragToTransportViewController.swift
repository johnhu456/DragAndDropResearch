//
//  DragToTransportViewController.swift
//  DragAndDropResearch
//
//  Created by 胡翔 on 2017/10/24.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit
import AVKit


class DragToTransportViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    private let kCellReuseIdentifer = "kCellReuseIdentifer"
    
    private var tableView : UITableView!
    
    private var videoPlayer:AVPlayer!
    private var videoPlayItem:AVPlayerItem!
    private var videoPlayerLayer:AVPlayerLayer!
    
    private var videoPlayView:UIView!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        setupTableView()
    }
    
    func setupTableView () {
        tableView = UITableView.init(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifer)
        view.addSubview(tableView)
    }
    func setupVideoPlayer() {
        let videoUrl = NSURL.init(string:"http://111.1.50.88/mp4files/5100000004A4FB36/clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        videoPlayItem = AVPlayerItem.init(url: videoUrl! as URL)
        videoPlayer = AVPlayer.init(playerItem: videoPlayItem)
        videoPlayItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        videoPlayerLayer = AVPlayerLayer.init(player: videoPlayer)
        videoPlayerLayer.frame = view.frame
        videoPlayView = UIView.init(frame: view.frame)
    }
    
    func setupDragItem() {
//        let itemProvider = NSItemProvider.init(object: videoPlayView)
//        let dragItem = UIDragItem.init(itemProvider: <#T##NSItemProvider#>)
    }
 
    func setupUserInterface() {
        videoPlayView.layer.addSublayer(videoPlayerLayer)
        view.addSubview(videoPlayView)
        videoPlayer.play()

    }
    
    //MARK: - UITableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseIdentifer)
        if cell == nil {
            cell = UITableViewCell.init(style: .value1, reuseIdentifier: kCellReuseIdentifer)
        }
        switch indexPath.row {
        case 0:
            //Drag url
            cell?.contentView.backgroundColor = UIColor.red
            cell?.detailTextLabel?.text = "Drag URL"
        default:
            //Drag video
            cell?.contentView.backgroundColor = UIColor.green
            cell?.detailTextLabel?.text = "Drag video"
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    //MARK: - Helper
}
