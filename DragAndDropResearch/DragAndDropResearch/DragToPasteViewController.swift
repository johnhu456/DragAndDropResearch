//
//  NormalDragDropViewController.swift
//  DragAndDropResearch
//
//  Created by Moxtra on 2017/8/1.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit

class PasteImageView : UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.blue
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
                            self.image = (image as! UIImage)
                        }
                    }
                })
            }
        }
    }
}

class DragToPasteViewController: UIViewController,UIDragInteractionDelegate,UIDropInteractionDelegate {
    var dragView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        view.pasteConfiguration = UIPasteConfiguration(forAccepting: UIImage.self)
        setupUserInterface()

    }
    
    // MARK: - UserInterface
    private func setupUserInterface() {
        let dragImage = UIImage.init(named: "madao")
        dragView = UIImageView.init(frame: CGRect.init(x: 50, y: 50, width: 150, height: 150))
        dragView.backgroundColor = UIColor.red
        dragView.isUserInteractionEnabled = true
        dragView.image = dragImage
        dragView.contentMode = .scaleAspectFill
        
        //Add an UIDragInteraction to support drag
        dragView.addInteraction(UIDragInteraction.init(delegate: self))
        view.addSubview(dragView)
        
        let pasteImageView = PasteImageView.init(frame: CGRect.init(x: 200, y: 200, width: 150, height: 150))
        //Config pasteConfiguration for accept a 
        pasteImageView.pasteConfiguration = UIPasteConfiguration(forAccepting: UIImage.self)
        pasteImageView.isUserInteractionEnabled = true
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
    
    override func paste(itemProviders: [NSItemProvider]) {

    }
    
//    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
//
//    }
//
//    func dropInteraction(_ interaction: UIDropInteraction,
//                         sessionDidUpdate session: UIDropSession) -> UIDropProposal {
//        return UIDropProposal(operation: UIDropOperation.copy)
//
//    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
//        let point = session.location(in: view)
//        for dragItem in session.items {
//            let newImageView
//        }
    }
//

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
