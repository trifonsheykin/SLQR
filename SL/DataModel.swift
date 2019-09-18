//
//  DataModel.swift
//  SL
//
//  Created by Трифон Шейкин on 28/05/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import Foundation
import SQLite

//enum Positions: String {
//    case Pitcher = "Pitcher"
//    case Catcher = "Catcher"
//    case FirstBase = "First Base"
//    case SecondBase = "Second Base"
//    case ThirdBase = "Third Base"
//    case Shortstop = "Shortstop"
//    case LeftField = "Left Field"
//    case CenterField = "Center Field"
//    case RightField = "Right field"
//    case DesignatedHitter = "Designated Hitter"
//}

//typealias Team = (
//    teamId: Int64?,
//    city: String?,
//    nickName: String?,
//    abbreviation: String?
//)

//typealias Player = (
//    playerId: Int64?,
//    firstName: String?,
//    lastName: String?,
//    number: Int?,
//    teamId: Int64?,
//    position: Positions?
//)

typealias Key = (
    rowId: Int64?,
    keyTitle: String?,
    aesKey:Blob?,
    ipAddress: String?,
    doorIdString: String?,
    doorIdOfBro: String?,
    userId:Blob?,
    userTag: Int64?,
    startDoorTime:Blob?,
    stopDoorTime:Blob?,
    accessPointSsid: String?,
    acActivated: Int64?,
    acSecretWord:Blob?
)


