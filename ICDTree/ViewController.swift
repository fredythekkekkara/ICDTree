//
//  ViewController.swift
//  ICDTree
//
//  Created by IRIS Medical Solutions on 27/08/18.
//  Copyright © 2018 IRIS Medical Solutions. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    
    @IBOutlet weak var icdSearchBox: UISearchBar!
    @IBOutlet weak var ICD_Tree_Table: UITableView!
    let initial_ICD_Ranges = ["A00-B99", "C00-D49", "D50-D89", "E00-E89", "F01-F99", "G00-G99", "H00-H59", "H60-H95", "I00-I99", "J00-J99", "K00-K95", "L00-L99", "M00-M99", "N00-N99", "O00-O9A", "P00-P96", "Q00-Q99", "R00-R99", "S00-T88", "V00-Y99", "Z00-Z99"]
    var ROW_COUNT = 0
    var ICD_DATA = [[String:String]]()
    let CODE = "CODE"
    let DESC = "DESC"
    let INDENT = "INDENT"
    let POS = "POS"
    var ROW_COUNT_DICT = [String:Int]()
    
    
    let BOOK_CLOSED = "Book_Layer_1.png"
    let BOOK_OPEN = "OpenedBookl.png"
    let CHECK_MARK = "CheckMark.png"
    let BLANK = "icons8-circled-thin-50.png"
    
    var ICD_10_JSON = [String:Any]()
    var DESC_JSON = [String:Any]()
    var FINAL_CODE_ARRAY = [String]()
    
    var isExpanded = [String:Bool]()
    var collapseCount = [String:Int]()
    
    var selectedCodes = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        ICD_Tree_Table.estimatedRowHeight = 50
//        ICD_Tree_Table.autoresizesSubviews = true
        ICD_Tree_Table.rowHeight = UITableViewAutomaticDimension
        //    finalCodeArray
        ICD_10_JSON = parseJSON(fileName: "ICD_10_DICT")
        DESC_JSON = parseJSON(fileName: "ICD_10_DESC")
        var tempFinalCOdeArary = parseJSON(fileName: "FINAL_ICD_CODES")
        if tempFinalCOdeArary["FinalICDCodes"] as? [String] != nil{
            FINAL_CODE_ARRAY = tempFinalCOdeArary["FinalICDCodes"] as! [String]
        }
        print(FINAL_CODE_ARRAY)
        ICD_DATA = []
        for elements in initial_ICD_Ranges{
            var temp_desc = ""
            var temp_Data = [String:String]()
            temp_Data[CODE] = elements
            if DESC_JSON[elements] as? String != nil{
                temp_desc = DESC_JSON[elements] as! String
            }
            temp_Data[POS] = "0"
            temp_Data[DESC] = temp_desc
            temp_Data[INDENT] = "10"
            ICD_DATA.append(temp_Data)
        }
        ROW_COUNT = ICD_DATA.count
        DispatchQueue.main.async {
            self.ICD_Tree_Table.reloadData()
        }
    }
    
//icdCell
    //cellIndentation
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ROW_COUNT
    }
//    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "icdCell")
//        treeCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "treeCell")

        var icdView = cell?.viewWithTag(120) as! UIView
        var treeImage = cell?.viewWithTag(121) as! UIImageView
