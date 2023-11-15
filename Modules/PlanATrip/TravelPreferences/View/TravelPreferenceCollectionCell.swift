//
//  TravelPreferenceCollectionCell.swift
//  RCRC
//
//  Created by Aashish Singh on 02/05/23.
//

import UIKit
enum TravelPreferenceCellType {
    case maxWalkTime, walkSpeed
}

class TravelPreferenceCollectionCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: DynamicHeightCollectionView!
    var cellType: TravelPreferenceCellType = .maxWalkTime
    
    var reloadWalkTimeByTableView: ((UITableViewCell, Int) -> Void)?
    var selectedWalkMaxTime: Int = 2 {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        registerCell()
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 1, height: 0)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView.collectionViewLayout = layout
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func registerCell() {
        collectionView?.register(UINib(nibName: "PreferenceCollectionCell", bundle: nil), forCellWithReuseIdentifier: "PreferenceCollectionCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        collectionView.frame = CGRect(x: collectionView.frame.origin.x, y: collectionView.frame.origin.y, width: collectionView.frame.width, height: 10000)
        collectionView.layoutIfNeeded()
        let newCellSize = CGSize(width: self.frame.width, height: 120)
        return newCellSize
    }
    
}

extension TravelPreferenceCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MaxWalkTimePreferences.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: PreferenceCollectionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "PreferenceCollectionCell", for: indexPath) as! PreferenceCollectionCell
        cell.configure(value: MaxWalkTimePreferences.allCases[indexPath.item].displayTime)
        cell.buttonCheckBox.isSelected = indexPath.item == selectedWalkMaxTime
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let yourWidth: CGFloat = (self.frame.size.width - 48) / 3
        let yourHeight: CGFloat = 40
        return CGSize(width: yourWidth, height: yourHeight)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.reloadWalkTimeByTableView?(self, indexPath.item)
    }

}

class DynamicHeightCollectionView: UICollectionView {
}

