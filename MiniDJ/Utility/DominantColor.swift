//
//  DominantColor.swift
//  Controllers
//
//  Created by Yuri Petrosyan on 16/07/2024.
//

import Foundation
import UIKit

extension UIImage {
    func dominantColor() -> UIColor? {
        guard let cgImage = self.cgImage else { return nil }
        
        let width = 1
        let height = 1
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: nil,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: width * 4,
                                      space: CGColorSpaceCreateDeviceRGB(),
                                      bitmapInfo: bitmapInfo) else { return nil }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        guard let data = context.data else { return nil }
        
        let pointer = data.bindMemory(to: UInt8.self, capacity: 4)
        let r = CGFloat(pointer[0]) / 255.0
        let g = CGFloat(pointer[1]) / 255.0
        let b = CGFloat(pointer[2]) / 255.0
        let a = CGFloat(pointer[3]) / 255.0
        
        let originalColor = UIColor(red: r, green: g, blue: b, alpha: a)
        
        // Increase saturation
        let increasedSaturationColor = originalColor.adjustSaturation(by: 3) // Adjust factor as needed
        
        return increasedSaturationColor
    }
}

extension UIColor {
    func adjustSaturation(by factor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        saturation = min(saturation * factor, 1.0)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}
