//
//  ViewController.swift
//  20220426-VineelaJanjirala-NYCSchools
//
//  Created by Vineela Janjirala on 26/04/22.
//

import UIKit
import SwiftSoup
import SwiftyXMLParser

enum ScriptCounts {
    static let ScriptCount = 16
}

class ViewController: UIViewController {
    
    @IBOutlet weak var schoolName_table: UITableView!
    
    var schoolsArr = Array<Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        schoolName_table.estimatedRowHeight = 300
        schoolName_table.rowHeight = UITableView.automaticDimension
        schoolName_table.separatorColor = .clear
        self.fetchHTMLFromWebsite()
    }
}

extension ViewController {
    //Mark: Fetch the HTML content from the URL
    func fetchHTMLFromWebsite() {
        ApiManager.sharedInstance.getHTMLFromWebSite{ [weak self] (responseString) in
            self?.parseHTML(responseString)
        }
    }
    
    //Mark: parsing of HTML Content
    func parseHTML(_ html: String) {
        
        do {
            
            //Mark: Get the body from HTML content
            let doc : Document = try SwiftSoup.parseBodyFragment(html)
            
            //Mark: Get the Script Tags from HTML content by TagName
            let scriptelement: Elements = try doc.getElementsByTag("script")
            
            var scriptIndex = 0
            for script in scriptelement {
                
                scriptIndex = scriptIndex + 1
                
                //Mark: As all the script tags does not contain id's to fetch perticuler script tag fetching script by checking index static
                //Note: To Do: Adding of script id should be modify from Host Side.
                //Note: Addition of script id change is from website side channge i.e host side change
                
                if(scriptIndex == ScriptCounts.ScriptCount){
                    
                    //Mark: Get all child nodes here
                    let childNodes = script.getChildNodes().first
                    
                    guard let childNodeAttributes = childNodes?.getAttributes() else {
                        return
                    }
                    
                    for attribute in childNodeAttributes {
                        
                        let attributeStringAsJson = attribute.getValue()
                        
                        var dictonary:NSDictionary?
                        //Mark: As Attribute data is in String format
                        //Content in string format is changed to Json format to fetch scool data URL
                        if let data = attributeStringAsJson.data(using: String.Encoding.utf8) {
                            do {
                                dictonary = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary
                                if dictonary != nil
                                {
                                
                                guard let dict:[[String:Any]] = dictonary!["distribution"] as? [[String:Any]] else {
                                    return
                                }
                                //Mark: Filtering the array to fetch School data url  for XML format
                                let filteredArray = dict.filter { $0["encodingFormat"] as! String == "application/xml" }
                                guard let schooldataUrl: String = filteredArray.first?["contentUrl"] as? String else
                                    {
                                    return
                                    }
                                
                                self.getSchoolData(schooldataUrl)
                                
                                }
                            } catch let error as NSError {
                                print(error)
                            }
                        }
                    }
                }
            }
            
        }
        catch let error as NSError {
            print(error)
        }
        
    }
    
    //Mark: After web scrapping , Finally will get the School data URL which is XML type
    //In this this function get the data from the URL and the rasponce is XML
    //Get the keys from XML parsing and form a Array which contains Dictionary elements
    func getSchoolData(_ schoolDataUrl: String) {
        
        let url = URL(string: schoolDataUrl)
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            guard let data = data else {
                print("invalid data!")
                return
            }
            let xmlStr = String(data: data, encoding: .utf8)!
            
            let xml = try! XML.parse(xmlStr)
            
            for element in xml.response.row.row {
                var schoolsInfo = Dictionary<String, String>()
                
                if let schoolName = element.school_name.text {
                    schoolsInfo["school_name"] = schoolName
                }
                if let id = element._id.text {
                    schoolsInfo["id"] = id
                }
                if let address = element._address.text {
                    schoolsInfo["address"] = address
                }
                if let location = element.location.text {
                    schoolsInfo["location"] = location
                }
                if let dbn = element.dbn.text {
                    schoolsInfo["dbn"] = dbn
                }
                if let phoneNumber = element.phone_number.text {
                    schoolsInfo["phone_number"] = phoneNumber
                }
                
                self.schoolsArr.append(schoolsInfo)
            }
            print(self.schoolsArr.prefix(upTo: 3))
            
            DispatchQueue.main.async {
                self.schoolName_table.reloadData()
            }
        }
        .resume()
    }
    
}


// Mark: Table View Delegate and Data Source Methods to set table data
extension ViewController: UITableViewDelegate, UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return schoolsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Reusable cell creation
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SchoolNamesList") as? SchoolNamesList {
            cell.selectionStyle = .none
            guard let resultNew = schoolsArr[indexPath.row] as? [String:Any] else {
                return cell
            }
            
            // Setting up the school name to table cell object
            cell.schoolName_lbl.text = "School Name: " + (resultNew["school_name"]  as? String ?? "")
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


