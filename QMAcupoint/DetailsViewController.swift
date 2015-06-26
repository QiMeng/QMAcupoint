//
//  DetailsViewController.swift
//  QMAcupoint
//
//  Created by QiMENG on 15/6/25.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {

    var infoModel:Model!
    
    @IBOutlet weak var mainScroll: UIScrollView!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var jpgimageView: UIImageView!
    
    @IBOutlet weak var gifImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "\(infoModel.parent) - \(infoModel.title)"
        
        let detail = Service.readInfoPointModel(infoModel) as! Model
        
        infoLabel.text = detail.info
        
        
        jpgimageView.sd_setImageWithURL(NSURL(string: detail.jpg), usingProgressView: nil)
        
        gifImageView.sd_setImageWithURL(NSURL(string: detail.gif), usingProgressView: nil)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
