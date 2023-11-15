//
//  BusDetailsCell.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 30/01/23.
//

import UIKit

class BusDetailsCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: LocalizedLabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControlHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var busCollectView: UICollectionView!
    @IBOutlet weak var pageControl: CustomPageControl!
    @IBOutlet weak var busViewTopConstraint: NSLayoutConstraint!

    var cellTapped: ((BusDetailsCell) -> Void)?
    var busImages: [String?]? {
        didSet {
            configurePageControl()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        busCollectView.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        busCollectView.inputViewController?.automaticallyAdjustsScrollViewInsets = false
        busCollectView.contentInsetAdjustmentBehavior = .never
        self.selectionStyle = .none
        registerCell()
        busCollectView.delegate = self
        busCollectView.dataSource = self
    }
    
    func registerCell() {
        busCollectView?.register(UINib(nibName: "BusDetailsCollectionCell", bundle: nil), forCellWithReuseIdentifier: "BusDetailsCollectionCell")
    }
    
    func configurePageControl() {
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPage = 0
        pageControl.numberOfPages = busImages?.count ?? 0
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func pageSelected(_ sender: UIPageControl) {
    }
    
    func configure(title: String, selectedIndexPath: IndexPath?, currentIndexPath: IndexPath, description: NSMutableAttributedString?, documents: [String?]?) {
        
        titleLabel.text = title
        /*let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.firstLineHeadIndent = 0.0
        description?.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, description?.length ?? 0))*/
        
        if selectedIndexPath == currentIndexPath {
            if let documentsData = documents, !documentsData.isEmpty {
                busViewTopConstraint.constant = 16
                collectionViewHeightConstraint.constant = 180
                collectionViewBottomConstraint.constant = 8
                pageControlHeightConstraint.constant = 15
                pageControl.isHidden = false
            } else {
                busViewTopConstraint.constant = 0
                collectionViewHeightConstraint.constant = 0
                collectionViewBottomConstraint.constant = 0
                pageControlHeightConstraint.constant = 0
                pageControl.isHidden = true
            }
            answerLabelTopConstraint.constant = 16
            answerLabel.attributedText = description?.trimmedAttributedString()
            accessoryButton.setImage(Images.busCollapse, for: .normal)
        } else {
            pageControl.isHidden = true
            answerLabelTopConstraint.constant = 0
            busViewTopConstraint.constant = 0
            collectionViewHeightConstraint.constant = 0
            collectionViewBottomConstraint.constant = 0
            pageControlHeightConstraint.constant = 0
            answerLabel.attributedText = NSAttributedString(string: "")
            accessoryButton.setImage(Images.busExpand, for: .normal)
        }
        //answerLabel.sizeToFit()
        //answerLabel.lineBreakMode = .byWordWrapping
    }
    
    @IBAction func accessoryButtonTapped(_ sender: UIButton) {
        self.cellTapped?(self)
    }
    
    func setBusImageCache() {
        if let busImages = busImages {
            for (_, contentURL) in busImages.enumerated() {
                //let indexPath = IndexPath(item: index, section: 0)
                let urlString = URLs.busContentURL + (contentURL ?? "")
                if let url = URL(string: urlString ) as NSURL? {
                    if let _ = busImageCache.object(forKey: BusImageCache(url: url)) {
                    } else {
                        ServiceManager.sharedInstance.downloadImage (url: urlString ) { [weak self] result in
                            if case let .success(newsImage) = result {
                                busImageCache.setObject(newsImage, forKey: BusImageCache(url: url))
                            }
                        }
                    }
                }
            }
        }
    }
}

extension BusDetailsCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return busImages?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: BusDetailsCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "BusDetailsCollectionCell", for: indexPath) as! BusDetailsCollectionCell
        //Keep placeHolder and remove nil
        cell.busImageView.image = nil
        cell.setBusImage(busImages?[indexPath.row])
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
