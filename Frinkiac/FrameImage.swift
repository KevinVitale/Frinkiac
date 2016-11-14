// MARK: - Frame Image -
//------------------------------------------------------------------------------
public final class FrameImage<M: MemeGenerator>: Equatable {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    /// An optional task that downloads image data when started.
    ///
    /// - note: Prior to assigning this a new value, any current in-flight work
    ///         is cancelled.
    fileprivate var imageTask: URLSessionTask? = nil {
        willSet { imageTask?.cancel() }
        didSet  { imageTask?.resume() }
    }

    /// A meme generator.
    fileprivate let memeGenerator: M

    // MARK: - Public -
    //--------------------------------------------------------------------------
    public let frame: Frame
    public fileprivate(set) var caption:  Caption?     = nil
    public fileprivate(set) var image:    ImageType?   = nil
    public fileprivate(set) var memeText: MemeText?    = nil
    public fileprivate(set) var response: URLResponse? = nil

    // MARK: - Deinit -
    //--------------------------------------------------------------------------
    deinit {
        imageTask?.cancel()
    }
    
    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    /**
     Instantiates a new `FrameImage` for the given `frame`.

     - parameter memeGenerator: The meme generator instance to use. If omitted,
                                one will be created automatically.
     - parameter frame: The model being represented.
     */
    public required init(_ memeGenerator: M = M(), frame: Frame) {
        self.memeGenerator = memeGenerator
        self.frame = frame
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    public static func ==(lhs: FrameImage<M>, rhs: FrameImage<M>) -> Bool {
        return lhs.frame == rhs.frame
    }
}

// MARK: - Extension, Image Request -
//--------------------------------------------------------------------------
extension FrameImage {
    // MARK: - Caption Request -
    //--------------------------------------------------------------------------
    /**
     Update `caption`, applying the text of `caption` to the image.
     
     - parameter callback: A callback that, when invoked, returns the results of
                           `self` after being updated.
     */
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

    // MARK: - Update Request -
    //--------------------------------------------------------------------------
    /**
     Updates `text` for the image.
     
     - parameter text: The meme text to display on the image.
     - parameter callback: A callback that, when invoked, returns the results of
                           `self` after being updated.

     - note: This call has side-effects which updates the value of `image`, 
             `memeText`, and `response`.
     */
    public func update(text: MemeText? = nil, callback: @escaping Callback<FrameImage<M>?>) {
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
}
