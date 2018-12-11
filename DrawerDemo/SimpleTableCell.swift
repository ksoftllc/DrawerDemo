
import UIKit

struct SimpleTableCellViewModel {
    let image: UIImage?
    let title: String
    let subtitle: String
}

class SimpleTableCell: UITableViewCell {

    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        _imageView.layer.cornerRadius = _imageView.frame.height/2
        _imageView.layer.borderWidth = 1
        _imageView.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    func configure(model: SimpleTableCellViewModel){
        _titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        imageView?.image = model.image
    }


}
