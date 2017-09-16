//
//  TSecondViewController.swift
//  Whatisit
//
//  Created by 田中颯太 on 2017/08/05.
//  Copyright © 2017年 田中颯太. All rights reserved.
//

import UIKit
//チュートリアル画面でステータスバーを非表示にする
class TSecondViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
