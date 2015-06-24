//
//  ViewController.swift
//  QMAcupoint
//
//  Created by QiMENG on 15/6/24.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        SVProgressHUD.show()
        
        Service.medicaPage(0, withBlock: { (obj, error) -> Void in
            
            Service.info()
            
        })
//
//        UIImageView().sd_setImageWithURL(NSURL(string: "http://img.m.supfree.net/xuewei/gif/2.gif"))
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

