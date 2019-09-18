//
//  PresentersProtocol.swift
//  SL
//
//  Created by Трифон Шейкин on 02/06/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import Foundation
protocol PresentersProtocol: class {
    
    func resetUIWithConnection(status: Bool)
    func updateStatusViewWith(status: String)
    func update(message: String)
}
