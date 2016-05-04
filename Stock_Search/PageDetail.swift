//
//  PageDetail.swift
//  Stock_Search
//
//  Created by 高宇 on 5/1/16.
//  Copyright © 2016 Alfred_Gao. All rights reserved.
//

import Foundation
import UIKit
import CoreData
class PageDetail : UIViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate,FBSDKSharingDelegate{
    
    
    var favItemArray = [NSManagedObject]()
    var newText = [String:AnyObject]()
    var detailText = [String:AnyObject]()
    var showTitleArray = ["Name","Symbol","Last Price", "Change", "Time and Date","Market Cap","Volume","Change YTD","High Price","Low Price","Opening Price"]
    var showDetailArray=[String]()
    var isFavCheck = Bool()
    let addDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    
    
    @IBOutlet weak var chart_View: UIWebView!
   
    @IBOutlet weak var Detail_View: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var New_View: UITableView!
    
    @IBOutlet weak var Detail_Segment: UISegmentedControl!
    
    @IBOutlet weak var favButton: UIButton!
    // MARK: TableView Data Source Methods
    @IBOutlet weak var chartImg: UIImageView!
    @IBOutlet weak var charImgf: UIImageView!
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.Detail_View {
            return showDetailArray.count
        }
        else {
            return 4
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let subNew = newText["d"]!
        let subNewresult = subNew["results"]!
        let subArray = subNewresult![indexPath.row]
        let link = subArray["Url"] as! String
        
        if let url = NSURL(string: link) {
            UIApplication.sharedApplication().openURL(url)
        }
        print(link)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let defaultV = UITableViewCell()
        if tableView == self.Detail_View {
            let cell = Detail_View.dequeueReusableCellWithIdentifier("detailCell") as! detailCell
            cell.detail_Label.text = showTitleArray[indexPath.row]
            cell.detail_Value.text = showDetailArray[indexPath.row]
            if cell.detail_Label.text ==  "Change" {
                if cell.detail_Value.text?.substringToIndex((cell.detail_Value.text?.startIndex.advancedBy(1))!) == "+" {
                    let img = UIImage(named: "icon/up.png")
                    cell.detail_img.image = img
                } else {
                    let img = UIImage(named: "icon/down.png")
                    cell.detail_img.image = img
                }
            }
            
            if cell.detail_Label.text == "Change YTD" {
                if cell.detail_Value.text?.substringToIndex((cell.detail_Value.text?.startIndex.advancedBy(1))!) == "+" {
                    let img = UIImage(named: "icon/up.png")
                    cell.detail_img.image = img
                } else {
                    let img = UIImage(named: "icon/down.png")
                    cell.detail_img.image = img
                }

            }
            return cell
        } else if tableView == self.New_View {
            let cell = New_View.dequeueReusableCellWithIdentifier("newsCell") as! newsCell
            let subNew = newText["d"]!
            let subNewresult = subNew["results"]!
            let subArray = subNewresult![indexPath.row]
            let titleStr = subArray["Title"] as! String
            let desStr = subArray["Description"] as! String
            let srcStr = subArray["Source"] as! String
            let dateStr = subArray["Date"] as! String
            print(titleStr)
            cell.NewsMainTitle.text = titleStr
            cell.NewsSubTitle.text = desStr
            cell.NewsSrc.text = srcStr
            cell.NewsDate.text = formateTime(dateStr)
            return cell
        }
        
        return defaultV
        
    }
    
