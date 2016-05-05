//
//  ViewController.swift
//  Stock_Search
//
//  Created by 高宇 on 4/20/16.
//  Copyright © 2016 Alfred_Gao. All rights reserved.
//

import UIKit
import CCAutocomplete
import CoreData
import LocalAuthentication

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{

    @IBOutlet weak var Stock_search_field: UITextField!
    @IBOutlet weak var Stock_search_label: UILabel!
    @IBOutlet weak var favView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let addDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var favItemArray = [NSManagedObject]()
    let countryList = countries
    var isFirstLoad:Bool = true
    var alert:UIAlertController!
    var flag:Int! = 0
    var detailArray = [String:AnyObject]()
    var newArray = [String:AnyObject]()
    var searchFieldCheck: Bool! = false
    var symbolName = String()
    
    @IBOutlet weak var switchButton: UISwitch!
    
    //Timer
    
    var seconds = 0
    var timer = NSTimer()
    var timeIsOn = false
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        var fingerPrintboj = LAContext()
        var fingerPrintError:NSError?
        
        fingerPrintboj.canEvaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, error: &fingerPrintError)
        
        if fingerPrintError != nil {
            
        } else {
            fingerPrintboj.evaluatePolicy(LAPolicy.DeviceOwnerAuthenticationWithBiometrics, localizedReason: "Press finger to verify", reply: {(complete:Bool!, error:NSError?) -> Void in
                if error != nil{
                    print(error!.localizedDescription)
                }else {
                    if complete == true {
                        print("Verification Successful")
                    }
                    else{
                        print("Finger Print doesn't match")
                    }
                }
            })
        }
        
        
        
        
        
        
        
        
        
        
        
        
        self.Stock_search_field.delegate = self
        
        self.navigationController?.navigationBar.hidden = true
        
        let managedContext = addDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "FavEntity")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            favItemArray = results as! [NSManagedObject]
            
        } catch {
            print(error)
        }
        print(favItemArray.count)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.isFirstLoad {
            self.isFirstLoad = false
            Autocomplete.setupAutocompleteForViewcontroller(self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
        //MARK: Action
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let managedContext = addDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "FavEntity")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest)
            
            favItemArray = results as! [NSManagedObject]
            
        } catch {
            print(error)
        }
        print(favItemArray.count)
        
        let managedContext1 = addDelegate.managedObjectContext
        
        let fetchRequest1 = NSFetchRequest(entityName: "FavEntity")
        
        do {
            let results = try managedContext1.executeFetchRequest(fetchRequest1)
            
            favItemArray = results as! [NSManagedObject]
            
        } catch {
            print(error)
        }
        print(favItemArray.count)
        
        favView.reloadData()

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return favItemArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let favcell = tableView.dequeueReusableCellWithIdentifier("favCell") as! favCell
        
        var favObjArray = [NSManagedObject]()
        favObjArray = favItemArray as! [NSManagedObject]
        if let name = favObjArray[indexPath.row].valueForKey("company_name") {
            let marketStr:String = favObjArray[indexPath.row].valueForKey("marketcap") as! String
            let marketCap:String = "Market Cap: " + marketStr
            favcell.changeLabel.text = favObjArray[indexPath.row].valueForKey("change") as! String
            favcell.marketcapLabel.text = marketCap
            favcell.nameLabel.text = favObjArray[indexPath.row].valueForKey("company_name") as! String
            favcell.priceLabel.text = favObjArray[indexPath.row].valueForKey("price") as! String
            favcell.symbolLabel.text = favObjArray[indexPath.row].valueForKey("symbol") as! String
            
            if favObjArray[indexPath.row].valueForKey("updown") as! Bool == true {
                favcell.changeLabel.backgroundColor = UIColor.greenColor()
            } else {
                favcell.changeLabel.backgroundColor = UIColor.redColor()
            }
            
        }
        
        return favcell
    }
    
     func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath)
     {
        if editingStyle == .Delete {
            var name = String()
            let obj:NSManagedObject = favItemArray[indexPath.row] as! NSManagedObject
            name = obj.valueForKey("company_name") as! String
            favItemArray.removeAtIndex(indexPath.row)
            favView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            
            let managedContext = addDelegate.managedObjectContext
            
            let fetchRequest = NSFetchRequest(entityName: "FavEntity")
            
            do {
                
                
                let results = try managedContext.executeFetchRequest(fetchRequest)
                
                let favItemDelArray = results as! [NSManagedObject]
                var index:Int = 0;
                for item in favItemDelArray {
                    if let nameCheck = item.valueForKey("company_name") {
                        if  name == item.valueForKey("company_name") as! String {
                            managedContext.deleteObject(item)
                            do {
                                try managedContext.save()
                            } catch {
                                print("error")
                            }
                        }
                        
                    }
                    index += 1
                }
                
            } catch {
                print("Error")
            }
            //end of Del in Core data
            favView.reloadData()
        }
    }
    
    
    @IBAction func get_Quote(sender: UIButton) {
        
        if Stock_search_field.text == "" || Stock_search_field.text == nil {
            let alert = UIAlertController(
                title:"Please Enter a Stock Name or Symbol.",
                message:nil,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            
             alert.addAction(UIAlertAction(
                title:"OK",
                style: UIAlertActionStyle.Cancel,
                handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
        else if flag == 1 {
             let alert = UIAlertController(
                title:"Invalid Symbol",
                message:nil,
                preferredStyle: UIAlertControllerStyle.Alert)
            
             alert.addAction(UIAlertAction(
                title:"OK",
                style: UIAlertActionStyle.Cancel,
                handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            

        }
        
        else {
            
            let url:String = "http://socketsearch-1272.appspot.com/?api=lookup&symbol=" + symbolName
            let newUrl:String = "http://socketsearch-1272.appspot.com/index.php?symbol_name=" + symbolName
            detailArray = httpRequest(url)
            newArray = httpRequest(newUrl)
            print(detailArray)
            searchFieldCheck = true
            if detailArray["Status"] as! String != "SUCCESS" {
                let alert = UIAlertController(
                    title:"Get Quote Failure, Pls try again!!!",
                    message:nil,
                    preferredStyle: UIAlertControllerStyle.Alert)
                
                alert.addAction(UIAlertAction(
                    title:"OK",
                    style: UIAlertActionStyle.Cancel,
                    handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
       
        if segue.identifier == "cellSeg" {
            let detailController: PageDetail = segue.destinationViewController as! PageDetail
            let index = self.favView.indexPathForSelectedRow
            let currentCell = favView.cellForRowAtIndexPath(index!) as! favCell
            let symbol:String! = currentCell.symbolLabel.text
            let url:String = "http://socketsearch-1272.appspot.com/?api=lookup&symbol=" + symbol
            let newUrl:String = "http://socketsearch-1272.appspot.com/index.php?symbol_name=" + symbol
            detailArray = httpRequest(url)
            newArray = httpRequest(newUrl)
            print(detailArray)
            detailController.detailText = detailArray
            detailController.newText = newArray
        } else {
            let detailController: PageDetail = segue.destinationViewController as! PageDetail
            detailController.detailText = detailArray
            detailController.newText = newArray
            
        }
    }
    
    /*override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if searchFieldCheck == false {
            /*let alert = UIAlertController(title:"Please Enter a Stock Name or Symbol.", message:nil, preferredStyle: UIAlertControllerStyle.Alert)
            showViewController(alert, sender:self)
            alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Cancel, handler: nil))*/
            return false
        }
        
        
        /*if flag == 1 {
            let alert = UIAlertController(title:"Invalid Symbol", message:nil, preferredStyle: UIAlertControllerStyle.Alert)
            showViewController(alert, sender:self)
            alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Cancel, handler: nil))
            return false
        }*/
        
        return true
    
    }*/
    
    
    
    //MARK: Conform the CCAutocomplete Protocol
}

extension ViewController:AutocompleteDelegate{
    func autoCompleteTextField() -> UITextField {
        return self.Stock_search_field
    }
    
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 2
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        var url = String()
        if term[term.startIndex] == " " || term[term.startIndex.advancedBy(1)] == " " || term[term.startIndex.advancedBy(2)] == " " {
           url = "http://socketsearch-1272.appspot.com/index.php?input=hahaha"
        } else {
           url =  "http://socketsearch-1272.appspot.com/index.php?input=" + term
        }
        let googleUrl = NSURL(string: url)!
        var jsonArray = [[String:String]]()
        let semaphore = dispatch_semaphore_create(0)
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(googleUrl, completionHandler:
            {( data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                do {
                    if let getString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                        jsonArray = try NSJSONSerialization.JSONObjectWithData(
                            data!, options:.AllowFragments)as! [[String:String]]
                        dispatch_semaphore_signal(semaphore)
                        
                    }
                } catch {
                    print(error)
                }
        }).resume()
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        
        var showArray = [String]()
        for item in jsonArray {
            print(item)
            let str: String = item["Symbol"]! + "-" + item["Name"]! + "-" + item["Exchange"]!
            showArray += [str];
        }
        self.flag = 0
        if showArray.isEmpty{
            self.flag = 1;
        }
        
        print(showArray)
        
        let completeArray: [AutocompletableOption] = showArray.map { showText -> AutocompleteCellData in
            
            return AutocompleteCellData(text: showText, image: nil)
            }.map( { $0 as AutocompletableOption })
        
        return completeArray
        
    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame)/3.0
    }
    
    func didSelectItem(item: AutocompletableOption) {
        print(item.text[item.text.startIndex])
        var splashIndex = 1;
        
        while item.text[item.text.startIndex.advancedBy(splashIndex)] != "-"{
            splashIndex += 1
        }
        
        print(splashIndex)
        
        let symbolName = item.text.substringToIndex(item.text.startIndex.advancedBy(splashIndex))
        
        print(symbolName)
        self.symbolName = symbolName
        
    }
    // MARK Switch Action with timer
    @IBAction func swicthAction(sender: AnyObject) {
        if switchButton.on{
            timer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: (#selector(ViewController.showActivityIndicator)), userInfo: nil, repeats: true)
        
        
        }
        else {
            activityIndicator.stopAnimating()
            timer.invalidate()
        }
    }
    
    // MARK refresh Action
    @IBAction func refreshAction(sender: AnyObject) {
        showActivityIndicator()
    }
    
    
    // Indicator show function
    func showActivityIndicator() {
        activityIndicator.startAnimating()
        let delay = 1 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()){
            self.activityIndicator.stopAnimating()
        }

    }
    
    
    func httpRequest(url:String) -> [String:AnyObject] {
        let connectUrl = NSURL(string: url)!
        var jsonArray = [String:AnyObject]()
        let semaphore = dispatch_semaphore_create(0)
        
        let session = NSURLSession.sharedSession()
        session.dataTaskWithURL(connectUrl,completionHandler:
            {( data: NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                do{
                    if let getString = NSString(data:data!, encoding: NSUTF8StringEncoding) {
                        jsonArray = try NSJSONSerialization.JSONObjectWithData(data!, options:.AllowFragments)as! [String:AnyObject]
                        dispatch_semaphore_signal(semaphore)
                    }
                } catch {
                    print(error)
                }
        }).resume()
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
        return jsonArray
        
    }

}

