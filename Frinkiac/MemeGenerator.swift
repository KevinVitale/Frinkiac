// MARK: - Meme Generator -
//------------------------------------------------------------------------------
public protocol MemeGenerator: ServiceProvider {
    var imageGenerator: ImageGenerator { get }
    init()
}

// MARK: - Extension, Defaults -
//------------------------------------------------------------------------------
extension MemeGenerator {
    public var path:    String?     { return "api" }
    public var scheme:  String      { return "https" }
    public var session: URLSession  { return .shared }
}

// MARK: - Extension, API Services -
//------------------------------------------------------------------------------
extension MemeGenerator {
    public func search(for quote: String, callback: @escaping Callback<([Frame], URLResponse?)>) -> URLSessionDataTask {
        return fetch(endpoint: "search", parameters: ["q":quote]) { next in
            callback {
                let result = try next()
                let quotes = ((result.0 as? [Any]) ?? []).map(Frame.init)
                return (quotes, result.1)
            }
        }
    }

    public func caption(with frame: Frame, callback: @escaping Callback<(Caption, URLResponse?)>) -> URLSessionDataTask {
        return fetch(endpoint: "caption", parameters: ["e":frame.episode, "t":frame.timestamp]) { next in
            callback {
                let result = try next()
                let caption = Caption(json: result.0)
                return (caption, result.1)
            }
        }
    }

    public func random(callback: @escaping Callback<(Caption, URLResponse?)>) -> URLSessionDataTask {
        return fetch(endpoint: "random") { next in
            callback {
                let result = try next()
                let caption = Caption(json: result.0)
                return (caption, result.1)
            }
        }
    }
}
