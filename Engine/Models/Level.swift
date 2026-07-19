import Foundation

public struct Level: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let campaignSequenceNum: Int
    public let startingMoney: Int
    public var lives: Int
    public var paths: [Path]
    public var towerSlots: [TowerSlot]
    public var waves: [Wave]

    public init(id: UUID,
                name: String,
                campaignSequenceNum: Int,
                startingMoney: Int,
                lives: Int,
                paths: [Path],
                towerSlots: [TowerSlot],
                waves: [Wave]) {
        self.id = id
        self.name = name
        self.campaignSequenceNum = campaignSequenceNum
        self.startingMoney = startingMoney
        self.lives = lives
        self.paths = paths
        self.towerSlots = towerSlots
        self.waves = waves
    }
}
