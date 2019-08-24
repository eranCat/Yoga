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
        
        btn.backgroundColor = .gray
        btn.setTitleColor(.white, for: .normal)
        
        btn.setTitle(sortType.translated.capitalized, for: .normal)
        
        btn.titleLabel?.font = btn.titleLabel?.font.withSize(16)
        
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
        
        UIView.animate(withDuration: 0.2,animations:  {
            self.alertContentView.alpha = 0
        }){ _ in
            self.dismiss(animated: true)
            completion?()
        }
    }
    
    static func show() {
        guard let vc = newVC(storyBoardName: "FilterDialog", id: "FilterDialog") as? SortAlert
            else{return}
        //delegate from outside to call when sort picked
        
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        
        UIApplication.shared.presentedVC?.present(vc, animated: true)
    }
}
