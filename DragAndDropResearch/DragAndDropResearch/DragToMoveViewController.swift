//
//  DragToMoveViewController.swift
//  DragAndDropResearch
//
//  Created by Moxtra on 2017/8/2.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit

class DragToMoveViewController: UIViewController,UIDragInteractionDelegate,UIDropInteractionDelegate {
    private var segmentControl : UISegmentedControl!
    private var dragImageView : UIImageView!
    private var selectedImageView : UIImageView!
    private var dropPoint : CGPoint?
    
    override func viewDidLoad() {
        title = "Drag to move"
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        view.isUserInteractionEnabled = true
        segmentControl = UISegmentedControl(items:["Move","Copy"])
        segmentControl.selectedSegmentIndex = 0
        navigationItem.titleView = segmentControl
        
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
        
        //Add UIDropInteraction to support drop
        view.addInteraction(UIDropInteraction.init(delegate: self))
        
        selectedImageView = dragImageView
    }
    
    // MARK: - UIDragInteractionDelegate
    
    func dragInteraction(_ interaction: UIDragInteraction, sessionWillBegin session: UIDragSession) {
        selectedImageView = interaction.view as! UIImageView
    }
    
    func dragInteraction(_ interaction: UIDragInteraction, itemsForBeginning session: UIDragSession) -> [UIDragItem] {
        let dragImage = dragImageView.image
        let itemProvider = NSItemProvider.init(object: dragImage!)
        let dragItem = UIDragItem.init(itemProvider: itemProvider)
        return [dragItem]
    }
    
 
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let operation = segmentControl.selectedSegmentIndex == 0 ? UIDropOperation.move : .copy
        let proposal = UIDropProposal.init(operation: operation)
        dropPoint = session.location(in: view)
        return proposal
    }
//
    func dropInteraction(_ interaction: UIDropInteraction, item: UIDragItem, willAnimateDropWith animator: UIDragAnimating) {
        if segmentControl.selectedSegmentIndex == 0 {
            //Move
            animator.addAnimations {
                self.selectedImageView.center = self.dropPoint!
            }
            animator.addCompletion { _ in
                self.selectedImageView.center = self.dropPoint!
            }
        }
//        else {
//            createImageFromProviderAndPoint(provider: item.itemProvider, point: self.dropPoint!)
//        }
    }

    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        self.dropPoint = session.location(in: interaction.view!)
        //Must implement this method
        if session.localDragSession == nil {
            self.dropPoint = session.location(in: interaction.view!)
                for dragItem in session.items {
                    createImageFromProviderAndPoint(provider: dragItem.itemProvider, point: self.dropPoint!)
                }
        } else {
            self.selectedImageView.center = self.dropPoint!
        }
    }

    // MARK: - Helper
    private func createImageCopyAtPoint(point:CGPoint) {
        let newImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kImageSizeWidth, height: kImageSizeHeight))
        newImageView.center = point
        newImageView.isUserInteractionEnabled = true
        newImageView.backgroundColor = UIColor.clear
        newImageView.image = UIImage.init(named: "madao")
        newImageView.addInteraction(UIDragInteraction.init(delegate: self))
        view.addSubview(newImageView)
    }

    private func createImageFromProviderAndPoint(provider:NSItemProvider, point:CGPoint) {
        let newImageView = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: kImageSizeWidth, height: kImageSizeHeight))
        newImageView.center = point
        newImageView.isUserInteractionEnabled = true
        newImageView.backgroundColor = UIColor.clear
        provider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
            if object != nil {
                DispatchQueue.main.async {
                    newImageView.image = (object as! UIImage)
                    newImageView.addInteraction(UIDragInteraction.init(delegate: self))
                    self.view.addSubview(newImageView)
                }
            }
            else {
                // Handle the error
            }
        })
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
