# Set up the demo for react native photo sdk editor
[PhotoEditor SDK](https://www.photoeditorsdk.com/)
There is a official blog about how to set it up, however, there are some errors inside it, and it is not up to date.
Even though there is an official demo repo, if you clone it, without correct instruction, you will still not be able to run it.

So I tried to give a detailed instruction about how to set it up with react native.

## Setup React Native
1. install `react-native`
2. `react-native init TestNative`
3. `cd ./TestNative && react-native run-ios`
4. Then check everything is fine until now.

## Set up the IOS Native Modules
1. Install the PhotoEditor SDK framework.
2. Import it correctly into the Xcode
3. Unlock License
4. Try to run the demo

### Install PhotoEditor SDK
We can install it with `pod`
1. create the `podfile` in `./ios/`
2. add
    ```ruby
    target 'TestNative' do
      pod 'PhotoEditorSDK'
    end
    ```
3. then install: `cd ./ios && pod install`
4. Then use Xcode open `TestNative.xcworkspace` inside `ios` folder
5. click `TestNative`, and go to `building setting`, find `Build Options`, set `Always Embed Swift Standard Libraries` to Yes


### Create Native Module
1. Open Xcode (as described above)
2. right click `TestNative` and choose `New file`, choose `Cocoa Touch Class` and Target set to `TestNative`
3. PESDKModule.h
    ```objective-c
    //
    //  PESDKModule.h
    //  TestNative
    //
    //  Created by PascalSun on 31/7/18.
    //  Copyright © 2018 Facebook. All rights reserved.
    //

    #import <React/RCTBridgeModule.h>
    #import <React/RCTEventEmitter.h>

    @interface PESDKModule : RCTEventEmitter <RCTBridgeModule>

    @end
    ```
4. PESDKModule.m
    ```objective-c
    //
    //  PESDKModule.m
    //  TestNative
    //
    //  Created by PascalSun on 31/7/18.
    //  Copyright © 2018 Facebook. All rights reserved.
    //

    #import "PESDKModule.h"
    #import <React/RCTUtils.h>
    #import <PhotoEditorSDK/PhotoEditorSDK.h>

    @interface PESDKModule () <PESDKPhotoEditViewControllerDelegate>
    @end

    @implementation PESDKModule

    RCT_EXPORT_MODULE(PESDK);

    RCT_EXPORT_METHOD(present:(NSString *)path) {
      dispatch_async(dispatch_get_main_queue(), ^{
        PESDKPhotoEditViewController *photoEditViewController = [[PESDKPhotoEditViewController alloc] initWithPhotoAsset:[[PESDKPhoto alloc] initWithData:[NSData dataWithContentsOfFile:path]] configuration:[[PESDKConfiguration alloc] init]];
        photoEditViewController.delegate = self;

        UIViewController *currentViewController = RCTPresentedViewController();
        [currentViewController presentViewController:photoEditViewController animated:YES completion:NULL];
      });
    }

    #pragma mark - IMGLYPhotoEditViewControllerDelegate

    - (void)photoEditViewController:(PESDKPhotoEditViewController *)photoEditViewController didSaveImage:(UIImage *)image imageAsData:(NSData *)data {
      [photoEditViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self sendEventWithName:@"PhotoEditorDidSave" body:@{ @"image": [UIImageJPEGRepresentation(image, 1.0) base64EncodedStringWithOptions: 0], @"data": [data base64EncodedStringWithOptions:0] }];
      }];
    }

    - (void)photoEditViewControllerDidCancel:(PESDKPhotoEditViewController *)photoEditViewController {
      [photoEditViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
        [self sendEventWithName:@"PhotoEditorDidCancel" body:@{}];
      }];
    }

    - (void)photoEditViewControllerDidFailToGeneratePhoto:(PESDKPhotoEditViewController *)photoEditViewController {
      [self sendEventWithName:@"PhotoEditorDidFailToGeneratePhoto" body:@{}];
    }

    #pragma mark - RCTEventEmitter

    - (NSArray<NSString *> *)supportedEvents {
      return @[ @"PhotoEditorDidSave", @"PhotoEditorDidCancel", @"PhotoEditorDidFailToGeneratePhoto" ];
    }

    @end
    ```
5. run `react-native run-ios`
6. console.log NativeModules inside `App.js` to check whether there is a module called PESDK

### Unlock License
1. create an account with PhotoEditor SDK
2. go to subscriptions
3. go to Xcode, check the TestNative Bundle Identifier in General Part, for this one is: org.reactjs.native.example.TestNative
4. paste it in the IOS BUNDLE IDS, and then save LICENSE FILE
5. create an empty file in Xcode, and put it in `ios` folder, name it as `LICENSE_IOS`, paste the content inside the LICENSE_FILE into this file.
6. open TestNative folder,  `AppDelegate.m`, add the code:
   ```objective-c
    #import <PhotoEditorSDK/PhotoEditorSDK.h> // top

    [PESDK unlockWithLicenseAt:[[NSBundle mainBundle] URLForResource:@"LICENSE_IOS" withExtension:nil]]; // line before return Yes
   ```
7. run `react-native run-ios` or build it via Xcode

### Run the demo
1. first we need to install react-native-fs
2. then replace the App.js with the file in the repo.
3. run it.

#### Install react-native-fs
1. install it via npm: `npm install react-native-fs --save`
2. link it: `react-native link`
3. Have not finished here, check this link, do as the step 1 & 2, [import lib link](https://facebook.github.io/react-native/docs/linking-libraries-ios.html)