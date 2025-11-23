//
//  NibOwnerLoadable.swift
//  Pokemon
//
//  Created by 莊羚羊 on 2025/11/23.
//

import Foundation
import UIKit

// NibOwnerLoadable 協議的作用是為了讓 xib 能夠從 Nib 文件中載入其內容。通過遵從這個協議，視圖可以使用 loadNibContent 方法來載入 Nib 文件的內容

protocol NibOwnerLoadable: AnyObject {
    static var nib: UINib { get }
}

// MARK: - Default implmentation
extension NibOwnerLoadable {
    
    static var nib: UINib {
        UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

// MARK: - Supporting methods
extension NibOwnerLoadable where Self: UIView {
    
    // 如果 .nib 檔名和 class 名一致就用這個
    func loadNibContent() {
        guard let views = Self.nib.instantiate(withOwner: self, options: nil) as? [UIView],
            let contentView = views.first else {
                fatalError("Fail to load \(self) nib content")
        }
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    // 如果 .nib 檔名和 class 不一致就要用這個輸入 .nib 檔名，才抓得到檔案
    func loadNibContent(nibName: String) {
        guard let views = Bundle.main.loadNibNamed(nibName, owner: self, options: nil) as? [UIView],
            let contentView = views.first else {
                fatalError("Fail to load \(self) nib content")
        }
        self.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
}
