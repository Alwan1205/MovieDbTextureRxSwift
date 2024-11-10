//
//  ImageTitleCellNode.swift
//  MovieDBPractice
//
//  Created by Alwan on 06/11/24.
//

import AsyncDisplayKit

class ImageTitleCellNode: ASCellNode {
    
    var delegate: MovieListVCDelegate?
    private let movie: Movie
    private let imageNode = ASNetworkImageNode()
    private let titleNode = ASTextNode()
    
    init(movie: Movie) {
        self.movie = movie
        super.init()
        
        if !movie.posterPath.isEmpty {
            imageNode.url = URL(string: "\(Environment.shared.posterBaseUrl)\(movie.posterPath)")
            imageNode.style.preferredSize = CGSize(width: UIScreen.main.bounds.width / 2, height: 150)
            imageNode.contentMode = .scaleAspectFill
            
            titleNode.attributedText = NSAttributedString(
                string: movie.title,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16, weight: .bold),
                    .foregroundColor: UIColor.white
                ]
            )
            
            addSubnode(imageNode)
            addSubnode(titleNode)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
            DispatchQueue.main.async {
                self.view.addGestureRecognizer(tapGesture)
            }
        }
        else {
            print("movie \(movie.title) posterPath isEmpty")
        }
    }
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        
        let verticalStack = ASStackLayoutSpec.vertical()
        verticalStack.spacing = 0
        verticalStack.children = [imageNode, titleNode]
        
        return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 10, left: 15, bottom: 20, right: 15), child: verticalStack)
    }
    
    @objc private func cellTapped() {
        print("cellTapped")
        delegate?.pushToMovieDetail(movieParam: movie)
    }
    
}
