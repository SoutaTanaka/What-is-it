//
//  HistoryViewController.swift
//  Whatisit
//
//  Created by 田中颯太 on 2017/08/09.
//  Copyright © 2017年 田中颯太. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet var tableView: UITableView!
    var info: [String] = []
    var infos: [[String]] = []
    var prob: [[String]] = []
    var photos: [UIImage] = []
    var number: Int!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    let realm = try! Realm()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photos = []
        info = []
        infos = []
        prob = []
        var datas = realm.objects(InfomationData.self)
        
        for i in 0 ..< datas.count {
            photos.append(UIImage(data: datas[i].img)!)
            info.append(datas[i].ID)
            // dataにinfの中の要素が一つ一つ入って、そのうちのinfoだけ取り出している
            infos.append(datas[i].inf.map { data in data.info })
            prob.append(datas[i].inf.map { data in data.prob})
            print(info)
        }
        
        
        
        print(datas)
        tableView.reloadData()
    }
    
    // info.append(realm.ID)
    // Do any additional setup after loading the view.
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return info.count
    }
    //TableViewセルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "History Table View Cell", for: indexPath) as! HistoryTablseViewCell
        cell.label.text = info[indexPath.row]
        cell.imege.image = photos[indexPath.row]
        return cell
    }
    //tableviewが押された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //押したセルの番号を取得
        number = indexPath.row
        print("select \(infos[number])")
        performSegue(withIdentifier: "SecondView", sender: nil)
        tableView.reloadData()
    }
    //ここ
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        var datas = realm.objects(InfomationData.self)
        if editingStyle == .delete {
            info.remove(at: indexPath.row)
            infos.remove(at: indexPath.row)
            prob.remove(at: indexPath.row)
            photos.remove(at: indexPath.row)
            
            let data = datas[indexPath.row]
                try! realm.write {
                    realm.delete(data)
                }
            
            tableView.reloadData()
            
        }
    }
    //Hey
    override  func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SecondView" {
            let tableViewController = segue.destination as! TableViewController
            tableViewController.infom = infos[number]
            tableViewController.proba = prob[number]
            tableViewController.images = photos[number]
            print("prepare \(infos[number])")
            
        }
        
        
        
    }
    
}
