//
//  Constants.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//

import Foundation

let clusterId = "s14520.blr1"
let apiKey = "cI9s3KkjZCFGsyy7JVva60WKyElnnMMW5OwqDxno"

struct Constants {
    static func socketURL(for channel: String) -> URL {
//        return URL(string: "wss://demo.piesocket.com/v3/\(channel)?api_key=demo&notify_self")!
        return URL(string: "wss://\(clusterId).piesocket.com/v3/\(channel)?api_key=\(apiKey)")!
    }
}
