// MARK: - Image Provider -
//------------------------------------------------------------------------------
struct ImageProvider: ImageGenerator {
    // MARK: - Service Provider -
    //--------------------------------------------------------------------------
    let host: String
    private(set) var session: URLSession

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    init(host: String) {
        self.host = host

        // Session
        //----------------------------------------------------------------------
        let delegateQueue = OperationQueue()
        delegateQueue.underlyingQueue = DispatchQueue(label: "\(ImageProvider.self)"
            , qos: .background
            , attributes: .concurrent
            , autoreleaseFrequency: .workItem
            , target: nil
        )
        session = URLSession(configuration: .default
            , delegate: nil
            , delegateQueue: delegateQueue
        )
    }
}
