//
//  Extensions.swift
//  Messenger
//
//  Created by MRK on 13.04.2024.
//

/*
 bir UIView örneği üzerinde genişlik, yükseklik, üst kenar, alt kenar, sol kenar ve sağ kenar gibi özelliklere erişmek için hesaplanmış özellikler sağlar.
 */

import Foundation
import UIKit

extension UIView{
    
    public var width: CGFloat{
        return self.frame.size.width
    }
    
    public var height: CGFloat{
        return self.frame.size.height
    }
    
    public var top: CGFloat{
        return self.frame.origin.y
    }
    
    public var bottom: CGFloat{
        return self.frame.size.height + self.frame.origin.y
    }
    
    public var left: CGFloat{
        return self.frame.origin.x
    }
    
    public var right: CGFloat{
        return self.frame.size.width + self.frame.origin.x
    }
    
}

extension Notification.Name {
    static let didLogNotification = Notification.Name("didLogInNotification")
}
