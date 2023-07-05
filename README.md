# UltraCore

[![CI Status](https://img.shields.io/travis/rakish.shalkar@gmail.com/UltraCore.svg?style=flat)](https://travis-ci.org/rakish.shalkar@gmail.com/UltraCore)
[![Version](https://img.shields.io/cocoapods/v/UltraCore.svg?style=flat)](https://cocoapods.org/pods/UltraCore)
[![License](https://img.shields.io/cocoapods/l/UltraCore.svg?style=flat)](https://cocoapods.org/pods/UltraCore)
[![Platform](https://img.shields.io/cocoapods/p/UltraCore.svg?style=flat)](https://cocoapods.org/pods/UltraCore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
    end
  end
end
```


## Installation

UltraCore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'UltraCore', :git => "https://github.com/typi-team/ultra-ios.git"
```

## How to use

### How to display the chat page:

You need to call `update(sid token)` and wait for a response in the callback, which can return an error. If there is no error, you should call `entryConversationsViewController`, which returns a `UIViewController` that you can show in your `UIViewController` stack.

```swift

update(sid: UserDefaults.standard.string(forKey: "K_SID") ?? "") { [weak self] error in
    guard let `self` = self else { return }
    DispatchQueue.main.async {
        if let error = error {
            self.present(viewController: entrySignUpViewController(), animated: true)
        } else {
            self.navigationContoller?.push(entryConversationsViewController())
        }        
    }
}
```

### How to handle push notifications:

UltraCore can handle the following notification attributes: `[msg_id, chat_id, sender_id]`

You need to pass a dictionary to `handleNotification(data: [AnyHashable: Any], callback: @escaping (UIViewController?) -> Void)`. If the handling is successful, return a `UIViewController` that you can show in your UIViewController stack.

```swift
// Обработка нажатия на уведомление
handleNotification(data: response.notification.request.content.userInfo) { viewController in
    guard let viewController = viewController else { return }
    self.window?.rootViewController?.present(UINavigationController(rootViewController: viewController), animated: true)
}
```        

### Updating SID:

To update the token for the `UltraCore` application to function properly, you need to call the method `update(sid token: String, with callback: @escaping (Error?) -> Void)`.


```swift
update(sid: newSid, with: {_ in })
```

## Author

rakish.shalkar@gmail.com, Rakish.Shalkar

## License

UltraCore is available under the MIT license. See the LICENSE file for more info.
