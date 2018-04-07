//
//  Array+Additions.swift
//  Everpobre
//
//  Created by David Lopez Rodriguez on 07/04/2018.
//  Copyright © 2018 David López Rodriguez. All rights reserved.
//

import Foundation

extension Array {
    func group<U: Hashable>(by key: (Element) -> U) -> [[Element]] {
        //keeps track of what the integer index is per group item
        var indexKeys = [U : Int]()
        var grouped = [[Element]]()
        
        for element in self {
            let key = key(element)
            
            if let ind = indexKeys[key] {
                grouped[ind].append(element)
            } else {
                grouped.append([element])
                indexKeys[key] = grouped.count - 1
            }
        }
        
        return grouped
    }
}
