import Foundation

public struct Level: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let startingMoney: Int
    public var lives: Int
    public var paths: [Path]
    public var towerSlots: [TowerSlot]
    public var waves: [Wave]

    public init(id: UUID,
                name: String,
        startingMoney: Int,
        lives: Int,
        paths: [Path],
        towerSlots: [TowerSlot],
        waves: [Wave]) {
        self.id = id
        self.name = name
        self.startingMoney = startingMoney
        self.lives = lives
        self.paths = paths
        self.towerSlots = towerSlots
        self.waves = waves
    }
}
