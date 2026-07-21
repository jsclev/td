import Foundation

public struct LevelInfo: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let startingMoney: Int
    public var numStartingLives: Int
    public let startedAt: Date
    public let endedAt: Date
    public var paths: [Path]
    public var towerSlots: [TowerSlot]
    public var waves: [Wave]

    public init(id: UUID,
                name: String,
                startedAt: Date,
                endedAt: Date,
                startingMoney: Int,
                numStartingLives: Int,
                paths: [Path],
                towerSlots: [TowerSlot],
                waves: [Wave]) {
        self.id = id
        self.name = name
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.startingMoney = startingMoney
        self.numStartingLives = numStartingLives
        self.paths = paths
        self.towerSlots = towerSlots
        self.waves = waves
    }
}
