//
//  GalleryViewDelegate.swift
//  NASALibrary
//
//  Created by Vadim Shalugin on 08.08.2020.
//  Copyright © 2020 Vadim Shalugin. All rights reserved.
//

import UIKit

// MARK:- Collection View Delegate Methods

extension GalleryViewController {
    
//MARK:- Showing full size photo
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Image tapped 🤭")
        collectionView.allowsSelection = false
        let image = imageRecords[indexPath.row].image
        if image == UIImage(named: "NASA") {
            operationManager.suspendBackgroundOperations()
            operationManager.updateDownloadQueueForPriorityItems(at: [indexPath])
            downloadImage(at: indexPath, withPriority: .high) { [weak self] (indexPath) in
                self?.showFullSizePhoto(for: (self?.imageRecords[indexPath.row].image!)!)
                self?.operationManager.resumeBackgroundOperations()
            }
        } else {
            showFullSizePhoto(for: image!)
        }
    }
    
//MARK:- Getting new images urls
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
         if indexPath.row == imageRecords.count - 20 {
            print("The end is near 🙀")
            pageNumber += 1
            getImagesURLS()
         }
    }
    
//MARK:- Uploading images for visible cells
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            downloadImagesForVisibleCells()
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        downloadImagesForVisibleCells()
    }
    
//MARK:- Showing footer
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard navigationController?.toolbar.isHidden == true else{return}
        navigationController?.setToolbarHidden(false, animated: true)
        if operationManager.operationsSuspended {
            operationManager.resumeAllOperations()
        }
    }
}
