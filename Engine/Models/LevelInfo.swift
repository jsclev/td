import Foundation
import CoreGraphics

public struct LevelInfo: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let name: String
    public let campaign: Campaign
    public let startingMoney: Int
    public var numStartingLives: Int
    public let startedAt: Date
    public let endedAt: Date
    /// The internal, exactly-16:9 region of the level art (in the art's own
    /// pixel coordinates) that is always fully on screen — no map panning,
    /// ever. All gameplay content sits inside it; the renderer scales and
    /// centres the map so this rect exactly fits the running device's screen.
    public let playableRect: CGRect
    public var paths: [Path]
    public var towerSlots: [TowerSlot]
    public var waves: [Wave]

    public init(id: UUID,
                name: String,
                campaign: Campaign,
                startedAt: Date,
                endedAt: Date,
                startingMoney: Int,
                numStartingLives: Int,
                playableRect: CGRect,
                paths: [Path],
                towerSlots: [TowerSlot],
                waves: [Wave]) {
        self.id = id
        self.name = name
        self.campaign = campaign
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.startingMoney = startingMoney
        self.numStartingLives = numStartingLives
        self.playableRect = playableRect
        self.paths = paths
        self.towerSlots = towerSlots
        self.waves = waves
    }
}
