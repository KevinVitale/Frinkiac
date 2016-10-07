// MARK: - Frinkiac -
//------------------------------------------------------------------------------
public struct Frinkiac: MemeGenerator {
    /// - parameter host: `frinkiac.com`.
    public var host: String {
        return "frinkiac.com"
    }

    /// - parameter shared: A shared instance.
    public static let shared = Frinkiac()
}
