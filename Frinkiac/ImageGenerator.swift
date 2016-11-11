// MARK: - Image Generator -
//------------------------------------------------------------------------------
public protocol ImageGenerator: ServiceProvider {
    init(host: String)
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

// MARK: - Extension, Image -
//------------------------------------------------------------------------------
extension URL {
    fileprivate func image() throws -> ImageType? {
        let data = try Data(contentsOf: self)
        return ImageType(data: data)
    }
}
