//
//  YoutubeSearchController.swift
//  YoutubeParcer
//
//  Created by Ihor Golia on 02.06.2022.
//

import Foundation
import Combine

class YoutubeSearchController {
    
    private var subscriptions = Set<AnyCancellable>()
    
    var searchIdsPublisher = CurrentValueSubject<[String], Never>([])
    
    var searchPath: String?
    var networkLayer = NetworkLayer()
    var youtubeParcer = YoutubeParcer()
    var viewController: YoutubeSearchViewController?
    
    func setupWith(viewController: YoutubeSearchViewController) {
        if let textPublisher  = viewController.textPublisher {
            textPublisher.flatMap { text ->  AnyPublisher<String?, Error> in
                guard let text = text else {
                    return Just("")
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
                return self.networkLayer.search(text:text)
            }
            .sink(receiveCompletion: { complition in
                
            }, receiveValue:  { value in
                guard let value = value else {
                    return
                }
                
                let ids = self.youtubeParcer.videoIds(from: value)
                self.searchIdsPublisher.value = Array(Set(ids))
                
            })
            .store(in: &subscriptions)
        }
        
    
        searchIdsPublisher
            .flatMap{ ids -> AnyPublisher<[(String, URL?)], Never> in
                
                return Publishers.MergeMany( ids.map {
                    Publishers.CombineLatest(
                        Just($0),
                        self.youtubeParcer.getVideoInfo(id:$0)
                    )
                })
                .collect()
                    .eraseToAnyPublisher()
                
            }
            .map {
                $0.map {
                    VideoModel(id: $0.0,
                               url: $0.1)
                }
                
            }
            .sink { values in
                viewController.configure(values)
            //TODO: Get HLS
        }
        .store(in: &subscriptions)
        
        
    }
    
}
