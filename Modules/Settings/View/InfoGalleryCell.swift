//
//  InfoGalleryCell.swift
//  RCRC
//
//  Created by Aashish Singh on 21/02/23.
//

import UIKit

class InfoGalleryCell: UITableViewCell {

    @IBOutlet weak var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: CustomPageControl!
    
    var cellTapped: ((BusDetailsCell) -> Void)?
    
    private var timer: Timer?
    private var indexCurrentCell = 0
    
    var busImages: [String]? {
        didSet {
            if let busImages = busImages, busImages.count > 0 {
                configurePageControl()
            } else {
                collectionView.isHidden = true
                pageControl.isHidden = true
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInsetAdjustmentBehavior = .never
        self.selectionStyle = .none
        registerCell()
        collectionView.delegate = self
        collectionView.dataSource = self
        configurePageControl()
    }
    
    func registerCell() {
        collectionView?.register(UINib(nibName: "BusDetailsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BusDetailsCollectionCell")
    }
    
    func configurePageControl() {
        
        pageControl.isHidden = false
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 0
        pageControl.numberOfPages = busImages?.count ?? 0
        collectionView.isHidden = false
        collectionHeightConstraint.constant = 240
        collectionView.reloadData()
        
//        if let images = ServiceManager.sharedInstance.images, images.count > 0 {
//            var height: CGFloat = 240
//            for image in images {
//                let ratio = image.size.width / image.size.height
//                let updatedHeight = (collectionView.frame.width - 24) / ratio
//                if updatedHeight > height {
//                    height = updatedHeight
//                }
//            }
//            self.collectionHeightConstraint.constant = height
//            self.collectionView.layoutIfNeeded()
//            self.layoutIfNeeded()
//        }
    }
}

extension InfoGalleryCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BusDetailsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusDetailsCollectionCell", for: indexPath) as! BusDetailsCollectionCell
        cell.busImageView.image = nil
        if let images = ServiceManager.sharedInstance.images, images.count > 0, images.count == busImages?.count ?? 0 {
            cell.busImageView.image = images[indexPath.row]
        } else {
            cell.setBusImage(busImages?[indexPath.row])
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width , height:  collectionView.frame.height - (collectionView.safeAreaInsets.top + collectionView.safeAreaInsets.bottom))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}
