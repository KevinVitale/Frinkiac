// MARK: - Image Generator -
//------------------------------------------------------------------------------
public protocol ImageGenerator: ServiceProvider {
}

// MARK: - Extension, Defaults -
//------------------------------------------------------------------------------
extension ImageGenerator {
    public var path:    String?     { return nil }
    public var scheme:  String      { return "https" }
}

// MARK: - Extension, API Services -
//------------------------------------------------------------------------------
extension ImageGenerator {
    public func image(frame: Frame, text: MemeText? = nil, callback: @escaping Callback<(ImageType?, URLResponse?)>) -> URLSessionDownloadTask {
        return download(endpoint: frame.imageLink, parameters: text?.query, callback: { closure in
            callback {
                let result = try closure()
                let image = try result.0.image()
                let response = result.1
                return(image, response)
            }
        })
    }
    
    public func gif(frame: Frame, duration: Int, text: MemeText? = nil, callback: @escaping Callback<(ImageType?, URLResponse?)>) -> URLSessionDownloadTask {
        return download(endpoint: frame.gifLink(duration: duration), parameters: text?.query, callback: { closure in
            callback {
                let result = try closure()
                let image = try result.0.image()
                let response = result.1
                return(image, response)
            }
        })
    }

    public func gif(start: Frame, end: Frame, text: MemeText? = nil, callback: @escaping Callback<(ImageType?, URLResponse?)>) -> URLSessionDownloadTask {
        return gif(frame: start, duration: start.duration(between: end), callback: callback)
    }
}

// MARK: - Image Provider -
//------------------------------------------------------------------------------
public struct ImageProvider: ImageGenerator {
    // MARK: - Service Provider -
    //--------------------------------------------------------------------------
    public let host: String
    public private(set) var session: URLSession

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

// MARK: - Extension, Image -
//------------------------------------------------------------------------------
extension URL {
    fileprivate func image() throws -> ImageType? {
        let data = try Data(contentsOf: self)
        return ImageType(data: data)
    }
}
