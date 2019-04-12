<p align="center">
<img src="https://github.com/applidium/ADOverlayContainer/blob/master/Assets/icon.png" width="700">
</p>

<H4 align="center">
  OverlayContainer is a UI library written in Swift. It makes it easier to develop overlay based interfaces, such as the one presented in the Apple Maps, Stocks or Shortcuts apps
</H4>

<p align="center">
  <a href="https://developer.apple.com/"><img alt="Platform" src="https://img.shields.io/badge/platform-iOS-green.svg"/></a>
  <a href="https://developer.apple.com/swift"><img alt="Swift4" src="https://img.shields.io/badge/language-Swift%204.2-orange.svg"/></a>
  <a href="https://cocoapods.org/pods/OverlayContainer"><img alt="CocoaPods" src="https://img.shields.io/cocoapods/v/OverlayContainer.svg?style=flat"/></a>
  <a href="https://github.com/Carthage/Carthage"><img alt="Carthage" src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"/></a>
  <a href="https://travis-ci.org/applidium/ADOverlayContainer"><img alt="Build Status" src="https://api.travis-ci.org/applidium/ADOverlayContainer.svg?branch=master"/></a>
  <a href="https://github.com/applidium/ADOverlayContainer/blob/master/LICENSE"><img alt="License" src="https://img.shields.io/cocoapods/l/OverlayContainer.svg?style=flat"/></a>
</p>

---

## Features

There are alternatives like:

