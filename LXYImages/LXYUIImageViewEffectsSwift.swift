//
//  LXYUIImage+ImageEffectsSwift.swift
//  LXYImages
//
//  Created by 李 欣耘 on 16/3/18.
//  Copyright © 2016年 lixinyun. All rights reserved.
//
//  This is let image fuzzy processing 
//  git remote add origin https://github.com/lxy1990125/LXYImages.git

import UIKit
import Accelerate

extension UIImage{
    
//MARK: Image Bian Bian Bian
    func applyBlurRadius(inputImage: UIImage, blurRadius: CGFloat,tintColor: UIColor,saturationDeltaFactor: CGFloat,maskImage: UIImage?) -> UIImage?{
        if inputImage.size.width < 1 || inputImage.size.height < 1 {
            return nil
        }
        if inputImage.CGImage == nil {
            return nil
        }
        if maskImage != nil && maskImage!.CGImage == nil {
            return nil
        }
        
        let imageRect : CGRect = CGRect.init(origin: CGPointZero, size: inputImage.size)
        var effectImage : UIImage = inputImage
        
        let hasBlur : Bool = blurRadius > 1.192092896e-07
        let hasStaturationChange : Bool = fabs(saturationDeltaFactor - 1) > 1.192092896e-07
        if hasBlur == true || hasStaturationChange == true {
            UIGraphicsBeginImageContextWithOptions(inputImage.size, false, UIScreen.mainScreen().scale)
            let effectIncontext : CGContextRef = UIGraphicsGetCurrentContext()! //定义输入绘图环境
            CGContextScaleCTM(effectIncontext, 1.0, -1.0)
            CGContextTranslateCTM(effectIncontext, 0, -inputImage.size.height)
            CGContextDrawImage(effectIncontext, imageRect, inputImage.CGImage)
            
            var effectInBuffer : vImage_Buffer = vImage_Buffer.init(data: CGBitmapContextGetData(effectIncontext), height: UInt(CGBitmapContextGetHeight(effectIncontext)), width: UInt(CGBitmapContextGetWidth(effectIncontext)), rowBytes: CGBitmapContextGetBytesPerRow(effectIncontext))   //定义一个vImage输入的缓冲
            
            UIGraphicsBeginImageContextWithOptions(inputImage.size, false, UIScreen.mainScreen().scale)
            let effectOutContext : CGContextRef = UIGraphicsGetCurrentContext()!//定义输出环境
            var effectOutBuffer : vImage_Buffer = vImage_Buffer.init(data: CGBitmapContextGetData(effectOutContext), height: UInt(CGBitmapContextGetHeight(effectOutContext)), width: UInt(CGBitmapContextGetWidth(effectOutContext)), rowBytes: CGBitmapContextGetBytesPerRow(effectOutContext))   //定义一个vImage输出的缓冲
            
            
            if hasBlur == true {
                let inputRadius : CGFloat = blurRadius * UIScreen.mainScreen().scale
                var radius = floor(Double(inputRadius) * 3 * sqrt(2 * M_PI) / 4 + 0.5)
                if radius % 2 != 1 {
                    radius += 1
                }
                var a : UInt8 = 0
                vImageBoxConvolve_ARGB8888(&effectInBuffer , &effectOutBuffer, nil, 0, 0, UInt32(radius), UInt32(radius), &a, UInt32(kvImageEdgeExtend));
                vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, nil, 0, 0, UInt32(radius), UInt32(radius), &a, UInt32(kvImageEdgeExtend));
                vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, nil, 0, 0, UInt32(radius), UInt32(radius), &a, UInt32(kvImageEdgeExtend));
            }
            var effectImageBuffersAreSwapped : Bool = false
            if hasStaturationChange == true {
                let s : CGFloat = saturationDeltaFactor
                let floatingPointSaturationMatrix : [CGFloat] = [
                    0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
                    0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
                    0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
                    0,                    0,                    0,  1,
                ]
                let divisor : Int32 = 256
                let matrixSize : UInt = UInt(strideofValue(floatingPointSaturationMatrix)/strideofValue(floatingPointSaturationMatrix[0]))//大小
                var saturationMatrix : [int_fast16_t] = [int_fast16_t(matrixSize)]
                for i : Int in 0 ..< Int(matrixSize) {
                    saturationMatrix[i] = int_fast16_t(roundf(Float(floatingPointSaturationMatrix[i]) * Float(divisor)))
                }
                if hasBlur == true {
                    vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, nil, nil, UInt32(kvImageNoFlags))
                    effectImageBuffersAreSwapped = true;
                }else {
                    vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, nil, nil, UInt32(kvImageNoFlags))
                }
                
            }
            if effectImageBuffersAreSwapped == false {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
            
            if effectImageBuffersAreSwapped == true {
                effectImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
            }
        }
        //UIGraphicsEndImageContext();
        //Set up Output context
        UIGraphicsBeginImageContextWithOptions(inputImage.size, false, UIScreen.mainScreen().scale)
        let outputContext : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextScaleCTM(outputContext, 1.0, -1.0)
        CGContextTranslateCTM(outputContext, 0, -inputImage.size.height)
        
        //Draw base image
        CGContextDrawImage(outputContext, imageRect, inputImage.CGImage)
        
        if hasBlur == true {
            CGContextSaveGState(outputContext);
            if maskImage != nil {
                CGContextClipToMask(outputContext, imageRect, maskImage!.CGImage);
            }
            CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
            CGContextRestoreGState(outputContext);
        }
        
        // Add in color tint.
        if !tintColor.isKindOfClass(NSNull) {
            CGContextSaveGState(outputContext);
            CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
            CGContextFillRect(outputContext, imageRect);
            CGContextRestoreGState(outputContext);
        }
        
        // Output image is ready.
        let outputImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return outputImage

    }
  
}
