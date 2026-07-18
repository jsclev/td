// Level.swift
// A level is pure data: polyline paths in virtual art coordinates, tower
// slots at fixed points in the same space, and a wave timeline. Enemies track
// a single scalar (distance along path); Path converts that to a Point when
// something spatial needs to happen (range checks, splash, rendering later).

public struct Path: Sendable, Equatable {
    public let points: [Point]
    /// cumulative[i] == polyline length from points[0] to points[i].
    public let cumulative: [Double]
    public let totalLength: Double

    public init(points: [Point]) {
        precondition(points.count >= 2, "A path needs at least two points")
        self.points = points
        var cum: [Double] = [0]
        cum.reserveCapacity(points.count)
        var total = 0.0
        for i in 1..<points.count {
            total += points[i - 1].distance(to: points[i])
            cum.append(total)
        }
        self.cumulative = cum
        self.totalLength = total
    }

    /// Position at a given travelled distance, clamped to the endpoints.
    public func point(atDistance d: Double) -> Point {
        if d <= 0 { return points[0] }
        if d >= totalLength { return points[points.count - 1] }
        // Binary search for the segment containing d.
        var lo = 0
        var hi = cumulative.count - 1
        while lo + 1 < hi {
            let mid = (lo + hi) / 2
            if cumulative[mid] <= d { lo = mid } else { hi = mid }
        }
        let segStart = cumulative[lo]
        let segLen = cumulative[hi] - segStart
        let t = segLen > 0 ? (d - segStart) / segLen : 0
        return Point.lerp(points[lo], points[hi], t)
    }
}

extension Path: Codable {
    private enum K: String, CodingKey { case points }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: K.self)
        self.init(points: try c.decode([Point].self, forKey: .points))
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: K.self)
        try c.encode(points, forKey: .points)
    }
}

/// A buildable position, authored in the same virtual space as the artwork.
public struct TowerSlot: Codable, Sendable, Equatable {
    public var index: Int
    public var position: Point

    public init(index: Int, position: Point) {
        self.index = index
        self.position = position
    }
}

/// One line in a wave: "spawn `count` of `enemyTypeID`, one every `interval`
/// seconds, starting `delay` seconds after the wave begins, on path `pathIndex`."
public struct SpawnEntry: Codable, Sendable, Equatable {
    public var enemyTypeID: String
    public var count: Int
    public var interval: Double
    public var delay: Double
    public var pathIndex: Int

    public init(enemyTypeID: String, count: Int, interval: Double, delay: Double = 0, pathIndex: Int = 0) {
        self.enemyTypeID = enemyTypeID
        self.count = count
        self.interval = interval
        self.delay = delay
        self.pathIndex = pathIndex
    }
}

public struct Wave: Codable, Sendable, Equatable {
    /// Absolute start time in seconds from level start. (A call-next-wave-early
    /// mechanic later becomes an offset applied to this.)
    public var startTime: Double
    public var spawns: [SpawnEntry]

    public init(startTime: Double, spawns: [SpawnEntry]) {
        self.startTime = startTime
        self.spawns = spawns
    }
}

public struct LevelDefinition: Codable, Sendable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var startingGold: Int
    public var lives: Int
    public var paths: [Path]
    public var slots: [TowerSlot]
    public var waves: [Wave]

    public init(
        id: String,
        name: String,
        startingGold: Int,
        lives: Int,
        paths: [Path],
        slots: [TowerSlot],
        waves: [Wave]
    ) {
        self.id = id
        self.name = name
        self.startingGold = startingGold
        self.lives = lives
        self.paths = paths
        self.slots = slots
        self.waves = waves
    }
}