//        var arrowLbl = cell?.viewWithTag(122) as! UILabel
        var icdLabel = cell?.viewWithTag(123) as! UILabel
        icdLabel.numberOfLines = 0
        cell?.selectionStyle = .none
        let cellData = ICD_DATA[indexPath.row]
        let code = cellData[CODE]!
        let desc = cellData[DESC]!
        let indent = Int(cellData[INDENT]!)!
        let pos = cellData[POS]!
        print(indent)
        let initFrame = cell?.contentView.frame
        switch indent {
        case 10:
//            cell?.indentationLevel = 0
            cell?.layoutMargins.left = 5

        case 20:
//            cell?.indentationLevel = 1
            cell?.layoutMargins.left = 15

        case 30:
//            cell?.indentationLevel = 2
            cell?.layoutMargins.left = 30

        case 40:
//            cell?.indentationLevel = 3
            cell?.layoutMargins.left = 45

        case 50:
//            cell?.indentationLevel = 4
            cell?.layoutMargins.left = 60

        case 60:
//            cell?.indentationLevel = 5
            cell?.layoutMargins.left = 75

        case 70:
//            cell?.indentationLevel = 6
            cell?.layoutMargins.left = 90

        case 80:
//            cell?.indentationLevel = 7
            cell?.layoutMargins.left = 105

        default:
//            cell?.indentationLevel = 0
            cell?.layoutMargins.left = 15
        }
        if isExpanded[code] as? Bool == true{
            treeImage.image = UIImage(named: BOOK_OPEN)
        }else{
            treeImage.image = UIImage(named: BOOK_CLOSED)
        }

        icdLabel.text = "\(code) - \(desc)"

        if FINAL_CODE_ARRAY.contains(code){
            treeImage.image = UIImage(named: BLANK)
            cell?.backgroundColor = UIColor(red: 211/255, green: 211/255, blue: 211/255, alpha: 1)
            icdView.backgroundColor = cell?.backgroundColor
        }else{
            cell?.backgroundColor = .white
            icdView.backgroundColor = cell?.backgroundColor
        }
        if selectedCodes.contains(code){
            treeImage.image = UIImage(named: CHECK_MARK)
            cell?.backgroundColor = UIColor(red: 102/255, green: 194/255, blue: 255/255, alpha: 1)
            icdView.backgroundColor = cell?.backgroundColor
        }
       
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedData = ICD_DATA[indexPath.row]
        let selectedIndex = indexPath.row
        let selectedCode = selectedData[CODE]!
        let currentIndentation = Int(selectedData[INDENT]!)!
        print(isExpanded)
        if isExpanded[selectedCode] as? Bool == nil || isExpanded[selectedCode] as? Bool == false{
            if ICD_10_JSON[selectedCode] as? [String] != nil{
                let expandCodes = ICD_10_JSON[selectedCode] as! [String]
                var temp_ICD_Data = [[String:String]]()
                for elements in expandCodes{
                    var pos = "0"
                    if elements == expandCodes.first{
                        pos = "1"
                    }else if elements == expandCodes.last{
                        pos = "3"
                    }else{
                        pos = "2"
                    }
                    var temp_desc = ""
                    var temp_Data = [String:String]()
                    temp_Data[CODE] = elements
                    if DESC_JSON[elements] as? String != nil{
                        temp_desc = DESC_JSON[elements] as! String
                    }
                    let indent = currentIndentation + 10
                    temp_Data[INDENT] = String(indent)
                    temp_Data[DESC] = temp_desc
                    temp_Data[POS] = pos
                    temp_ICD_Data.append(temp_Data)
                }
                ICD_DATA.insert(contentsOf: temp_ICD_Data, at: indexPath.row + 1)
                ROW_COUNT = ICD_DATA.count
                isExpanded[selectedCode] = true
                collapseCount[selectedCode] = expandCodes.count
            }else{
            //Final Code
                if FINAL_CODE_ARRAY.contains(selectedCode){
                    if !selectedCodes.contains(selectedCode){
                        selectedCodes.append(selectedCode)
                    }else{
                        selectedCodes.remove(at: selectedCodes.index(of: selectedCode)!)
                    }
                }
            }
        }else{
            //collapse
            var collapseElements = [selectedCode]
            for i in 0...6{
                print("\(i)")
                for elements in collapseElements{
                    print("\(elements)")
                    if ICD_10_JSON[elements] as? [String] != nil{
                        let collapseItems = ICD_10_JSON[elements] as! [String]
                        for items in collapseItems{
                            print("\(items)")
                            if isExpanded[items] as? Bool == true{
                                if !collapseElements.contains(items){
                                    collapseElements.append(items)
                                }
                            }
                        }
                    }
                }
            }
            var deleteCount = 0
            print(collapseElements)
            print(collapseCount)
            for elements in collapseElements{
                isExpanded[elements] = false
                deleteCount = deleteCount + collapseCount[elements]!
            }
            print(deleteCount)
            
            for i in stride(from: deleteCount, to: 0, by: -1) {
                let deleteIndex = selectedIndex + i
                print(deleteIndex)
                ICD_DATA.remove(at: deleteIndex)
            }
        }
        ROW_COUNT = ICD_DATA.count
        print(ICD_DATA)
        DispatchQueue.main.async {
            self.ICD_Tree_Table.reloadData()
        }
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let searchString = searchText
        DispatchQueue.main.async {
            if searchString != ""{
                if searchString.count > 3{
                    let resutlCodes = self.findCodesForSearchString(text: searchString)
                    let searchResultArray = self.prepareSearchArray(searchCodes: resutlCodes)
                    self.ICD_DATA = searchResultArray
                    self.ROW_COUNT = self.ICD_DATA.count
                    self.ICD_Tree_Table.reloadData()
                }
            }else{
                let searchResultArray = self.prepareSearchArray(searchCodes: self.initial_ICD_Ranges)
                self.ICD_DATA = searchResultArray
                self.ROW_COUNT = self.ICD_DATA.count
                self.isExpanded = [:]
                self.collapseCount = [:]
                self.ICD_Tree_Table.reloadData()
            }
        }
    }
    func findCodesForSearchString(text: String) -> [String]{
        var searchCodeResult = [String]()
        let descDict = DESC_JSON as! [String:String]
        for elements in descDict{
            if elements.key.contains(text){
                if !searchCodeResult.contains(elements.key){
                    searchCodeResult.append(elements.key)
                }
            }else if elements.value.contains(text){
                if !searchCodeResult.contains(elements.key){
                    searchCodeResult.append(elements.key)
                }
            }
        }
        return searchCodeResult
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func parseJSON(fileName: String) -> [String:Any]{
        var returnObj = [String:Any]()
        if let path = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                
                if jsonResult as? [String:Any] != nil{
                    returnObj = jsonResult as! [String:Any]
                }
                
            } catch {
                // handle error
            }
        }
        return returnObj
    }
    
    func prepareSearchArray(searchCodes: [String]) -> [[String:String]]{
        var returnArray = [[String:String]]()
        for elements in searchCodes{
            var temp_desc = ""
            var temp_Data = [String:String]()
            temp_Data[CODE] = elements
            if DESC_JSON[elements] as? String != nil{
                temp_desc = DESC_JSON[elements] as! String
            }
            temp_Data[POS] = "0"
            temp_Data[DESC] = temp_desc
            temp_Data[INDENT] = "10"
            returnArray.append(temp_Data)
        }
        return returnArray
    }

}

