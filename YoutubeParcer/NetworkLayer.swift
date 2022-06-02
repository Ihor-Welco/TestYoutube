//
//  NetworkLayer.swift
//  YoutubeParcer
//
//  Created by Ihor Golia on 02.06.2022.
//

import Foundation
import Alamofire
import Combine

class NetworkLayer {
    var session = Session()
    
    func search(text: String) -> AnyPublisher<String?, Error> {
        guard let url = URL(string:"https://www.youtube.com/results?search_query=\(text)") else {
            return Just<String?>(nil)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        let request = session.request(url,
                                      method: .get,
                                      headers: nil,
                                      interceptor: nil,
                                      requestModifier: nil)
        
        
        return request.publishResponse(using: StringResponseSerializer())
            .map {
                $0.value
            }
            .mapError{ error -> Error in
                return error
            }
            .eraseToAnyPublisher()
        
    }
}
