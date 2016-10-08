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

    static var shared: Self { get }
}

// MARK: - Extension, Requests -
//------------------------------------------------------------------------------
extension ServiceProvider {
    func urlRequest(endpoint: String, parameters: [String:Any]? = nil) -> URLRequest? {
        // Generate `string` with `path`
        //----------------------------------------------------------------------
        var string = "\(scheme)://\(host)"
        if let path = path {
            string = string.appendingFormat("/%@/", path)
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
