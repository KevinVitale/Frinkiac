import Frinkiac
import PlaygroundSupport

public typealias MemeService = Frinkiac
public let searchController = FrameSearchController<MemeService>()

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = searchController
