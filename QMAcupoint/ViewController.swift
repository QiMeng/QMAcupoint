//
//  ViewController.swift
//  QMAcupoint
//
//  Created by QiMENG on 15/6/24.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var group:Array<Model> = []
    var subArray:Array<Model> = []
    
    
    @IBOutlet weak var mainSearch: UISearchBar!
    @IBOutlet weak var mainTable: UITableView!
    
    var selectGroupCell:GroupCell?
    var selectGroupInt:Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        selectGroupInt = -1
        
        mainTable.tableFooterView = UIView()
        
        
//        group = Service.readGroup() as! Array<Model>
//        
//        mainTable.reloadData()
        
//        reloadData()
        
    }
    
    func reloadData() {
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
        Service.medicaPage(0, withBlock: { (obj, error) -> Void in
            Service.info()
        })

    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return group.count
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let m = group[section] as Model
        
        return m.subArray.count
        
//        if selectGroupInt == section {
//            return subArray.count
//        }
//        return 0
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let m = group[section] as Model
//        
//        return m.parent + "(\(m.count))"
//    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(44)
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let m = group[section] as Model
        
        let groupCell = tableView.dequeueReusableCellWithIdentifier("GroupCell") as! GroupCell
        
//        groupCell.tag = section + 1000
//        let tap = UITapGestureRecognizer(target: self, action: "touchGroup:")
//        groupCell.addGestureRecognizer(tap)
//        if selectGroupInt == section {
//            groupCell.infoBtn?.transform =  CGAffineTransformMakeRotation(CGFloat(M_PI * 0.5))
//        }

        groupCell.nameLabel?.text = m.parent + "(\(m.count))"
        

        return groupCell;
        
    }
    

//    func touchGroup(sender: UITapGestureRecognizer){
//        
//        let groupCell = sender.view as! GroupCell
//        
//        
//        UIView.animateWithDuration(0.3, animations: { () -> Void in
//            
//            if groupCell == self.selectGroupCell {
//                
//                groupCell.infoBtn?.transform =  CGAffineTransformIdentity
//                self.selectGroupCell = nil
//                
//            }else {
//                
//                self.selectGroupCell?.infoBtn?.transform =  CGAffineTransformIdentity
//                
//                groupCell.infoBtn?.transform =  CGAffineTransformMakeRotation(CGFloat(M_PI * 0.5))
//            }
//            
//        }) { (isBool) -> Void in
//            
//            self.selectGroupCell = groupCell
//            
//            let section =  groupCell.tag - 1000
//            self.selectGroupInt = section
//            
//            let m = self.group[section] as Model
//            
//            self.subArray = Service.readPointsFromGroup(m) as! Array<Model>
//            self.mainTable.reloadData()
//            self.mainTable.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: Int(self.selectGroupInt!)), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
//        }
//    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! UITableViewCell
        
//        cell.indentationLevel = 1
        
        let subs = group[indexPath.section] as Model
        
        let m = subs.subArray[indexPath.row] as! Model
        
        cell.textLabel?.text = m.title
        
        return cell
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

