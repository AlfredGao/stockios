//
//  PageDetail.swift
//  Stock_Search
//
//  Created by 高宇 on 5/1/16.
//  Copyright © 2016 Alfred_Gao. All rights reserved.
//

import Foundation
import UIKit

class PageDetail : UIViewController, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate{
    
    var newText = [String:AnyObject]()
    var detailText = [String:AnyObject]()
    var showTitleArray = ["Name","Symbol","Last Price", "Change", "Time and Date","Market Cap","Volume","Change YTD","High Price","Low Price","Opening Price"]
    var showDetailArray=[String]()
    
    
    
    @IBOutlet weak var chart_View: UIWebView!
   
    @IBOutlet weak var Detail_View: UITableView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var New_View: UITableView!
    
    @IBOutlet weak var Detail_Segment: UISegmentedControl!
    
    // MARK: TableView Data Source Methods
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.Detail_View {
            return showDetailArray.count
        }
        else {
            return 4
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
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
        } else {
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
            cell.NewsDate.text = dateStr
            return cell
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
        
        scrollView.contentSize = CGSizeMake(400, 1200)

    }
    
    override func viewDidLayoutSubviews() {
        scrollView.scrollEnabled = true
        scrollView.contentSize = CGSizeMake(400, 1200)
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        let Symbol = detailText["Symbol"] as! String
        let jsStr = "drawHistory(\"" + Symbol + "\")"
        print(jsStr)
        chart_View.stringByEvaluatingJavaScriptFromString(jsStr)

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

