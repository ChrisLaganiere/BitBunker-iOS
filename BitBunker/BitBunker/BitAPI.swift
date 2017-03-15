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


struct File {
    var filename: String
    var vaultName: String
    var content: String? = nil
    static func filesFromJSON(rawJSON: Any) -> [File]? {
        var files = [File]()
        if let json = rawJSON as? NSArray {
            for o in json {
                if let rawFile = o as? NSDictionary,
                    let filename = rawFile["filename"] as? String {
                    let content = rawFile["content"] as? String
                    let vaultName = rawFile["vaultName"] as? String ?? ""
                    let file = File(filename: filename, vaultName: vaultName, content: content)
                    files.append(file)
                }
            }
        }
        return files.count > 0 ? files : nil
    }
}

/*
 Model contacting server
 */
class BitAPI {

    static func createVault(vaultName: String, secret: String, success: @escaping (NSDictionary)->(), failure: @escaping (Error?)->()) {
        if let url = actionURL {
            let params = [
                "action": "createvault",
                "vault": vaultName,
                "secret": secret
            ]
            post(url: url, params: params, success: success, failure: failure)
        }
    }

    static func openVault(vaultName: String, secret: String, success: @escaping (NSDictionary)->(), failure: @escaping (Error?)->()) {
        if let url = actionURL {
            let params = [
                "action": "openvault",
                "vault": vaultName,
                "secret": secret
            ]
            post(url: url, params: params, success: success, failure: failure)
        }
    }

    static func listVault(vaultName: String, success: @escaping (NSDictionary)->(), failure: @escaping (Error?)->()) {
        if let url = actionURL {
            let params = [
                "action": "listvault",
                "vault": vaultName
            ]
            post(url: url, params: params, success: success, failure: failure)
        }
    }

    static func replaceFile(updated: File, original: File?, success: @escaping (NSDictionary)->(), failure: @escaping (Error?)->()) {
        if let url = actionURL {
            let params = [
                "action": "replacefile",
                "filename": updated.filename,
                "vault": updated.vaultName,
                "content": updated.content ?? ""
            ]
            post(url: url, params: params, success: { (response) in
                success(response)
                if let originalFilename = original?.filename,
                    (updated.filename != originalFilename) {
                    // to do: delete file
                }
            }, failure: failure)
        }
    }

    static func getFile(filename: String, vaultName: String, success: @escaping (NSDictionary)->(), failure: @escaping (Error?)->()) {
        if let url = actionURL {
            let params = [
                "action": "getfile",
                "vault": vaultName,
                "filename": filename
            ]
            post(url: url, params: params, success: success, failure: failure)
        }
    }

    // MARK: - Mock Data

    static func getMockVaultList(callback: ([File])->()) {
        callback([
            File(filename: "File #1", vaultName: "vault #1", content: "aaaa"),
            File(filename: "File #2", vaultName: "vault #1", content: "aaaafffsad"),
            File(filename: "File #3", vaultName: "vault #1", content: "aadadfadfasdfdfdsa"),
            File(filename: "File #4", vaultName: "vault #1", content: "aaaaaafdfdfecace"),
            File(filename: "File #5", vaultName: "vault #1", content: "aaaaxxx"),
            File(filename: "File #6", vaultName: "vault #1", content: "aaaaxffx"),
            File(filename: "File #7", vaultName: "vault #1", content: "aaaaccccacacac"),
            File(filename: "File #8", vaultName: "vault #1", content: "aaaaballs"),
            File(filename: "File #9", vaultName: "vault #1", content: "aaaafdsafds"),
            File(filename: "File #10", vaultName: "vault #1", content: "aaaaadaf"),
            File(filename: "File #11", vaultName: "vault #1", content: "aaaasss"),
            File(filename: "File #12", vaultName: "vault #1", content: "aaaadafer"),
        ])
    }

    // MARK: - Helper Methods

    private static func post(url: URL, params: [String: String], success: @escaping (NSDictionary)->(), failure: @escaping (Error?)->()) {
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
                        if let JSON = response.result.value as? NSDictionary {
//                            print("JSON: \(JSON)")
                            success(JSON)
                        } else {
                            print("Incorrect json type")
                            failure(nil)
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
