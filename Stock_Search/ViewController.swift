//
//  ViewController.swift
//  Stock_Search
//
//  Created by 高宇 on 4/20/16.
//  Copyright © 2016 Alfred_Gao. All rights reserved.
//

import UIKit
import CCAutocomplete

class ViewController: UIViewController{

    @IBOutlet weak var Stock_search_field: UITextField!
    @IBOutlet weak var Stock_search_label: UILabel!
    
    
    
    
    let countryList = countries
    var isFirstLoad:Bool = true
    var alert:UIAlertController!
    var flag:Int! = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
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
    
    @IBAction func get_Quote(sender: UIButton) {
        if Stock_search_field.text == "" {
            let alert = UIAlertController(title:"Please Enter a Stock Name or Symbol", message:nil, preferredStyle: UIAlertControllerStyle.Alert);
            showViewController(alert, sender: self)
            alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Cancel, handler :nil))
            
            
        }
        
        if flag == 1 {
            let alert = UIAlertController(title:"Invalid Symbol", message:nil, preferredStyle: UIAlertControllerStyle.Alert)
            showViewController(alert, sender:self)
            alert.addAction(UIAlertAction(title:"OK", style: UIAlertActionStyle.Cancel, handler: nil))
        }
    }
    
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
        let url :String =  "http://socketsearch-1272.appspot.com/index.php?input=" + term
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
        if showArray.isEmpty{
            self.Stock_search_label.text = "Empty"
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
        self.Stock_search_label.text = item.text
    }

}

