//
//  MarkerView.swift
//  RCRC
//
//  Created by Aashish Singh on 23/05/23.
//

import UIKit

class MarkerView: UIView {

    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var markerImage: UIImageView!
    @IBOutlet weak var markerPopImage: UIImageView!
    
    
    var setTime: String? = "" {
        didSet {
            labelTime.font = Fonts.CodecRegular.eleven
            markerImage.image = Images.livebusStatus?.imageWithNewSize()
//            markerPopImage.image = markerPopImage.image?.setNewImageAsPerLanguage()
           // markerPopImage.image = markerPopImage.image?.withTintColor(.white)

            labelTime.text = setTime
        }
    }
    
    var setTextColor: UIColor = Colors.black {
        didSet {
            labelTime.textColor = setTextColor
        }
    }
        
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        nibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        nibSetup()
    }
    
    private func nibSetup() {
        backgroundColor = .clear
    }
    
}

extension Bundle {

    static func loadView<T>(fromNib name: String, withType type: T.Type) -> T {
        if let view = Bundle.main.loadNibNamed(name, owner: nil, options: nil)?.first as? T {
            return view
        }

        fatalError("Could not load view with type " + String(describing: type))
    }
}
