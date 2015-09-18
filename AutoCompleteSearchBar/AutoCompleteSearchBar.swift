//
//  AutoCompleteSearchBar.swift
//  MadeInChina
//
//  Created by sheng rong on 9/15/15.
//  Copyright © 2015 MICN. All rights reserved.
//

import Foundation
import UIKit

public protocol AutoCompleteSearchBarDelegate{
    
    //return the results in array of string
    func autoCompleteSeachBarResults(searchBar: AutoCompleteSearchBar, withInputText:String) -> [String]
    //when one of the result was clicked, return the selected result content
    func autoCompleteSearchBarOnSelect(selectedText : String )
}

@objc public class AutoCompleteSearchBar: UISearchBar, UITableViewDataSource, UITableViewDelegate {
    
    static public let HEIGHT_FOR_CELL = 30
    static public let RESULT_FONT_SIZE = CGFloat(12.0)
    static public let SEARCH_TEXT_OFFSET_X = CGFloat(30)
    static public let RESULT_FONT_NAME = "Helvetica"
    
    //compact mode switch
    public var compact : Bool = true
    //max autocomplete container width
    public var maxWidthAutoComplete : CGFloat?
    //max autocomplete container height
    public var maxHeightAutoComplete : CGFloat?
    //max number of result shown in table view
    public var maxResultNumber : Int?
    
