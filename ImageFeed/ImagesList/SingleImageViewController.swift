import Foundation
import UIKit

final class SingleImageViewController: UIViewController {
    var fullImageUrl: String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLargeImage(url: fullImageUrl ?? "")
        scrollView.minimumZoomScale = 0.36
        scrollView.maximumZoomScale = 1.25
        rescaleAndCenterImageInScrollView(image: imageView.image ?? UIImage())
    }
    
    private func rescaleAndCenterImageInScrollView (image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        
        let visibleRectSize = scrollView.bounds.size
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func recenterImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        
        let hScale = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2.0 : 0
        let vScale = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2.0 : 0
        
        scrollView.contentInset = UIEdgeInsets(top: vScale, left: hScale, bottom: vScale, right: hScale)
        scrollView.layoutIfNeeded()
    }
    
    private func loadLargeImage(url: String) {
        let url = URL(string: url)
        UIBlockingProgressHUD.show()
        imageView.kf.setImage(with: url, completionHandler: { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            switch result {
            case .success(let imageResult):
                self.rescaleAndCenterImageInScrollView(image: imageResult.image)
            case .failure:
                self.showError()
            }
        })
    }
    
    private func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так(",
                                      message: "Попробовать ещё раз?",
                                      preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Не надо", style: .default) {_ in
            alert.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in
            guard let self = self else { return }
            self.loadLargeImage(url: self.fullImageUrl ?? "")
        }
        alert.addAction(action1)
        alert.addAction(action2)
        self.present(alert, animated: true)
    }
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func didTapShareButton(_ sender: Any) {
        let share = UIActivityViewController(activityItems: [imageView.image ?? UIImage()], applicationActivities: nil)
        self.present(share, animated: true, completion: nil)
    }
}

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recenterImage()
    }
}
