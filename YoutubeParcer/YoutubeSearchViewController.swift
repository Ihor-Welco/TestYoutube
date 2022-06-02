//
//  YoutubeSearchViewController.swift
//  YoutubeParcer
//
//  Created by Ihor Golia on 02.06.2022.
//

import UIKit
import Combine

struct VideoModel: Hashable {
    var id: String
    var url: URL?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}

class YoutubeSearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    private var subscriptions = Set<AnyCancellable>()
    
    @IBOutlet weak var videoCollection: UICollectionView!
    var textPublisher: AnyPublisher<String?, Never>?
    
    enum Section {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, VideoModel>
    var diffableDataSource: DataSource?
    
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Section, VideoModel>
    
    
    var controller = YoutubeSearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let nib = UINib(nibName: "MovieCell", bundle: nil)
        
        videoCollection.register(nib,
                                 forCellWithReuseIdentifier: "MovieCell")
        
        setupSearchBar()
        setupDataSource()
        controller.setupWith(viewController: self)
    }
    
    func configure(_ models: [VideoModel]) {
        
        var snapshot = SnapshotType()
        
        snapshot.appendSections([Section.main])
        snapshot.appendItems(models, toSection: Section.main)
        
        diffableDataSource?.apply(snapshot)
    }
    
    
    func setupDataSource() {
        diffableDataSource = DataSource(collectionView: videoCollection, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
            cell.configure(videoURL: itemIdentifier.url)
            return cell
            
        })
    }
    
    func setupSearchBar() {
        textPublisher = NotificationCenter.default.publisher(for: UISearchTextField.textDidChangeNotification,
                                                             object: searchBar.searchTextField)
        .map {
            ($0.object as! UISearchTextField).text
        }
        .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }


}
