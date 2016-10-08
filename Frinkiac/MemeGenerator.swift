// MARK: - Meme Generator -
//------------------------------------------------------------------------------
public protocol MemeGenerator: ServiceProvider {
}

// MARK: - Extension, Defaults -
//------------------------------------------------------------------------------
extension MemeGenerator {
    public var scheme: String {
        return "https"
    }
    
    public var path: String? {
        return "api"
    }
}

// MARK: - Extension, API Services -
//------------------------------------------------------------------------------
extension MemeGenerator {
    private static var imageService: (scheme: String, host: String) {
        return (scheme: shared.scheme, host: shared.host)
    }
    
    private static func request(session: URLSession = URLSession.shared, endpoint: String, parameters: [String:Any]? = nil, callback: @escaping (() throws -> (Any, URLResponse)) -> ()) -> URLSessionDataTask {
        let request = shared.urlRequest(endpoint: endpoint, parameters: parameters)!
        print(request)
        return session.dataTask(with: request) { data, response, error in
            callback {
                guard error == nil else {
                    throw error!
                }
                return (try data?.parseJSON(), response!)
            }
        }
    }

    /**
     Searches for frames containing `quote`.
     
     - parameter quote: The text to be searched for.
     - parameter callback: The returning logic invoked when the request is made.
     - returns: A `URLSessionTask` which, when started, performs the request.
     */
    public static func search(for quote: String, callback: @escaping (() throws -> ([Frame], URLResponse)) -> ()) -> URLSessionTask {
        return request(endpoint: "search", parameters: ["q":quote]) { next in
            callback {
                let result = try next()
                let quotes = (result.0 as? [Any])?.map { Frame(imageService: imageService, json: $0) } ?? []
                return (quotes, result.1)
            }
        }
    }

    /**
     Fetches the associated `Caption` for `frame`.
     
     - parameter frame: The frame being requested.
     - parameter callback: The returning logic invoked when the request is made.
     - returns: A `URLSessionTask` which, when started, performs the request.
     */
    public static func caption(with frame: Frame, callback: @escaping (() throws -> (Caption, URLResponse)) -> ()) -> URLSessionTask {
        return request(endpoint: "caption", parameters: ["e":frame.episode,"t":frame.timestamp]) { next in
            callback {
                let result = try next()
                let caption = Caption(imageService: imageService, json: result.0)
                return (caption, result.1)
            }
        }
    }

    /**
     Generates a random caption.
     
     - parameter callback: The returning logic invoked when the request is made.
     - returns: A `URLSessionTask` which, when started, performs the request.
     */
    public static func random(callback: @escaping (() throws -> (Caption, URLResponse)) -> ()) -> URLSessionTask {
        return request(endpoint: "random") { next in
            callback {
                let result = try next()
                let caption = Caption(imageService: imageService, json: result.0)
                return (caption, result.1)
            }
        }
    }
}

// MARK: - Extension, Parse JSON -
//------------------------------------------------------------------------------
extension Data {
    /**
     Parses the receiver into a JSON object.
     
     - parameter options: An optional set of parsing options.
     - returns: A JSON object (either an ordered or unordered set).
     */
    fileprivate func parseJSON(_ options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }
}

// MARK: - Extension, URL Escaped String -
//------------------------------------------------------------------------------
extension String {
    /// https://www.w3.org/TR/html5/forms.html#url-encoded-form-data
    /// http://stackoverflow.com/questions/24879659/how-to-encode-a-url-in-swift/24888789#24888789
    var URLEscapedString: String? {
        let unreserved = "*-._"
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: unreserved)
        allowed.insert(charactersIn: " ")

        let encoded = addingPercentEncoding(withAllowedCharacters: allowed)?
            .replacingOccurrences(of: " ", with: "+")

        return encoded
    }
}
