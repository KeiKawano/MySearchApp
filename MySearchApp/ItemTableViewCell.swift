//
//  ItemTableViewCell.swift
//  MySearchApp
//
//  Created by Kei on 2017/03/20.
//  Copyright © 2017年 Kei. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView! // 商品画像
    @IBOutlet weak var itemTitleLabel: UILabel! //　商品タイトル
    @IBOutlet weak var itemPriceLabel: UILabel! // 商品価格
    var itemUrl: String? // 商品ページのURL。遷移先の画面で利用する
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        // 元々入っている情報を再利用時にクリア
        itemImageView.image = nil
    }
}
