//
//  BitAPI.swift
//  BitBunker
//
//  Created by Chris on 2/9/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import Foundation

let serverHostname = "http://192.168.0.163"

/*
 Model contacting server
 */
class BitAPI {

    static func requestFile(filename: String, password: String) {
        if let url = URL(string: serverHostname + "/api/get/" + filename) {
            let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
                if let response = response, let data = data {
                    print(response)
                    print(NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "")
                } else if let error = error {
                    print(error)
                }
            }

            task.resume()
        }
    }

}
