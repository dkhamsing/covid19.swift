//
//  Covid19TabController.swift
//  covid19
//
//  Created by Daniel on 3/20/21.
//  Copyright © 2021 dk. All rights reserved.
//

import UIKit

class Covid19TabController: UITabBarController {
    init() {
        super.init(nibName: nil, bundle: nil)

        self.viewControllers = covidViewControllers
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension Covid19TabController {
    var covidViewControllers: [UIViewController] {
        return  [
            dataNavigationController,
            casesNavigationController,
            newsNavigationController,
            twitterNavigationController,
        ]
    }

    var dataNavigationController: UINavigationController {
        let viewController = DataViewController(Website.content)
        viewController.tabBarItem.image = UIImage(systemName: Tab.web.imageSystemName)
        viewController.tabBarItem.title = Tab.web.name

        let navigationController = UINavigationController(viewController)

        return navigationController
    }

    var casesNavigationController: UINavigationController {
        let viewController = CasesViewController()
        viewController.tabBarItem.image = UIImage(systemName: Tab.data.imageSystemName)
        viewController.tabBarItem.title = Tab.data.name

        let navigationController = UINavigationController(viewController)

        return navigationController
    }

    var newsNavigationController: UINavigationController {
        let viewController = NewsViewController(Tab.news.name)
        viewController.tabBarItem.image = UIImage(systemName: Tab.news.imageSystemName)

        let navigationController = UINavigationController(viewController)

        return navigationController
    }

    var twitterNavigationController: UINavigationController {
        let viewController = TwitterViewController(title: Tab.twitter.name, usernames: Twitter.content)
        viewController.tabBarItem.image = UIImage(systemName: Tab.twitter.imageSystemName)

        let navigationController = UINavigationController(viewController)

        return navigationController
    }
}

private extension UINavigationController {
    convenience init(_ rootViewController: UIViewController, _ prefersLargeTitles: Bool = true) {
        self.init(rootViewController: rootViewController)
        self.navigationBar.prefersLargeTitles = prefersLargeTitles
    }
}
