//
//  ViewController.swift
//  AI
//
//  Created by 田中颯太 on 2017/03/27.
//  Copyright © 2017年 田中颯太. All rights reserved.
//

import UIKit
import Photos
import SwiftyJSON
import GoogleMobileAds

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, GADInterstitialDelegate, GADNativeExpressAdViewDelegate, GADVideoControllerDelegate {
    //くるくる回るやつ( UIActivityIndicatorView)
    @IBOutlet var activity: UIActivityIndicatorView!
    //表示するイメージ
    @IBOutlet var images: UIImageView!
    var selectedimage: UIImage! = nil
    var swith = true
    
    var score: Double!
    //テスト用
    //  @IBOutlet var textView: UITextView!
    var push: Int = 3
    //UITableView用の配列
    var information: [String] = []
    var probability: [String] = []
    
    //広告用
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet var adView: GADNativeExpressAdView!
    var interstitial: GADInterstitial!
    #if DEBUG
    let adUnitId = "ca-app-pub-3940256099942544/2934735716"
    #else
    let adUnitId = "ca-app-pub-4903713163214848/2909356615"
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        admob()
        
        adView.adUnitID = adUnitId
        adView.rootViewController = self
        adView.delegate = self
        let videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
        adView.videoController.delegate = self
        GADRequest().testDevices = [kGADSimulatorID]
        adView.load(GADRequest())
        
        
        activity.hidesWhenStopped = true
        activity.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        
        images.image = UIImage(named: "Pleas-Select-Image-UI.png")
        #if DEBUG
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
            bannerView.adUnitID = "ca-app-pub-4903713163214848/7339556217"//ok
        #endif
        //bannerView.adUnitID = "ca-app-pub-4903713163214848/9528507412"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //カメラロールから選ぶ
    @IBAction func startimage (){
        push = push + 1
        
        if self.push == 5 {
            self.interstitial.present(fromRootViewController: self)
            self.push = 0
        }
        
        
        
        self.selectFromCameralole()
        bannerView.load(GADRequest())
        adView.load(GADRequest())
        
    }
    //写真を撮る
    @IBAction func startphoto () {
        push = push + 1
        
        if self.push == 5 {
            self.interstitial.present(fromRootViewController: self)
            self.push = 0
        }
        
        
        opencamera()
        bannerView.load(GADRequest())
        adView.load(GADRequest())
    }
    //データを送る
    @IBAction func sendData () {
        print(swith)
        if selectedimage == nil{
            var alert = UIAlertController(title: "画像解析エラー", message: "画像を選択してください", preferredStyle: UIAlertControllerStyle.alert)
            var cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
                (action: UIAlertAction!) in
            })
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
            
        }else{
        if swith == true {
            swith = false
            
            information = []
            probability = []
            
            
                activity.startAnimating()
                push = push + 1
                
                if self.push == 5 {
                    self.interstitial.present(fromRootViewController: self)
                    self.push = 0
                    
                }
                callApi(image: selectedimage)
                
            }
            //   self.textView.text = ""
            
        }
        
        
        
    }
    
    
    //UIImagePickerControllerに関しての記述
    func opencamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            _ = UIAlertController(title: "カメラ使用できません", message: "現在カメラを使うことが許可されておりません。設定から許可してください", preferredStyle: .actionSheet)
        }
    }
    func selectFromCameralole(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
        } else {
            _ = UIAlertController(title: "アルバムが使用できません", message: "現在アルバムを使うことが許可されておりません。設定から許可してください", preferredStyle: .actionSheet)
        }
        
    }
    //imagesに撮った,選択した画像を代入。
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] {
            selectedimage = image as? UIImage
        }
        picker.dismiss(animated: true, completion: nil)
        images.image = selectedimage
    }
    
    //ImagePickerControllerの記述終わり
    
    //IBMにデータを送信するプログラムに関しての記述。
    
    func callApi(image: UIImage) {
        // print ("canSendData")
        // 解析結果はAppDelegateの変数を経由してSubViewに渡す
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // API呼び出し準備
        let APIKey = "5656a398aa0fb87b9d95e29473ffe15bb1889ce2" // APIKeyを取得してここに記述   捨て垢(yahoo)のものを使用中
        let url = "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=" + APIKey + "&version=2016-05-20"
        guard let destURL = URL(string: url) else {
            print ("url is NG: " + url) // debugF
            return
        }
        var request = URLRequest(url: destURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = UIImageJPEGRepresentation(image, 1)
        
        var dataStr:String?
        
        // activityIndicator始動
        // WatsonAPIコール
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error == nil {
                
                
                
                //                appDelegate.analyzedFaces = self.interpretJson(image: image, json: json)
                
                // リクエストは非同期のため画面遷移をmainQueueで行わないとエラーになる
                OperationQueue.main.addOperation(
                    {
                        // APIレスポンス：正常
                        let json = JSON(data: data!)
                        //print(json)
                        
                        //print(json["images_processed"])
                        //                print(json.dictionaryValue)
                        
                        //                let jsonDictionary:Dictionary = json.dictionaryValue
                        
                        var classes : Dictionary = ["class": String(), "score": Float()] as [String : Any]
                        
                        classes["class"] =  json["images"][0]["classifiers"][0]["classes"][0]["class"].string
                        
                        for i in 0...20 {
                            
                            let textClasses =  json["images"][0]["classifiers"][0]["classes"][i]["class"].stringValue
                            let textScore = json["images"][0]["classifiers"][0]["classes"][i]["score"].stringValue
                            
                            if textClasses != "" {
                                self.information.append(textClasses)
                                self.score = atof(textScore)
                                self.score = self.score * 100000000000000
                                self.score = self.score / 1000000000000
                                // print (self.score)
                                self.probability.append(String(self.score))
                                //   self.textView.text  = self.textView.text + "[\(textClasses),\(textScore )],"
                                // self.textView.text  = "[\(textClasses),\(textScore )],"
                                // print( "classes[class]:\(classes["class"]!)")
                                
                                dataStr = classes["class"] as! String?
                                //print( " dataStr:\(String(describing:  dataStr))")
                                //print( " dataStr:\(String(describing:  dataStr))")
                            }
                            
                        }
                        //                        print (self.information)
                        //                        print(self.probability)
                        self.activity.stopAnimating()
                        self.performSegue(withIdentifier: "result", sender: nil)
                        self.swith = true
                        self.bannerView.load(GADRequest())
                    }
                    
                    
                    
                    
                )
                
                // アニメーションの設定
                // navi.modalTransitionStyle = .coverVertical
                
                
            } else {
                // APIレスポンス：エラー
                print(error.debugDescription)   // debug
            }
        }
        task.resume()
        
    }
    
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    //広告の関数
    fileprivate func admob() {
        interstitial = createAndLoadInterstitial()
        // Set up a new game.
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID: "ca-app-pub-4903713163214848/8955890212")//ok
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        print("end")
        print(ad)
        interstitial = createAndLoadInterstitial()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "result" {
            let tableViewController = segue.destination as! TableViewController
            tableViewController.infom = information
            tableViewController.proba = probability
            tableViewController.images = selectedimage
        }
        
    }
    
    //    func nativeExpressAdViewDidReceiveAd(_ nativeExpressAdView: GADNativeExpressAdView) {
    //        if adView.videoController.hasVideoContent() {
    //            print("Received an ad with a video asset.")
    //        } else {
    //            print("Received an ad without a video asset.")
    //        }
    //    }
    //    func videoControllerDidEndVideoPlayback(_ videoController: GADVideoController) {
    //        print("The video asset has completed playback.")
    //    }
}



