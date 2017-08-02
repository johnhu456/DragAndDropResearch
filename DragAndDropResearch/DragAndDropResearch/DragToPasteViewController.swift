//
//  NormalDragDropViewController.swift
//  DragAndDropResearch
//
//  Created by Moxtra on 2017/8/1.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit

class PasteImageView : UIImageView {
    let tipLayer : CATextLayer
    let customBorderLayer : CAShapeLayer
    
    override init(frame: CGRect) {
        tipLayer = CATextLayer.init()
        customBorderLayer = CAShapeLayer.init()
        super.init(frame: frame)
        
        backgroundColor = UIColor.lightGray
        customBorderLayer.strokeColor = UIColor.darkGray.cgColor
        customBorderLayer.fillColor = nil;
        customBorderLayer.path = UIBezierPath.init(rect: bounds).cgPath
        customBorderLayer.frame = self.bounds;
        customBorderLayer.lineWidth = 3;
        customBorderLayer.lineCap = "round";
        customBorderLayer.lineDashPattern = [10, 10];
        layer.addSublayer(customBorderLayer)
        
        tipLayer.string = "Drag image to here"
        tipLayer.frame = bounds
        tipLayer.font = UIFont.systemFont(ofSize: 14)
        layer.addSublayer(tipLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func paste(itemProviders: [NSItemProvider]) {
        for dragItem in itemProviders {
            if dragItem.canLoadObject(ofClass: UIImage.self) {
                dragItem.loadObject(ofClass: UIImage.self, completionHandler: { (image, error) in
                    if image != nil {
                        DispatchQueue.main.async {
                            self.tipLayer.removeFromSuperlayer()
                            self.customBorderLayer.removeFromSuperlayer()
                            self.image = (image as! UIImage)
                        }
                    }
                })
            }
        }
    }
}

let kImageSizeWidth = 300
let kImageSizeHeight = 200

class DragToPasteViewController: UIViewController,UIDragInteractionDelegate,UIDropInteractionDelegate {
    var dragView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        setupUserInterface()

    }
    
    // MARK: - UserInterface
    private func setupUserInterface() {
        let dragImage = UIImage.init(named: "madao")
        dragView = UIImageView.init(frame: CGRect.init(x: 50, y: 80, width: kImageSizeWidth, height: kImageSizeHeight))
        dragView.isUserInteractionEnabled = true
        dragView.backgroundColor = UIColor.clear
        dragView.image = dragImage
        dragView.clipsToBounds = true
        dragView.contentMode = .scaleAspectFill
        
        //Add an UIDragInteraction to support drag
        dragView.addInteraction(UIDragInteraction.init(delegate: self))
        view.addSubview(dragView)
        
        let pasteImageView = PasteImageView.init(frame: CGRect.init(x: Int(view.bounds.size.width - 350), y: 80, width: kImageSizeWidth, height: kImageSizeHeight))
        //Config pasteConfiguration for accept a image
        pasteImageView.pasteConfiguration = UIPasteConfiguration(forAccepting: UIImage.self)
        pasteImageView.isUserInteractionEnabled = true
        pasteImageView.clipsToBounds = true
        pasteImageView.contentMode = .scaleAspectFill
        view.addSubview(pasteImageView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIDragInteractionDelegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let dragImage = dragView.image
        let itemProvider = NSItemProvider.init(object: dragImage!)
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        return [dragItem]
    }
}
