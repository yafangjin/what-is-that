//
//  PersistanceManager.swift
//  whatisthat
//
//  Created by 靳亚芳 on 12/4/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import Foundation

class PersistanceManager {
    static let sharedInstance = PersistanceManager()
    
    let favKey = "favkey"
    
    func fetchFav() -> [FavModel]{
        let userDefaults = UserDefaults.standard
        
        let data = userDefaults.object(forKey: favKey) as? Data
        
        if let data = data {
            //data is not nil, so use it
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [FavModel] ?? [FavModel]()
        }
        else {
            //data is nil
            return [FavModel]()
        }
    }
    
    func isFavoriated(_ title: String) -> Bool {
        let favoriates = fetchFav()
        for item in favoriates {
            if item.title == title{
                return true
            }
        }
        return false
    }
    
    func saveFav(_ favModel: FavModel){
        let userDefaults = UserDefaults.standard
        
        var favoriates = fetchFav()
        favoriates.append(favModel)
        let data = NSKeyedArchiver.archivedData(withRootObject: favoriates)
        
        userDefaults.set(data, forKey: favKey)
    }
    
    func removeFav(_ favModel: FavModel){
        let userDefaults = UserDefaults.standard
        
        var favoriates = fetchFav()
        for index in 0..<favoriates.count {
            if favoriates[index].title == favModel.title{
                favoriates.remove(at: index)
                break
            }
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: favoriates)
        
        userDefaults.set(data, forKey: favKey)
        
    }
    
}
