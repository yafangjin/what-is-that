//
//  GoogleStructs.swift
//  whatisthat
//
//  Created by 靳亚芳 on 12/11/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import Foundation
struct Root: Codable {
    
    let responses: [Responses]
    
}

struct Responses: Codable {
    
    let labelAnnotations: [LabelAnnotations]
    
}

struct LabelAnnotations: Codable {
    
    let mid: String
    let description: String
    let score: Double
    
}
