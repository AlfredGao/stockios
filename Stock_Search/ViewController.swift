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
    
    
    var autoCompleteViewController: AutoCompleteViewController!
    
    let countryList = countries
    
    var isFirstLoad:Bool = true
    
    
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
    //MARK: Text
    
    
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

