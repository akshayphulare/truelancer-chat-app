//
//  Constants.swift
//  Truelancer Chat App
//
//  Created by Akshay Phulare on 21/04/25.
//

import Foundation

struct Constants {
    static func socketURL(for channel: String) -> URL {
        return URL(string: "wss://demo.piesocket.com/v3/\(channel)?api_key=demo&notify_self")!
    }
}
