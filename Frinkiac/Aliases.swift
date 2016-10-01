#if os(macOS)
    import Cocoa
    public typealias ImageType = NSImage
#else
    import UIKit
    public typealias ImageType = UIImage

// MARK: - Extension, Simpsons Yellow -
//------------------------------------------------------------------------------
extension UIColor {
    public class var simpsonsYellow: UIColor {
        return UIColor(red: 1.0, green: (217.0/255.0), blue: (15.0/255.0), alpha: 1.0)
    }

    public class var simpsonsBlue: UIColor {
        return UIColor(red: (23.0/255.0), green: (145.0/255.0), blue: 1.0, alpha: 1.0)
    }

    public class var simpsonsPaleBlue: UIColor {
        return UIColor(red: (112.0/255.0), green: (209.0/255.0), blue: 1.0, alpha: 1.0)
    }

    public class var simpsonsPastelGreen: UIColor {
        return UIColor(red: (209.0/255.0), green: 1.0, blue: (135.0/255.0), alpha: 1.0)
    }

    public class var simpsonsFleshy: UIColor {
        return UIColor(red: (209.0/255.0), green: (178.0/255.0), blue: (112.0/255.0), alpha: 1.0)
    }
}
#endif

//------------------------------------------------------------------------------
public typealias Callback<T> = ((() throws -> T?) -> ())
