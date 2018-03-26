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
import RealmSwift

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, GADInterstitialDelegate, GADNativeExpressAdViewDelegate, GADVideoControllerDelegate {
    //くるくる回るやつ( UIActivityIndicatorView)
    @IBOutlet var activityView: UIActivityIndicatorView!
    //表示するイメージ
    @IBOutlet var initialScreenDisplayImage: UIImageView!
    //広告用
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet var adView: GADNativeExpressAdView!
    //変数
    var selectedImage: UIImage! = nil
    var hasWorkedParsing = true
    var imageDisplayInTutorial: [UIImage] = []
    var score: Double!
    var pushAdbuttanInt: Int = 3
    var information: [String] = []
    var probability: [String] = []
    var interstitial: GADInterstitial!
    
    #if DEBUG
    let adUnitId = "ca-app-pub-3940256099942544/2934735716"
    #else
    let adUnitId = "ca-app-pub-4903713163214848/2909356615"
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialBootDecision()
        tutorialDisplayInitialSetting()
        //広告
        admob()
        adInitialSetting()
        //くるくる
        activityIndicatorView()
        //画像が選択されてない状態を防ぐため
        initialScreenDisplayImage.image = UIImage(named: "Pleas-Select-Image-UI.png")
        //広告IDの設定
        adIdSetting()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //くるくる回るやつ( UIActivityIndicatorView)
    func activityIndicatorView (){
        activityView.hidesWhenStopped = true
        activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
    }
    
    //広告の設定(インターステシャル広告)
    func adInitialSetting(){
        adView.adUnitID = adUnitId
        adView.rootViewController = self
        adView.delegate = self
        let videoOptions = GADVideoOptions()
        videoOptions.startMuted = true
        adView.videoController.delegate = self
        GADRequest().testDevices = [kGADSimulatorID]
        adView.load(GADRequest())
    }
    
    func initialBootDecision () {
        let ud = UserDefaults.standard
        if ud.bool(forKey: "firstLaunch") {
            
            // 初回起動時の処理
            performSegue(withIdentifier: "Tutur", sender: nil)
            // 2回目以降の起動では「firstLaunch」のkeyをfalseに
            ud.set(false, forKey: "firstLaunch")
            
        }
    }
    
    
    //チュートリアル画面に使う配列に画像を代入
    func tutorialDisplayInitialSetting (){
        imageDisplayInTutorial.append(#imageLiteral(resourceName: "Simulator-Screen-Shot-2017.06.07-19.14.29.png"))
        imageDisplayInTutorial.append(#imageLiteral(resourceName: "Simulator-Screen-Shot-2017.07.12-19.51.38.png"))
    }
    
    func adIdSetting (){
        #if DEBUG
            bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        #else
            bannerView.adUnitID = "ca-app-pub-4903713163214848/7339556217"//ok
        #endif
        //bannerView.adUnitID = "ca-app-pub-4903713163214848/9528507412"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    //データを送る
    
    
    
    //UIImagePickerController(カメラ)に関しての記述
    func opencamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.camera
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
            //カメラの使用を許可されていない場合アラートを表示
        } else {
            _ = UIAlertController(title: "カメラ使用できません", message: "現在カメラを使うことが許可されておりません。設定から許可してください", preferredStyle: .actionSheet)
        }
    }
    //カメラロールから画像を選択することに関しての記述
    func selectFromCameralole(){
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePickerController.allowsEditing = true
            self.present(imagePickerController, animated: true, completion: nil)
            //上と同様
        } else {
            _ = UIAlertController(title: "アルバムが使用できません", message: "現在アルバムを使うことが許可されておりません。設定から許可してください", preferredStyle: .actionSheet)
        }
        
    }
    
    //MARK: -  ImagePicker
    
    //imagesに撮った,選択した画像を代入。
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] {
            selectedImage = image as? UIImage
        }
        picker.dismiss(animated: true, completion: nil)
        //selectedimageに選択した画像を代入
        initialScreenDisplayImage.image = selectedImage
    }
    
    //ImagePickerControllerの記述終わり
    
    //IBMにデータを送信するプログラムに関しての記述。
    
    func callApi(image: UIImage) {
        // print ("canSendData")
        // 解析結果はAppDelegateの変数を経由してSubViewに渡す
        let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
        //APIを使うためのKey
        let APIKey = "edd1a381a1356c9d0ec86cd824455f5d6160e5ab"
        //POSTするURLを宣言
        let url = "https://gateway-a.watsonplatform.net/visual-recognition/api/v3/classify?api_key=" + APIKey + "&version=2016-05-20"
        //URLが有効でなかった場合(デバッグ用)
        guard let destURL = URL(string: url) else {
            print ("url is NG: " + url) // debugF
            return
        }
        //urlPOST
        var request = URLRequest(url: destURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = UIImageJPEGRepresentation(image, 1)
        
        
        
        // activityIndicator始動
        // WatsonAPIコール
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            if error == nil {
                // リクエストは非同期のため画面遷移をmainQueueで行わないとエラーになる
                OperationQueue.main.addOperation(
                    {
                        // APIレスポンス：正常
                        
                        //Realm
                        var  receivedInforms:InfomationData = InfomationData()
                        
                        receivedInforms.img = UIImagePNGRepresentation(self.selectedImage)
                        
                        
                        
                        //解析結果がJSONで帰ってくるのでJSON型のjson変数に代入
                        let receivedJson = try! JSON(data: data!)
                            
                    
                        // 辞書型の
                        var receivedClasses : Dictionary = ["class": String(), "score": Float()] as [String : Any]
                        
                        receivedClasses["class"] =  receivedJson["images"][0]["classifiers"][0]["classes"][0]["class"].string
                        
                        for i in 0...20 {
                            receivedInforms =  self.processOfInformationAndProbability(json: receivedJson, classes: receivedClasses, roop: i, informs: receivedInforms)
                        }
                        receivedInforms.ID = self.information[0]
                        let realms = try! Realm()
                        try! realms.write {
                            realms.add( receivedInforms)
                        }
                        print( receivedInforms)
                        
                        self.activityViewStop()
                        
                    }
                )
                // アニメーションの設定
            } else {
                // APIレスポンス：エラー
                print(error.debugDescription)   // debug
            }
        }
        task.resume()
    }
    
    func activityViewStop (){
        self.activityView.stopAnimating()
        self.performSegue(withIdentifier: "result", sender: nil)
        self.hasWorkedParsing = true
        self.bannerView.load(GADRequest())
    }
    
    func processOfInformationAndProbability(json: JSON, classes: [String : Any], roop: Int, informs: InfomationData) -> InfomationData {
        var dataStr:String?
        let textClasses =  json["images"][0]["classifiers"][0]["classes"][roop]["class"].stringValue
        let textScore = json["images"][0]["classifiers"][0]["classes"][roop]["score"].stringValue
        if textClasses != nil {
            let dataInfo: Infoprob = Infoprob()
            dataInfo.info = textClasses
            
            if textClasses != "" {
                self.information.append(textClasses)
                //確率がDouble型でそのままだと見切れてしまうので小数点以下第一位までにする
                self.score = atof(textScore)
                self.score = self.score * 100000000000000
                self.score = self.score / 1000000000000
                dataInfo.prob = String(self.score)
                self.probability.append(String(self.score))
                dataStr = classes["class"] as! String?
                informs.inf.append(dataInfo)
                
            }
        }
        return informs
    }
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
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
    
    func displayAdByCriteria (){
        if self.pushAdbuttanInt == 5 {
            self.interstitial.present(fromRootViewController: self)
            self.pushAdbuttanInt = 0
        }
    }
    
    func analyzingErrorAlert () {
        //アラートを表示
        let alert = UIAlertController(title: "画像解析エラー", message: "画像を選択してください", preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: {
            (action: UIAlertAction!) in
        })
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    //tableViewControllerにデータを引き渡す
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "result" {
            let tableViewController = segue.destination as! TableViewController
            tableViewController.infom = information
            tableViewController.proba = probability
            tableViewController.images = selectedImage
        }
    }
    
    //カメラロールから選ぶ
    @IBAction func startimage (){
        pushAdbuttanInt += 1
       displayAdByCriteria()
        self.selectFromCameralole()
        bannerView.load(GADRequest())
        adView.load(GADRequest())
    }
    
    
    //写真を撮る
    @IBAction func startphoto () {
        //変数pushが5になったら広告を表示
        pushAdbuttanInt += 1
       displayAdByCriteria()
        
        //カメラを起動
        opencamera()
        //広告を再読み込み
        bannerView.load(GADRequest())
        adView.load(GADRequest())
    }
    
    @IBAction func sendData () {
        print(hasWorkedParsing)
        //画像が選択されていなかったら
        if selectedImage == nil{
            analyzingErrorAlert()
            //画像が選択されていたなら
        }else{
            //解析ボタンを何度も押せなくするためのif文
            if hasWorkedParsing == true {
                hasWorkedParsing = false
                //情報、確率の配列を初期化
                information = []
                probability = []
                //くるくる回るやつ( UIActivityIndicatorView)を起動
                activityView.startAnimating()
                //広告カウントを追加
                pushAdbuttanInt = pushAdbuttanInt + 1
                //変数pushが5なら広告を表示
                displayAdByCriteria()
                
                //APIに画像を送る関数を呼び出し。その際引数として選択した画像を設定
                callApi(image: selectedImage)
            }
        }
    }
    
    //画面遷移。名前はノリでつけたので気にしない←ここ重要
    @IBAction func exit (fooooooooooooooooooo: UIStoryboardSegue){
    }
}
