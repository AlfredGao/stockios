//
//  ViewController.swift
//  Stock_Search
//
//  Created by 高宇 on 4/20/16.
//  Copyright © 2016 Alfred_Gao. All rights reserved.
//

import UIKit
import CCAutocomplete

class ViewController: UIViewController,AutocompleteDelegate{

    @IBOutlet weak var stock_search_label: UILabel!
    @IBOutlet weak var stock_search_field: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK: Text
    
    
    //MARK: Conform the CCAutocomplete Protocol
    func autoCompleteTextField() -> UITextField {
        return stock_search_field
    }
    
    func autoCompleteThreshold(textField: UITextField) -> Int {
        return 1
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        let cell =  AutocompleteCellData(text:  "AAAA", image: nil)
        let cell2 = AutocompleteCellData(text: "BBBB", image: nil)
        let cell3 = AutocompleteCellData(text: "CCCC", image: nil)
        let cell4 = AutocompleteCellData(text: "DDDD", image: nil)
        
        let test = [cell,cell2, cell3, cell4]
        
        return test
    }
    
    func autoCompleteHeight() -> CGFloat {
        return 500
    }
    
    func didSelectItem(item: AutocompletableOption) {
        stock_search_label.text = item.text
    }
    }

