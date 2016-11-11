// MARK: - Meme Text -
//--------------------------------------------------------------------------
public enum MemeText {
    case lines(String?)

    public var text: String {
        switch self {
        case .lines(let lines?):
            return lines
        default:
            return ""
        }
    }
}

extension MemeText {
    var query: [String:Any]? {
        switch self {
        case .lines(let lines?):
            return ["lines" : lines]
        default:
            return nil
        }
    }
}

extension String {
    public var memeText: MemeText {
        return .lines(self)
    }
}
