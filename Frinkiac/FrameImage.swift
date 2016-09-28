//------------------------------------------------------------------------------
// MARK: - Frame Image -
//------------------------------------------------------------------------------
public final class FrameImage: Equatable {
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public let frame: Frame
    public private(set) var image: ImageType? = nil

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init(_ frame: Frame, delegate: FrameImageDelegate? = nil) {
        self.frame = frame
        //----------------------------------------------------------------------
        frame.imageLink.download {
            if let image = try? $0() {
                self.image = image

                DispatchQueue.main.async {
                    delegate?.frame(self, didUpdate: image!)
                }
            }
        }
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    public static func ==(lhs: FrameImage, rhs: FrameImage) -> Bool {
        return lhs.frame.id == rhs.frame.id
    }
}

// MARK: - Frame Image Delegate -
//------------------------------------------------------------------------------
public protocol FrameImageDelegate: class {
    func frame(_ : FrameImage, didUpdate image: ImageType)
}
