// MARK: - Image Link -
//------------------------------------------------------------------------------
public enum ImageLink {
    case image(scheme: String, host: String, episode: String, timestamp: Int)
    case meme(scheme: String, host: String, episode: String, timestamp: Int, text: String)
    case gif(scheme: String, host: String, episode: String, start: Int, end: Int, text: String)

    public var url: URL {
        switch self {
        case .image(let scheme, let host, let episode, let timestamp):
            return URL(string: "\(scheme)://\(host)/meme/\(episode)/\(timestamp).jpg")!
        case .meme(let scheme, let host, let episode, let timestamp, let text):
            return URL(string: "\(scheme)://\(host)/meme/\(episode)/\(timestamp).jpg?lines=\(text.URLEscapedString ?? "")")!
        case .gif(let scheme, let host, let episode, let start, let end, let text):
            return URL(string: "\(scheme)://\(host)/gif/\(episode)/\(start)/\(end).gif?lines=\(text.URLEscapedString ?? "")")!
        }
    }

    /**
     Downloads the image located at `self.imageLink`.

     - parameter callback: A callback that can receive another function
                           which will return the image when executed.
     */
    public func download(callback: @escaping Callback<ImageType>) -> URLSessionTask {
        return ImageDownloader.download(image: url) { url, response, error in
            callback {
                guard error == nil else {
                    throw error!
                }

                let data = try Data(contentsOf: url!)
                return ImageType(data: data)
            }
        }
    }
}
