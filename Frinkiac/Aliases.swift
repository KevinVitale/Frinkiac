#if os(macOS)
    import Cocoa
    public typealias ImageType = NSImage
#else
    import UIKit
    public typealias ImageType = UIImage
#endif
//------------------------------------------------------------------------------
typealias Callback<T> = ((() throws -> T?) -> ())
