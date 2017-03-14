//
//  BitAPI.swift
//  BitBunker
//
//  Created by Chris on 2/9/17.
//  Copyright © 2017 CacheMoney. All rights reserved.
//

import Foundation
import Alamofire

let serverHostname = "http://localhost:8000"
let actionURL = URL(string: serverHostname + "/action")

let aeskey = "passwordpasswordpasswordpassword"
let iv = "drowssapdrowssap"

/*
 Model contacting server
 */
class BitAPI {

    static func openVault(vaultName: String, secret: String) {
        if let url = actionURL {
            let params = [
                "action": "openvault",
                "vault": vaultName,
                "secret": secret
            ]
            post(url: url, params: params, success: { (response) in
                print(response)
            }, failure: { (error) in
                print(error ?? "")
            })
        }
    }

    static func createVault(vaultName: String, secret: String) {
        if let url = actionURL {
            let params = [
                "action": "createvault",
                "vault": vaultName,
                "secret": secret
            ]
            post(url: url, params: params, success: { (response) in
                print(response)
            }, failure: { (error) in
                print(error ?? "")
            })
        }
    }

    static func replaceFile(filename: String, vaultName: String, content: String) {
        if let url = actionURL {
            let params = [
                "action": "replacefile",
                "filename": filename,
                "vault": vaultName,
                "content": content
            ]
            post(url: url, params: params, success: { (response) in
                print(response)
            }, failure: { (error) in
                print(error ?? "")
            })
        }
    }

    static func getFile(filename: String, vaultName: String) {
        if let url = actionURL {
            let params = [
                "action": "getfile",
                "vault": vaultName,
                "filename": filename
            ]
            post(url: url, params: params, success: { (response) in
                print(response)
            }, failure: { (error) in
                print(error ?? "")
            })
        }
    }

    //MARK: - Helper Methods

    private static func post(url: URL, params: [String: String], success: @escaping (String)->(), failure: @escaping (Error?)->()) {
        // create param string to encrypt
        let privateKey = aeskey

        var paramString = ""
        for (key, value) in params {
            paramString += "\(key)=\(value);"
        }

        do {
            let encrypted = try paramString.aesEncrypt(privateKey, iv: iv)
            let params: Parameters = [
                "bunker": encrypted ?? ""
            ]
            Alamofire.request(url, method: .post, parameters: params)
                .validate(statusCode: 200..<300)
                .responseJSON { response in
                    switch response.result {
                    case .success:
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                    case .failure(let error):
                        failure(error)
                    }
            }
        } catch let error {
            failure(error)
        }
    }
}
