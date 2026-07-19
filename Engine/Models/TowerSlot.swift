public struct TowerSlot: Codable, Sendable, Equatable {
    public var index: Int
    public var position: Point

    public init(index: Int, position: Point) {
        self.index = index
        self.position = position
    }
}
