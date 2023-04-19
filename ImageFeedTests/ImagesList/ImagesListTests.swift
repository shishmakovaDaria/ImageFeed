import XCTest
@testable import ImageFeed

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as? ImagesListViewController else { return }
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterConvertDate() {
        //Given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as? ImagesListViewController else { return }
        let presenter = ImagesListPresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        presenter.photos = [
            Photo(id: "",
                  size: CGSize(),
                  createdAt: dateFormatter.date(from: "2016-05-03T11:00:28-04:00"),
                  welcomeDescription: nil,
                  thumbImageURL: "",
                  largeImageURL: "",
                  isLiked: true)
            ]
        
        //When
        let date = presenter.makePhotoDate(row: 0)
        var result: Bool {
            date == "3 мая 2016 г."
        }
       
        //Then
        XCTAssertTrue(result)
    }
}
