//
//  SocketManager.swift
//  SL
//
//  Created by Трифон Шейкин on 02/06/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import Foundation
import SQLite
import CryptoSwift

class SocketManager: NSObject, StreamDelegate{
    
    var readStream: Unmanaged<CFReadStream>?
    var writeStream: Unmanaged<CFWriteStream>?
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var messages = [AnyHashable]()
    weak var uiPresenter :PresentersProtocol!
    
    var myContext: UIViewController?
    init(with presenter:PresentersProtocol){
        
        self.uiPresenter = presenter
    }
    func connectWith(socket: DataSocket) {
        
        CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault, (socket.ipAddress! as CFString), UInt32(socket.port), &readStream, &writeStream)
        messages = [AnyHashable]()
        open()
    }
    
    func disconnect(){
        
        close()
    }
    
    func open() {
        print("Opening streams.")
        outputStream = writeStream?.takeRetainedValue()
        inputStream = readStream?.takeRetainedValue()
        outputStream?.delegate = self
        inputStream?.delegate = self
        outputStream?.schedule(in: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.schedule(in: RunLoop.current, forMode:  RunLoop.Mode.default)
        outputStream?.open()
        inputStream?.open()
    }
    
    func close() {
        print("Closing streams.")
        uiPresenter?.resetUIWithConnection(status: false)
        inputStream?.close()
        outputStream?.close()
        inputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        outputStream?.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
        inputStream?.delegate = nil
        outputStream?.delegate = nil
        inputStream = nil
        outputStream = nil
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {//func stream(_ aStream: Stream, handle eventCode: Stream.Event)
        print("stream event \(eventCode)")
        switch eventCode {
        case .openCompleted:
            uiPresenter?.resetUIWithConnection(status: true)
            print("Stream opened")
        case .hasBytesAvailable:
            if aStream == inputStream {
                var dataBuffer = Array<UInt8>(repeating: 0, count: 1024)
                var len: Int
                while (inputStream?.hasBytesAvailable)!{
                    len = (inputStream?.read(&dataBuffer, maxLength: 1024))!
                    if len > 0 {
                        let bytes = [UInt8](dataBuffer[0..<len])
                        if len == 8 {
                            errorHandle(message: bytes)
                        }else{
                            messageReceived(message: bytes)
                        }
                        
                    }
                }
                if dialogStage == 3 {close()}
            }
        case .hasSpaceAvailable:
            print("Stream has space available now")
        case .errorOccurred:
            print("\(aStream.streamError?.localizedDescription ?? "")")
        case .endEncountered:
            aStream.close()
            aStream.remove(from: RunLoop.current, forMode: RunLoop.Mode.default)
            print("close stream")
            uiPresenter?.resetUIWithConnection(status: false)
        default:
            print("Unknown event")
        }
    }
    func errorHandle(message: [UInt8]){
        //print(intToStr(input: message))
        let errorCode: String = intToStr(input: message)
        var out: String?
        if errorCode == "ERROR 10"{//        {//SEQ_START_MSG_LENGTH_ERR = 10,//input message is no valid length
            out = "SEQ_START_MSG_LENGTH_ERR\nmessage length is not valid"
        }else if errorCode == "ERROR 11" {// SEQ_FLOW_MSG_LENGTH_ERR = 11,//input message is no valid length
            out = "SEQ_FLOW_MSG_LENGTH_ERR\nmessage length is not valid"
        }else if errorCode == "ERROR 12"{//NEW_MSG_LINK_ERR = 12, //device is working with another link at the moment
            out = "NEW_MSG_LINK_ERR\nDevice is busy. Try to connect later"
        }else if errorCode == "ERROR 13"{//PING_XOR_ERR = 13,
            out = "PING_XOR_ERR\nCheck synchronisation"
        }else if errorCode == "ERROR 14"{//PING_TEXT_ERR = 14,
            out = "PING_TEXT_ERR\nNot ping command"
        }else if errorCode == "ERROR 20"{// SYNC_XOR_CHECK_ERR = 20,
            out = "SYNC_XOR_CHECK_ERR\nSync process error"
        }else if errorCode == "ERROR 21"{// SYNC_XOR_CMD_ERR = 21,
            out = "SYNC_XOR_CMD_ERR\nSync process error"
        }else if errorCode == "ERROR 22"{//SYNC_FLOW_CMD_ERR = 22,
            out = "SYNC_FLOW_CMD_ERR\nSync process error"
        }else if errorCode == "ERROR 23"{//MSG_TWO_TYPE_ERR = 23,
            out = "MSG_TWO_TYPE_ERR\nYour access code is not valid"
        }else if errorCode == "ERROR 24"{//USER_TAG_ERR = 24,
            out = "USER_TAG_ERR\nCheck your access code"
        }else if errorCode == "ERROR 30"{//DOOR_OPEN_XOR_ERR = 30,
            out = "DOOR_OPEN_XOR_ERR\nCheck your access code"
        }else if errorCode == "ERROR 31"{//DOOR_OPEN_USER_ID_ERR = 31,
            out = "DOOR_OPEN_USER_ID_ERR\nCheck your access code"
        }else if errorCode == "ERROR 32"{//DOOR_OPEN_DOOR_ID_ERR = 32,
            out = "DOOR_OPEN_DOOR_ID_ERR\nCheck the door ID"
        }else if errorCode == "ERROR 33"{//DOOR_OPEN_ASSESS_TIME_ERR = 33,
            out = "DOOR_OPEN_ASSESS_TIME_ERR\nCheck your access time"
        }else if errorCode == "ERROR 40"{//PASS_ACTION_XOR_ERR = 40,
            out = "PASS_ACTION_XOR_ERR\nCheck synchronisation"
        }else if errorCode == "ERROR 41"{//PASS_ACTION_USER_ID_ERR = 41,
            out = "PASS_ACTION_USER_ID_ERR\nCheck synchronisation"
        }else if errorCode == "ERROR 42"{//PASS_ACTION_ADMIN_TAG_ERR = 42,
            out = "PASS_ACTION_ADMIN_TAG_ERR\nCheck synchronisation"
        }else if errorCode == "ERROR 43"{//PASS_ACTION_PLAY_PASS_ERR = 43,
            out = "PASS_ACTION_PLAY_PASS_ERR\nCheck your pass code"
        }else if errorCode == "ERROR 50"{//NEW_USER_ADM_KEY_ERR = 50,
            out = "NEW_USER_ADM_KEY_ERR\nCheck your access code"
        }else if errorCode == "ERROR 51"{//NEW_USER_XOR_CHECK_ERR = 51,
            out = "NEW_USER_XOR_CHECK_ERR\nCheck your access code"
        }else if errorCode == "ERROR 52"{//NEW_USER_ID_EMPTY_ERR = 52,
            out = "NEW_USER_ID_EMPTY_ERR\nCheck your access code"
        }else if errorCode == "ERROR 53"{//NEW_USER_ID_KEY_ERR = 53,
            out = "NEW_USER_ID_KEY_ERR\nCheck your access code"
        }else if errorCode == "ERROR 60"{//SECRET_CHECK_AES_ERR = 60,
            out = "SECRET_CHECK_AES_ERR\nCheck your access code"
        }else if errorCode == "ERROR 61"{//SECRET_ACCESS_TIME_ERR = 61,
            out = "SECRET_ACCESS_TIME_ERR\nCheck your access time"
        }else if errorCode == "ERROR 62"{//SECRET_ACCESS_RTC_ERR = 62,
            out = "SECRET_ACCESS_RTC_ERR\nCheck your access time"
        }else if errorCode == "ERROR 63"{//SECRET_USER_ID_ERR = 63
            out = "SECRET_USER_ID_ERR\nCheck your access code"
        }else if errorCode == "ERROR 06"{//SECRET_USER_ID_ERR = 63
            out = "XOR check error.\nYour access code is not valid"
        }else{
            out = "description not found"
        }
        
        
        let alertController = UIAlertController(
            title: errorCode,
            message: out,
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.myContext!.present(alertController, animated: true, completion: nil)
        }
        
    }
    func intToStr(input:[UInt8]) -> String{
        let data = NSData(bytes: input, length: input.count)
        let newNSString = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)!
        return newNSString as String
    }
    
    
    
    var dialogStage = 1;
    var XORcheck: UInt8 = 0
    var initVectorRX: [UInt8] = [0]
    var initVectorTX: [UInt8] = [0]
    var globalKey: Key?
    var globalSSID: String?
    
    func startInteraction(key: Key, ssid: String!, socket: DataSocket, context: UIViewController) -> Bool{
        print("Start interaction")
        myContext = context
        if ssid == nil {return false}
        if key.accessPointSsid!.count == 0 || key.accessPointSsid == ssid {
            connectWith(socket: socket)
            globalSSID = ssid
            dialogStage = 1
            do {
                globalKey = try KeyDataHelper.findByDoorId(doorId: key.doorIdString!)!
            }catch{
                print("No doorId")
            }
            var nonce = makeRandomArray(16)
            nonce[0] = UInt8(key.userTag!)
            XORcheck = xorCalc(input: nonce)
            initVectorRX = nonce
            outputStream?.write(nonce, maxLength: nonce.count)
            print("Send nonce:")
            print(nonce)
            return true
        }
        return false
        
        
    }
    

    
    func messageReceived(message: [UInt8]){
        print("Message received")
        if dialogStage == 1 {
            print("Dialog stage 1")
            let encryptedData: [UInt8] = encryptCommand(input: message)
            if encryptedData.count > 1 {
                print("Send encrypted data to open the door")
                outputStream?.write(encryptedData, maxLength: encryptedData.count)
                dialogStage = 2
            }
        }else if dialogStage == 2 {
            print("Dialog stage 2")
            saveDataToDb(newAes: getNewAes(cipher: message))
            dialogStage = 3
        }
        

    }
    
    func encryptCommand(input: [UInt8]) -> [UInt8]!{
        initVectorTX = input
        let decryptedData = decrypt(data: input, initVector: initVectorRX, aesKey: (globalKey?.aesKey!.bytes)!)
        if(decryptedData![0] == XORcheck){
            print(" XORcheck is OK")
            if globalKey?.acActivated == 0 {
                print("Key is not activated. NEW USER REG")
                var plaintext: [UInt8] = [UInt8](repeating: 0, count: 1)
                plaintext[0] = 11//MESSAGE TYPE: NEW_USER_REG 11
                plaintext.append(xorCalc(input: decryptedData!))     //XOR
                plaintext += (globalKey?.userId!.bytes)!   //((globalKey?.userId!.bytes)!)
                plaintext += (globalKey?.acSecretWord!.bytes)!
                plaintext += (globalKey?.doorIdString!.fromBase64() ?? nil)!
                plaintext.append(contentsOf: [0,0,0,0,0,0])
                XORcheck = xorCalc(input: plaintext);
                let txData: [UInt8] = encrypt(data: plaintext, initVector: initVectorTX, aesKey: (globalKey?.aesKey!.bytes)!)
                print("current AES:")
                print((globalKey?.aesKey!.bytes)!)
                initVectorRX = [UInt8](txData[32..<48])
                return txData
            }else{
                print("Key is activated. DOOR_OPEN_MSG")
                var plaintext: [UInt8] = [UInt8](repeating: 0, count: 1)
                plaintext[0] = 5//MESSAGE TYPE: DOOR_OPEN_MSG = 5;//1
                plaintext.append(xorCalc(input: decryptedData!))//1
                plaintext += (globalKey?.userId!.bytes)!//4
                plaintext += (globalKey?.doorIdString!.fromBase64() ?? nil)!//4
                plaintext.append(contentsOf: [0,0,0,0,0,0])
                XORcheck = xorCalc(input: plaintext);
                let txData: [UInt8] = encrypt(data: plaintext, initVector: initVectorTX, aesKey: (globalKey?.aesKey!.bytes)!)
                print("current AES:")
                print((globalKey?.aesKey!.bytes)!)
                initVectorRX = txData
                return txData
            }
        }else{
            errorHandle(message: "ERROR 06".bytes as [UInt8])
            let out:[UInt8] = [UInt8](repeating: 0, count: 1)
            return out
        }
        
    }
    
    
    func getNewAes(cipher: [UInt8]) -> [UInt8]!{
        print("getting new AES from encrypted message:")
        print(cipher)
        let decryptedData: [UInt8] = decrypt(data: cipher, initVector: initVectorRX, aesKey: (globalKey?.aesKey!.bytes)!)
        print("decryption done")
        print(decryptedData)
        if(decryptedData[1] == XORcheck){
            print("new AES:")
            print([UInt8](decryptedData[2..<34]))
            return [UInt8](decryptedData[2..<34])
        }else{
            errorHandle(message: "ERROR 06".bytes as [UInt8])
        }
        return nil
    }
    
    func saveDataToDb(newAes: [UInt8]){
        print("saving new AES to DB")
        globalKey?.aesKey = Blob(bytes: newAes)
        if globalKey?.acActivated == 0 {
            globalKey?.acActivated = 1
            globalKey?.acSecretWord = Blob(bytes: [0])
            globalKey?.accessPointSsid = globalSSID
        }
        
        do {
            try KeyDataHelper.update(item: globalKey!)
            print("Save key to self")
        }catch{}
        
        let broDoorId = (globalKey?.doorIdOfBro)!
        do {
            var key = try KeyDataHelper.findByDoorId(doorId: broDoorId)
            if key != nil {
                key?.aesKey = Blob(bytes: newAes)
                if key?.acActivated == 0 {
                    key?.acActivated = 1
                    key?.acSecretWord = Blob(bytes: [0])
                    key?.accessPointSsid = globalSSID
                }
                do {
                    try KeyDataHelper.update(item: key!)
                    print("Save key to bro")
                }catch{}
                
                
            }
            
            
        }catch{
            print("No bro doorId")
        }
        
        
    }
    
    
    func encrypt(data: [UInt8], initVector: [UInt8], aesKey: [UInt8]) -> [UInt8]!{
        do {
            return try AES(key: aesKey, blockMode: CBC(iv: initVector), padding: .noPadding).encrypt(data)
        } catch {
            print("Encrytion error")
        }
        return nil
    }
    
    
    func decrypt(data: [UInt8], initVector: [UInt8], aesKey: [UInt8]) -> [UInt8]!{
        do {
            return [UInt8](try AES(key: aesKey, blockMode: CBC(iv: initVector), padding: .noPadding).decrypt(data))
        } catch {
            print("Decrytion error")
        }
        return nil
    }
    
    func send(message: String){
        
        let response = "msg:\(message)"
        let buff = [UInt8](message.utf8)
        if let _ = response.data(using: .ascii) {
            outputStream?.write(buff, maxLength: buff.count)
        }
        
    }
    func makeRandomArray(_ n: Int) -> [UInt8] {
        return (0..<n).map{ _ in UInt8.random(in: 0 ... 255) }
    }
    
    func xorCalc(input: [UInt8]) -> UInt8 {
        var output: UInt8 = input[0]
        for i in 1..<input.count{
            output = output ^ input[i]
        }
        return output
    }

    
    
}
