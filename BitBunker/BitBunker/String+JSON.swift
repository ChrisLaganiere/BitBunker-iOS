//
//  String+JSON.swift
//  BitBunker
//
//  Created by Chris on 3/15/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import Foundation

extension String {

    var jsonValue: Any? {

        let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)

        if let jsonData = data {
            // Will return an object or nil if JSON decoding fails
            do {
                return try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers)
            } catch let error {
                print(error)
                return nil
            }
        } else {
            // Lossless conversion of the string was not possible
            return nil
        }
    }
}
