// mark: - Morbotron -
//------------------------------------------------------------------------------
public struct Morbotron: MemeGenerator {
    /// - parameter scheme: `https`.
    public var scheme: String {
        return "https"
    }
    /// - parameter host: `frinkiac.com`.
    public var host: String {
        return "morbotron.com"
    }
    /// - parameter path: `api`.
    public var path: String? {
        return "api"
    }

    /// - parameter shared: A shared instance.
    public static let shared = Morbotron()
}
