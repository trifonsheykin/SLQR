//
//  DataHelper.swift
//  SL
//
//  Created by Трифон Шейкин on 28/05/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import Foundation
import SQLite


protocol DataHelperProtocol {
    associatedtype T
    static func createTable() throws -> Void
    static func insert(item: T) throws -> Int64
    static func update(item: T) throws -> Void
    static func delete(item: T) throws -> Void
    static func findAll() throws -> [T]?
    static func findByDoorId(doorId: String) throws -> T?
}

class KeyDataHelper: DataHelperProtocol {
    static let TABLE_NAME = "Keys"
    static let table = Table(TABLE_NAME)
    static let rowId = Expression<Int64>("rowId")
    static let keyTitle = Expression<String>("keyTitle")
    static let aesKey = Expression<Blob>("aesKey")
    static let ipAddress = Expression<String>("ipAddress")
    static let doorIdString = Expression<String>("doorIdString")
    static let doorIdOfBro = Expression<String>("doorIdOfBro")
    static let userId = Expression<Blob>("userId")
    static let userTag = Expression<Int64>("userTag")
    static let startDoorTime = Expression<Blob>("startDoorTime")
    static let stopDoorTime = Expression<Blob>("stopDoorTime")
    static let accessPointSsid = Expression<String>("accessPointSsid")
    static let acActivated = Expression<Int64>("acActivated")
    static let acSecretWord = Expression<Blob>("acSecretWord")
    typealias T = Key
    
    static func createTable() throws {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        do {
            let _ = try DB.run( table.create(ifNotExists: true) {t in
                t.column(rowId, primaryKey: true)
                t.column(keyTitle)
                t.column(aesKey)
                t.column(ipAddress)
                t.column(doorIdString)
                t.column(doorIdOfBro)
                t.column(userId)
                t.column(userTag)
                t.column(startDoorTime)
                t.column(stopDoorTime)
                t.column(accessPointSsid)
                t.column(acActivated)
                t.column(acSecretWord)
            })
        } catch _ {
            // Error throw if table already exists
        }
    }
    
    static func insert(item: Key) throws -> Int64 {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if (item.keyTitle != nil &&
            item.aesKey != nil &&
            item.ipAddress != nil &&
            item.doorIdString != nil &&
            item.doorIdOfBro != nil &&
            item.userId != nil &&
            item.userTag != nil &&
            item.startDoorTime != nil &&
            item.stopDoorTime != nil &&
            item.accessPointSsid != nil &&
            item.acActivated != nil &&
            item.acSecretWord != nil) {
            let insert = table.insert(keyTitle <- item.keyTitle!,
                                      aesKey <- item.aesKey!,
                                      ipAddress <- item.ipAddress!,
                                      doorIdString <- item.doorIdString!,
                                      doorIdOfBro <- item.doorIdOfBro!,
                                      userId <- item.userId!,
                                      userTag <- item.userTag!,
                                      startDoorTime <- item.startDoorTime!,
                                      stopDoorTime <- item.stopDoorTime!,
                                      accessPointSsid <- item.accessPointSsid!,
                                      acActivated <- item.acActivated!,
                                      acSecretWord <- item.acSecretWord!)
            do {
                let rowId = try DB.run(insert)
                guard rowId > 0 else {
                    throw DataAccessError.Insert_Error
                }
                return rowId
            } catch _ {
                throw DataAccessError.Insert_Error
            }
        }
        throw DataAccessError.Nil_In_Data
    }
    
    //update types
    //change keyTitle find by _id_
    //change all but save _id_ and _doorID_
    //change acActivated and accessPointSsid when used 1st time find by _id_
    //change aesKey find by _id_
    
    static func update(item: Key) throws {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if(item.keyTitle != nil &&
            item.aesKey != nil &&
            item.ipAddress != nil &&
            item.doorIdString != nil &&
            item.doorIdOfBro != nil &&
            item.userId != nil &&
            item.userTag != nil &&
            item.startDoorTime != nil &&
            item.stopDoorTime != nil &&
            item.accessPointSsid != nil &&
            item.acActivated != nil &&
            item.acSecretWord != nil){
            if let id = item.rowId {
                let query = table.filter(rowId == id)
                do {
                    let tmp = try DB.run(query.update(keyTitle <- item.keyTitle!,
                                                      aesKey <- item.aesKey!,
                                                      ipAddress <- item.ipAddress!,
                                                      doorIdString <- item.doorIdString!,
                                                      doorIdOfBro <- item.doorIdOfBro!,
                                                      userId <- item.userId!,
                                                      userTag <- item.userTag!,
                                                      startDoorTime <- item.startDoorTime!,
                                                      stopDoorTime <- item.stopDoorTime!,
                                                      accessPointSsid <- item.accessPointSsid!,
                                                      acActivated <- item.acActivated!,
                                                      acSecretWord <- item.acSecretWord!))//delete())
                    guard tmp == 1 else {
                        throw DataAccessError.Update_Error
                    }
                } catch _ {
                    throw DataAccessError.Update_Error
                }
            }
        }
    }
    
