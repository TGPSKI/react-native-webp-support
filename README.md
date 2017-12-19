react-native-webp adds support for WebP images for react-native components.

# Installation

1. ```npm install react-native-webp --save```
2. ```rnpm link``` (or manually add module to your project)
3. Open your project in xcode
4. Right click your project root and select "Add Files to ..."
5. Select "WebP.framework" and "WebPDemux.framework" from node_modules/react-native-webp/ and click "OK"
6. Select your Target
7. Select "Build Settings"
8. Add "$(SRCROOT)/../node_modules/react-native-webp" to the "Framework Search Path"

# Usage
You don't have to do anything other than use WebP images. This project adds a custom RCTImageDataDecoder to your project, so all react-native components should be able to use WebP files. If you are using custom components that work with UIImages directly (without using RCTImageDataDecoder) you will have to change that code.
