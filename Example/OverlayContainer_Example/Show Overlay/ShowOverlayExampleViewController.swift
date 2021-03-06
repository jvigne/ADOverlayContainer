//
//  ShowOverlayExampleViewController.swift
//  OverlayContainer_Example
//
//  Created by Gaétan Zanella on 11/04/2019.
//  Copyright © 2019 Gaétan Zanella. All rights reserved.
//

import OverlayContainer
import UIKit


class ShowOverlayExampleViewController: UIViewController,
    ActionViewControllerDelegate,
    OverlayContainerViewControllerDelegate {

    enum Notch: Int, CaseIterable {
        case min, med, max
    }

    private let actionViewController = ActionViewController()
    private let coloredViewController = ColoredViewController()
    private let overlayContainerController = OverlayContainerViewController()

    var showsOverlay = false

    // MARK: - UIViewController

    override func loadView() {
        view = UIView()
        addChild(overlayContainerController, in: view)
        actionViewController.delegate = self
        overlayContainerController.delegate = self
        overlayContainerController.viewControllers = [
            actionViewController,
            coloredViewController
        ]
    }

    // MARK: - ActionViewControllerDelegate

    func actionViewControllerDidSelectionAction() {
        showsOverlay.toggle()
        let targetNotch: Notch = showsOverlay ? .med : .min
        overlayContainerController.moveOverlay(toNotchAt: targetNotch.rawValue, animated: true)
    }

    // MARK: - OverlayContainerViewControllerDelegate

    func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
        return Notch.allCases.count
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        heightForNotchAt index: Int,
                                        availableSpace: CGFloat) -> CGFloat {
        switch Notch.allCases[index] {
        case .max:
            return availableSpace - 100
        case .med:
            return availableSpace / 2
        case .min:
            return 0
        }
    }

    func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                        canReachNotchAt index: Int,
                                        forOverlay overlayViewController: UIViewController) -> Bool {
        switch Notch.allCases[index] {
        case .max:
            return showsOverlay
        case .med:
            return showsOverlay
        case .min:
            return !showsOverlay
        }
    }
}
