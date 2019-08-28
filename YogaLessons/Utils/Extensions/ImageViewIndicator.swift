import UIKit
import SVProgressHUD

private var activityIndicatorAssociationKey: UInt8 = 0

extension UIImageView {

    
    private var activityIndicator: UIActivityIndicatorView! {
        get {
            return objc_getAssociatedObject(self, &activityIndicatorAssociationKey) as? UIActivityIndicatorView
        }
        set(newValue) {
            objc_setAssociatedObject(self, &activityIndicatorAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func showActivityIndicator() {
        
        if (activityIndicator == nil) {

            activityIndicator = .init(style: .whiteLarge)
            activityIndicator.color = .blue
            activityIndicator.backgroundColor = .white

            activityIndicator.hidesWhenStopped = true
            activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
            
            activityIndicator.roundCorners(radius: activityIndicator.frame.width/2)


            activityIndicator.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)

            activityIndicator.autoresizingMask =
                [.flexibleLeftMargin , .flexibleRightMargin , .flexibleTopMargin , .flexibleBottomMargin]

            activityIndicator.isUserInteractionEnabled = false


            OperationQueue.main.addOperation{
                self.addSubview(self.activityIndicator)
                self.activityIndicator.startAnimating()
            }
        }
    }
    
    
    func hideActivityIndicator() {
        OperationQueue.main.addOperation{
            self.activityIndicator.stopAnimating()
        }
    }
}
