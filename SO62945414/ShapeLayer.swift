//
//  ShapeLayer.swift
//  SO62945414
//
//  Created by Paul Bryan on 7/20/20.
//  Copyright © 2020 Paul Bryan. All rights reserved.
//

import UIKit

class ShapeLayer: CAShapeLayer {

	@objc var diameter: CGFloat {min(self.bounds.width, self.bounds.height)}
	var radius: CGFloat {diameter/2}
	var smallStrokeWidth: CGFloat { 1 }
	@objc var dummy = 0

	override func layoutSublayers() { // print("ShapeLayer.layoutSublayers()")
		super.layoutSublayers()
	}

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(dummy) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }
	
	override func draw(in ctx: CGContext) { // print("ShapeLayer.draw(in:)")
		ctx.setFillColor(UIColor.systemRed.cgColor)
		ctx.setStrokeColor(UIColor.black.cgColor)
		ctx.fillEllipse(in: self.bounds.insetBy(dx: smallStrokeWidth/2, dy: smallStrokeWidth/2))

		ctx.setLineWidth(smallStrokeWidth)
		ctx.strokePath()
		ctx.strokeEllipse(in: self.bounds.insetBy(dx: smallStrokeWidth/2, dy: smallStrokeWidth/2))
	}
}
