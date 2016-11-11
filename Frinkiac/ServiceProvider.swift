// MARK: - Service Provider -
//------------------------------------------------------------------------------
public protocol ServiceProvider {
    /// The service's scheme.
    /// - note: Any valid URL scheme is fine.
    var scheme: String { get }

    /// The service's host.
    /// - note: **Example:** `api.example.com`.
    var host: String { get }

    /// An optional default path.
    /// - note: **Example:** `v2`.
    var path: String? { get }

    /// A `URLSession` to be used in requests.
    var session: URLSession { get }
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

// MARK: - Extension, Fetch -
//------------------------------------------------------------------------------
extension ServiceProvider {
    /**
     Fetches JSON from the given `endpoint`.
     
     - parameter endpoint: The API endpoint for the desired resource.
     - parameter parameters: An optional set of request parameters.
     - parameter callback: A callback which returns another callback that, when
                           invoked, returns the results of the request.
     - returns: A session task that, when started, begins the request.
     */
    func fetch(endpoint: String, parameters: [String:Any]? = nil, callback: @escaping Callback<(Any, URLResponse)>) -> URLSessionDataTask {
        let request = urlRequest(endpoint: endpoint, parameters: parameters)!
        return fetch(request: request, callback: callback)
    }

    /**
     Fetches JSON for the given `request`.

     - parameter request: The object describing the network request.
     - parameter callback: A callback which returns another callback that, when
                           invoked, returns the results of the request.
     - returns: A session task that, when started, beings the request.
     */
    private func fetch(request: URLRequest, callback: @escaping Callback<(Any, URLResponse)>) -> URLSessionDataTask {
        return (session ?? .shared)
            .dataTask(with: request) { data, response, error in
                callback {
                    guard error == nil else {
                        throw error!
                    }
                    return (try data?.parseJSON() as Any, response!)
                }
        }
    }
}

// MARK: - Extension, Download -
//------------------------------------------------------------------------------
extension ServiceProvider {
    /**
     Fetches the file for the given `request`, storing the result on disk.
     
     - parameter endpoint: The API endpoint for the desired resource.
     - parameter parameters: An optional set of request parameters.
     - parameter callback: A callback which returns another callback that, when
                           invoked, returns the results of the request.
     - returns: A session task that, when started, begins the request.
     */
    func download(endpoint: String, parameters: [String:Any]? = nil, callback: @escaping Callback<(URL, URLResponse)>) -> URLSessionDownloadTask {
        let request = urlRequest(endpoint: endpoint, parameters: parameters)!
        return download(request: request, callback: callback)
    }

    /**
     Fetches the file for the given 'request', storing the result on disk.

     - parameter request: The object describing the network request.
     - parameter callback: A callback which returns another callback that, when
                           invoked, returns the results of the request.
     - returns: A session task that, when started, beings the request.
     */
    private func download(request: URLRequest, callback: @escaping Callback<(URL, URLResponse)>) -> URLSessionDownloadTask {
        return session
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
