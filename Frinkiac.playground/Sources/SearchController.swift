import UIKit
import Frinkiac

public typealias MemeService = Frinkiac

public let searchController = FrameSearchController<MemeService>()
public let searchProvider = FrameSearchProvider<MemeService> {
    searchController.images = $0
}
