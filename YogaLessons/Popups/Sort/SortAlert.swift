//
//  PopUpViewController.swift
//  Lec16
//
//  Created by Eran karaso on 26/06/2019.
//  Copyright © 2019 Eran karaso. All rights reserved.
//

import UIKit

class SortAlert: UIViewController {
    
    @IBOutlet weak var optionsStack: UIStackView!
    
    @IBOutlet weak var segmentType: UISegmentedControl!
    
    @IBOutlet weak var alertContentView: UIView!
    
    
    static var currentDataTypeIndex:Int?//[classes,events] -> 0/1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertContentView.layer.cornerRadius = 10
        alertContentView.clipsToBounds = true
    
        shadow()
        
        setupSortButtons()
        setupTypeSegment()
        
        alertContentView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        animateFromTop()
        animateZoom(into: true)
    }
    
    func animateZoom(into:Bool,completion:((Bool)->Void)? = nil) {
        
        alertContentView.alpha = into ? 0.7 : 1

        let from:CGFloat = into ? 0.001 : 1
        let to:CGFloat = into ? 1 : 0.001
        
        alertContentView.transform =
            CGAffineTransform.identity.scaledBy(x: from, y: from)
        
        let duration = into ? 0.4 : 0.3
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 20, options: .curveEaseInOut, animations: {
            
            self.alertContentView.transform =
                CGAffineTransform.identity.scaledBy(x: to, y: to)
            self.alertContentView.alpha = into ? 1 : 0
            
            
        }, completion: completion)
    }
    
    func animateFromTop() {
        alertContentView.center.y = -alertContentView.frame.height - 10
        alertContentView.alpha = 1
        
        UIView.animate(withDuration: 0.6,
                       delay: 0,
                       usingSpringWithDamping: 1,
                       initialSpringVelocity: 10,
                       options: .curveEaseInOut,
                       animations: { [weak self] in
                        guard let self = self else{return}
                        
                        self.alertContentView.center.y = self.view.frame.height/2
            },
                       completion: nil)
    }
    
    
    func shadow(color:UIColor = .black,
                opacity:Float = 0.75,
                offset:CGSize = .init(width: 2,height: 2),
                radius:CGFloat = 5) {
        
        let layer = alertContentView.layer
        
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.shadowRadius = radius

        //        ask iOS to cache the rendered shadow so that it doesn't need to be redrawn
        layer.shouldRasterize = true

        layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    fileprivate func setupSortButtons() {
        optionsStack.translatesAutoresizingMaskIntoConstraints = false
        SortType.allCases.forEach{ addAction(sortType: $0) }
    }
    
    func setupTypeSegment() {
        
        let font = UIFont(name: "Kailasa", size: 18) ?? UIFont.systemFont(ofSize: 18)
        segmentType.setTitleTextAttributes(
            [NSAttributedString.Key.font: font],
            for: .normal)
        
        segmentType.removeAllSegments()
        
        for (i,dt) in DataType.allCases.enumerated(){
            
            let type = dt.translated.capitalized
            segmentType.insertSegment(withTitle: type, at: i, animated: false)
        }
        
        segmentType.selectedSegmentIndex = SortAlert.currentDataTypeIndex ?? 0
    }
    fileprivate func addAction(sortType:SortType) {
        //new button
        //target = handler
        
        let btn = UIButton(type: .system)
        //        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        btn.rounded = 8
        
        btn.backgroundColor = UIColor._primary
        btn.setTitleColor(UIColor._accent, for: .normal)
        btn.setTitleColor(.white, for: .selected)

        
        btn.setTitle(sortType.translated.capitalized, for: .normal)
        
        btn.titleLabel?.font = btn.titleLabel?.font.withSize(18)
        
        btn.tag = sortType.rawValue
        
        btn.addTarget(self, action: #selector(helper(_:)), for: .touchUpInside)
        
        self.optionsStack.addArrangedSubview(btn)
    }
    @objc
    func helper(_ btn:UIButton){
        
        guard let sType = SortType(rawValue: btn.tag),
            let dType = DataType(rawValue: segmentType.selectedSegmentIndex)
            else{return hide()}
        
        NotificationCenter.default.post(name: ._sortTapped , userInfo: ["dataTuple":(dType,sType)])
        
        hide()
    }
    
    
    @IBAction func done(_ sender: UIButton) {
        
        let dType = DataType.allCases[segmentType.selectedSegmentIndex]
            
        NotificationCenter.default.post(name: ._sortTapped , userInfo: ["dataTuple":(dType,SortType.best)])
        
        SortAlert.currentDataTypeIndex = dType.rawValue
        
        hide()
    }
    
    
    @IBAction func close(_ sender: UIButton) {
        hide()
    }
    
    func hide(completion:(()->Void)? = nil){
        
        animateZoom(into: false){ _ in
            self.dismiss(animated: true)
            completion?()
        }
    }
    
    class func show() {
        guard let vc = newVC(storyBoardName: "FilterDialog", id: "FilterDialog") as? SortAlert
            else{return}
        //delegate from outside to call when sort picked
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        UIApplication.shared.presentedVC?.present(vc, animated: true)
    }
}
