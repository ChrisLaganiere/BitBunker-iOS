//
//  BitAPI.swift
//  BitBunker
//
//  Created by Chris on 2/9/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import Foundation

let serverHostname = "http://localhost:8000"

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

    static func openVault(vaultName: String, secret: String) {
        if let url = URL(string: serverHostname + "/openvault") {
            post(url: url, params: ["secret": secret], success: { (data) in
                if let data = data {
                    print(data)
                }
            })
        }
    }

    //MARK: - Helper Methods

    private static func post(url: URL, params: [String: String], success: (_ data: Data?)->()) {
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        var paramString = ""
        var addComma = false
        for (key, value) in params {
            if addComma {
                paramString += ";"
            } else {
                addComma = true
            }
            paramString += "\(key)=\(value)"
        }

        request.httpBody = paramString.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                print(error)
            } else {
                print(response)
            }
        }

        task.resume()
    }

}
