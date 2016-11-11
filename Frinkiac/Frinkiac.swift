/**
 Provides API services for `frinkiac.com`.
 */
public struct Frinkiac: MemeGenerator {
    // MARK: - Service Provider -
    //--------------------------------------------------------------------------
    public let host: String = "frinkiac.com"

    // MARK: - Image Provider -
    //--------------------------------------------------------------------------
    public private(set) var imageGenerator: ImageGenerator

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init() {
        imageGenerator = ImageProvider(host: host)
    }
}
