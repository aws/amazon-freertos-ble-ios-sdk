import UIKit

extension UIFont {

    class func amazonEmberBoldFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AmazonEmber-Bold", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    class func amazonEmberMediumFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AmazonEmber-Medium", size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }

    class func amazonEmberRegularFontOfSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "AmazonEmber-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}
