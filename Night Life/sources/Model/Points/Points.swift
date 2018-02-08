//
//  Points.swift
//  Night Life
//
//  Created by admin on 03.03.16.
//  Copyright © 2016 com.NightLife. All rights reserved.
//

import Foundation
import ObjectMapper


struct Points : Mappable {

  var points : Int = 0
  
  init?(map: Map) {
    mapping(map: map)
  }
  
  mutating func mapping(map: Map) {

    points <- map["points"]
  }
  
}

