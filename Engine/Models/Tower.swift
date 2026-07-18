// Tower.swift
// A tower level carries a full damage profile across the three families:
// shot (vs cover), terror (vs discipline), and a contagion application
// chance (vs hardiness). Most towers use one or two; the data model lets a
// single tower mix all three so hybrids don't need special cases.

public enum Targeting: String, Codable, Sendable, CaseIterable {
    /// Furthest along the path (closest to your exit). The KR default.
    case first
    /// Least far along the path.
    case last
    /// Highest current HP — the long-rifle "pick the big one" behaviour.
    case strongest
    /// Lowest current morale (skipping already-Broken units) — lets terror
    /// towers finish wavering squads and cascade breaks.
    case shakiest
}

public struct TowerLevel: Codable, Sendable, Equatable {
    public var cost: Int
    public var range: Double
    /// Seconds between volleys.
    public var fireInterval: Double
    public var shotMin: Double
    public var shotMax: Double
    public var terrorMin: Double
    public var terrorMax: Double
    /// 0 == single target. Otherwise every enemy within this radius of the
    /// primary target takes the full rolled damage (falloff is a later knob).
    public var aoeRadius: Double
    /// Chance per volley to infect the (primary) target, scaled by (1 - hardiness).
    public var contagionChance: Double
    public var targeting: Targeting

    public init(
        cost: Int,
        range: Double,
        fireInterval: Double,
        shotMin: Double = 0,
        shotMax: Double = 0,
        terrorMin: Double = 0,
        terrorMax: Double = 0,
        aoeRadius: Double = 0,
        contagionChance: Double = 0,
        targeting: Targeting = .first
    ) {
        self.cost = cost
        self.range = range
        self.fireInterval = fireInterval
        self.shotMin = shotMin
        self.shotMax = shotMax
        self.terrorMin = terrorMin
        self.terrorMax = terrorMax
        self.aoeRadius = aoeRadius
        self.contagionChance = contagionChance
        self.targeting = targeting
    }
}

public struct TowerType: Codable, Sendable, Identifiable, Equatable {
    public var id: String
    public var name: String
    /// levels[0] is the build; levels[1...] are upgrades.
    public var levels: [TowerLevel]

    public init(id: String, name: String, levels: [TowerLevel]) {
        self.id = id
        self.name = name
        self.levels = levels
    }
}

/// Runtime tower occupying a slot.
public struct Tower: Sendable {
    public var typeIndex: Int
    public var slotIndex: Int
    /// Index into TowerType.levels.
    public var level: Int
    /// Seconds until the next shot is allowed.
    public var cooldown: Double

    public init(typeIndex: Int, slotIndex: Int, level: Int = 0, cooldown: Double = 0) {
        self.typeIndex = typeIndex
        self.slotIndex = slotIndex
        self.level = level
        self.cooldown = cooldown
    }
}
