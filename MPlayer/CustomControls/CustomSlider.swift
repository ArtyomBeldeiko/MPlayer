//
//  CustomSlider.swift
//  MPlayer
//
//  Created by Artyom Beldeiko on 19.09.22.
//

import Foundation
import UIKit

class CustomSlider: UISlider {

    private let trackHeight: CGFloat = 4

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let point = CGPoint(x: bounds.minX, y: bounds.midY)
        return CGRect(origin: point, size: CGSize(width: bounds.width, height: trackHeight))
    }

    private let thumbWidth: Float = 52
    lazy var startingOffset: Float = 0 - (thumbWidth / 8.5)
    lazy var endingOffset: Float = thumbWidth / 8.5

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let xTranslation =  startingOffset + (minimumValue + endingOffset) / maximumValue * value
        return super.thumbRect(forBounds: bounds, trackRect: rect.applying(CGAffineTransform(translationX: CGFloat(xTranslation), y: 0)), value: value)
    }
}
