//
//  ViewController.swift
//  ImageFeed
//
//  Created by Дарья Шишмакова on 22.12.2022.
//

import UIKit

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let image = UIImage(named: photoName[indexPath.row]) else { return 0 }
        
        let imageViewWeidth = tableView.bounds.width - 32
        let imageWidth = image.size.width
        let scale = imageViewWeidth / imageWidth
        let imageViewHeight = image.size.height * scale
        
        return imageViewHeight + 8
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photoName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imagesListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imagesListCell, with: indexPath)
        return imagesListCell
        
    }
}

class ImagesListViewController: UIViewController {

    @IBOutlet private var tableView: UITableView!
    
    private var photoName: [String] = Array(0..<20).map{"\($0)"}
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    

    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let image = UIImage(named: photoName[indexPath.row]) else { return }
        
        cell.cellImage.image = image
        cell.dateLabel.text = dateFormatter.string(from: Date())
        
        if indexPath.row % 2 == 0 {
            cell.likeButton.imageView?.image = UIImage(named: "Like Inactive")
        } else {
            cell.likeButton.imageView?.image = UIImage(named: "Like Active")
        }
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.ypBlack.withAlphaComponent(0.0).cgColor, UIColor.ypBlack.withAlphaComponent(0.2).cgColor]
        gradient.locations = [0,1]
        gradient.frame = cell.gradientView.bounds
        
        cell.gradientView.layer.insertSublayer(gradient, at: 0)
    }
}

