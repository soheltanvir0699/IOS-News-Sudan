//
//  TabBarController.swift
//  IOS News App
//
//  Created by Fabien Maurice on 21/12/2018.
//  Copyright © 2018 Fabien Maurice. All rights reserved.
//

import Foundation
import UIKit
import RAMAnimatedTabBarController
import TransitionableTab

enum TypeTrans: String {
    case move
    case fade
    case scale
    case custom
    
    static var all: [TypeTrans] = [.move, .scale, .fade, .custom]
}
class CustomTabBarController: RAMAnimatedTabBarController {
    
     var type: TypeTrans = .move
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewControllers?.compactMap{ ($0 as? UINavigationController)?.visibleViewController }.forEach {
            $0.navigationController?.navigationBar.barTintColor = Constant().MAINCOLOR
        }
        
    }
    
}

extension CustomTabBarController: TransitionableTab  {

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return animateTransition(tabBarController, shouldSelect: viewController)
    }
}
