import XCTest
@testable import ImageFeed

final class ProfileTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        //Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        //When
        _ = viewController.view
        
        //Then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testShowAlert() {
        //Given
        let viewController = ProfileViewControllerSpy()
        let alertPresenter = AlertPresenter(viewController: viewController)
        
        //When
        alertPresenter.makeLogOutAlert()
        
        //Then
        XCTAssertTrue(viewController.showAlertCalled)
    }
    
    func testProfileUpdate() {
        //Given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        let profile = presenter.profile
        
        //When
        guard let profile = profile else { return }
        viewController.updateProfileDetails(name: profile.name,
                                            login: profile.loginName,
                                            bio: profile.bio)
        
        //Then
        XCTAssertEqual(viewController.nameLabel.text, profile.name)
        XCTAssertEqual(viewController.nickNameLabel.text, profile.loginName)
        XCTAssertEqual(viewController.statusLabel.text, profile.bio)
    }
}
