//
//  FavModel.swift
//  whatisthat
//
//  Created by 靳亚芳 on 12/2/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import Foundation

class FavModel:NSObject {
    let imageName: String
    let title: String
    
    let imageNameKey = "imageName"
    let titleKey = "title"
 
    init(imageName: String, title: String) {
        
        self.imageName = imageName
        self.title = title
    }
    
    required init?(coder aDecoder: NSCoder) {
        imageName = aDecoder.decodeObject(forKey: imageNameKey) as! String
        title = aDecoder.decodeObject(forKey: titleKey) as! String
    }    
}

extension FavModel: NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(imageName, forKey: imageNameKey)
        aCoder.encode(title, forKey: titleKey)
    }
}
