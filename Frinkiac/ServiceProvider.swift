// MARK: - Service Provider -
//------------------------------------------------------------------------------
public protocol ServiceProvider {
    /// - parameter scheme: The service's scheme.
    /// - note: Any valid URL scheme is fine.
    var scheme: String { get }

    /// - parameter scheme: The service's host.
    /// - note: **Example:** `api.example.com`.
    var host: String { get }

    /// - parameter path: An optional default path.
    /// - note: **Example:** `v2`.
    var path: String? { get }

    /// - parameter session: An optional `URLSession` to be used in requests.
    /// - note: If `nil`, `URLSession.shared` will be used.
    var session: URLSession? { get }
}

// MARK: - Extension, Requests -
//------------------------------------------------------------------------------
extension ServiceProvider {
    fileprivate func urlRequest(endpoint: String, parameters: [String:Any]? = nil) -> URLRequest? {
        // Generate `string` with `path`
        //----------------------------------------------------------------------
        var string = "\(scheme)://\(host)/"
        if let path = path {
            string = string.appendingFormat("%@/", path)
        }

        // Generate `string` with `endpoint`
        //----------------------------------------------------------------------
        var substringIndex = endpoint.startIndex
        if endpoint.hasPrefix("/") {
            substringIndex = endpoint.index(after: endpoint.startIndex)
        }
        string.append(endpoint.substring(from: substringIndex))

        // Generate `components`
        //----------------------------------------------------------------------
        var components = URLComponents(string: string)

        // Generate `query`
        //----------------------------------------------------------------------
        components?.queryItems = parameters?
            .map { (name: $0.key, value: "\($0.value)") }
            .map(URLQueryItem.init)

        // Generate `url`
        //----------------------------------------------------------------------
        guard let url = components?.url else {
            return nil
        }

        // Return `request`
        //----------------------------------------------------------------------
        return URLRequest(url: url)
    }
}

// MARK: - Extension, Request -
//------------------------------------------------------------------------------
extension ServiceProvider {
    func fetch(endpoint: String, parameters: [String:Any]? = nil, callback: @escaping Callback<(Any, URLResponse)>) -> URLSessionDataTask {
        let request = urlRequest(endpoint: endpoint, parameters: parameters)!
        return fetch(request: request, callback: callback)
    }

    private func fetch(request: URLRequest, callback: @escaping Callback<(Any, URLResponse)>) -> URLSessionDataTask {
        return (session ?? .shared)
            .dataTask(with: request) { data, response, error in
                callback {
                    guard error == nil else {
                        throw error!
                    }
                    return (try data?.parseJSON(), response!)
                }
        }
    }
    
    func download(endpoint: String, parameters: [String:Any]? = nil, callback: @escaping Callback<(URL, URLResponse)>) -> URLSessionDownloadTask {
        let request = urlRequest(endpoint: endpoint, parameters: parameters)!
        return download(request: request, callback: callback)
    }

    private func download(request: URLRequest, callback: @escaping Callback<(URL, URLResponse)>) -> URLSessionDownloadTask {
        return (session ?? .shared)
            .downloadTask(with: request) { url, response, error in
                callback {
                    guard error == nil else {
                        throw error!
                    }
                    return (url!, response!)
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