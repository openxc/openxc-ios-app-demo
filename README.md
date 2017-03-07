# OpenXC-iOS-App-Demo
OpenXC Enabler app that use all of the features of the [openxc-ios-framework](https://github.com/openxc/openxc-ios-framework). This can be a starting app for any OpenXC iOS application that wishes to use the C5 BLE device.

The OpenXC iOS Framework must be downloaded and included in this app. Make sure that openXCiOSFramework.framework is added as an “Embedded Binary” in the openXCenabler General project settings.

Once the application & framework is downloaded, add both the frameworks(openxc-ios & protobuf) in "Link Binary with Libraries" under "Build Phases" and "Embedded Binary". 

##Supported versions:
* iOS - upto 10.2
* XCode - upto 8.2.1
* Swift - Swift3

Note: Travis build supports only upto XCode8.1 & iOS 10.1 


## Building from XCode
XCode8 and iOS10 must be installed to build the application. Refer to this [step by step guide](https://github.com/openxc/openxc-ios-framework/blob/master/StepsToBuildOpenXCiOSFrameworkAndDemoApp.docx) for more details.


## Contributing

Please see our [Contribution Documents](https://github.com/openxc/openxc-ios-app-demo/blob/master/CONTRIBUTING.mkd)

## License
Copyright (c) 2016 Ford Motor Company
Licensed under the BSD license.
