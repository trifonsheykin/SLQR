//
//  MyTableViewController.swift
//  SL
//
//  Created by Трифон Шейкин on 25/05/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import UIKit
import SQLite
//import CoreNFC
import QRCodeReader
import CoreLocation
import SystemConfiguration.CaptiveNetwork
var myIndex = 0
//var teamList = [Team]()
var keyList = [Key]()

/*

 
 */

class MyTableViewController: UITableViewController, QRCodeReaderViewControllerDelegate, CLLocationManagerDelegate{
    
    
    //NFCNDEFReaderSessionDelegate,
    //var session: NFCNDEFReaderSession?
    /// - Tag: endScanning
    var locationManager = CLLocationManager()
    var currentNetworkInfos: Array<NetworkInfo>? {
        get {
            return SSID.fetchNetworkInfo()
        }
    }
    var socketConnector:SocketManager!
    var database: Connection!
    var bosId: Int64 = 0

    @IBAction func scan(_ sender: Any) {

        readerVC.delegate = self
        
        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        present(readerVC, animated: true, completion: nil)


    }
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = true
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()
        let qr = result.value
        if let key = keyList.first(where: {$0.doorIdString == qr}) {
            self.startSocketInteraction(key: key)
        } else {
            print("key not found")//"ERROR 02: AES keys not found"
            let alertController = UIAlertController(
                    title: "ERROR 02",
                    message: "AES keys not found",
                    preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        dismiss(animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            updateWiFi()
        }
    }
    
    
//    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
//        // Check the invalidation reason from the returned error.
//        if let readerError = error as? NFCReaderError {
//            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
//                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
//                let alertController = UIAlertController(
//                    title: "Session Invalidated",
//                    message: error.localizedDescription,
//                    preferredStyle: .alert
//                )
//                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                DispatchQueue.main.async {
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//
//    }
    
//    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
//        session.invalidate()
//        DispatchQueue.main.asyncAfter(deadline: .now()) { [weak self] in
//            let temp = String(data: messages[0].records[0].payload, encoding: .utf8)
//            let nfc = String(temp!.suffix(8))
//            if let key = keyList.first(where: {$0.doorIdString == nfc}) {
//                self!.startSocketInteraction(key: key)
//            } else {
//                print("key not found")//"ERROR 02: AES keys not found"
//                let alertController = UIAlertController(
//                    title: "ERROR 02",
//                    message: "AES keys not found",
//                    preferredStyle: .alert
//                )
//                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                DispatchQueue.main.async {
//                    self!.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
//
//    }
    
    func startSocketInteraction(key: Key){
        
        let ssid = getWiFiSSID()
        if ssid == nil{
            let alertController = UIAlertController(
                title: "ERROR 01",
                message: "No Wi-Fi connection found",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            DispatchQueue.main.async {
                self.present(alertController, animated: true, completion: nil)
            }
        }else{
            let portVal = "48910"
            let ipAddr = key.ipAddress
            let soc = DataSocket(ip: ipAddr!, port: portVal)
            if self.socketConnector.startInteraction(key: key, ssid: ssid, socket: soc, context: self) == false{
                let alertController = UIAlertController(
                    title: "Check Wi-Fi connection",
                    message: "Unknown SSID",
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
       
       
        
    }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
            socketConnector = SocketManager(with: self)
            resetUIWithConnection(status: false)
            let dataStore = SQLiteDataStore.sharedInstance
            do {
                try dataStore.createTables()
                
            } catch _ {}
            updateData()
        if #available(iOS 13.0, *) {
            let status = CLLocationManager.authorizationStatus()
            if status == .authorizedWhenInUse {
                updateWiFi()
            } else {
                locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                
            }
        } else {
            updateWiFi()
        }
            

    }
    
    func updateWiFi() {
        print("SSID: \(currentNetworkInfos?.first?.ssid ?? "no SSID")")

    }
    
    func getWiFiSSID() -> String! {
        return currentNetworkInfos?.first!.ssid
    }
    
    
    func updateData() {

        keyList = [Key]()
        do {
            if let keys = try KeyDataHelper.findAll() {
                for key in keys {
                    print("\(key.keyTitle!) \(key.doorIdString!)")
                    keyList.append(Key(rowId: key.rowId,
                                       keyTitle: key.keyTitle,
                                       aesKey: key.aesKey,
                                       ipAddress: key.ipAddress,
                                       doorIdString: key.doorIdString,
                                       doorIdOfBro: key.doorIdOfBro,
                                       userId: key.userId,
                                       userTag: key.userTag,
                                       startDoorTime: key.startDoorTime,
                                       stopDoorTime: key.stopDoorTime,
                                       accessPointSsid: key.accessPointSsid,
                                       acActivated: key.acActivated,
                                       acSecretWord: key.acSecretWord))
                    
                }
            }
        } catch _ {}
        
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateData()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return keyList.count
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
     
        let key = keyList[indexPath.row]
        print(key)
        let open = UIContextualAction(style: .normal, title: "Open") { (action, view, nil) in
            self.startSocketInteraction(key: key)
            //print("Send data to \(key.doorIdString!)")
        }
        startSocketInteraction(key: key)
        
        open.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        let config = UISwipeActionsConfiguration(actions: [open])
        config.performsFirstActionWithFullSwipe = false
       
        return config
        
    }
    
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let key = keyList[indexPath.row]
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, nil) in
            do {try KeyDataHelper.delete(item: key)}
            catch{}
            self.updateData()
            tableView.reloadData()
            print("Delete door \(key.keyTitle ?? "not found")")
        }
        
        let config = UISwipeActionsConfiguration(actions: [delete])
        config.performsFirstActionWithFullSwipe = false
        return config
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let key: Key
        key = keyList[indexPath.row]
        cell.textLabel?.text = "\(key.keyTitle!): " + accessTimeByteToStr(bytes: key.startDoorTime!) +
        " - " + accessTimeByteToStr(bytes: key.stopDoorTime!)
        if key.acActivated == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.929388709, green: 0.9385905774, blue: 0.9385905774, alpha: 1)
        }else{
            cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        //cell.detailTextLabel?.text =
        return cell
    }
    
    func accessTimeByteToStr(bytes: Blob) -> String{
        let string: String = bytes.toHex()
        //var hour, minute, day, month,
        var year :String = ""
        var month :String = ""
        var day :String = ""
        var minute :String = ""
        var hour :String = ""
        var i:Int = 0
        for char in string{
            if i == 0 || i == 1{
                year.append(contentsOf: String(char))
            }else if i == 2 || i == 3 {
                month.append(contentsOf: String(char))
            }else if i == 4 || i == 5 {
                day.append(contentsOf: String(char))
            }else if i == 6 || i == 7 {
                hour.append(contentsOf: String(char))
            }else if i == 8 || i == 9 {
                minute.append(contentsOf: String(char))
            }
            i += 1
        }
        return String(hour + ":" + minute + " " + day + "/" + month + "/" + year)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        myIndex = indexPath.row
        performSegue(withIdentifier: "segue", sender: self)
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}

