# openxc-ios-app-demo
OpenXC Enabler app that use all of the features of the [openxc-ios-framework](https://github.com/openxc/openxc-ios-framework). This can be a starting app for any OpenXC iOS application that wishes to use the C5 BLE device.

The OpenXC iOS Framework must be downloaded and included in this app. Make sure that openXCiOSFramework.framework is added as an “Embedded Binary” in the openXCenabler General project settings.

Once the application & framework is downloaded, add both the frameworks(openxc-ios & protobuf) in "Link Binary with Libraries" under "Build Phases" and "Embedded Binary". 
