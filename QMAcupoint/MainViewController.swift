//
//  MainViewController.swift
//  QMAcupoint
//
//  Created by QiMENG on 15/6/25.
//  Copyright (c) 2015年 QiMENG. All rights reserved.
//

import UIKit

class MainViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate , UICollectionViewDelegateFlowLayout, UISearchBarDelegate{

    var group:Array<Model> = []
    
    @IBOutlet weak var mainSearch: UISearchBar!
    @IBOutlet weak var mainCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        group = Service.readGroup() as! Array<Model>
        
    }

    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        mainSearch.setShowsCancelButton(true, animated: true)
        return true
    }
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        
        if !searchBar.text.isEmpty {
            searchBar.text = ""
            group = Service.readGroup() as! Array<Model>
            mainCollection.reloadData()
        }
        
        mainSearch.setShowsCancelButton(false, animated: true)
        mainSearch.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        group = Service.search(searchBar.text) as! Array<Model>
        
        mainCollection.reloadData()
        
        mainSearch.setShowsCancelButton(false, animated: true)
        mainSearch.resignFirstResponder()
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return group.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let m = group[section] as Model
        return m.subArray.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! UICollectionViewCell
        
        let titleLabel = cell.contentView.viewWithTag(100) as! UILabel
        
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 1
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 3
        
        let subs = group[indexPath.section] as Model
        let m = subs.subArray[indexPath.row] as! Model
        
        titleLabel.text = m.title
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let subs = group[indexPath.section] as Model
        let m = subs.subArray[indexPath.row] as! Model
        
        let option = NSStringDrawingOptions.UsesLineFragmentOrigin
        let attributes = NSDictionary(object: UIFont.systemFontOfSize(20), forKey: NSFontAttributeName)
        
        let stringRect = m.title!.boundingRectWithSize(CGSizeMake(CGFloat.max, CGFloat.max), options: option, attributes: attributes as [NSObject : AnyObject], context: nil)
        
        return stringRect.size
        
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let subs = group[indexPath.section] as Model
        let model = subs.subArray[indexPath.row] as! Model

        self.performSegueWithIdentifier("DetailsViewController", sender: model)
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "DetailsViewController" {
            
            var ctrl = segue.destinationViewController as! DetailsViewController
            ctrl.infoModel = sender as? Model
        }
        
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(10, 10, 10, 10)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var reusableview: UICollectionReusableView?
        
        if kind == UICollectionElementKindSectionHeader {
        
            let headerView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderCell", forIndexPath: indexPath) as! UICollectionReusableView
            
            reusableview = headerView
            
            let titleLabel = headerView.viewWithTag(100) as! UILabel
            
            let m = group[indexPath.section] as Model
            
            titleLabel.text = m.parent + "(\(m.count))"
            
        }
        
        return reusableview!
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
