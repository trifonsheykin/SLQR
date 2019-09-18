//
//  QrViewController.swift
//  SL
//
//  Created by Трифон Шейкин on 27/05/2019.
//  Copyright © 2019 Трифон Шейкин. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader



class QrViewController: UIViewController, QRCodeReaderViewControllerDelegate {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            scanAction() 
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    
}
