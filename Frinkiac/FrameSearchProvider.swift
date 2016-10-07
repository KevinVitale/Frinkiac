// MARK: - Frame Search Provider -
//------------------------------------------------------------------------------
public final class FrameSearchProvider<S: MemeGenerator> {
    // MARK: - Private -
    //--------------------------------------------------------------------------
    /// - parameter callback: The callback provided during initialization.
    private var callback: (([FrameImage]) -> ()) = { _ in }

    /// - parameter searchTask: The task which performs the search.
    private var searchTask: URLSessionTask? = nil
    private var delegate: FrameImageDelegate? = nil

    /// - parameter results: The frames returned by searching for `searchText`.
    /// - note: Updating this value invokes `callback`, iff: `newValue` isn't `nil`.
    private var results: [FrameImage]? = nil {
        didSet {
            if let results = results {
                callback(results)
            }
        }
    }

    /// - parameter searchText: The search query.
    /// - note: Before updating this value, any in-flight `searchTask` is cancelled,
    ///         and `searchTask` is reassigneld with a new task. After this value is
    ///         updated, `searchTask` is started.
    private var searchText: String = "" {
        willSet {
            searchTask?.cancel()
            searchTask = find(newValue) { [weak self] in
                if let results = try? $0() {
                    self?.results = results
                }
            }
        }
        didSet {
            searchTask?.resume()
        }
    }

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init(delegate: FrameImageDelegate? = nil, callback: @escaping (([FrameImage]) -> ())) {
        self.delegate = delegate
        self.callback = callback
    }

    public func reset() {
        results = []
    }
    
    // MARK: - Find -
    //--------------------------------------------------------------------------
    /**
     Searches for those frames containg `text`.

     - parameter text: The text being searched for.
     - parameter callback: A callback that can receive another function
                           which will return the frames when executed.
     
     - returns: A session task that, when started, performs a search
                and executes `callback`.
     */
    private func find(_ text: String, callback: @escaping ((() throws -> [FrameImage]?) -> ())) -> URLSessionTask {
        return S.search(for: text) { [weak self] result in
            callback {
                try? result().0.map { FrameImage($0, serviceHost: S.shared, delegate: self?.delegate) }
            }
        }
    }

    /**
     Search for frames containing `text`.

     - parameter text: The query to search for. 
     */
    public func find(_ text: String) {
        searchText = text
    }
}
