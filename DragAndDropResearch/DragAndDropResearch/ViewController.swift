//
//  ViewController.swift
//  DragAndDropResearch
//
//  Created by Moxtra on 2017/8/1.
//  Copyright © 2017年 MADAO. All rights reserved.
//

import UIKit

let kCellReuseIdentifer = "kCellReuseIdentifer"

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    var tableView : UITableView!
    let options = ["Drag to paste","Drag to move","Drag to copy"]

    override func viewDidLoad() {
        title = "Drag and Drop"
        super.viewDidLoad()
        setupUserInterface()
        // Do any additional setup after loading the view, typically from a nib.
    }

    //MARK: - UserInterface
    private func setupUserInterface() {
        tableView = UITableView.init(frame: self.view.frame)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kCellReuseIdentifer)
        view.addSubview(tableView)
    }
    
    //MARK: - UITableViewDataSource/Delegate
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = tableView.dequeueReusableCell(withIdentifier: kCellReuseIdentifer)
        tableViewCell?.textLabel?.text = options[indexPath.row]
        return tableViewCell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
          navigationController?.pushViewController(DragToPasteViewController.init(), animated: true)
        case 1:
          navigationController?.pushViewController(DragToMoveViewController.init(), animated: true)
        default:
            return
        }
    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

}