    func formateTime(input_time: String) -> String {
        let time = input_time
        var timeArray = time.characters.split{$0 == "T"}.map(String.init)
        //        This is date
        var date = timeArray[0]
        var hourArray = timeArray[1].characters.split{$0 == "Z"}.map(String.init)
        //        This is Otiginal Hour and Min
        let hourMin = hourArray[0]
        //        This is original hour
        var hourStr = hourMin.characters.split{$0 == ":"}.map(String.init)
        var newHour = Int(hourStr[0])! - 7
        var output = ""
        if newHour < 10 && newHour > 0 {
            output = date + " 0" + String(newHour) + ":" + hourStr[1] + ":" + hourStr[2]
            //            print(output)
            return output
        }
        else if newHour < 0 {
            newHour = newHour + 24
            var dateArray = date.characters.split{$0 == "-"}.map(String.init)
            dateArray[2] = String(Int(dateArray[2])! - 1)
            date = dateArray[0] + "-" + dateArray[1] + "-0" + dateArray[2]
            output = date + " " + String(newHour) + ":" + hourStr[1] + ":" + hourStr[2]
            //            print(output)
            return output
        }
        else {
            return date + " " + String(newHour) + ":" + hourStr[1] + ":" + hourStr[1]
        }
    }
    
    
    func transferTime(item:String) -> String {
        print(item)
        var spaceIndex = 1
        
        while item[item.startIndex.advancedBy(spaceIndex)] != " " {
            spaceIndex += 1
        }
        
        print(spaceIndex)
        
        var secSpaceIndex = spaceIndex + 1
        spaceIndex += 1
        while item[item.startIndex.advancedBy(secSpaceIndex)]  != " "{
            secSpaceIndex += 1
        }
        secSpaceIndex += 1
        
        let Month = item.substringWithRange(Range<String.Index>(start: item.startIndex.advancedBy(spaceIndex), end: item.startIndex.advancedBy(secSpaceIndex)))
        print(Month)
        
        var thrSpaceIndex = secSpaceIndex
        
        while item[item.startIndex.advancedBy(thrSpaceIndex)] != " " {
            thrSpaceIndex += 1;
        }
        thrSpaceIndex += 1
        
        let date = item.substringWithRange(Range<String.Index>(start: item.startIndex.advancedBy(secSpaceIndex), end: item.startIndex.advancedBy(thrSpaceIndex)))
        
        var fouSpaceIndex = thrSpaceIndex + 5
        
        let time = item.substringWithRange(Range<String.Index>(start: item.startIndex.advancedBy(thrSpaceIndex), end: item.startIndex.advancedBy(fouSpaceIndex)))
        
        let year = item.substringFromIndex(item.endIndex.advancedBy(-4))
        
        let retval = Month + date + year + " " + time
        print(retval)
        print(time)
        print(date)
        print(year)
        return retval
        
    }
    
    func transferVol(item:Float) -> String {
        if item < 1000000 {
            print(item)
            return String(item)
        }
        else if item >= 1000000 && item < 1000000000 {
            let retval = item/1000000;
            var retStr = String(format: "%.2f", retval)
            retStr += " Million";
            print(retStr)
            return retStr
        }
        else {
            let val = item/1000000000;
            var retStr = String(format: "%.2f", val)
            retStr += " Billion"
            print(retStr)
            return retStr
        }
    }
    
    func transferMoney(item:Float) -> String {
        print(item)
        let digitTwo = String(format:"%.2f",item)
        print(digitTwo)
        let retVal = "$ " + digitTwo
        return retVal
    }

    func transferChange(item:Float, item1: Float) -> String {
        var retval = String()
        let digitTwo = String(format: "%.2f", item)
        let digitPercent = String(format: "%.2f", item1)
        if item > 0{
           retval = "+"+digitTwo+"("+digitPercent+"%)"
        } else {
            retval = digitTwo+"("+digitPercent+"%)"

        }
        print(retval)
        return retval
    }
    
    override func viewDidLoad() {
        print(detailText)
        self.title = detailText["Symbol"] as! String
        showDetailArray.append(detailText["Name"] as! String)
        showDetailArray.append(detailText["Symbol"] as! String)
        showDetailArray.append(transferMoney(detailText["LastPrice"]as! Float))
        showDetailArray.append(transferChange(detailText["Change"]as! Float, item1: detailText["ChangePercent"]as! Float))
        showDetailArray.append(transferTime(detailText["Timestamp"] as! String))
        showDetailArray.append(transferVol(detailText["MarketCap"] as! Float))
        showDetailArray.append(String(detailText["Volume"]!))
        showDetailArray.append(transferChange(detailText["ChangeYTD"]as! Float, item1: detailText["ChangePercentYTD"]as! Float))
        showDetailArray.append(transferMoney(detailText["High"]as! Float))
        showDetailArray.append(transferMoney(detailText["Low"]as! Float))
        showDetailArray.append(transferMoney(detailText["Open"]as! Float))
        
        chart_View.delegate = self
        chart_View.loadRequest(NSURLRequest(URL:NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("webView/stock_chart_app", ofType: "html")!)))
        
        scrollView.contentSize = CGSizeMake(370, 1000)
        
        var SymbolName = String()
        SymbolName = detailText["Symbol"] as! String
        
        let imgUrl = "http://chart.finance.yahoo.com/t?s=" + SymbolName + "&lang=en-US&width=352&height=264"
        if let URL = NSURL(string: imgUrl) {
            if let imgData = NSData(contentsOfURL: URL) {
                charImgf.image = UIImage(data: imgData)
            }
        }
        
