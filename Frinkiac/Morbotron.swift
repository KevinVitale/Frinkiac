// MARK: - Morbotron -
//------------------------------------------------------------------------------
public struct Morbotron: MemeGenerator {
    // MARK: - Service Provider -
    //--------------------------------------------------------------------------
    public let host: String = "morbotron.com"
    
    // MARK: - Image Provider -
    //--------------------------------------------------------------------------
    public private(set) var imageProvider: ImageProvider

    // MARK: - Initialization -
    //--------------------------------------------------------------------------
    public init() {
        imageProvider = ImageProvider(host: host)
    }
}
