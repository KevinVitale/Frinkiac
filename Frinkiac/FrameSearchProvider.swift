// MARK: - Frame Search Provider -
//------------------------------------------------------------------------------
public final class FrameSearchProvider<M: MemeGenerator> {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    /**
     The callback provided during initialization.
     */
    private var callback: ([FrameImage<M>]) -> () = { _ in }

    /**
     The task which performs the search. 
     */
    private var searchTask: URLSessionTask? = nil

    /**
     The task which fetches a random caption.
     */
    fileprivate var randomTask: URLSessionTask? = nil {
        willSet {
            randomTask?.cancel()
        }
        didSet {
            randomTask?.resume()
        }
    }

    /**
     The frames returned by searching for `searchText`.
     
     - note: Updating this value invokes `callback`, iff: `newValue` isn't `nil`.
     */
    private var results: [FrameImage<M>]? = nil {
        didSet {
            if let results = results {
                callback(results)
            }
        }
    }

    /**
     The search query.
     
     - note: Before updating this value, any in-flight `searchTask` is cancelled,
             and `searchTask` is reassigneld with a new task. After this value 
             is updated, `searchTask` is started.
     */
    fileprivate var searchText: String = "" {
        willSet {
            searchTask?.cancel()
            searchTask = find(newValue) { [weak self] in
                if let frames = try? $0().0 {
                    self?.results = frames.flatMap { frame -> FrameImage<M>? in
                        guard let memeGenerator = self?.memeGenerator else {
                            return nil
                        }
                        return FrameImage(memeGenerator, frame: frame)
                    }
                }
            }
        }
        didSet {
            searchTask?.resume()
        }
    }

    // MARK: - Deinit -
    //--------------------------------------------------------------------------
    deinit {
        randomTask?.cancel()
    }

    // MARK: - Public -
    //--------------------------------------------------------------------------
    /**
     The meme generator service provider.
     */
    public let memeGenerator: M
    
    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    /**
     Initializes a new frame search provider.
     
     - parameter memeGenerator: The domain (and service) being searched. 
     - parameter callback: A callback invoked whenever search results populate.
     */
    public init(_ memeGenerator: M = M(), callback: @escaping ([FrameImage<M>]) -> ()) {
        self.memeGenerator = memeGenerator
        self.callback = callback
    }
}

// MARK: - Extension, Find -
//------------------------------------------------------------------------------
extension FrameSearchProvider {
    /**
     Searches for those frames containg `text`.

     - parameter text: The text being searched for.
     - parameter callback: A callback that can receive another function
                           which will return the frames when executed.
     
     - returns: A session task that, when started, performs a search
                and executes `callback`.
     */
    fileprivate func find(_ text: String, callback: @escaping Callback<([Frame], URLResponse?)>) -> URLSessionTask {
        return memeGenerator.search(for: text, callback: callback)
    }

    /**
     Search for frames containing `text`.

     - parameter text: The query to search for. 
     */
    public func find(_ text: String) {
        searchText = text
    }
}

// MARK: - Extension, Random -
//------------------------------------------------------------------------------
extension FrameSearchProvider {
    /**
     Search for a random caption.
     
     - parameter callback: The callback receiving the result when executed.
     - note: This does not update `results` in the same way `find(_:)` does.
     */
    public func random(callback: @escaping Callback<(frame: FrameImage<M>?, caption: Caption, response: URLResponse?)>) {
        randomTask = memeGenerator.random { [weak self] closure in
            do {
                let result = try closure()
                //--------------------------------------------------------------
                let caption = result.0
                let memeGenerator = self?.memeGenerator ?? M()
                //--------------------------------------------------------------
                callback { (FrameImage(memeGenerator, frame: caption.frame), caption, result.1) }
            } catch let error {
                callback { throw error }
            }
        }
    }
}
