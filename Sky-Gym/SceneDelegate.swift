//
//  SceneDelegate.swift
//  Sky-Gym
//
//  Created by KP iOSDev on 23/09/20.
//  Copyright © 2020 KP iOSDev. All rights reserved.
//

import UIKit
import SWRevealViewController
import FirebaseCore
import FirebaseFirestore
import IQKeyboardManagerSwift

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let swRevealVC = SWRevealViewController()
    //let swRevealVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "swRevealVC") as! SWRevealViewController
    let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! ViewController

    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
//        let dashboardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "dashbaordVC") as! AdminDashboardViewController
//        let menuItemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "menuItemVC") as! MenuItemsViewController
//         self.swRevealVC.frontViewController = dashboardVC
//         self.swRevealVC.rearViewController = menuItemVC
//         window?.rootViewController = swRevealVC
//         window?.makeKeyAndVisible()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window = self.window
        //FirebaseApp.configure()
       // setRoot()
        IQKeyboardManager.shared.enable = true
    }
    

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

