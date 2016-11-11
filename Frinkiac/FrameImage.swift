// MARK: - Frame Image -
//------------------------------------------------------------------------------
public final class FrameImage<M: MemeGenerator>: Equatable {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private var imageTask: URLSessionTask? = nil {
        willSet { imageTask?.cancel() }
        didSet  { imageTask?.resume() }
    }
    private let memeGenerator: M

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public let frame: Frame
    public private(set) var caption: Caption? = nil
    public private(set) var image: ImageType? = nil
    public private(set) var response: URLResponse? = nil
    public private(set) var memeText: MemeText? = nil

    // MARK: - Deinit -
    //--------------------------------------------------------------------------
    deinit {
        imageTask?.cancel()
    }
    
    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public required init(_ memeGenerator: M = M(), frame: Frame) {
        self.memeGenerator = memeGenerator
        self.frame = frame
    }

    // MARK: - Image Request -
    //--------------------------------------------------------------------------
    public func image(text: MemeText? = nil, callback: @escaping Callback<FrameImage<M>?>) {
        imageTask = memeGenerator.imageGenerator.image(frame: frame, text: text) { [weak self] closure in
            do {
                let result = try closure()
                //--------------------------------------------------------------
                self?.image = result.0
                self?.response = result.1
                self?.memeText = text
                //--------------------------------------------------------------
                callback {
                    return self
                }
            } catch let error {
                callback { throw error }
            }
        }
    }

    // MARK: - Caption Request -
    //--------------------------------------------------------------------------
    public func caption(callback: @escaping Callback<FrameImage<M>?>) {
        imageTask = memeGenerator.caption(with: frame) { [weak self] in
            do {
                let result = try $0()
                self?.caption = result.0
                self?.update(text: .lines(self?.caption?.lines), callback: callback)
            } catch let error {
                callback { throw error }
            }
        }
    }

    // MARK: - Update Text Request -
    //--------------------------------------------------------------------------
    public func update(text: MemeText? = nil, callback: @escaping Callback<FrameImage<M>?>) {
        image(text: text, callback: callback)
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    public static func ==(lhs: FrameImage<M>, rhs: FrameImage<M>) -> Bool {
        return lhs.frame == rhs.frame
    }
}
