//
//  AppDelegate.swift
//  MovieDBPractice
//
//  Created by Alwan on 06/11/24.
//

import UIKit

let TheAppController = UIApplication.shared.delegate as! AppDelegate

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainNavigationController: UINavigationController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let vc = MovieListViewController()
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.isNavigationBarHidden = true
        navigationController.modalPresentationStyle = .fullScreen
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        return true
    }
}