- [Pulley](https://github.com/52inc/Pulley)
- [FloatingPanel](https://github.com/SCENEE/FloatingPanel)

`OverlayContainer` uses a different approach:

- It tries to be as lightweight and non-intrusive as possible. The layout and the UI customization are done by you to avoid to corrupt your project.
- It perfectly mimics the overlay presented in the Siri Shotcuts app. See [this article](https://gaetanzanella.github.io//2018/replicate-apple-maps-overlay/) for details.
- It provides more features:

- [x] Unlimited notches 
- [x] Notches modifiable at runtime
- [x] Adaptive to any custom layouts
- [x] Rubber band effect
- [x] Animations and target notch policy fully customizable
- [x] Unit tested

See the provided examples for help or feel free to ask directly.

---

<p align="center">
<img src="https://github.com/applidium/ADOverlayContainer/blob/master/Assets/scroll.gif" width="222">
</p>

---

- [Requirements](#requirements)
- [Installation](#installation)
  - [CocoaPods](#cocoapods)
  - [Carthage](#carthage)
- [Usage](#usage)
  - [Setup](#mininim-setup)
  - [Overlay style](#overlay-style)
  - [Scroll view support](#scroll-view-support)
  - [Pan gesture support](#pan-gesture-support)
  - [Tracking the overlay](#tracking-the-overlay)
  - [Examples](#examples)
- [Advanced Usage](#advanced-usage)
  - [Multiple overlays](#multiple-overlays)
  - [Showing & Hiding the overlay](#show-&-hide-the-overlay)
  - [Backdrop view](#backdrop-usage)
  - [Safe Area](#safe-area)
  - [Custom Translation](#custom-translation)
  - [Custom Translation Animations](#custom-translation-animations)
  - [Reloading the notches](#reloading-the-notches)
- [Author](#author)
- [License](#license)


## Requirements

OverlayContainer is written in Swift 4.2. Compatible with iOS 10.0+.

## Installation

OverlayContainer is available through [CocoaPods](https://cocoapods.org). To install it, simply add the following line to your Podfile:

### Cocoapods

```ruby
pod 'OverlayContainer'
```

### Carthage

Add the following to your Cartfile:

```ruby
github "https://github.com/applidium/ADOverlayContainer"
```

## Usage

### Setup

The main component of the library is the `OverlayContainerViewController`. It defines an area where a view controller, called the overlay view controller, can be dragged up and down, hidding or revealing the content underneath it.

`OverlayContainer` uses the last view controller of its `viewControllers` as the overlay view controller. It stacks the other view controllers on top of each other, if any, and adds them underneath the overlay view controller.

A startup sequence might look like this :

```swift
let mapsController = MapsViewController()
let searchController = SearchViewController()

let containerController = OverlayContainerViewController()
containerController.delegate = self
containerController.viewControllers = [
    mapsController,
    searchController
]

window?.rootViewController = containerController
```

Specifing only one view controller is absolutely valid. For instance, in [MapsLikeViewController](https://github.com/applidium/ADOverlayContainer/blob/master/Example/OverlayContainer_Example/Maps/MapsLikeViewController.swift) the overlay only covers partially its content.

The overlay container view controller needs at least one notch. Implement `OverlayContainerViewControllerDelegate` to specify the number of notches wished:

```swift
enum OverlayNotch: Int, CaseIterable {
    case minimum, medium, maximum
}

func numberOfNotches(in containerViewController: OverlayContainerViewController) -> Int {
    return OverlayNotch.allCases.count
}

func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    heightForNotchAt index: Int,
                                    availableSpace: CGFloat) -> CGFloat {
    switch OverlayNotch.allCases[index] {
        case .maximum:
            return availableSpace * 3 / 4
        case .medium:
            return availableSpace / 2
        case .minimum:
            return availableSpace * 1 / 4
    }
}
```

### Overlay style

The overlay style defines how the overlay view controller will be constrained in the `OverlayContainerViewController`.

```swift
enum OverlayStyle {
    case flexibleHeight // default
    case rigid
}

let overlayContainer = OverlayContainerViewController(style: .rigid)
```

* rigid

![rigid](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/rigid.gif)

The overlay view controller will be constrained with a height equal to the highest notch. The overlay won't be fully visible until the user drags it up to this notch.

* flexibleHeight

![flexibleHeight](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/flexibleHeight.gif)

The overlay view controller will not be height-constrained. It will grow and shrink as the user drags it up and down.

Note though that while the user is dragging the overlay, the overlay's view may perform some extra layout computations. This is specially true for the table views or the collection views : some cells may be dequeued or removed when its frame changes. Try `.rigid` if you encounter performance issues.

**Be careful to always provide a minimum height higher than the intrinsic content of your overlay.**

### Scroll view support

The container view controller can coordinate the scrolling of a scroll view with the overlay translation.

![scrollToTranslation](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/scrollToTranslation.gif)

Use the associated delegate method :

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    scrollViewDrivingOverlay overlayViewController: UIViewController) -> UIScrollView? {
    return (overlayViewController as? DetailViewController)?.tableView
}
```

Or directly set the dedicated property :

```swift
let containerController = OverlayContainerViewController()
containerController.drivingScrollView = myScrollView
```

### Pan gesture support

The container view controller detects pan gestures on its own view. 
Use the dedicated delegate method to check that the specified starting pan gesture location corresponds to a grabbable view in your custom overlay.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    shouldStartDraggingOverlay overlayViewController: UIViewController,
                                    at point: CGPoint,
                                    in coordinateSpace: UICoordinateSpace) -> Bool {
    guard let header = (overlayViewController as? DetailViewController)?.header else {
        return false
    }
    let convertedPoint = coordinateSpace.convert(point, to: header)
    return header.bounds.contains(convertedPoint)
}
```

### Tracking the overlay

You can track the overlay motions using the dedicated delegate methods.

`didDragOverlay` is called each time the overlay is dragged by the user to the specified height.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    didDragOverlay overlayViewController: UIViewController,
                                    toHeight height: CGFloat,
                                    availableSpace: CGFloat)
```

`didEndDraggingOverlay` is called when the user has finished dragging the overlay. The container is about to move the overlay to the specified notch.

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    didEndDraggingOverlay overlayViewController: UIViewController,
                                    transitionCoordinator: OverlayContainerTransitionCoordinator)
```

The `transition coordinator` provides information about the animation that is about to start:

```swift
/// The notch's index the container expects to reach.
var targetNotchIndex: Int { get }

/// The notch's height the container expects to reach.
var targetNotchHeight: CGFloat { get }

/// The current translation height.
var overlayTranslationHeight: CGFloat { get }

/// The notch indexes.
var notchIndexes: Range<Int> { get }

/// The reachables indexes.
var reachableIndexes: [Int] { get }

/// Returns the height of the specified notch.
func height(forNotchAt index: Int) -> CGFloat
```

### Examples

To test the examples, open `OverlayContainer.xcworkspace` and run the `OverlayContainer_Example` target.

Choose the layout you wish to display in the `AppDelegate` :

* MapsLikeViewController: A custom layout which adapts its hierachy on rotations.

![Maps](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/maps.gif)

* ShortcutsLikeViewController: A custom layout which adapts its hierachy on trait collection changes : Moving from a `UISplitViewController` on regular environment to a simple `StackViewController` on compact environment. Visualize it on an iPad Pro.

![Shortcuts](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/shortcuts.gif)

## Advanced usage

### Multiple overlays

`OverlayContainer` does not provide a built-in view controller navigation management. It focuses its effort on the overlay translation.

However in the project, there is an example of a basic solution to overlay multiple overlays on top of each other, like in the `Apple Maps` app. It is based on an `UINavigationController` and a custom implementation of its delegate:

```swift
// MARK: - UINavigationControllerDelegate

func navigationController(_ navigationController: UINavigationController,
                          animationControllerFor operation: UINavigationController.Operation,
                          from fromVC: UIViewController,
                          to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    return OverlayNavigationAnimationController(operation: operation)
}

func navigationController(_ navigationController: UINavigationController,
                          didShow viewController: UIViewController,
                          animated: Bool) {
    overlayController.drivingScrollView = (viewController as? SearchViewController)?.tableView
}
```

`OverlayNavigationAnimationController` tweaks the native behavior of the `UINavigationController`: it slides the pushed view controllers up from the bottom of the screen. Feel free to add shadows and modify the animation curve depending on your needs. The only restriction is that you can not push an `UINavigationController` inside another `UINavigationController`.

### Showing & Hiding the overlay

`OverlayContainer` provides a easy way to enable & disable notches on the fly. A frequent use case is to show & hide the overlay. `ShowOverlayExampleViewController` provides a basic implementation of it:

```swift
var showsOverlay = false

func showOrHideOverlay() {
    showsOverlay.toggle()
    let targetNotch: Notch = showsOverlay ? .med : .hidden
    overlayContainerController.moveOverlay(toNotchAt: targetNotch.rawValue, animated: true)
}

// MARK: - OverlayContainerViewControllerDelegate

func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    heightForNotchAt index: Int,
                                    availableSpace: CGFloat) -> CGFloat {
    switch Notch.allCases[index] {
    case .max:
        return ...
    case .med:
        return ...
    case .hidden:
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
    case .hidden:
        return !showsOverlay
    }
}
```

Make sure to use the `rigid` overlay style if the content can not be flattened.

### Backdrop view

Coordinate the overlay movements to the aspect of a view using the dedicated delegate methods. See the [backdrop view example](https://github.com/applidium/ADOverlayContainer/blob/master/Example/OverlayContainer/BackdropExampleViewController.swift).

![backdrop](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/backdropView.gif)

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    didDragOverlay overlayViewController: UIViewController,
                                    toHeight height: CGFloat,
                                    availableSpace: CGFloat) {
    backdropView.alpha = // compute alpha based on height
}

func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    didEndDraggingOverlay overlayViewController: UIViewController,
                                    transitionCoordinator: OverlayContainerTransitionCoordinator) {
    backdropView.alpha = // compute alpha based on the transitionCoordinator
    transitionCoordinator.animate(alongsideTransition: { context in
        self.backdropView.alpha =  // compute the final alpha value on the transitionCoordinator
    }, completion: nil)
}
```

### Safe Area

Be careful when using safe areas. As described in the [WWDC "UIKit: Apps for Every Size and Shape" video](https://masterer.apple.com/videos/play/wwdc2018-235/?time=328), the safe area insets will not be updated if your views exceeds the screen bounds. This is specially the case when using the `OverlayStyle.flexibleHeight`.

The simpliest way to handle the safe area correctly is to compute your notch heights using the `safeAreaInsets` provided by the container and avoid the `safeAreaLayoutGuide` bottom anchor in your overlay :

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    heightForNotchAt index: Int,
                                    availableSpace: CGFloat) -> CGFloat {
    let bottomInset = containerViewController.view.safeAreaInsets.bottom
    switch OverlayNotch.allCases[index] {

        // ...

        case .minimum:
            return bottomInset + 100
    }
}
```

### Custom Translation

Adopt `OverlayTranslationFunction` to modify the relation between the user's finger translation and the actual overlay translation.

By default, the overlay container uses a `RubberBandOverlayTranslationFunction` that provides a rubber band effect.

![rubberBand](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/rubberBand.gif)

```swift
func overlayContainerViewController(_ containerViewController: OverlayContainerViewController,
                                    overlayTranslationFunctionForOverlay overlayViewController: UIViewController) -> OverlayTranslationFunction? {
    let function = RubberBandOverlayTranslationFunction()
    function.factor = 0.7
    function.bouncesAtMinimumHeight = false
    return function
}
```

### Custom Translation Animations

Adopt `OverlayTranslationTargetNotchPolicy` & `OverlayAnimatedTransitioning` protocols to define where the overlay should go once the user's touch is released and how to animate the translation.

By default, the overlay container uses a `SpringOverlayTranslationAnimationController` that mimics the behavior of a spring. 
The associated target notch policy `RushingForwardTargetNotchPolicy` will always try to go forward if the user's finger reachs a certain velocity. It might also decide to skip some notches if the user goes too fast.

Tweak the provided implementations or implement our own objects to modify the overlay translation behavior.

![animations](https://github.com/applidium/ADOverlayContainer/blob/master/Assets/animations.gif)

```swift

func overlayTargetNotchPolicy(for overlayViewController: UIViewController) -> OverlayTranslationTargetNotchPolicy? {
    let policy = RushingForwardTargetNotchPolicy()
    policy.minimumVelocity = 0
    return policy
}

func animationController(for overlayViewController: UIViewController) -> OverlayAnimatedTransitioning? {
    let controller = SpringOverlayTranslationAnimationController()
    controller.damping = 0.2
    return controller
}
```

### Reloading the notches

You can reload all the data that is used to construct the notches using the dedicated method:

```swift
func invalidateNotchHeights()
```

This method does not reload the notch heights immediately. It only clears the current container's state. Call `moveOverlay(toNotchAt:animated:)` to perform the change immediately or to move the overlay to a correct notch if the number of notches has changed.

## Author

gaetanzanella, gaetan.zanella@fabernovel.com

## License

OverlayContainer is available under the MIT license. See the LICENSE file for more info.