    public var autoCompleteDelegate : AutoCompleteSearchBarDelegate?
    private var autoComplteResult : [String]?
    private var resultTableView : UITableView?
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        maxWidthAutoComplete = bounds.width
        maxResultNumber = 5
        setup()
    }
    
    public init(frame: CGRect, maxWidthForAutoCompleteContainer:CGFloat, maxHeightForAutoCompleteContainer: CGFloat) {
        self.maxHeightAutoComplete = maxHeightForAutoCompleteContainer
        self.maxWidthAutoComplete = maxWidthForAutoCompleteContainer
        super.init(frame: frame)
        setup()
    }
    
    public init(frame: CGRect, maxWidthForAutoCompleteContainer:CGFloat, maxResultNumber: Int){
        self.maxResultNumber = maxResultNumber
        self.maxWidthAutoComplete = maxWidthForAutoCompleteContainer
        super.init(frame: frame)
    }
    
    convenience public override init(frame: CGRect) {
        self.init(frame:frame, maxWidthForAutoCompleteContainer:frame.width, maxResultNumber : 5)
    }
    
    deinit{
        resultTableView?.delegate = nil
        resultTableView?.dataSource = nil
        resultTableView = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        maxWidthAutoComplete = bounds.width
        maxResultNumber = 5
        setup()
    }
    
    private func setup(){
        
        //initialize data
        autoComplteResult = []
        
        var tableHeight : CGFloat?
        if maxHeightAutoComplete == nil {
             tableHeight = CGFloat(maxResultNumber! * AutoCompleteSearchBar.HEIGHT_FOR_CELL)
        }else{
            tableHeight = maxHeightAutoComplete
        }
        
        //searchBar setting
        self.searchTextPositionAdjustment = UIOffsetMake(0, 0)
        
        // find my viewcontroller container
        let viewForViewController : UIViewController? = self.firstAvailableViewController()
        if viewForViewController == nil{
            return
        }
        
        //convert my coordinate point to the one within viewcontroller
        let globalPoint = self.convertPoint(frame.origin, toView: viewForViewController?.view)
        
        
        //create and config autoComplete
        resultTableView = UITableView(frame: CGRectMake(0, globalPoint.y + frame.height, maxWidthAutoComplete!, tableHeight!))
        viewForViewController!.view.addSubview(resultTableView!)
        
        resultTableView?.separatorStyle = .None
        resultTableView?.rowHeight = CGFloat(AutoCompleteSearchBar.HEIGHT_FOR_CELL)
        resultTableView?.registerClass(UITableViewCell.self, forCellReuseIdentifier: "autoCompleteResultCell")
        
        resultTableView?.layer.cornerRadius = 2
        resultTableView?.layer.borderWidth = 1
        resultTableView?.layer.borderColor = UIColor.clearColor().CGColor
        
        resultTableView!.delegate = self
        resultTableView!.dataSource = self
        resultTableView?.hidden = true
        
        //notification for search text change
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "searchTextChange:", name: UITextFieldTextDidChangeNotification, object: nil)
    }
    
    func searchTextChange(sender:NSNotificationCenter){
        if self.text == ""{
            resultTableView?.hidden = true
            return
        }
        autoComplteResult = (self.autoCompleteDelegate?.autoCompleteSeachBarResults(self, withInputText: self.text!))!
        guard let results = autoComplteResult
            where results.count > 0 else{
                return
        }
        resultTableView?.reloadData()
        resultTableView?.hidden = false
        updateLayout()
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell : UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("autoCompleteResultCell", forIndexPath: indexPath)
        if cell == nil{
            cell = UITableViewCell(style: .Default, reuseIdentifier: "autoCompleteResultCell")
        }
        cell?.textLabel?.font = UIFont(name: AutoCompleteSearchBar.RESULT_FONT_NAME, size: AutoCompleteSearchBar.RESULT_FONT_SIZE)
        cell?.textLabel!.text = autoComplteResult![indexPath.row]
        cell?.textLabel?.backgroundColor = UIColor.clearColor()
        let selectedView: UIView = UIView(frame: (cell?.bounds)!)
        selectedView.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        cell?.selectedBackgroundView = selectedView
        return cell!
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autoComplteResult!.count
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedText = autoComplteResult![indexPath.row]
        self.text = selectedText
        autoComplteResult = []
        resultTableView?.hidden = true
        self.autoCompleteDelegate?.autoCompleteSearchBarOnSelect(selectedText)
    }
    
    //update table frame
    private func updateLayout(){
        
        let sortedResults = autoComplteResult!.sort(sortedByStringSize)
        let longestString = sortedResults.last
        
        let tableWidth : CGFloat
        let tableOffset : CGFloat
        if compact{
            //calculate table width by using the longest string in results plus cell inset within tableview * 2
            let insetX = resultTableView?.separatorInset.left
            tableWidth = UIFont(name: AutoCompleteSearchBar.RESULT_FONT_NAME, size: AutoCompleteSearchBar.RESULT_FONT_SIZE)!.sizeOfString(longestString!, constrainedToWidth: Double(self.maxWidthAutoComplete!)).width + insetX! * 2
            tableOffset = AutoCompleteSearchBar.SEARCH_TEXT_OFFSET_X
        }else{
            tableWidth = maxWidthAutoComplete!
            tableOffset = 0
        }
        
        //calculate table height by using number of result,or maxresult shown, or maxHeight
        var numberShown = autoComplteResult?.count
        if autoComplteResult?.count > maxResultNumber{
            numberShown = maxResultNumber
        }
        var tableHeight : CGFloat
        if maxHeightAutoComplete == nil{
            tableHeight = CGFloat(numberShown! * AutoCompleteSearchBar.HEIGHT_FOR_CELL)
        }else{
            tableHeight = maxHeightAutoComplete!
        }
        //update frame
        self.resultTableView?.frame = CGRectMake(tableOffset, (resultTableView?.frame.origin.y)!, tableWidth, tableHeight)
    }
    
    func sortedByStringSize(s1: String, s2:String) -> Bool{
        let size1 : CGSize = UIFont(name: AutoCompleteSearchBar.RESULT_FONT_NAME, size:AutoCompleteSearchBar.RESULT_FONT_SIZE)!.sizeOfString(s1, constrainedToWidth: Double(self.maxWidthAutoComplete!))
        let size2 : CGSize = UIFont(name: AutoCompleteSearchBar.RESULT_FONT_NAME, size:AutoCompleteSearchBar.RESULT_FONT_SIZE)!.sizeOfString(s2, constrainedToWidth: Double(self.maxWidthAutoComplete!))
        return size1.width < size2.width
    }
}

private extension UIResponder {
    // Thanks to Phil M
    // http://stackoverflow.com/questions/1340434/get-to-uiviewcontroller-from-uiview-on-iphone
    
    func firstAvailableViewController() -> UIViewController? {
        // convenience function for casting and to "mask" the recursive function
        return self.traverseResponderChainForFirstViewController() as! UIViewController?
    }
    
    func traverseResponderChainForFirstViewController() -> AnyObject? {
        if let nextResponder = self.nextResponder() {
            if nextResponder.isKindOfClass(UIViewController) {
                return nextResponder
            } else if (nextResponder.isKindOfClass(UIView)) {
                return nextResponder.traverseResponderChainForFirstViewController()
            } else {
                return nil
            }
        }
        return nil
    }
}


extension UIFont{
    func sizeOfString (string: String, constrainedToWidth width: Double) -> CGSize {
        return NSString(string: string).boundingRectWithSize(CGSize(width: width, height: DBL_MAX),
            options: [.UsesLineFragmentOrigin, .UsesFontLeading],
            attributes: [NSFontAttributeName: self],
            context: nil).size
    }
}