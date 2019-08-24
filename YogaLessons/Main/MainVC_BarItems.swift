//
//  Main.swift
//  YogaLessons
//
//  Created by Eran karaso on 29/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

//MARK: tab bar button items
extension MainTabBarController:UITabBarControllerDelegate{
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        guard let i = tabBar.items?.firstIndex(of: item)
            else { return }
        
        self.currentSourceType = SourceType.allCases[i]
        
        updateTitle()
        
        navigationItem.setRightBarButtonItems(barItemsForTab[i], animated: true)
    }
    
    func createSignedBarItems() -> [UIBarButtonItem] {
        
        typealias signedVC_Type = SignedTableViewController
        
        guard let signedVC = viewControllers?.first(where: { $0 is signedVC_Type}) as? signedVC_Type
            else{return [sortBtn]}
        
        let editBtn = signedVC.editButtonItem
        
        editBtn.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        
        //        guard let t = YUser.currentUser?.type ,
        //            t != .student else{
        //                return [editBtn,sortBtn]
        //        }
        
        
        return [editBtn,sortBtn]
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        return animateSlide(selectedIndex: tabBarController.selectedIndex,viewController: viewController)
    }
    
    
    func animateSlide(selectedIndex : Int,viewController:UIViewController) -> Bool {
        guard let fromView = selectedViewController?.view,
            let toView = viewController.view else {
                return false
        }
        
        guard let controllerIndex = self.viewControllers?.firstIndex(of: viewController)
            else{return false}
        
        let viewSize = fromView.frame
        let scrollRight = controllerIndex > selectedIndex
        // Avoid UI issues when switching tabs fast
        
        guard fromView.superview?.subviews.contains(toView) != true
            else{ return false }
        
        fromView.superview?.addSubview(toView)
        let screenWidth = UIScreen.main.bounds.size.width
        
        toView.frame = .init(x: (scrollRight ? screenWidth : -screenWidth),
                             y: viewSize.origin.y,
                             width: screenWidth, height: viewSize.size.height)
        
        UIView.animate(withDuration: 0.25, delay: 0,
                       options: [.curveEaseOut, .preferredFramesPerSecond60],
                       animations: {
                        
                        fromView.frame = CGRect(x: (scrollRight ? -screenWidth : screenWidth),
                                                y: viewSize.origin.y,
                                                width: screenWidth, height: viewSize.size.height)
                        
                        toView.frame = CGRect(x: 0, y: viewSize.origin.y,
                                              width: screenWidth, height: viewSize.size.height)
        }) { finished in
            guard finished else{return}
            
            fromView.removeFromSuperview()
            self.selectedIndex = controllerIndex
        }
        
        
        return true
    }
}