    static func delete(item: Key) throws {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        if let id = item.rowId {
            let query = table.filter(rowId == id)
            do {
                let tmp = try DB.run(query.delete())
                guard tmp == 1 else {
                    throw DataAccessError.Delete_Error
                }
            } catch _ {
                throw DataAccessError.Delete_Error
            }
        }
    }
    
    static func findAll() throws -> [Key]? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        var retArray = [T]()
        let items = try DB.prepare(table)
        for item in items {
            retArray.append(Key( rowId: item[rowId],
                                 keyTitle: item[keyTitle],
                                 aesKey: item[aesKey],
                                 ipAddress: item[ipAddress],
                                 doorIdString: item[doorIdString],
                                 doorIdOfBro: item[doorIdOfBro],
                                 userId: item[userId],
                                 userTag: item[userTag],
                                 startDoorTime: item[startDoorTime],
                                 stopDoorTime: item[stopDoorTime],
                                 accessPointSsid: item[accessPointSsid],
                                 acActivated: item[acActivated],
                                 acSecretWord: item[acSecretWord]))
        }
        return retArray
    }
    
    static func findByDoorId(doorId: String) throws -> Key? {
        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
            throw DataAccessError.Datastore_Connection_Error
        }
        
        let query = table.filter(doorIdString == doorId)
        let items = try DB.prepare(query)
        for item in items {
            return Key( rowId: item[rowId],
                        keyTitle: item[keyTitle],
                        aesKey: item[aesKey],
                        ipAddress: item[ipAddress],
                        doorIdString: item[doorIdString],
                        doorIdOfBro: item[doorIdOfBro],
                        userId: item[userId],
                        userTag: item[userTag],
                        startDoorTime: item[startDoorTime],
                        stopDoorTime: item[stopDoorTime],
                        accessPointSsid: item[accessPointSsid],
                        acActivated: item[acActivated],
                        acSecretWord: item[acSecretWord])
        }
    
        return nil
    }
    
    
    
}




