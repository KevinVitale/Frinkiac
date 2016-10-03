// MARK: - Image Downloader -
//------------------------------------------------------------------------------
struct ImageDownloader {
    // MARK: - Singleton -
    //--------------------------------------------------------------------------
    private static let shared = ImageDownloader(qos: .background)
    
    // MARK: - Private -
    //--------------------------------------------------------------------------
    private let session: URLSession

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    private init(qos: DispatchQoS) {
        let delegateQueue = OperationQueue()
        delegateQueue.underlyingQueue = DispatchQueue(label: "\(ImageDownloader.self)", qos: qos, attributes: .concurrent, autoreleaseFrequency: .workItem, target: nil)
        session = URLSession(configuration: .default, delegate: nil, delegateQueue: delegateQueue)
    }

    // MARK: - Download Task -
    //--------------------------------------------------------------------------
    static func download(image url: URL, completionHandler: @escaping (URL?, URLResponse?, Error?) -> Swift.Void) -> URLSessionTask {
        return shared.session.downloadTask(with: url, completionHandler: completionHandler)
    }
}
