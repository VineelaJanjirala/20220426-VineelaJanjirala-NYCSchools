//
//  ApiManager.swift
//  20220426-VineelaJanjirala-NYCSchools
//
//  Created by Vineela Janjirala on 26/04/22.
//

import Foundation


class ApiManager : NSObject {
    
    static let sharedInstance = ApiManager()
    let baseURL = "https://data.cityofnewyork.us/Education/2017-DOE-High-School-Directory/s3k6-pzi2"
    
    func getHTMLFromWebSite( completion: @escaping (String)-> Void){

        guard let url = URL(string: baseURL) else {
            return
        }
        do {
            let html = try String(contentsOf: url)
            completion(html)
        }
        catch let error as NSError {
            print(error)
        }
    }
   
}
