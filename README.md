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


## Set up android native modules
0. set `react-native-fs`
1. install photoEditorSdk
2. create native modules
3. config License
4. resolve other issues

### set up react-native-fs
as react-native-fs is a native module lib, so in `android/build.gradle`, add 
```android
subprojects {
    afterEvaluate {project ->
        if (project.hasProperty("android")) {
            android {
                compileSdkVersion rootProject.ext.compileSdkVersion
                buildToolsVersion rootProject.ext.buildToolsVersion
            }
        }
    }
}

```

### install photoEditorSDK:

1. in `android/build.gradle`, add `maven { url "https://artifactory.9elements.com/artifactory/imgly" }` in `allprjects` part.
2. as `react-native-fs` and `photoEditorSDK` have some shared lib, so we need add the config packageOptions in app config.
    - in `android/app/build.gradle`, in `android { } `add 
    ```android
        packagingOptions {
             pickFirst 'lib/armeabi-v7a/libRSSupport.so'
             pickFirst 'lib/arm64-v8a/librsjni.so'
             pickFirst 'lib/arm64-v8a/libRSSupport.so'
             pickFirst 'lib/mips/libRSSupport.so'
             pickFirst 'lib/x86/libRSSupport.so'
             pickFirst 'lib/mips/librsjni.so'
             pickFirst 'lib/x86_64/libRSSupport.so'
             pickFirst 'lib/x86/librsjni.so'
             pickFirst 'lib/x86_64/librsjni.so'
             pickFirst 'lib/armeabi-v7a/librsjni.so'
    
        }
    ```
    - the same file, in dependencies add: `compile 'ly.img.android:photo-editor-sdk:5.1.4'`
    - in  `android/app/src/main/AndroidManifest.xml`, change `android:allowBackup` value to `true`
    - the same file as above, add permission configuration: 
        ```android
            <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
            <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
        ```

### add native modules
1. create the folder `pesdk` under `/android/app/src/main/java/com/`
2. add 2 file inside the folder: `PESDKModule.java` and `PESDKPackage.java`, check the repo for the content of the 2 files
3. add PESDKconfig in Main(`android/app/src/main/java/com/testnative/MainApplication.java`):
    - `import com.pesdk.PESDKPackage;`
    -  `import ly.img.android.PESDK;`
    - and inside ` getPackages()`, add PESDK: `new PESDKPackage()`


### Config License
The same as the ios setting part, the application_id for the application is in `android/app/build.gradle`

Download the License file, and create `assets` folder inside `android/app/src/main`, put the License file inside it.

Then in `android/app/src/main/java/com/testnative/MainApplication.java`, add `PESDK.init(this, 'License name')` under `SoLader.init`


## Other issues
1. renderscript problem: 
   - solution: in `android/app/build.gradle`, defaultconfig, add: 
    ```android
      renderscriptTargetApi 18
      renderscriptSupportModeEnabled true
    ```

    

       