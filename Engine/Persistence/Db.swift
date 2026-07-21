import Foundation
import SQLite3
import os

public class Db {
    private let logger = LogUtility.getLogger(LogCategory.Db, Db.self)

    let dbExtension = "sqlite"
    private var conn: OpaquePointer?
    public let fullRefresh: Bool
    public let levelInfoDao: LevelInfoDAO
//    public let cityDao: CityDAO
//    public let cityNameDao: CityNameDAO
//    public let civilizationDao: CivilizationDAO
//    public let commandDao: CommandDAO
//    public let createCityCommandDao: CreateCityCommandDAO
//    public let cityProductionDao: CityProductionDAO
//    public let languageDao: LanguageDAO
//    public let gameDao: GameDAO
//    public let mapDao: MapDAO
//    public let moveUnitCommandDao: MoveUnitCommandDAO
//    public let playerEndTurnDao: PlayerEndTurnDAO
//    public let playerDao: PlayerDAO
//    public let startResearchingTechDao: StartResearchingTechDAO
//    public let skinDao: SkinDAO
//    public let spawnUnitDao: SpawnUnitDAO
//    public let unitTypeDao: UnitTypeDAO
//    public let techDAO: TechDAO
//    public let terrainDao: TerrainDAO
//    public let themeDao: ThemeDAO
//    public let turnDao: TurnDAO
//    public let unitDao: UnitDAO
    
    public static func getAbsolutePathToDb(dbFilename: String, fullRefresh: Bool) -> String {
        let logger = LogUtility.getLogger(LogCategory.Db, Db.self)
        let dbExtension = "sqlite"
        let fileManager = FileManager.default
        let documentsDirectory = FileUtil.getDocumentsURL()
        
        // Get the database file that is included inside the bundle
        if let dbBundleUrl = Bundle.main.url(forResource: dbFilename, withExtension: dbExtension) {
            let targetDbPath = documentsDirectory.appendingPathComponent("\(dbFilename).\(dbExtension)").path

            if fullRefresh {
                do {
                    if fileManager.fileExists(atPath: targetDbPath) {
                        do {
                            try fileManager.removeItem(atPath: targetDbPath)
                        }
                        catch let error {
                            logger.error("error occurred, here are the details: \(error)")
                        }
                    }
                    
                    try fileManager.copyItem(atPath: dbBundleUrl.path, toPath: targetDbPath)
                }
                catch {
                    logger.error("Unable to copy \(dbFilename).\(dbExtension): \(error)")
                }
            } else {
                // Copy the db file from the bundle if it's not in the Documents directory
                if !fileManager.fileExists(atPath: targetDbPath) {
                    do {
                        try fileManager.copyItem(atPath: dbBundleUrl.path, toPath: targetDbPath)
                    }
                    catch let error {
                        logger.error("error occurred, here are the details: \(error)")
                    }
                }
            }
        }
        else {
            logger.warning("Unable to find the database file inside the bundle.")
            // throw SQLiteError.OpenDatabase(message: "Unable to find the \"Documents\" directory.")
        }
        
        #if os(tvOS)
//            let docDirUrls = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        #else
            let docDirUrls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        #endif
        
        if docDirUrls.count == 0 {
            logger.error("Unable to find the \"Documents\" directory.")
            // throw SQLiteError.OpenDatabase(message: "Unable to find the \"Documents\" directory.")
        }
        
        let documentsUrl = docDirUrls[0]
        let dbPath = documentsUrl.appendingPathComponent("\(dbFilename).\(dbExtension)").path
        
        return dbPath
    }
    
