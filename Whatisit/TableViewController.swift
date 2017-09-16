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
import Social
import RealmSwift

class TableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //解析結果の表示用TableView
    @IBOutlet var tableView: UITableView!
    //解析した画像を表示するためのImageView
    @IBOutlet var uiimage: UIImageView!
    //広告用View
    @IBOutlet var bannerView: GADBannerView!
    //情報、確率を入れるための配列
    var infom: [String] = []
    var proba: [String] = []
    //
    var images: UIImage!
    //URL変換の際に一時的に情報を入れておく変数
    var word: String!
    //セル番号の取得の際に使う変数
    var number:Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //広告の設定
        #if DEBUG
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
            bannerView.adUnitID = "ca-app-pub-4903713163214848/6920753815"//ok
        #endif
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
        tableView.dataSource = self
        //imageに
        uiimage.image = images
        //tableViewの読み込み
        tableView.reloadData()
        
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("table view \(infom)")
        uiimage.image = images
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //tableviewに関して
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infom.count
    }
    //TableViewセルの設定
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! CustomTableViewCell
        cell.info.text = infom[indexPath.row]
        cell.sc.text = proba[indexPath.row]
        
        return cell
    }
    //tableviewが押された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //押したセルの番号を取得
        number = indexPath.row
        //wordにinform配列からセル番号に対応する言葉を代入
        word = infom[number]
        action()
        //tabeleViewを読み込み直す
        tableView.reloadData()
    }
    //ステータスバーの表示設定
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //TableViewが押された時に表示するActionSheet
    func action (){
        //ActionSeetの作成
        let action: UIAlertController = UIAlertController(title: "動作を選択", message: "動作を選択してください", preferredStyle: UIAlertControllerStyle.actionSheet)
        //ActionSeetの表示内容を作成
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) -> Void in
            print("Cancel")
        })
        //検索
        let sarthi: UIAlertAction = UIAlertAction(title: "Google検索", style: UIAlertActionStyle.default, handler: {
            (action: UIAlertAction!) -> Void in
            
            
            //wordをURLで使える形に変換してwordeに代入
            if let worde = self.word.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed ) {
                //url作成
                let url = NSURL(string:"https://www.google.co.jp/search?q=" + worde)
                if let url = url {
                    //SFsafariViewControllerを使用しサイトを表示
                    let safariViewController = SFSafariViewController(url: url as URL)
                    self.present(safariViewController, animated: false, completion: nil)
                }
                
            }
            
        })
        //シェア
        let sher: UIAlertAction = UIAlertAction(title: "シェア", style: UIAlertActionStyle.default, handler:{
            (action:UIAlertAction!) -> Void in
            //シェアが押された時の処理
            //ActivityViewControllerを呼び出し
            self.pushActivityButton()
            
        })
        
        //表示内容の追加
        //キャンセルボタン
        action.addAction(cancelAction)
        //google検索
        action.addAction(sarthi)
        //シェアボタン
        action.addAction(sher)
        //ActionSeetの設定
        present(action, animated: true, completion: nil)
        
    }
    //ActivityViewControllerの関数
    func pushActivityButton() {
        //シェアする内容を設定
        let texto = self.word + " What is it で作成" + " https://itunes.apple.com/US/app/id1242896457?mt=8"
        let imageeee = self.images
        //itemsにシェアする内容を入れる
        let items: [Any] = [texto, imageeee]
        
        // UIActivityViewControllerをインスタンス化
        let activityVc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        
        
        // UIAcitivityViewControllerを表示
        self.present(activityVc, animated: true, completion: nil)
    }
}
