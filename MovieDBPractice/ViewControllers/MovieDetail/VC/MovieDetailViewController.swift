//
//  MovieDetailViewController.swift
//  MovieDBPractice
//
//  Created by Alwan on 06/11/24.
//

import UIKit
import AsyncDisplayKit

class MovieDetailViewController: ASDKViewController<ASDisplayNode> {
    
    private let posterImage: ASNetworkImageNode
    private let closeButton: ASButtonNode
    private let titleText: ASTextNode
    private let releaseDateText: ASTextNode
    private let overviewText: ASTextNode
    
    init(movie: Movie) {
        posterImage = ASNetworkImageNode()
        closeButton = ASButtonNode()
        titleText = ASTextNode()
        releaseDateText = ASTextNode()
        overviewText = ASTextNode()
        
        super.init(node: ASDisplayNode())
        node.automaticallyManagesSubnodes = true
        
        let safeAreaInsets = UIApplication.shared.windows[0].safeAreaInsets
        
        if !movie.posterPath.isEmpty {
            posterImage.url = URL(string: "\(Environment.shared.posterBaseUrl)\(movie.posterPath)")
            posterImage.style.preferredSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
            posterImage.contentMode = .scaleAspectFill
        }
        
        let paddedCloseButton = ASInsetLayoutSpec(insets: UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 5), child: closeButton)
        
        closeButton.setTitle("", with: UIFont.systemFont(ofSize: 0), with: .black, for: .normal)
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.style.preferredSize = CGSize(width: 50, height: 50)
        closeButton.backgroundColor = .gray
        closeButton.cornerRadius = 25
        closeButton.addTarget(self, action: #selector(closeButtonTapped), forControlEvents: .touchUpInside)
        
        let posterOverlay = ASOverlayLayoutSpec(child: self.posterImage, overlay: ASRelativeLayoutSpec(
            horizontalPosition: .end,
            verticalPosition: .start,
            sizingOption: [],
            child: paddedCloseButton
        ))
        
        let titleNode = ASDisplayNode()
        titleNode.automaticallyManagesSubnodes = true
        
        let contentNode = ASDisplayNode()
        contentNode.automaticallyManagesSubnodes = true
        contentNode.style.flexGrow = 1.0
        
        titleText.attributedText = NSAttributedString(
            string: movie.title,
            attributes: [
                .font: UIFont.systemFont(ofSize: 32,
                                         weight: .bold),
                .foregroundColor: UIColor.white
            ])
        
        releaseDateText.attributedText = NSAttributedString(
            string: movie.releaseDate,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16,
                                         weight: .regular),
                .foregroundColor: UIColor.white
            ])
        
        overviewText.attributedText = NSAttributedString(
            string: movie.overview,
            attributes: [
                .font:UIFont.systemFont(ofSize: 14, weight: .regular),
                .foregroundColor: UIColor.white
            ])
        
//        node.addSubnode(posterImage)
//        node.addSubnode(titleText)
//        node.addSubnode(releaseDateText)
//        node.addSubnode(overviewText)
        
        titleNode.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            
            let verticalStack = ASStackLayoutSpec.vertical()
            verticalStack.children = [titleText, releaseDateText]
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 30, left: 15, bottom: 15, right: 15), child: verticalStack)
        }
        
        contentNode.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15), child: overviewText)
        }
        
        node.layoutSpecBlock = { [weak self] _, _ in
            guard let self = self else { return ASLayoutSpec() }
            
            let verticalStack = ASStackLayoutSpec.vertical()
            verticalStack.children = [posterOverlay, titleNode, contentNode]
            
            return ASInsetLayoutSpec(insets: UIEdgeInsets(top: safeAreaInsets.top, left: 0, bottom: safeAreaInsets.bottom + 15, right: 0), child: verticalStack)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
    }
    
    @objc func closeButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }

}
