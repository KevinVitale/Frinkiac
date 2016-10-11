// MARK: - Frame -
//------------------------------------------------------------------------------
public struct Frame: Equatable {
    // MARK: - Computed -
    //--------------------------------------------------------------------------
    public var episode: String {
        return self["Episode"] as? String ?? ""
    }
    public var id: Int {
        return self["Id"] as? Int ?? 0
    }
    public var timestamp: Int {
        return self["Timestamp"] as? Int ?? 0
    }

    // MARK: - Internal -
    //--------------------------------------------------------------------------
    let json: Any

    // MARK: - Subscript -
    //--------------------------------------------------------------------------
    private subscript(key: String) -> Any? {
        return (json as? [String:AnyObject])?[key]
    }

    public var imageLink: String {
        return "meme/\(episode)/\(timestamp).jpg"
    }
    
    public func gifLink(duration end: Int) -> String {
        return "gif/\(timestamp)/\(timestamp.advanced(by: end))/\(end).gif"
    }

    public func duration(between frame: Frame) -> Int {
        return timestamp.distance(to: frame.timestamp)
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    public static func ==(lhs: Frame, rhs: Frame) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Episode -
//------------------------------------------------------------------------------
public struct Episode: Equatable {
    // MARK: - Computed -
    //--------------------------------------------------------------------------
    public var director: String {
        return self["Director"] as? String ?? ""
    }
    public var episodeNumber: Int {
        return self["EpisodeNumber"] as? Int ?? 0
    }
    public var id: Int {
        return self["Id"] as? Int ?? 0
    }
    public var key: String {
        return self["Key"] as? String ?? ""
    }
    public var originalAirDate: String {
        return self["OriginalAirDate"] as? String ?? ""
    }
    public var season: Int {
        return self["Season"] as? Int ?? 0
    }
    public var title: String {
        return self["Title"] as? String ?? ""
    }
    public var wikiLink: String {
        return self["WikiLink"] as? String ?? ""
    }
    public var writer: String {
        return self["Write"] as? String ?? ""
    }

    // MARK: - Internal -
    //--------------------------------------------------------------------------
    let json: Any
    
    // MARK: - Subscript -
    //--------------------------------------------------------------------------
    private subscript(key: String) -> Any? {
        return (json as? [String:AnyObject])?[key]
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    public static func ==(lhs: Episode, rhs: Episode) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Subtitle -
//------------------------------------------------------------------------------
public struct Subtitle: Equatable {
    // MARK: - Computed -
    //--------------------------------------------------------------------------
    public var content: String {
        return self["Content"] as? String ?? ""
    }
    public var endTimestamp: Int {
        return self["EndTimestamp"] as? Int ?? 0
    }
    public var episode: String {
        return self["Episode"] as? String ?? ""
    }
    public var id: Int {
        return self["Id"] as? Int ?? 0
    }
    public var language: String {
        return self["Language"] as? String ?? ""
    }
    public var representatativeTimestamp: Int {
        return self["RepresentativeTimestamp"] as? Int ?? 0
    }
    public var startTimestamp: Int {
        return self["StartTimestamp"] as? Int ?? 0
    }

    // MARK: - Internal -
    //--------------------------------------------------------------------------
    let json: Any

    // MARK: - Subscript -
    //--------------------------------------------------------------------------
    private subscript(key: String) -> Any? {
        return (json as? [String:AnyObject])?[key]
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    public static func ==(lhs: Subtitle, rhs: Subtitle) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - Caption -
//------------------------------------------------------------------------------
public struct Caption: Equatable {
    // MARK: - Computed -
    //--------------------------------------------------------------------------
    public var episode: Episode {
        return Episode(json: self["Episode"]!)
    }
    public var frame: Frame {
        return Frame(json: self["Frame"]!)
    }
    public var nearby: [Frame] {
        return (self["Nearby"] as? [Any] ?? []).map(Frame.init)
    }
    public var subtitles: [Subtitle] {
        return (self["Subtitles"] as? [Any] ?? []).map(Subtitle.init)
    }

    // MARK: - Internal -
    //--------------------------------------------------------------------------
    let json: Any

    // MARK: - Subscript -
    //--------------------------------------------------------------------------
    private subscript(key: String) -> Any? {
        return (json as? [String:AnyObject])?[key]
    }

    // MARK: - Inferred -
    //--------------------------------------------------------------------------
    public var lines: String {
        return subtitles.caption
    }
    public var subtitle: String {
        return subtitles.subtitle.capitalized
    }

    // MARK: - Equatable -
    //--------------------------------------------------------------------------
    public static func ==(lhs: Caption, rhs: Caption) -> Bool {
        return lhs.frame == rhs.frame && lhs.subtitle == rhs.subtitle
    }
}

// MARK: - Extension, Ccaption -
//------------------------------------------------------------------------------
extension Sequence where Iterator.Element == Subtitle {
    fileprivate var subtitle: String {
        return map { $0.content }
            .joined(separator: " ")
    }
    fileprivate var caption: String {
        return subtitle.lineSplitted
    }
}

// MARK: - Extension, Line Splitted -
//------------------------------------------------------------------------------
extension String {
    /// https://github.com/gausie/slack-frinkiac/blob/master/src/server.js#L38
    fileprivate var lineSplitted: String {
        return components(separatedBy: " ")
            .reduce([[String]]()) { lines, word in
                var nextLines = lines
                let line = nextLines.last ?? []
                
                let lastLineLength = line.joined(separator: " ").characters.count
                let wordLength = word.characters.count + 1
                
                if lastLineLength + wordLength <= 25, lastLineLength > 0 {
                    // Start the next line
                    nextLines[nextLines.index(before: nextLines.endIndex)].append(word)
                } else {
                    // Continue appending more words
                    nextLines.append([word])
                }
                return nextLines
            }
            .map { $0.joined(separator: " ") }
            .joined(separator: "\n")
    }
}

