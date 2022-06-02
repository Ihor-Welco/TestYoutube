//
//  YoutubeParcer.swift
//  YoutubeParcer
//
//  Created by Ihor Golia on 02.06.2022.
//

import Foundation
import XCDYouTubeKit
import Combine

class YoutubeParcer {
    
    func videoIds(from: String) -> [String] {
        let parceRez = from.matches(for: "(watch\\?v=[A-Za-z0-9_-])\\w+")
        
        return parceRez.compactMap {
            $0.split(separator: "=").last
        }.map {
            String($0)
        }
        
    }
    
    func getVideoInfo(id: String) -> Future<URL?, Never> {
        
        let key = "Paste your key"
        
        XCDYouTubeClient.setInnertubeApiKey(key)
        return Future { [weak self] promise in

            XCDYouTubeClient.default().getVideoWithIdentifier(id) { video, error in
                promise(.success(video?.streamURL))
                
            }
        }
    }
    
}

extension String {
    func matches(for regex: String) -> [String] {
        
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self,
                                        range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
