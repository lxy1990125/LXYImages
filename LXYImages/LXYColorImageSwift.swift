//
//  LXYColorImageSwift.swift
//  LXYImages
//
//  Created by 李 欣耘 on 16/3/18.
//  Copyright © 2016年 lixinyun. All rights reserved.
//
// This is make ImageView has multiple colors 

import UIKit

enum GradientType: Int {
    case topToBottom = 0
    case leftToRight = 1
    case upleftTolowRight = 2
    case uprightTolowLeft = 3
}

class LXYColorImageSwift: UIImageView {
    class func shareInstance() ->LXYColorImageSwift! {
        struct Private {
            static var me : LXYColorImageSwift!
        }
        if  Private.me == nil {
            Private.me = LXYColorImageSwift()
        }
        return Private.me
    }
    
    func setImageWithFrame(frame: CGRect,colorArray: NSMutableArray,gradientType: GradientType) -> UIImageView{
        let backImage : UIImage = UIImage.init()
        
        self.image = backImage
        
        return self
    }
    
    private func buttonImageFromColors(colorArray: NSArray,gradientType: GradientType) -> UIImage {
        let ar : NSMutableArray = []
        for i : Int in 0 ..< colorArray.count {
            let color : UIColor = colorArray.objectAtIndex(i) as! UIColor
            ar.addObject(color.CGColor)
        }
        UIGraphicsBeginImageContextWithOptions(self.frame.size, true, 1)
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSaveGState(context)
        let colorSpace : CGColorSpaceRef = CGColorGetColorSpace((colorArray.lastObject as! UIColor).CGColor)!
        let gradient : CGGradientRef = CGGradientCreateWithColors(colorSpace, ar as CFArrayRef, nil)!;
        let start : CGPoint
        let end : CGPoint
        
        switch (gradientType) {
        case .topToBottom:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(0.0, self.frame.size.height);
            break;
        case .leftToRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(self.frame.size.width, 0.0);
            break;
        case .upleftTolowRight:
            start = CGPointMake(0.0, 0.0);
            end = CGPointMake(self.frame.size.width, self.frame.size.height);
            break;
        case .uprightTolowLeft:
            start = CGPointMake(self.frame.size.width, 0.0);
            end = CGPointMake(0.0, self.frame.size.height);
            break;
        default:
            print("hahaha")
            break;
        }
        CGContextDrawLinearGradient(context, gradient, start, end, .DrawsBeforeStartLocation);
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        //CGGradientRelease(gradient)
        CGContextRestoreGState(context)
       // CGColorSpaceRelease(colorSpace)
        UIGraphicsEndImageContext()
        return image;
    }
//MARK: singleColor Image 
    class func imageWithColor(color: UIColor) -> UIImage {
        let rect : CGRect = CGRectMake(0.0, 0.0, 1.0, 1.0)
        UIGraphicsBeginImageContext(rect.size);
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;

    }
}