        print(checkInFav())
        
        if checkInFav(){
            isFavCheck = true
//            let img = UIImage(named:"icon/Star-50.png")! as UIImage
            self.favButton.setBackgroundImage(UIImage(named:"icon/fb.png"), forState: UIControlState.Normal)
        }else {
            isFavCheck = false
            let img = UIImage(named:"icon/Star-50.png")! as UIImage
            self.favButton.setBackgroundImage(img, forState: UIControlState.Normal)
        }
        
        //let addDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        //let managedContext = addDelegate.managedObjectContext
        
        //delAll()
        print(newText)
        
    }
    
    
    // MARK: Clear core data programmatically (加了注释之后变成打印功能 取消注释是清空）
    func delAll() {
        let img = UIImage(named:"icon/Star-50.png")! as UIImage
        
        self.favButton.setBackgroundImage(img, forState: UIControlState.Normal)
        
        //let addDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let managedContext = addDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "FavEntity")
        
        do {
            
            
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            favItemArray = results as! [NSManagedObject]
            
//            for item in favItemArray {
//                
//                managedContext.deleteObject(item)
//                
//                    
//                
//            }
//            favItemArray.removeAll()
            
            for item in favItemArray {
                if let name = item.valueForKey("company_name") {
                    let nameStr = item.valueForKey("company_name") as! String
                    print(nameStr)
                }
            }
            
        } catch {
            print("Error")
        }
        //end del function
    }
    
    
    // MARK: check whether the stock user get is in core data
    func checkInFav() -> Bool {
        /* let addDelegate = UIApplication.sharedApplication().delegate as! AppDelegate */
        
        let managedContext = addDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "FavEntity")
        
        do {
            
            
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            favItemArray = results as! [NSManagedObject]
            
            for item in favItemArray {
                if let name = item.valueForKey("company_name") {
                    if detailText["Name"] as! String == item.valueForKey("company_name") as! String {
                        return true
                    }
                    
                }
                
            }
            
        } catch {
            print("Error")
        }
        return false
        //ENd check function
    }

    
    override func viewDidLayoutSubviews() {
        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSizeMake(370, 1000)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let Symbol = detailText["Symbol"] as! String
        let jsStr = "drawHistory(\"" + Symbol + "\")"
        chart_View.stringByEvaluatingJavaScriptFromString(jsStr)

    }
    
    // MARK add favourite list buttion function
    @IBAction func favAction(sender: UIButton) {
        /*if the stock user get is in core data set the proper icon image and action logical*/
        if isFavCheck {
            let img = UIImage(named:"icon/Star-50.png")! as UIImage
            
            self.favButton.setBackgroundImage(img, forState: UIControlState.Normal)
            
            //let addDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = addDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName: "FavEntity")
            
            /*do delete action*/
            do {
                
                
                let results = try managedContext.executeFetchRequest(fetchRequest)
                
                favItemArray = results as! [NSManagedObject]
                var index:Int = 0;
                for item in favItemArray {
                    if let name = item.valueForKey("company_name") {
                        if detailText["Name"] as! String == item.valueForKey("company_name") as! String {
                            managedContext.deleteObject(item)
                            favItemArray.removeAtIndex(index)
                            do {
                                try managedContext.save()
                            } catch {
                                print("error")
                            }
                        }
                        
                    }
                    index += 1
                }
                
                //check function to see whether del works or not
                for item in favItemArray {
                    if let name = item.valueForKey("company_name") {
                        var nameStr = item.valueForKey("company_name") as! String
                        nameStr += "del"
                        print(nameStr)
                    }
                }
                
            } catch {
                print("Error")
            }
            isFavCheck = false
            
        
        } else {
            /*if not do add logic action*/
            self.favButton.setBackgroundImage(UIImage(named:"icon/fb.png"), forState: UIControlState.Normal)
            
            //let addDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            
            let managedContext = addDelegate.managedObjectContext
            
            let favEntity = NSEntityDescription.entityForName("FavEntity", inManagedObjectContext: managedContext)
            
            let favItem = NSManagedObject(entity: favEntity!, insertIntoManagedObjectContext: managedContext)
            
            
            
            
            favItem.setValue(transferChange(detailText["Change"]as! Float, item1: detailText["ChangePercent"]as! Float), forKey: "change")
            favItem.setValue(detailText["Name"] as! String, forKey: "company_name")
            favItem.setValue(transferVol(detailText["MarketCap"] as! Float), forKey: "marketcap")
            favItem.setValue(transferMoney(detailText["LastPrice"]as! Float), forKey: "price")
            favItem.setValue(detailText["Symbol"] as! String, forKey: "symbol")
            
            if detailText["Change"]as! Float > 0 {
                favItem.setValue(true, forKey: "updown")
            }
            else {
                favItem.setValue(false, forKey: "updown")
            }
            
            /*add action*/
            
            do {
                
                try managedContext.save()
                
            }
            catch {
                print(error)
            }
            
            /*check function to see whether add works or not*/
            
            let fetchRequest = NSFetchRequest(entityName: "FavEntity")
            
            do {
                
                
                let results = try managedContext.executeFetchRequest(fetchRequest)
                
                favItemArray = results as! [NSManagedObject]
                
                for item in favItemArray {
                    if let name = item.valueForKey("company_name") {
                        var nameStr = item.valueForKey("company_name") as! String
                        nameStr += "Add"
                        print(nameStr)
                    }
                    
                }
                
            } catch {
                print("Error")
            }
            //End add action
            isFavCheck = true
        }
    }
    
   
    @IBAction func shareFB(sender: AnyObject) {
        let index:Int = 0;
          let content:FBSDKShareLinkContent = FBSDKShareLinkContent()
        //content.contentURL
          let subNew = newText["d"]!
          let subNewresult = subNew["results"]!
          let subArray = subNewresult![index]
          let link = subArray["Url"] as! String
        let cURL = NSURL(string: link)
    //let titleStr = subArray["Title"] as! String
//        let desStr = subArray["Description"] as! String
//        let srcStr = subArray["Source"] as! String
//        let dateStr = subArray["Date"] as! String
        let name:String = detailText["Name"] as! String
        let symbol:String = detailText["Symbol"] as! String
        let des = "Stock Information of " + name + "(" + symbol + ")"
        let imgUrl = "http://chart.finance.yahoo.com/t?s=" + symbol + "&lang=en-US&width=400&height=300"
        let URL = NSURL(string: imgUrl)
        let price:String = transferMoney(detailText["LastPrice"]as! Float)
        content.contentTitle = "Current Stock Price of " + name + " is " + price
        content.contentURL = cURL
        content.imageURL = URL

        content.contentDescription = des
        
        FBSDKShareDialog.showFromViewController(self, withContent: content, delegate: self)
        
    }
    
    func sharerDidCancel(sharer: FBSDKSharing!) {
        print("Share did cancel")
        let alert = UIAlertController(
        title:"Sharing to FaceBook Cancel",
        message:nil,
        preferredStyle: UIAlertControllerStyle.Alert)
        
        
        alert.addAction(UIAlertAction(
        title:"OK",
        style: UIAlertActionStyle.Cancel,
        handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)

    }
    
    func sharer(sharer: FBSDKSharing!, didCompleteWithResults results: [NSObject : AnyObject]!) {
        print(results)
        if results.isEmpty{
            let alert = UIAlertController(
            title:"You have not shared to FaceBook ",
            message:nil,
            preferredStyle: UIAlertControllerStyle.Alert)
            
            
            alert.addAction(UIAlertAction(
            title:"OK",
            style: UIAlertActionStyle.Cancel,
            handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else
        {
            let alert = UIAlertController(
            title:"Successfully share to FaceBook!",
            message:nil,
            preferredStyle: UIAlertControllerStyle.Alert)
            
            
            alert.addAction(UIAlertAction(
            title:"OK",
            style: UIAlertActionStyle.Cancel,
            handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
        }

    }
    
    func sharer(sharer: FBSDKSharing!, didFailWithError error: NSError!) {
        print(error.description)
    }
    
    @IBAction func toggle(sender: UISegmentedControl) {
        print(Detail_Segment.selectedSegmentIndex)
        
        if Detail_Segment.selectedSegmentIndex == 0 {
            scrollView.setContentOffset(CGPoint(x: 0,y: 0), animated: true)
        }
        
        if Detail_Segment.selectedSegmentIndex == 1 {
            scrollView.setContentOffset(CGPoint(x: 375,y: 0), animated: true)
        }
        
        if Detail_Segment.selectedSegmentIndex == 2 {
            scrollView.setContentOffset(CGPoint(x: 750,y: 0), animated: true)
        }
    }
}

