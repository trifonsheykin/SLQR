//
//  SQLiteDataStore.swift
//  SL
//
//  Created by Трифон Шейкин on 28/05/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import Foundation
import SQLite

public enum DataAccessError: Error{
    case Datastore_Connection_Error
    case Insert_Error
    case Delete_Error
    case Update_Error
    case Search_Error
    case Nil_In_Data
}



class SQLiteDataStore {
    static let sharedInstance = SQLiteDataStore()
    let BBDB: Connection?
    
    private init() {
        
        var path = "users.sqlite3"
        
        if let dirs: [NSString] =
            NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory,
                                                FileManager.SearchPathDomainMask.allDomainsMask, true) as [NSString] {
            
            let dir = dirs[0]
            path = dir.appendingPathComponent("users.sqlite3");
            //print(path)
        }
        
        do {
            BBDB = try Connection(path)
        } catch _ {
            BBDB = nil
        }
    }
    
    func createTables() throws{
        do {
            try KeyDataHelper.createTable()
            //try TeamDataHelper.createTable()
            //try PlayerDataHelper.createTable()
        } catch {
            throw DataAccessError.Datastore_Connection_Error
        }
        
    }
}
