// ContentCatalog.swift
// Immutable content snapshot for a run. String IDs (stable, DB-friendly,
// mod-friendly) are resolved once into dense Int indices; the hot loop only
// ever touches the arrays.

public struct ContentCatalog: Sendable {
    public let enemyTypes: [EnemyType]
    public let towerTypes: [TowerType]

    private let enemyIndexByID: [String: Int]
    private let towerIndexByID: [String: Int]

    public init(enemyTypes: [EnemyType], towerTypes: [TowerType]) {
        // Sort for deterministic index assignment regardless of source order.
        let enemies = enemyTypes.sorted { $0.id < $1.id }
        let towers = towerTypes.sorted { $0.id < $1.id }
        self.enemyTypes = enemies
        self.towerTypes = towers
        var em: [String: Int] = [:]
        em.reserveCapacity(enemies.count)
        for (i, e) in enemies.enumerated() { em[e.id] = i }
        var tm: [String: Int] = [:]
        tm.reserveCapacity(towers.count)
        for (i, t) in towers.enumerated() { tm[t.id] = i }
        self.enemyIndexByID = em
        self.towerIndexByID = tm
    }

    public func enemyIndex(id: String) -> Int? { enemyIndexByID[id] }
    public func towerIndex(id: String) -> Int? { towerIndexByID[id] }

    public enum CatalogError: Error, CustomStringConvertible {
        case unknownEnemyType(String)
        case unknownTowerType(String)

        public var description: String {
            switch self {
            case .unknownEnemyType(let id): return "Unknown enemy type id '\(id)'"
            case .unknownTowerType(let id): return "Unknown tower type id '\(id)'"
            }
        }
    }

    public func requireEnemyIndex(id: String) throws -> Int {
        guard let i = enemyIndexByID[id] else { throw CatalogError.unknownEnemyType(id) }
        return i
    }

    public func requireTowerIndex(id: String) throws -> Int {
        guard let i = towerIndexByID[id] else { throw CatalogError.unknownTowerType(id) }
        return i
    }
}
