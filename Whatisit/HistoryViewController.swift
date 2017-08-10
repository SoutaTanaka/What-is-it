//
//  HistoryViewController.swift
//  Whatisit
//
//  Created by 田中颯太 on 2017/08/09.
//  Copyright © 2017年 田中颯太. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var info: [String] = []
    var prob: [String] = []
    var photos: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    //TableViewセルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! CustomTableViewCell
        cell.info.text = info[indexPath.row]
        cell.sc.text = prob[indexPath.row]
        return cell
    }
 
    

}