extension MyTableViewController: PresentersProtocol{
    
    func resetUIWithConnection(status: Bool){
        
//        ipAddressField.isEnabled = !status
//        portField.isEnabled = !status
//        messageField.isEnabled = status
//        connectBtn.isEnabled = !status
//        sendBtn.isEnabled = status
        
        if (status){
            updateStatusViewWith(status: "Connected")
        }else{
            updateStatusViewWith(status: "Disconnected")
        }
    }
    func updateStatusViewWith(status: String){
        
        //statusLabl.text = status
    }
    
    func update(message: String){
        

        
        
    }
    
    
}
public class SSID {
    class func fetchNetworkInfo() -> [NetworkInfo]? {
        if let interfaces: NSArray = CNCopySupportedInterfaces() {
            var networkInfos = [NetworkInfo]()
            for interface in interfaces {
                let interfaceName = interface as! String
                var networkInfo = NetworkInfo(interface: interfaceName,
                                              success: false,
                                              ssid: nil,
                                              bssid: nil)
                if let dict = CNCopyCurrentNetworkInfo(interfaceName as CFString) as NSDictionary? {
                    networkInfo.success = true
                    networkInfo.ssid = dict[kCNNetworkInfoKeySSID as String] as? String
                    networkInfo.bssid = dict[kCNNetworkInfoKeyBSSID as String] as? String
                }
                networkInfos.append(networkInfo)
            }
            return networkInfos
        }
        return nil
    }
}
struct NetworkInfo {
    var interface: String
    var success: Bool = false
    var ssid: String?
    var bssid: String?
}
