//
//  GoogleVisionAPIManager.swift
//  whatisthat
//
//  Created by 靳亚芳 on 11/27/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import Foundation
import UIKit

protocol GoogleVisionAPIManagerDelegate {
    func descriptionFound(descriptions:[DescriptionModel])
    func descriptionNotFound(reason: GoogleVisionAPIManager.FailureReason)
}

class GoogleVisionAPIManager {
    
    enum FailureReason: String {
        case networkRequestFailed = "Your request failed, please try again."
        case noData = "No data received"
        case badJSONResponse = "Bad JSON response"
    }
    
    var delegate: GoogleVisionAPIManagerDelegate?
    
    func base64EncodeImage(_ image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata!.count > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSize(width: 800, height: oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedString(options: .endLineWithCarriageReturn)
    }
    
    func resizeImage(_ imageSize: CGSize, image: UIImage) -> Data {
        UIGraphicsBeginImageContext(imageSize)
        image.draw(in: CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage!)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func requestDescriptions(image: UIImage){
        // create our request URL
        var googleURL :URL {
            return URL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(GoogleKey)")!
        }

        let binaryImageData = base64EncodeImage(image)
        var request = URLRequest(url: googleURL)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(Bundle.main.bundleIdentifier ?? "", forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonObjectRequest = [
            "requests": [
                "image": [
                    "content": binaryImageData
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 20
                    ]
                ]
            ]
        ]
        // Serialize the JSON
        do{
            let Object = try JSONSerialization.data(withJSONObject: jsonObjectRequest, options: JSONSerialization.WritingOptions.prettyPrinted)
            request.httpBody = Object
        }catch{
            print(error.localizedDescription)
        }
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            //check for valid response with 200 (success)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                self.delegate?.descriptionNotFound(reason: .networkRequestFailed)
                return
            }
            
            //ensure data is non-nil
            guard let data = data, let _ = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] ?? [String:Any]() else {
                self.delegate?.descriptionNotFound(reason: .noData)
                
                return
            }
            
            let decoder = JSONDecoder()
            let decodedRoot = try? decoder.decode(Root.self, from: data)
            
            //ensure json structure matches our expections and contains a labelAnnotations array
            guard let root = decodedRoot else {
                self.delegate?.descriptionNotFound(reason: .badJSONResponse)
                
                return
            }
            
            let labelAnnotations = root.responses[0].labelAnnotations
            var descripts = [DescriptionModel]()
            for labelAnnotations in labelAnnotations {
                let desc = DescriptionModel(name: labelAnnotations.description, percent: labelAnnotations.score)
                descripts.append(desc)
            }
            
            self.delegate?.descriptionFound(descriptions: descripts)
            
        }
        task.resume()
    }
}
