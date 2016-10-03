// MARK: - Image Link -
//------------------------------------------------------------------------------
public enum ImageLink {
    case image(episode: String, timestamp: Int)
    case meme(episode: String, timestamp: Int, text: String)
    case gif(episode: String, start: Int, end: Int, text: String)

    public var url: URL {
        var link = Frinkiac.baseLink
        switch self {
        case .image(let episode, let timestamp):
            link.append("/meme/\(episode)/\(timestamp).jpg")
        case .meme(let episode, let timestamp, let text):
            link.append("/meme/\(episode)/\(timestamp).jpg?lines=\(text.URLEscapedString ?? "")")
        case .gif(let episode, let start, let end, let text):
            link.append("/gif/\(episode)/\(start)/\(end).gif?lines=\(text.URLEscapedString ?? "")")
        }
        return URL(string: link)!
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