    public init(dbPath: String, fullRefresh: Bool) {
        var rc: Int32
        rc = sqlite3_open_v2(dbPath, &conn, SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)
        
        if (rc != SQLITE_OK) {
//            try close(conn: conn)
            let sqliteMsg = String(cString: sqlite3_errmsg(conn))
            let errMsg = "Failed to open database connection to \(dbPath).  \(sqliteMsg)"
            fatalError("\(errMsg)")
        }
        
        // Enable foreign keys (they are off by default in SQLite as of version 3.34)
        let pragma = "PRAGMA foreign_keys=ON;"
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(conn, pragma, -1, &stmt, nil) == SQLITE_OK {
            if sqlite3_step(stmt) == SQLITE_DONE {
                // logger.debug("Turned on foreign keys using command \"\(pragma, privacy: .public)\"")
            }
            else {
                let errMsg = String(cString: sqlite3_errmsg(conn)!)
                fatalError("\(errMsg)")
            }
        }
        else {
            let errMsg = String(cString: sqlite3_errmsg(conn)!)
            fatalError("\(errMsg)")
        }
        
        if sqlite3_finalize(stmt) != SQLITE_OK {
            let errMsg = String(cString: sqlite3_errmsg(conn)!)
            fatalError("\(errMsg)")
        }
        
        self.fullRefresh = fullRefresh
        
        levelInfoDao = LevelInfoDAO(conn: conn)
//        unitTypeDao = UnitTypeDAO(conn: conn)
//        cityNameDao = CityNameDAO(conn: conn)
//        cityDao = CityDAO(conn: conn)
//        civilizationDao = CivilizationDAO(conn: conn, cityNameDao: cityNameDao)
//        unitDao = UnitDAO(conn: conn)
//        commandDao = CommandDAO(conn: conn, cityDao: cityDao, unitDao: unitDao, unitTypeDao: unitTypeDao)
//        createCityCommandDao = CreateCityCommandDAO(conn: conn, commandDao: commandDao, cityDao: cityDao)
//        playerEndTurnDao = PlayerEndTurnDAO(conn: conn, commandDao: commandDao)
//        languageDao = LanguageDAO(conn: conn)
//        gameDao = GameDAO(conn: conn)
//        mapDao = MapDAO(conn: conn)
//        cityProductionDao = CityProductionDAO(conn: conn, commandDao: commandDao, unitTypeDao: unitTypeDao)
//        moveUnitCommandDao = MoveUnitCommandDAO(conn: conn, commandDao: commandDao)
//        startResearchingTechDao = StartResearchingTechDAO(conn: conn, commandDao: commandDao)
//        playerDao = PlayerDAO(conn: conn, mapDao: mapDao, unitDao: unitDao, cityNameDao: cityNameDao)
//        skinDao = SkinDAO(conn: conn)
//        spawnUnitDao = SpawnUnitDAO(conn: conn, commandDao: commandDao, unitDao: unitDao)
//        techDAO = TechDAO(conn: conn)
//        terrainDao = TerrainDAO(conn: conn)
//        themeDao = ThemeDAO(conn: conn)
//        turnDao = TurnDAO(conn: conn)
    }
    
//    public func getGame(gameId: UUID, themeId: UUID) throws -> Game {
//        let theme = try themeDao.getBy(themeId: themeId)
//        logger.debug("⚫ Turn 0: Successfully retrieved \"\(theme.name, privacy: .public)\" theme from the database.")
//        
//        if fullRefresh {
//            try turnDao.insert(turns: Turn.allTurns, theme: theme)
//        }
//        
//        let turns = try turnDao.getTurns(theme: theme)
//        logger.debug("⚫ Turn 0: Successfully retrieved \(turns.count) turns from the database.")
//        
//        let techsDict = try techDAO.getAllBy(theme: theme)
//        logger.debug("⚫ Turn 0: Successfully retrieved \(techsDict.count) techs from the database.")
//        
//        let unitRegistry = try unitTypeDao.getUnitRegistry(theme: theme)
//        logger.debug("⚫ Turn 0: Successfully loaded the unit registry from the database with \(unitRegistry.size) units.")
//        
//        let buildingRegistry = try buildingTypeDao.getBuildingRegistry(theme: theme)
//        logger.debug("⚫ Turn 0: Successfully loaded the building registry from the database with \(buildingRegistry.size) buildings.")
//        
//        let map = try mapDao.get(gameId: gameId)
//        logger.debug("⚫ Turn 0: Successfully retrieved game map from the database.")
//        map.bake()
//        
//        let convertedTurns = Turn.convert(turns: turns)
//        let publicGameState = PublicGameState(gameType: Constants.gameType,
//                                              turns: convertedTurns,
//                                              unitRegistry: unitRegistry,
//                                              buildingRegistry: buildingRegistry,
//                                              techsDict: techsDict)
//
//        let players = try playerDao.getPlayers(gameId: gameId, publicGameState: publicGameState, gameMap: map)
//        logger.debug("⚫ Turn 0: Successfully retrieved \(players.count) players from the database.")
//        
//        for player in players {
//            publicGameState.add(playerPublicProfile: player.publicProfile)
//        }
//        
//        var convertedPlayers: [Player] = []
//        for player in players {
//            convertedPlayers.append(Player(id: player.id,
//                                           publicGameState: publicGameState,
//                                           publicProfile: player.publicProfile,
//                                           map: player.map,
//                                           logLevel: player.logLevel))
//        }
//        return Game(id: gameId, theme: theme, publicGameState: publicGameState, players: convertedPlayers, map: map)
//    }
    
    public func close() {
        if let conn = conn {
            sqlite3_close(conn)
        }
    }
}
