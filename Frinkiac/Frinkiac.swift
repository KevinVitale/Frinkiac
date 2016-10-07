// MARK: - Frinkiac -
//------------------------------------------------------------------------------
public struct Frinkiac: MemeGenerator {
    /// - parameter scheme: `https`.
    public var scheme: String {
        return "https"
    }
    /// - parameter host: `frinkiac.com`.
    public var host: String {
        return "frinkiac.com"
    }
    /// - parameter path: `api`.
    public var path: String? {
        return "api"
    }

    /// - parameter shared: A shared instance.
    public static let shared = Frinkiac()
}