//class TeamDataHelper: DataHelperProtocol {
//    static let TABLE_NAME = "Teams"
//
//    static let table = Table(TABLE_NAME)
//    static let teamId = Expression<Int64>("teamid")
//    static let city = Expression<String>("city")
//    static let nickName = Expression<String>("nickname")
//    static let abbreviation = Expression<String>("abbreviation")
//
//
//    typealias T = Team
//
//    static func createTable() throws {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        do {
//            let _ = try DB.run( table.create(ifNotExists: true) {t in
//                t.column(teamId, primaryKey: true)
//                t.column(city)
//                t.column(nickName)
//                t.column(abbreviation)
//            })
//
//        } catch _ {
//            // Error throw if table already exists
//        }
//
//    }
//
//    static func insert(item: T) throws -> Int64 {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        if (item.city != nil && item.nickName != nil && item.abbreviation != nil) {
//            let insert = table.insert(city <- item.city!, nickName <- item.nickName!, abbreviation <- item.abbreviation!)
//            do {
//                let rowId = try DB.run(insert)
//                guard rowId > 0 else {
//                    throw DataAccessError.Insert_Error
//                }
//                return rowId
//            } catch _ {
//                throw DataAccessError.Insert_Error
//            }
//        }
//        throw DataAccessError.Nil_In_Data
//
//    }
//
//    static func delete (item: T) throws -> Void {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        if let id = item.teamId {
//            let query = table.filter(teamId == id)
//            do {
//                let tmp = try DB.run(query.delete())
//                guard tmp == 1 else {
//                    throw DataAccessError.Delete_Error
//                }
//            } catch _ {
//                throw DataAccessError.Delete_Error
//            }
//        }
//    }
//
//    static func update (item: T) throws -> Void {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        if(item.abbreviation != nil){
//            if let id = item.teamId {
//                let query = table.filter(teamId == id)
//                do {
//                    let tmp = try DB.run(query.update(abbreviation <- item.abbreviation!))//delete())
//                    guard tmp == 1 else {
//                        throw DataAccessError.Update_Error
//                    }
//                } catch _ {
//                    throw DataAccessError.Update_Error
//                }
//            }
//        }
//
//    }
//
//    static func find(id: Int64) throws -> T? {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        let query = table.filter(teamId == id)
//        let items = try DB.prepare(query)
//        for item in  items {
//            return Team(teamId: item[teamId] , city: item[city], nickName: item[nickName], abbreviation: item[abbreviation])
//        }
//
//        return nil
//
//    }
//
//    static func findAll() throws -> [T]? {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        var retArray = [T]()
//        let items = try DB.prepare(table)
//        for item in items {
//            retArray.append(Team(teamId: item[teamId], city: item[city], nickName: item[nickName], abbreviation: item[abbreviation]))
//        }
//
//        return retArray
//
//    }
//
//}
//
//
//
//class PlayerDataHelper: DataHelperProtocol {
//
//
//
//    static let TABLE_NAME = "Players"
//
//    static let playerId = Expression<Int64>("playerid")
//    static let firstName = Expression<String>("firstName")
//    static let lastName = Expression<String>("lastName")
//    static let number = Expression<Int>("number")
//    static let teamId = Expression<Int64>("teamid")
//    static let position = Expression<String>("position")
//
//
//    static let table = Table(TABLE_NAME)
//
//    typealias T = Player
//
//    static func createTable() throws {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        do {
//            _ = try DB.run( table.create(ifNotExists: true) {t in
//
//                t.column(playerId, primaryKey: true)
//                t.column(firstName)
//                t.column(lastName)
//                t.column(number)
//                t.column(teamId)
//                t.column(position)
//
//            })
//        } catch _ {
//            // Error thrown when table exists
//        }
//    }
//
//    static func insert(item: T) throws -> Int64 {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        if (item.firstName != nil && item.lastName != nil && item.teamId != nil && item.position != nil) {
//            let insert = table.insert(firstName <- item.firstName!, number <- item.number!, lastName <- item.lastName!, teamId <- item.teamId!, position <- item.position!.rawValue)
//            do {
//                let rowId = try DB.run(insert)
//                guard rowId >= 0 else {
//                    throw DataAccessError.Insert_Error
//                }
//                return rowId
//            } catch _ {
//                throw DataAccessError.Insert_Error
//            }
//        }
//        throw DataAccessError.Nil_In_Data
//    }
//
//    static func delete (item: T) throws -> Void {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        if let id = item.playerId {
//            let query = table.filter(playerId == id)
//            do {
//                let tmp = try DB.run(query.delete())
//                guard tmp == 1 else {
//                    throw DataAccessError.Delete_Error
//                }
//            } catch _ {
//                throw DataAccessError.Delete_Error
//            }
//        }
//
//    }
//
//    static func find(id: Int64) throws -> T? {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        let query = table.filter(playerId == id)
//        let items = try DB.prepare(query)
//        for item in  items {
//            return Player(playerId: item[playerId], firstName: item[firstName], lastName: item[lastName], number: item[number], teamId: item[teamId], position: Positions(rawValue: item[position]))
//        }
//
//        return nil
//
//    }
//    static func update(item: Player) throws {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        if(item.firstName != nil){
//            if let id = item.teamId {
//                let query = table.filter(teamId == id)
//                do {
//                    let tmp = try DB.run(query.update(firstName <- item.firstName!))//delete())
//                    guard tmp == 1 else {
//                        throw DataAccessError.Update_Error
//                    }
//                } catch _ {
//                    throw DataAccessError.Update_Error
//                }
//            }
//        }
//    }
//    static func findAll() throws -> [T]? {
//        guard let DB = SQLiteDataStore.sharedInstance.BBDB else {
//            throw DataAccessError.Datastore_Connection_Error
//        }
//        var retArray = [T]()
//        let items = try DB.prepare(table)
//        for item in items {
//            retArray.append(Player(playerId: item[playerId], firstName: item[firstName], lastName: item[lastName], number: item[number], teamId: item[teamId], position: Positions(rawValue: item[position])))
//        }
//
//        return retArray
//    }
//}
