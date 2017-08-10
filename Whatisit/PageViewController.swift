//
//  PageViewController.swift
//  Whatisit
//
//  Created by 田中颯太 on 2017/08/05.
//  Copyright © 2017年 田中颯太. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    let sboard: UIStoryboard? = UIStoryboard(name:"Main", bundle:nil)
    var pageViewControllers: [UIViewController] = []
    var page: Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
       
             
        dataSource = self
        let tfirstViewController: TFirstViewController = storyboard!.instantiateViewController(withIdentifier: "TFirstViewController") as! TFirstViewController
        
        //2ページ目をインスタンス化
        let tsecondViewController: TSecondViewController = storyboard!.instantiateViewController(withIdentifier: "TSecondViewController") as! TSecondViewController
        
        pageViewControllers = [tfirstViewController,tsecondViewController]
        //UIPageViewControllerに表示対象を設定
        setViewControllers([pageViewControllers[0]], direction: .forward, animated: false, completion: nil)
        view.backgroundColor = #colorLiteral(red: 0.6431372549, green: 0.8431372549, blue: 0.8901960784, alpha: 1)
        
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return 2
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return page
    }
    
    func pageViewController(_ pageViewController:
        UIPageViewController, viewControllerBefore viewController:UIViewController) -> UIViewController? {
        //右にスワイプした場合に表示したいviewControllerを返す
        //ようはページを戻す
        //今表示しているページは何ページ目か取得する
        let index = pageViewControllers.index(of: viewController)
        
        if index == 0 {
            page = index!
            //1ページ目の場合は何もしない
            return nil
        } else {
            page = index! - 1
            //1ページ目の意外場合は1ページ前に戻す
            return pageViewControllers[index!-1]
        }
    }
    
    func pageViewController(_ pageViewController:
        UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        //左にスワイプした場合に表示したいviewControllerを返す
        //ようはページを進める
        //今表示しているページは何ページ目か取得する
        let index = pageViewControllers.index(of: viewController)
        if index == pageViewControllers.count-1 {
            //最終ページの場合は何もしない
            return nil
        } else {
            //最終ページの意外場合は1ページ進める
            return pageViewControllers[index!+1]
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
}


//チタン窒素コバルト
