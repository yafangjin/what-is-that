//
//  WikipediaAPIManager.swift
//  whatisthat
//
//  Created by 靳亚芳 on 12/7/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import Foundation

protocol WikipediaAPIManagerDelegate {
    func detailsFound(details: DetailsModel)
    func detailsNotFound(reason: WikipediaAPIManager.FailureReason)
}

class WikipediaAPIManager{
    
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No item data received"
        case badJSONResponse = "Bad JSON response"
        case defaultReason = "results not found"
    }
    
    var delegate: WikipediaAPIManagerDelegate?
    
    //this function parses the JSON manually
    func requestDetails(title: String) {
        var wikiURL: URL {
            return URL(string: "https://en.wikipedia.org/w/api.php")!
        }
        var urlComponents = URLComponents(string: WikiURL)!
        urlComponents.queryItems = [URLQueryItem(name: "format", value: "json"),
                                    URLQueryItem(name: "action", value: "query"),
                                    URLQueryItem(name: "prop", value: "extracts"),
                                    URLQueryItem(name: "titles", value: "\(title)"),]
        
        var request = URLRequest(url: urlComponents.url!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.detailsNotFound(reason: .networkRequestFailed)
                return
            }
            
            //ensure data is non-nil
            guard let data = data, let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] ?? [String:Any]() else {
                self.delegate?.detailsNotFound(reason: .noData)
                
                return
            }
            
            
            guard let dictionaryResponse = jsonResponse["query"] as? [String: Any]
                
                else {
                    self.delegate?.detailsNotFound(reason: .badJSONResponse)
                    return
            }
            
            guard let pagesAnnotations = dictionaryResponse["pages"] as? [String:Any], pagesAnnotations.count>0  else {
                self.delegate?.detailsNotFound(reason: .defaultReason)
                
                return
            }
            var detailsDictionary = [String: Any]()
            for (_, value) in pagesAnnotations {
                guard let value = value as? [String:Any] else{
                    self.delegate?.detailsNotFound(reason: .defaultReason)
                    
                    return
                }
                detailsDictionary = value
                break
            }
            
            guard let extractAnnotations = detailsDictionary["extract"] as? String,let pageidAnnotations = detailsDictionary["pageid"] as? NSNumber else {
                self.delegate?.detailsNotFound(reason: .defaultReason)
                return
            }
            let details = DetailsModel(content: extractAnnotations, page: pageidAnnotations)
            self.delegate?.detailsFound(details: details)
            
        }
        
        task.resume()
    }
}

