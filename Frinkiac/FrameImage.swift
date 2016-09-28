//------------------------------------------------------------------------------
// MARK: - Frame Image -
//------------------------------------------------------------------------------
public final class FrameImage: Equatable {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private let frameID: Int
    
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public private(set) var image: ImageType? = nil

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init(_ frame: Frame, delegate: FrameImageDelegate? = nil) {
        frameID = frame.id
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
        return lhs.frameID == rhs.frameID
    }
}

// MARK: - Frame Image Delegate -
//------------------------------------------------------------------------------
public protocol FrameImageDelegate: class {
    func frame(_ : FrameImage, didUpdate image: ImageType)
}
