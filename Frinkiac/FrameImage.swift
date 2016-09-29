//------------------------------------------------------------------------------
// MARK: - Frame Image -
//------------------------------------------------------------------------------
public final class FrameImage: Equatable {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private weak var delegate: FrameImageDelegate? = nil
    private var frameDownloadTask: URLSessionTask? = nil
    private var captionDownloadTask: URLSessionTask? = nil
    private var memeCaptionDownloadTask: URLSessionTask? = nil
    
    // MARK: - Public -
    //--------------------------------------------------------------------------
    public let frame: Frame
    public private(set) var image: ImageType? = nil {
        didSet {
            if let image = image {
                DispatchQueue.main.async {
                    self.delegate?.frame(self, didUpdate: image)
                }
            }
        }
    }
    public private(set) var caption: Caption? = nil
    public private(set) var meme: ImageType? = nil

    // MARK: - Memory Cleanup -
    //--------------------------------------------------------------------------
    deinit {
        frameDownloadTask?.cancel()
        captionDownloadTask?.cancel()
        memeCaptionDownloadTask?.cancel()
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init(_ frame: Frame, delegate: FrameImageDelegate? = nil) {
        self.frame = frame
        self.delegate = delegate

        // Download frame image
        //----------------------------------------------------------------------
        frameDownloadTask = frame.imageLink.download { [weak self] in
            if let image = try? $0()
             , let this = self {
                this.image = image
            }
        }
        frameDownloadTask?.resume()

        // Download caption image
        //----------------------------------------------------------------------
        captionDownloadTask = Frinkiac.caption(with: frame) { [weak self] in
            if let caption = try? $0().0 {
                self?.memeCaptionDownloadTask = caption.memeLink.download {
                    if let image = try? $0()
                     , let this = self {
                        this.meme = image
                    }
                }

                //--------------------------------------------------------------
                self?.memeCaptionDownloadTask?.resume()
            }
        }
        captionDownloadTask?.resume()
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
