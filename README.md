# react-native-webp-support

## Status: archived

See [Aleksefo/react-native-webp-format](https://github.com/Aleksefo/react-native-webp-format)

**Forked from [dbasedow/react-native-webp](https://github.com/dbasedow/react-native-webp)**

react-native-webp-support adds support for WebP images for react-native components. This fork includes additional documentation to help users incorporate WebP support into their projects.

# Why???

* We reduced our CodePush bundle size by __66%__ with `.webp` format
* We also reduced iOS and Android binary sizes by __25%__ with`.webp` format
* React Native JS Thread feels __so much faster__
* Navigator transitions are __so much smoother__

# Overview

__Android support:__ built out of the box with an available library from Google.

See [react-native Image API documentation](https://facebook.github.io/react-native/docs/image.html#gif-and-webp-support-on-android) for more details, or follow the implementation guide below.

__iOS support:__ Add WebP / WebPDemux frameworks and link `react-native-webp.xcodeproj` to your project.

# Installation

## Android

1. Add the following dependency to `android/app/build.gradle`:

```java
...

dependencies {
  ...
  // For WebP support, including animated WebP
  compile 'com.facebook.fresco:animated-webp:1.3.0'
  compile 'com.facebook.fresco:webpsupport:1.3.0'

  // For WebP support, without animations
  compile 'com.facebook.fresco:webpsupport:1.3.0'
}
...
```

2. Build a new binary, and use `.webp` formatted images

## iOS

1. `yarn add TGPSKI/react-native-webp-support`
2. Open your project in Xcode
3. Add `WebP.framework` and `WebPDemux.framework` from node_modules/react-native-webp-support/ to your project files (Right click your project and select "Add Files to ...")
	- [Alternative] Drag `WebP.framework` and `WebPDemux.framework` from node_modules/react-native-webp-support/ to project_root/ios
4. Add `WebP.framework` and `WebPDemux.framework` to your `Linked Frameworks and Libraries` in the General tab of your main project target
5. Add "$(SRCROOT)/../node_modules/react-native-webp-support" to your `Framework Search Paths`, located in the Build Settings tab of your main project target
	- [Alternative] Ensure $(PROJECT_DIR) is in your `Framework Search Paths`
6. Add `$(SRCROOT)/../node_modules/react-native-webp-support` to your `Header Search Paths`, located in the Build Settings tab of your main project target
7. Add `ReactNativeWebp.xcodeproj` from node_modules/react-native-webp-support/ to your project files (Right click your project and select "Add Files to ...")
8. Add `libReactNatveWebp.a` to your `Link Binary with Libraries` step, located in the Build Phases tab of your main project target
9. Build a new binary, and use `.webp` formatted images


*In general, I don't trust react-native link. I have generated a few bugs using this feature. Manual linking is my go-to for all dependencies.*

# Usage

You don't have to do anything other than use WebP images. This project adds a custom RCTImageDataDecoder to your project, so all react-native components should be able to use WebP files. If you are using custom components that work with UIImages directly (without using RCTImageDataDecoder) you will have to change that code.

# WebP Format Notes

[WebP Compression Study](https://developers.google.com/speed/webp/docs/webp_study)

[PNG vs. WebP Image Formats, Andrew Munsell Blog](https://www.andrewmunsell.com/blog/png-vs-webp/)

[PNG to WebP – Comparing Compression Sizes](https://optimus.keycdn.com/support/png-to-webp/)

## Support Libraries

Download & install cwebp and dwebp with your favorite package manager (compression and decompression).

[Google WebP Developer Page](https://developers.google.com/speed/webp/docs/cwebp)

[Google WebP Downloads](https://developers.google.com/speed/webp/download)

## Converting images to WebP Format

```bash
SOURCE_DIR=/your/path/here
DEST_DIR=/your/path/here
WEBP_QUALITY=70

cd $SOURCE_DIR
for f in *.png; do
  echo "Converting $f to WebP"
  ff=${f%????}
  echo "no ext ${ff}"
  cwebp -q $WEBP_QUALITY "$(pwd)/${f}" -o "${DEST_DIR}/${ff}.webp"
done

```

## File Size Comparison

### Source images

```bash
du -sh $DEST_DIR
```

### CodePush Bundle Size

```bash
REACT_NATIVE_SRC_ROOT=/your/path/here
IOS_CP_DEST=/your/path/here
ANDROID_CP_DEST=/your/path/here

cd $REACT_NATIVE_SRC_ROOT

# Run react-native bundle command for iOS and Android

## iOS
react-native bundle \
    --dev false \
    --platform ios \
    --entry-file index.ios.js \
    --bundle-output $IOS_CP_DEST/index.jsbundle \
    --assets-dest $IOS_CP_DEST

## Android
react-native bundle \
    --dev false \
    --platform android \
    --entry-file index.android.js \
    --bundle-output $ANDROID_CP_DEST/main.jsbundle \
    --assets-dest $ANDROID_CP_DEST

# Find unbundled size

IOS_ASSET_DIR=$IOS_CP_DEST/App/Images

IOS_BUNDLE_SIZE=$(du -sh $IOS_CP_DEST/index.jsbundle | awk '{$NF="";sub(/[ \t]+$/,"")}1')
IOS_ASSET_SIZE=$(du -sh $IOS_ASSET_DIR | awk '{$NF="";sub(/[ \t]+$/,"")}1')

ANDROID_BUNDLE_SIZE=$(du -sh $ANDROID_CP_DEST/main.jsbundle | awk '{$NF="";sub(/[ \t]+$/,"")}1')
ANDROID_ASSET_SIZE=$(du -sh $ANDROID_CP_DEST/drawable-* | awk '{$NF="";sub(/[ \t]+$/,"")}1')

echo IOS_BUNDLE_SIZE $IOS_BUNDLE_SIZE
echo IOS_ASSET_SIZE $IOS_ASSET_SIZE

echo ANDROID_BUNDLE_SIZE $ANDROID_BUNDLE_SIZE
echo ANDROID_ASSET_SIZE $ANDROID_ASSET_SIZE

# Find bundled sizes

zip -r ios-cp-archive.zip $IOS_CP_DEST
zip -r android-cp-archive.zip $ANDROID_CP_DEST

IOS_CP_COMPRESSED_SIZE=$(du -sh ios-cp-archive.zip | awk '{$NF="";sub(/[ \t]+$/,"")}1')
ANDROID_CP_COMPRESSED_SIZE=$(du -sh android-cp-archive.zip | awk '{$NF="";sub(/[ \t]+$/,"")}1')

echo IOS_CP_COMPRESSED_SIZE $IOS_CP_COMPRESSED_SIZE
echo ANDROID_CP_COMPRESSED_SIZE $ANDROID_CP_COMPRESSED_SIZEsta
```

## Add WebP Image Preview to OSX

[WebPQuickLook](https://github.com/emin/WebPQuickLook)

**From the repo above**

By default, OS X doesn't provide preview and thumbnail for all file types. WebP is Google's new image format and OS X doesn't recognize the .webp files. This plugin will give you an ability to see previews and thumbnails of WebP images.

```bash
curl -L https://raw.github.com/romanbsd/WebPQuickLook/master/WebpQuickLook.tar.gz | tar -xvz
mkdir -p ~/Library/QuickLook/
mv WebpQuickLook.qlgenerator ~/Library/QuickLook/
qlmanage -r
```

