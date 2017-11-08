//
//  DragToTransportViewController.swift
//  DragAndDropResearch
//
//  Created by 胡翔 on 2017/10/24.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit
import AVKit


class DragToTransportViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITableViewDragDelegate {
    private let kCellReuseIdentifer = "kCellReuseIdentifer"
    
    private var tableView : UITableView!
    
    private var videoPlayer:AVPlayer!
    private var videoPlayItem:AVPlayerItem!
    private var videoPlayerLayer:AVPlayerLayer!
    
    private var videoPlayView:UIView!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        setupTableView()
        setupVideoPlayer()
    }
    
    func setupTableView () {
        tableView = UITableView.init(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        tableView.register(DragToTransportCell.self, forCellReuseIdentifier: kCellReuseIdentifer)
        view.addSubview(tableView)
    }
    func setupVideoPlayer() {
        let videoUrl = NSURL.init(string:"http://111.1.50.88/mp4files/5100000004A4FB36/clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        videoPlayItem = AVPlayerItem.init(url: videoUrl! as URL)
        videoPlayer = AVPlayer.init(playerItem: videoPlayItem)
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
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseIdentifer) as! DragToTransportCell
        switch indexPath.row {
        case 0:
            //Drag url
            cell = DragToTransportCell.init(videoPlayer: videoPlayer, reuseIdentifier: kCellReuseIdentifer)
            cell.videoPlayer = self.videoPlayer
        default:
            //Drag video
            cell.contentView.backgroundColor = UIColor.green
            cell.detailTextLabel?.text = "Drag video"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    //MARK: - UITableViewDragDelegate
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let targetCell = tableView.cellForRow(at: indexPath) as! DragToTransportCell
        let itemProvider = NSItemProvider.init(item: "2" as NSSecureCoding, typeIdentifier: "public.mpeg-4")

        itemProvider.registerItem(forTypeIdentifier: "public.mpeg-4") { (loader, data, option) in
            let request = URLRequest.init(url: NSURL.init(string:"http://111.1.50.88/mp4files/5100000004A4FB36/clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")! as URL)
            let task = URLSession.shared.downloadTask(with: request, completionHandler: { (url, response, error) in
                let data2 = NSData.init(contentsOf: url!)
                print(url,response,error)
                loader(data2,nil)
            })
            task.resume()
        }
        
//        itemProvider.registerItem(forTypeIdentifier: "s") { (<#NSItemProvider.CompletionHandler!#>, <#AnyClass!#>, <#[AnyHashable : Any]!#>) in
//            <#code#>
//        }
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        return [dragItem]
    }
}
