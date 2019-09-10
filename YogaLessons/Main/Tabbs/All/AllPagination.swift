//
//  AllPagination.swift
//  YogaLessons
//
//  Created by Eran karaso on 13/08/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit
import SVProgressHUD


//Pagination
extension AllTableViewController{
//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        
////        let actualPosition = scrollView.panGestureRecognizer.translation(in: scrollView.superview)
////
////        let offsetY = scrollView.contentOffset.y
////        let contentHeight = scrollView.contentSize.height
////        if offsetY > contentHeight - scrollView.frame.size.height * leadingScreenForBatching {
////
////            if !isFetchingMore && !hasEndReached {
////                beginBatchFetch()
////            }
////        }
//        
//        
//        let height = scrollView.frame.size.height
//        let contentYoffset = scrollView.contentOffset.y
//        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
//        if distanceFromBottom < height {
//            if !hasEndReached && !isFetchingMore {
//                beginBatchFetch()
//            }
//        }
//    }
    
    
//    func beginBatchFetch() {
//        
//        isFetchingMore = true
//        dataSource.loadAllBatch(currentDataType, loadFromBegining: false) { endReached in
//            self.isFetchingMore = false
//            self.hasEndReached = endReached
//            
//            UIView.performWithoutAnimation {
//                self.tableView.reloadData()
//            }
//            
//        }
//    }
}
