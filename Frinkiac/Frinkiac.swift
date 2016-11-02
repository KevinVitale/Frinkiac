/**
 Provides API services for `frinkiac.com`.
 */
public struct Frinkiac: MemeGenerator {
    // MARK: - Service Provider -
    //--------------------------------------------------------------------------
    public let host: String = "frinkiac.com"

    // MARK: - Image Provider -
    //--------------------------------------------------------------------------
    public private(set) var imageProvider: ImageProvider

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init() {
        imageProvider = ImageProvider(host: host)
    }
}
