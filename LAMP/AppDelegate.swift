import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let navigationController: UINavigationController = {
        let controller = UINavigationController(nibName: nil, bundle: nil)
        controller.setNavigationBarHidden(true, animated: false)
        return controller
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navigationController
        navigationController.pushViewController(LoadingViewController(), animated: false)
        window?.makeKeyAndVisible()

        return true
    }

}

