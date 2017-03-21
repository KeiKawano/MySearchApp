//
//  SearchItemTableViewController.swift
//  MySearchApp
//
//  Created by Kei on 2017/03/20.
//  Copyright © 2017年 Kei. All rights reserved.
//

import UIKit

class SearchItemTableViewController: UITableViewController, UISearchBarDelegate{

    // 商品情報を格納する配列
    var itemDataArray = [ItemData]()
    // 商品画像のキャッシュを管理する変数
    var imageCache = NSCache<AnyObject, UIImage>()
    // APIを利用するためのアプリケーションID
    let appid: String = "dj0zaiZpPTFKZ1d2MnlEdGJCeSZzPWNvbnN1bWVyc2VjcmV0Jng9MmM-"
    // APIのURL
    let entryUrl: String = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch"
    // 数字を金額の形式に整形するためのフォーマッター
    let priceFormat = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 価格のフォーマット指定
        priceFormat.numberStyle = .currency
        priceFormat.currencyCode = "JPY"

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK - search bar delegate
    // キーボードのsearchボタンがタップされたときに呼び出される
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 入力された文字列の取り出し
        guard let inputText = searchBar.text else {
            // 文字入力なし
            return
        }
        // 入力文字が0文字より多いかどうかチェックする
        guard inputText.lengthOfBytes(using: String.Encoding.utf8) > 0 else {
            // 0文字より多くなかった
            return
        }
        // 保持している商品を一旦削除
        itemDataArray.removeAll()
        // パラメータを指定する
        let parameter = ["appid": appid, "query": inputText]
        // パラメータをエンコードしたURLを作成する
        let requestUrl = createRequestUrl(parameter: parameter)
        // APIをリクエストする
        request(requestUrl: requestUrl)
        // キーボードを閉じる
        searchBar.resignFirstResponder()
    }
    // パラメータのURLエンコード処理
    func encodeParameter(key: String, value: String) -> String? {
        // 値をエンコードする
        guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
            // エンコード失敗
            return nil
        }
        // エンコードした値をkey=value形式で返却する
        return "\(key)=\(escapedValue)"
    }
    // URL作成処理
    func createRequestUrl(parameter: [String: String]) -> String {
        var parameterString = ""
        for key in parameter.keys {
            // 値の取り出し
            guard let value = parameter[key] else {
                // 値なし。次のfor文の処理を行う
                continue
            }
            // 既にパラメータが設定されていた場合
            if parameterString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
                // パラメータ同士のセパレータである「&」を追加する
                parameterString += "&"
            }
            // 値をエンコードする
            guard let encodeValue = encodeParameter(key: key, value: value) else {
                // エンコード失敗。次のfor文の処理を行う
                continue
            }
            // エンコードした値をパラメータとして追加する
            parameterString += encodeValue
        }
        let requestUrl = entryUrl + "?" + parameterString
        return requestUrl
    }
    // 検索結果をパースして商品リストを作成する
    func parseData(resultSet: [String: Any]) {
        guard let firstObject = resultSet["0"] as? [String: Any] else {
            return
        }
        guard let results = firstObject["Result"] as? [String: Any] else {
            return
        }
        for key in results.keys.sorted() {
            // Requestのキーは無視する
            if key == "Request" {
                continue // 次のfor文の処理を行う
            }
            // 商品アイテム取得
            guard let result = results[key] as? [String: Any] else {
                continue // 次のfor文の処理を行う
            }
            // 商品データ格納オブジェクトを作成
            let itemData = ItemData()
            // レスポンスデータから画像の情報を取得する
            if let itemImageDic = result["Image"] as? [String: Any] {
                let itemImageUrl = itemImageDic["Medium"] as? String
                itemData.itemImageUrl = itemImageUrl
            }
            // 商品タイトルを格納
            let itemTitle = result["Name"] as? String
            itemData.itemTitle = itemTitle
            // 商品価格を格納
            if let itemPriceDic = result["Price"] as? [String: Any] {
                let itemPrice = itemPriceDic["_value"] as? String
                itemData.itemPrice = itemPrice
            }
            // 商品のURLを格納（WebView用）
            let itemUrl = result["Url"] as? String
            itemData.itemUrl = itemUrl
            
            // 商品のリストに追加
            self.itemDataArray.append(itemData)
        }
    }
    // リクエストを行う
    func request(requestUrl: String) {
        // URL生成
        guard let url = URL(string: requestUrl) else {
            return // URL生成失敗
        }
        // リクエスト生成
        let request = URLRequest(url: url)
        // 商品検索APIをコールして商品検索を行う
        let session = URLSession.shared
        let task = session.dataTask(with: request) {
            (data: Data?, response: URLResponse?, error: Error?) in
            // 通信完了後の処理
            // エラーチェック
            guard error == nil else{
                // エラー表示
                let alert = UIAlertController(title: "エラー", message: error?.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                // UIに関する処理はメインスレッドで行う
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
            // JSONで返却されたデータをパースして格納する
            guard let data = data else {
                return // データなし
            }
            // JSON形式への変換処理
            guard let jsonData = try! JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: Any] else {
                return // 変換失敗
            }
            // データを解析
            guard let resultSet = jsonData["ResultSet"] as? [String: Any] else {
                return // データなし
            }
            self.parseData(resultSet: resultSet)
            
            // テーブルの描画処理を実施
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        // 通信開始
        task.resume()
    }
    // MARK: - Table view data source
    // テーブルのセクション数を取得
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    // セクション内の商品数を取得
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return itemDataArray.count
    }
    // テーブルセルの取得処理
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        let itemData = itemDataArray[indexPath.row]
        // 商品のタイトル設定
        cell.itemTitleLabel.text = itemData.itemTitle
        // 商品価格設定処理（日本通過の形式で設定する）
        let number = NSNumber(integerLiteral: Int(itemData.itemPrice!)!)
        cell.itemPriceLabel.text = priceFormat.string(from: number)
        // 商品のURL設定
        cell.itemUrl = itemData.itemUrl
        // 画像の設定処理
        // 既にセルに設定されている画像と同じかどうかチェックする
        // 画像がまだ設定されていない場合に処理を行う
        guard let itemImageUrl = itemData.itemImageUrl else {
            // 画像なし商品
            return cell
        }
        // キャッシュの画像を取り出す
        if let cacheImage = imageCache.object(forKey: itemImageUrl as AnyObject) {
            // キャッシュ画像の設定
            cell.itemImageView.image = cacheImage
            return cell
        }
        // キャッシュの画像が無いためダウンロードする
        guard let url = URL(string: itemImageUrl) else {
            // urlが生成できなかった
            return cell
        }
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {
                return // エラーあり
            }
            guard let data = data else {
                return // データが存在しなし
            }
            guard let image = UIImage(data: data) else {
                return // imageが生成できなかった
            }
            // ダウンロードした画像をキャッシュに登録しておく
            self.imageCache.setObject(image, forKey: itemImageUrl as AnyObject)
            // 画像はメインスレッド上で設定する
            DispatchQueue.main.async {
                cell.itemImageView.image = image
            }
        }
        // 画像の読み込み処理開始
        task.resume()
        
        return cell
    }
    
    // 商品をタップして次の画面に遷移する前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ItemTableViewCell {
            if let webViewController = segue.destination as? WebViewController {
                // 商品ページのURLを設定する
                webViewController.itemUrl = cell.itemUrl
            }
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
