//
//  TableViewController.swift
//  Whatisit
//
//  Created by 田中颯太 on 2017/04/04.
//  Copyright © 2017年 田中颯太. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SafariServices

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var uiimage: UIImageView!
    @IBOutlet var bannerView: GADBannerView!
    var infom: [String] = []
    var proba: [String] = []
    var images: UIImage!
    var word: String!
    var number:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        word = "Helloc"
        
        
        bannerView.adUnitID = "ca-app-pub-4903713163214848/6920753815"//ok
        //bannerView.adUnitID = "ca-app-pub-4903713163214848/9528507412"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        //tableView.register(UINib(nibName: "MyCell", bundle: nil), forCellReuseIdentifier: "MyCell")
        
        tableView.dataSource = self
        uiimage.image = images
        tableView.reloadData()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //tableviewに関して
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infom.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! CustomTableViewCell
        cell.info.text = infom[indexPath.row]
        cell.sc.text = proba[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        number = indexPath.row
        word = infom[number]
        if let worde = word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed ) {
            let url = NSURL(string:"https://www.google.co.jp/search?q=" + worde)
            if let url = url {
                let safariViewController = SFSafariViewController(url: url as URL)
                present(safariViewController, animated: false, completion: nil)
            }

        }
        tableView.reloadData()
    }
}
