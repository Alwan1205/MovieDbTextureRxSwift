//
//  MovieListViewController.swift
//  MovieDBPractice
//
//  Created by Alwan on 06/11/24.
//

import UIKit
import AsyncDisplayKit
import SwiftyJSON
import RxSwift
import RxCocoa

protocol MovieListVCDelegate {
    func pushToMovieDetail(movieParam: Movie)
}

// step 1: MovieListViewController memiliki class ASDKViewController (inherit dari UIViewController, dari library AsyncDisplayKit), dan memiliki root node ASDisplayNode (counterpart dari UIView). ASDKViewController juga bisa memiliki root node lain sepert ASCollectionNode (counterpart dari UITableView atau UICollectionView)
class MovieListViewController: ASDKViewController<ASDisplayNode> {
    
    private let disposeBag = DisposeBag()
    // step 8: buat moviesRelay yang mengandung array dari movie, simpelnya moviesRelay ini adalah observable yang memiliki value dan juga bisa menjalankan fungsi tertentu saat value-nya berubah
    private let moviesRelay = BehaviorRelay<[Movie]>(value: []) // Rx
//    private var movies: [Movie] = [] // nonRx
    
    private var safeAreaInsets = UIEdgeInsets()
    private var screenBounds = CGRect()
    
    // step 2: inisialisasi node untuk UI
    private let topNode = ASDisplayNode()
    private let bottomNode = ASDisplayNode()
    private let popularMoviesLabel = ASTextNode()
    private var moviesCollectionNode = ASCollectionNode(collectionViewLayout: {
        // layout updated later
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 0 , height: 0)
        return layout
    }())
    
    override init() {
        // step 3: node adalah root node dari MovieListViewController, dan node-node lain bisa ditambahkan ke node secara manual atau secara otomatis dengan node.automaticallyManagesSubnodes = true (nanti ada penjelasan lebih lanjut)
        super.init(node: ASDisplayNode())
        node.automaticallyManagesSubnodes = true
        
        updateScreenSizes()
        setupNodes()
        node.layoutSpecBlock = nodeASLayoutSpec()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        // step 9: sambungkan moviesRelay dengan collectionNode, lakukan sebelum value dari moviesRelay berubah supaya saat value dari moviesRelay berubah bisa melakukan update sesuai kebutuhan (misal update collection node)
        bindMoviesRelayToCollectionNode()
        // step 11: fetch movies dari api
        fetchPopularMovies()
        
        // alwan test start
//        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
//            print("5 seconds later using Timer")
//            self.moviesRelay.accept([])
//        }
        // alwan test end
    }
    
    private func updateScreenSizes() {
        safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
        screenBounds = UIScreen.main.bounds
    }
    
    private func setupNodes() {
        // step 4: di sini setup node-node yang akan ditambahkan ke root node
        topNode.style.height = ASDimensionMake(.points, 60)
        topNode.automaticallyManagesSubnodes = true
        
        bottomNode.style.flexGrow = 1.0
        bottomNode.automaticallyManagesSubnodes = true
        
        popularMoviesLabel.attributedText = NSAttributedString(
            string: "POPULAR MOVIES",
            attributes: [
                .font: UIFont.systemFont(ofSize: 32, weight: .bold),
                .foregroundColor: UIColor.white
            ]
        )
        
        moviesCollectionNode = ASCollectionNode(collectionViewLayout: {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: screenBounds.width / 2 , height: 200)
            return layout
        }())
        moviesCollectionNode.backgroundColor = .clear
        moviesCollectionNode.dataSource = self
        moviesCollectionNode.delegate = self
    }
    
    private func nodeASLayoutSpec() -> ASLayoutSpecBlock {
        return { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            
            // step 5: jika tidak di set topNode.automaticallyManagesSubnodes = true, maka harus set manual seperti topNode.addSubnode(popularMoviesLabel)
            topNode.layoutSpecBlock = { [weak self] _, _ in
                guard let self = self else { return ASLayoutSpec() }
                return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15), child: popularMoviesLabel)
            }
            
            bottomNode.layoutSpecBlock = { [weak self] _, _ in
                guard let self = self else { return ASLayoutSpec() }
                return ASInsetLayoutSpec(insets: .zero, child: moviesCollectionNode)
            }
            
            // step 6: topNode dan bottomNode yang masing-masing memiliki node-node nya sendiri, dimasukkan ke dalam verticalStack
            let verticalStack = ASStackLayoutSpec.vertical()
            verticalStack.children = [topNode, bottomNode]
            
            // step 7: lalu ditambahkan ke ASLayoutSpecBlock milik root node untuk ditambahkan ke root node.
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: safeAreaInsets.top, left: 0, bottom: 0, right: 0), child: verticalStack)
        }
    }
    
    private func bindMoviesRelayToCollectionNode() {
        // step 10: dengan .subscribe(onNext: ... set moviesCollectionNode supaya otomatis akan reloadData() setiap value dari moviesRelay berubah, weak self dan disposeBag untuk menghapus reference yang sudah tidak terpakai supaya tidak memory leak
        moviesRelay
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                self?.moviesCollectionNode.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func fetchPopularMovies() {
        let url: String = "\(Environment.shared.baseUrl)\(EndpointManager().linkFetchPopularMovies)"
        
        let apiKey: String = Environment.shared.apiKey
        let language: String = "en-US"
        let page: Int = 1
        let parameters: [String: Any] = [
            "api_key": apiKey,
            "language": language,
            "page": page
        ]
        
        // newRx
        NetworkManager.shared.connectApi(url: url, parameters: parameters) { jsonObj in
            if let jsonObj = jsonObj {
                var movies: [Movie] = []
                for index in 0..<jsonObj["results"].count {
                    let movie = Movie()
                    movie.populateJSON(jsonObj["results"][index])
                    movies.append(movie)
                    print("fetched movie: \(movie.title)")
                }
                // step 12: update value dari moviesRelay dengan movies, moviesCollectionNode akan otomatis reload dengan value dari moviesRelay setiap ter-update
                self.moviesRelay.accept(movies)
            } else {
                print("jsonObj empty")
            }
        }
        
        // oldRx
//        NetworkManager.shared.rxConnectApi(url: url, parameters: parameters).compactMap { json -> [Movie]? in
//            guard let jsonArray = json?["results"].array else { return nil }
//            return jsonArray.map {
//                let movie = Movie()
//                movie.populateJSON($0)
//                print("fetched movie = \(movie.title)")
//                return movie
//            }
//        }
//        .observe(on: MainScheduler.instance)
//        .subscribe(onNext: { [weak self] movies in
//            self?.moviesRelay.accept(movies)
//            self?.moviesCollectionNode.reloadData()
//        }, onError: { error in
//            print("error fetchPopularMovies: \(error)")
//        })
//        .disposed(by: disposeBag)
        
        // nonRx
//        NetworkManager.shared.connectApi(url: url, parameters: parameters) { jsonObj in
//            if let jsonObj = jsonObj {
//                for index in 0..<jsonObj["results"].count {
//                    let movie = Movie()
//                    movie.populateJSON(jsonObj["results"][index])
//                    self.movies.append(movie)
//                    print("fetched movie: \(movie.title)")
//                }
//                
//                DispatchQueue.main.async {
//                    self.moviesCollectionNode.reloadData()
//                }
//            } else {
//                print("jsonObj empty")
//            }
//        }
        
    }
    
}

extension MovieListViewController: ASCollectionDataSource, ASCollectionDelegate {
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return moviesRelay.value.count
    }

    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        // step 13: untuk update moviesCollectionNode akan diambil dari sini
        let movie = moviesRelay.value[indexPath.row]
        
        return {
            let cellNode = ImageTitleCellNode(movie: movie)
            cellNode.delegate = self
            return cellNode
        }
    }
    
}

extension MovieListViewController: MovieListVCDelegate {
    
    func pushToMovieDetail(movieParam: Movie) {
        let movieDetailVC = MovieDetailViewController(movie: movieParam)
        
        DispatchQueue.main.async {
            self.navigationController?.pushViewController(movieDetailVC, animated: true)
        }
    }
    
}
