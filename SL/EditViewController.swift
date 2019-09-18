//
//  EditViewController.swift
//  SL
//
//  Created by Трифон Шейкин on 01/06/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import UIKit
import SQLite

class EditViewController: UIViewController {
    
    var key: Key!
    @IBOutlet weak var editText: UITextField!
    
    @IBOutlet weak var tvIpAddress: UILabel!
    @IBOutlet weak var tvDoorId: UILabel!
    @IBOutlet weak var tvStartTime: UILabel!
    @IBOutlet weak var tvStopTime: UILabel!
    @IBOutlet weak var tvActivated: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        key = keyList[myIndex]
        editText.text = key.keyTitle
        tvIpAddress.text = "Lock IP-address: " + key.ipAddress!
        tvDoorId.text = "Door ID: " + key.doorIdString!
        tvStartTime.text = "Start time: " + accessTimeByteToStr(bytes: key.startDoorTime!)
        tvStopTime.text = "Stop time: " + accessTimeByteToStr(bytes: key.stopDoorTime!)
        if key.acActivated == 0 {
            tvActivated.text = "Key is not activated"
        }else{
            tvActivated.text = "Key is activated"
        }
        // Do any additional setup after loading the view.
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
        return String(hour + ":" + minute + " " + day + "." + month + "." + year)
    }
    @IBAction func onClick(_ sender: Any) {
        key.keyTitle  = editText.text
        do {try KeyDataHelper.update(item: key)}
        catch{}
        
        self.navigationController?.popViewController(animated: true)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
