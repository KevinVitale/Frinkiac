// MARK: - Service Host -
//------------------------------------------------------------------------------
public protocol ServiceHost {
    /// - parameter scheme: The service's scheme.
    /// - note: Any valid URL scheme is fine.
    var scheme: String { get }

    /// - parameter scheme: The service's host.
    /// - note: **Example:** `api.example.com`.
    var host: String { get }

    /// - parameter path: An optional default path.
    /// - note: **Example:** `v2`.
    var path: String? { get }
}

// MARK: - Extension, URL Request -
//------------------------------------------------------------------------------
extension ServiceHost {
    /// - parameter baseURLString: The computed URL, as a `String`.
    private var baseURLString: String {
        var string = "\(scheme)://\(host)"
        if let path = path {
            string += "/\(path)"
        }
        return string
    }

    /**
     Appends `endpoint` to `baseURLString`.

     - parameter endpoint: The path endpoint to append.
     - returns: The full URL, as a `String`.
     */
    private func URLString(with endpoint: String) -> String {
        return "\(baseURLString)/" + endpoint.replacingOccurrences(of: "//", with: "/")
    }

    /**
     Generates a `URLRequest` for the given `endpoint` and optional `parameters`.

     - parameter endpoint: The path endpoint being requested.
     - parameter parameters: An optional set of query parameters to bet appended.
     - returns: An optional `URLRequest`.
     */
    private func URLRequest(endpoint: String, parameters: [String:Any]? = nil) -> URLRequest? {
        guard var components = URLComponents(string: URLString(with: endpoint)) else {
            return nil
        }

        components.queryItems = parameters?.queryItems()
        let request = Foundation.URLRequest(url: components.url!)

        return request
    }

    /**
     Generates a request, in the form of a data task, for the given path
     `endpoint` and optional `parameters`. The `callback` is executed with the
     given result. In the even of an error, an exception is thrown.
     
     - parameter session: The `URLSession` which generates the data task.
     - parameter endpoint: The path endpoint (aka, API route).
     - parameter parameters: An optional set of query parameters.
     - parameter callback: The returning logic invoked when the request is made.
     - returns: A `URLSessionDataTask` which, when started, performs the request.
     */
    func request(session: URLSession, endpoint: String, parameters: [String:Any]? = nil, callback: @escaping (() throws -> (Any, URLResponse)) -> ()) -> URLSessionDataTask {
        let request: URLRequest! = URLRequest(endpoint: endpoint, parameters: parameters)
        return session.dataTask(with: request) { data, response, error in
            callback {
                guard error == nil else {
                    throw error!
                }
                return (try data?.parseJSON(), response!)
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

/// - parameter KeyValuePair: Alias for JSON dictionary key-value pairs.
private typealias KeyValuePair = (key: String, value: Any)

// MARK: - Extension, Key Value Pair -
//------------------------------------------------------------------------------
extension Sequence where Iterator.Element == KeyValuePair {
    /**
     Converts each element in the array to a `URLQueryItem`.
     
     - returns: An array of `URLQueryItem`.
     */
    fileprivate func queryItems() -> [URLQueryItem] {
        return map { URLQueryItem(name: $0.key, value: "\($0.value)".URLEscapedString) }
    }
}

// MARK: - Extension, Key Value Pari -
//------------------------------------------------------------------------------
extension Dictionary where Key: ExpressibleByStringLiteral, Value: AnyObject {
    /**
     Converts each element in the dictionary to a `URLQueryItem`, then flattens
     the result into an array.
     
     - returns: An array of `URLQueryItem` generated from the dictionary.
     */
    fileprivate func queryItems() -> [URLQueryItem] {
        return enumerated()
            .map { $0.1 }
            .map { (key: $0.0 as! String, value: $0.1) }
            .queryItems()
    }
}
