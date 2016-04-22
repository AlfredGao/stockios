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
        return 1
    }
    
    func autoCompleteItemsForSearchTerm(term: String) -> [AutocompletableOption] {
        let filterTest = self.countryList.filter{(country) -> Bool in
            return country.lowercaseString.containsString(term.lowercaseString)
        }
        
        let countriesAndFlags: [AutocompletableOption] = filterTest.map { (var country) -> AutocompleteCellData in
            country.replaceRange(country.startIndex...country.startIndex, with: String(country.characters[country.startIndex]).capitalizedString)
            return AutocompleteCellData(text: country, image: nil)
            }.map( { $0 as AutocompletableOption })
        
        return countriesAndFlags
        
    }
    
    func autoCompleteHeight() -> CGFloat {
        return CGRectGetHeight(self.view.frame)/3.0
    }
    
    func didSelectItem(item: AutocompletableOption) {
        self.Stock_search_label.text = item.text
    }

}

