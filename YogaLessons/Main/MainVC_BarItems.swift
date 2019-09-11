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
    
    private var bounceAnimation: CAKeyframeAnimation {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.3, 0.9, 1.02, 1.0]
        bounceAnimation.duration = 0.3
        bounceAnimation.calculationMode = .cubic
        return bounceAnimation
    }
    
    func changeBarButtons(bySelectedIndex i: Int) {
        currentSourceType = SourceType.allCases[i]
        
        navigationItem.setRightBarButtonItems(barItemsForTab[i], animated: true)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        
        guard let i = tabBar.items?.firstIndex(of: item)
            else { return }
        
        if tabBar.subviews.count > i + 1{
            
            let subs = tabBar.subviews[i + 1].subviews
            
            if let imageView = subs.first(where: { $0 is UIImageView }){
                imageView.layer.add(bounceAnimation, forKey: nil)
            }
            
        }
        
        changeBarButtons(bySelectedIndex: i)
        
        NotificationCenter.default.post(name: ._signedTabSelected, object: nil)
    }
    
    func createSignedBarItems() -> [UIBarButtonItem] {
        
        typealias signedVC_Type = SignedTableViewController
        
        guard let signedVC = viewControllers?.first(where: { $0 is signedVC_Type}) as? signedVC_Type
            else{return [sortBtn]}
        
        let editBtn = signedVC.editButtonItem
        
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
        var scrollRight = controllerIndex > selectedIndex
        // Avoid UI issues when switching tabs fast
        
        let language = Locale.preferredLanguages[0]
        if language.starts(with: "he") ||  language.starts(with: "ar"){
            
            scrollRight = !scrollRight // switch direction
        }
        
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
