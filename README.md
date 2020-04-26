# Local website plugin for Publish

A [Publish](https://github.com/johnsundell/publish) plugin to localify HTML files in the output folder.

Goal: Make the generated website local on disk.
No need for webserver

Replaces all href and src attributes to be relative to output folder.

The generated website is therefore accessible offline, directly from filesystem.
Can be embedded in iOS app to be used within a WKWebView

Usage samples:

- FAQ in iOS/MacOS app
- Cocoapods ans SPM licences display in iOS/MacOS app

## Installation

To install it into your [Publish](https://github.com/johnsundell/publish) package, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        ...
        .package(url: "https://github.com/Deub27/LocalWebsitePublishPlugin.git", from: "0.1.0")
    ],
    targets: [
        .target(
            ...
            dependencies: [
                ...
                "LocalWebsitePublishPlugin"
            ]
        )
    ]
    ...
)
```

Then import LocalWebsitePublishPlugin wherever you’d like to use it:

```swift
import LocalWebsitePublishPlugin
```

For more information on how to use the Swift Package Manager, check out [this article](https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager), or [its official documentation](https://github.com/apple/swift-package-manager/tree/master/Documentation).

## Usage

The plugin can then be used within any publishing pipeline like this:

```swift
import LocalWebsitePublishPlugin
...
try Website().publish(using: [
    ...
    .installPlugin(.localifyHTML()),
    ...
])
```

Note, that the html files must already be present in the output folder at the corresponding step in the publishing pipeline. It is therefore neccessary to add this step after `.generateHTML(...)` .

The wildcard `.localifyHTML()` method localify all html files in the top level of the output folder and subfolders.
