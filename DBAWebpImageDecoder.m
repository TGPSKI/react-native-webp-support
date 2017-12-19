#import "DBAWebpImageDecoder.h"
#include "WebP/decode.h"
#include "WebP/demux.h"

static void free_data(void *info, const void *data, size_t size)
{
    free((void *) data);
}

@implementation DBAWebpImageDecoder

RCT_EXPORT_MODULE()

- (BOOL)canDecodeImageData:(NSData *)imageData
{
    int result = WebPGetInfo([imageData bytes], [imageData length], NULL, NULL);
    if (result == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (RCTImageLoaderCancellationBlock)decodeImageData:(NSData *)imageData
                                              size:(CGSize)size
                                             scale:(CGFloat)scale
                                        resizeMode:(UIViewContentMode)resizeMode
                                 completionHandler:(RCTImageLoaderCompletionBlock)completionHandler
{
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;
    
    UIImage *image;
    WebPBitstreamFeatures features;
    WebPGetFeatures([imageData bytes], [imageData length], &features);
    if (features.has_animation) {
        int width = features.width;
        int height = features.height;
        
        WebPData webp_data;
        const uint8_t* data = [imageData bytes];
        size_t size = [imageData length];
        webp_data.bytes = data;
        webp_data.size = size;
        
        WebPAnimDecoderOptions dec_options;
        WebPAnimDecoderOptionsInit(&dec_options);
        dec_options.color_mode = MODE_RGBA;
        
        WebPAnimDecoder* dec = WebPAnimDecoderNew(&webp_data, &dec_options);
        WebPAnimInfo anim_info;
        WebPAnimDecoderGetInfo(dec, &anim_info);
        int timestamp = 0;
        NSMutableArray<NSNumber *> *delays = [NSMutableArray arrayWithCapacity:anim_info.frame_count];
        NSMutableArray<id /* CGIMageRef */> *images = [NSMutableArray arrayWithCapacity:anim_info.frame_count];
        int frameIndex = 0;
        
        while (WebPAnimDecoderHasMoreFrames(dec)) {
            uint8_t* frame_rgba;
            uint8_t* curr_rgba = malloc(width * 4 * height);
            memset(curr_rgba, 0, width * 4 * height);
            int prevTimestamp = timestamp;
            WebPAnimDecoderGetNext(dec, &frame_rgba, &timestamp);
            
            memcpy(curr_rgba, frame_rgba, width * 4 * height);
            int delay = timestamp - prevTimestamp;
            delays[frameIndex] = [NSNumber numberWithInt:delay];
            
            CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, curr_rgba, width*height*4, free_data);
            CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
            images[frameIndex] = (__bridge_transfer id)imageRef;
            
            frameIndex++;
            CGDataProviderRelease(provider);
        }
        image = [UIImage imageWithCGImage:(__bridge CGImageRef _Nonnull)(images[0]) scale:scale orientation:UIImageOrientationUp];
        
        NSMutableArray<NSNumber *> *keyTimes = [NSMutableArray arrayWithCapacity:delays.count];
        NSTimeInterval runningDuration = 0;
        for (NSNumber *delayNumber in delays) {
            [keyTimes addObject:@(runningDuration / timestamp)];
            runningDuration += delayNumber.doubleValue;
        }
        [keyTimes addObject:@1.0];
        
        WebPAnimDecoderDelete(dec);
        
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        animation.calculationMode = kCAAnimationDiscrete;
        animation.repeatCount = anim_info.loop_count == 0 ? HUGE_VALF : anim_info.loop_count;
        animation.keyTimes = keyTimes;
        animation.values = images;
        animation.duration = timestamp / 1000.0;
        animation.removedOnCompletion = NO;
        image.reactKeyframeAnimation = animation;
    } else {
        int width = 0, height = 0;
        uint8_t *data = WebPDecodeRGBA([imageData bytes], [imageData length], &width, &height);
        CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, width*height*4, free_data);
        
        
        CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4 * width, colorSpaceRef, bitmapInfo, provider, NULL, YES, renderingIntent);
        image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        
        CGDataProviderRelease(provider);
        CGImageRelease(imageRef);
    }
    CGColorSpaceRelease(colorSpaceRef);
    completionHandler(nil, image);
    return ^{};
}
@end
