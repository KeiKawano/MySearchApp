//
//  WebViewController.swift
//  MySearchApp
//
//  Created by Kei on 2017/03/20.
//  Copyright © 2017年 Kei. All rights reserved.
//

import UIKit

// 商品ページを参照するための画面
class WebViewController: UIViewController {

    // 商品ページのURL
    var itemUrl: String?
    // 商品ページを参照するためのWebView
    @IBOutlet weak var webView: UIWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // WebViewのURLを読み込ませてWebページを表示させる
        guard let itemUrl = itemUrl else {
            return
        }
        guard let url = URL(string: itemUrl) else {
            return
        }
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
