//
//  NormalDragDropViewController.swift
//  DragAndDropResearch
//
//  Created by Moxtra on 2017/8/1.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit

class PasteImageView : UIImageView {
    private let tipLayer : CATextLayer
    private let customBorderLayer : CAShapeLayer
    
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

let kLabelSizeWidth = 150
let kLabelSizeHeight = 50

class DragToPasteViewController: UIViewController,UIDragInteractionDelegate {
    var dragImageView : UIImageView!
    var dragTextLabel : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        setupUserInterface()

    }
    
    // MARK: - UserInterface
    private func setupUserInterface() {
        
        //Config for drag image
        let dragImage = UIImage.init(named: "madao")
        dragImageView = UIImageView.init(frame: CGRect.init(x: 50, y: 80, width: kImageSizeWidth, height: kImageSizeHeight))
        dragImageView.isUserInteractionEnabled = true
        dragImageView.backgroundColor = UIColor.clear
        dragImageView.image = dragImage
        dragImageView.clipsToBounds = true
        dragImageView.contentMode = .scaleAspectFill
        
        //Add an UIDragInteraction to support drag
        dragImageView.addInteraction(UIDragInteraction.init(delegate: self))
        view.addSubview(dragImageView)
        
        let pasteImageView = PasteImageView.init(frame: CGRect.init(x: Int(view.bounds.size.width - 350), y: 80, width: kImageSizeWidth, height: kImageSizeHeight))
        //Config pasteConfiguration for accept a image
        pasteImageView.pasteConfiguration = UIPasteConfiguration(forAccepting: UIImage.self)
        pasteImageView.isUserInteractionEnabled = true
        pasteImageView.clipsToBounds = true
        pasteImageView.contentMode = .scaleAspectFill
        view.addSubview(pasteImageView)
        
        //Config for drag text
        dragTextLabel = UILabel.init(frame: CGRect.init(x: 50, y: 300, width: kLabelSizeWidth, height: kLabelSizeHeight))
        dragTextLabel.text = "Try drag me~"
        dragTextLabel.backgroundColor = UIColor.clear
        dragTextLabel.isUserInteractionEnabled = true
        dragTextLabel.addInteraction(UIDragInteraction.init(delegate: self))
        view.addSubview(dragTextLabel)
        
        let pasteTextField = UITextField.init(frame: CGRect.init(x: Int(pasteImageView.frame.origin.x), y: 300, width: kLabelSizeWidth, height: kLabelSizeHeight))
        pasteTextField.placeholder = "Drag text here"
        pasteTextField.borderStyle = .roundedRect
        pasteTextField.pasteConfiguration = UIPasteConfiguration(forAccepting: NSString.self)
        view.addSubview(pasteTextField)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIDragInteractionDelegate
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        if interaction.view == dragImageView {
            let dragImage = dragImageView.image
            let itemProvider = NSItemProvider.init(object: dragImage!)
            let dragItem = UIDragItem.init(itemProvider: itemProvider)
            return [dragItem]
        }
        else if interaction.view == dragTextLabel {
            let dragText = "Try drag me~"
            let itemProvider = NSItemProvider.init(object: dragText as NSString)
            let dragItem = UIDragItem.init(itemProvider: itemProvider)
            return [dragItem]
        }
        else {
           return []
        }
    }
}
