/**
 Provides API services for `morbotron.com`.
 */
public struct Morbotron: MemeGenerator {
    // MARK: - Service Provider -
    //--------------------------------------------------------------------------
    public let host: String = "morbotron.com"
    
    // MARK: - Image Provider -
    //--------------------------------------------------------------------------
    public private(set) var imageGenerator: ImageGenerator

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init() {
        imageGenerator = ImageProvider(host: host)
    }
}
