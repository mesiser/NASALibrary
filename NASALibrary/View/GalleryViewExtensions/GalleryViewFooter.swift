//
//  GalleryViewFooter.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 10.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

extension GalleryViewController {
    
    //MARK: - Footer
    
    func setToolBar() {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let flexibleSpace1 = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        let scrollUPButton = UIBarButtonItem(title: "↑", style: .plain, target: self, action: #selector(scrollToTop))
        scrollUPButton.tintColor = UIColor.white
        let arr: [Any] = [flexibleSpace, scrollUPButton, flexibleSpace1]
        setToolbarItems(arr as? [UIBarButtonItem] ?? [UIBarButtonItem](), animated: true)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    @objc func scrollToTop() {
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
        navigationController?.setToolbarHidden(true, animated: true)
    }
}
