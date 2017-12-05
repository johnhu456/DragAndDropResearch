//
//  DragToTransportViewController.swift
//  DragAndDropResearch
//
//  Created by 胡翔 on 2017/10/24.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit
import AVKit


class DragToTransportViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITableViewDragDelegate, UITableViewDropDelegate {
    private let kCellReuseIdentifer = "kCellReuseIdentifer"
    
    private var tableView : UITableView!
    
    private var videoPlayers:Array<AVPlayer>!
    private var videoPlayURLs:Array<NSURL>!
    
    private var videoPlayView:UIView!
    
    override func viewDidLoad() {
        view.backgroundColor = UIColor.white
        setupTableView()
        setupVideoPlayers()
    }
    
    func setupTableView () {
        tableView = UITableView.init(frame: view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        view.addSubview(tableView)
    }
    func setupVideoPlayers() {
        //Please ignore the naming
        
        videoPlayers = Array.init()
        videoPlayURLs = Array.init()
        
        let videoUrl1 = NSURL.init(string:"http://111.1.50.88/mp4files/5100000004A4FB36/clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
        let videoPlayItem1 = AVPlayerItem.init(url: videoUrl1! as URL)
        let videoPlayer1 = AVPlayer.init(playerItem: videoPlayItem1)
        
        let videoUrl2 = NSURL.init(string:"https://www.w3schools.com/html/movie.mp4")
        let videoPlayItem2 = AVPlayerItem.init(url: videoUrl2! as URL)
        let videoPlayer2 = AVPlayer.init(playerItem: videoPlayItem2)
        
        videoPlayers.append(videoPlayer1)
        videoPlayers.append(videoPlayer2)
        
        videoPlayURLs.append(videoUrl1!)
        videoPlayURLs.append(videoUrl2!)
    }
    
    //MARK: - UITableViewDelegate & DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoPlayers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: kCellReuseIdentifer) as? DragToTransportCell
        let currentPlayer = videoPlayers[indexPath.row]
        if (cell == nil) {
            cell = DragToTransportCell.init(videoPlayer: currentPlayer, reuseIdentifier: kCellReuseIdentifer)
        }
        cell!.videoPlayer = videoPlayers[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    //MARK: - UITableViewDragDelegate
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider.init(item: videoPlayURLs[indexPath.row] as NSSecureCoding, typeIdentifier: "public.mpeg-4")

        itemProvider.registerItem(forTypeIdentifier: "public.mpeg-4") { (loader, data, option) in
            let request = URLRequest.init(url: self.videoPlayURLs[indexPath.row] as URL)
            let task = URLSession.shared.downloadTask(with: request, completionHandler: { (url, response, error) in
                let videoData = NSData.init(contentsOf: url!)
                loader(videoData,nil)
            })
            task.resume()
        }
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let targetCell = tableView.cellForRow(at: indexPath) as! DragToTransportCell
        let dragPreviewParam = UIDragPreviewParameters.init()
        dragPreviewParam.visiblePath = UIBezierPath.init(rect: (targetCell.videoPlayerLayer?.frame)!)
        return dragPreviewParam
    }
    
    func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
        return session.hasItemsConforming(toTypeIdentifiers: ["public.mpeg-4"])
    }
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if (session.localDragSession != nil) {
            return UITableViewDropProposal.init(operation: .cancel)
        }
        return UITableViewDropProposal.init(operation: .copy)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let dropItem = coordinator.items[0]
        let itemProvider = dropItem.dragItem.itemProvider
        itemProvider.loadDataRepresentation(forTypeIdentifier: itemProvider.registeredTypeIdentifiers.first!) { (data, error) in
            let tempPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, .userDomainMask, true).first
            var videoPath = NSString.init(string: tempPath!)
            videoPath = videoPath.appendingPathComponent("test.mp4") as NSString
            let videoData = data! as NSData
            let tempUrl = URL.init(fileURLWithPath: videoPath as String)
            videoData.write(to: tempUrl, atomically: true)
            let playerItem = AVPlayerItem.init(url: tempUrl)
            let player = AVPlayer.init(playerItem: playerItem)
            self.videoPlayers.append(player)
            self.videoPlayURLs.append(tempUrl as NSURL)
            DispatchQueue.main.async {
                tableView.reloadData()
            }
        }
    }
}
