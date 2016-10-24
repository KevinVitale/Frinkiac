// MARK: - Image Generator -
//------------------------------------------------------------------------------
public struct ImageProvider: ServiceProvider {
    // MARK: - Service Provider -
    //--------------------------------------------------------------------------
    public let host: String
    public let path: String? = nil
    public let scheme = "https"
    public private(set) var session: URLSession? = nil

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

    // MARK: - Meme Text -
    //--------------------------------------------------------------------------
    public enum MemeText {
        case lines(String?)

        fileprivate var query: [String:Any]? {
            switch self {
            case .lines(let lines?):
                return ["lines" : lines]
            default:
                return nil
            }
        }

        public var text: String {
            switch self {
            case .lines(let lines?):
                return lines
            default:
                return ""
            }
        }
    }
}

// MARK: - Fetch
extension ImageProvider {
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

extension URL {
    fileprivate func image() throws -> ImageType? {
        let data = try Data(contentsOf: self)
        return ImageType(data: data)
    }
}
