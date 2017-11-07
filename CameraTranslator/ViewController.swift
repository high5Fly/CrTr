//
//  ViewController.swift
//  CameraTranslator
//
//  Created by Miroslav Danazhiev on 11/7/17.
//  Copyright © 2017 Miroslav Danazhiev. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tr = GoogleTranslatorManager()
        let param = GoogleTranslateParams(sourceLang: "en", targetLang: "de", text: "Hello World!")
        tr.translate(params: param) { (result) in
            print(result)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

