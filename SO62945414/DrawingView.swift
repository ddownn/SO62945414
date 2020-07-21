//
//  DrawingView.swift
//  SO62945414
//
//  Created by Paul Bryan on 7/17/20.
//  Copyright © 2020 Paul Bryan. All rights reserved.
//

import UIKit

class DrawingView: UIView {
	override class var layerClass: AnyClass {
		return DrawingLayer.self
	}
}

class DrawingLayer: CAShapeLayer {

	var vc: ViewController!

	var didSetup = false

	var diameter: CGFloat { return min(self.bounds.width, self.bounds.height) }
	var radius: CGFloat { return diameter/2 }

	var largeStrokeWidth: CGFloat { return ceil(radius/15) }
	var smallStrokeWidth: CGFloat { return ceil(largeStrokeWidth/5) }

	let smallFillColor: CGColor = UIColor.white.cgColor
	let largeFillColor: CGColor = UIColor.white.cgColor
	@objc var shapeFillColor: CGColor!

	var figureRect: CGRect { return CGRect(x: self.bounds.midX, y: 0, width: figureDiameter, height: figureDiameter).insetBy(dx: largeStrokeWidth/2, dy: largeStrokeWidth/2) }
	var figureCenter: CGPoint { return figureRect.center }
	var figureDiameter: CGFloat { return radius }
	var figureRadius: CGFloat { return figureDiameter/2 }

	var markerDiameter: CGFloat { return ceil(figureDiameter/4) }
	var markerRadius: CGFloat { return markerDiameter/2 }
	var markerLocRadius: CGFloat { return figureRadius - markerRadius - largeStrokeWidth - smallStrokeWidth/2 }
	var markerLoc: CGPoint { return CGPoint(x: figureCenter.x + cos(0) * markerLocRadius, y: figureCenter.y + sin(0) * markerLocRadius) }
	var markerRect: CGRect { return CGRect(x: markerLoc.x - markerRadius, y: markerLoc.y - markerRadius, width: markerDiameter, height: markerDiameter) }

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(shapeFillColor) {
            return true
        }
        return super.needsDisplay(forKey: key)
    }

    override func draw(in con: CGContext) {
		print((self.presentation() ?? self).bounds)
		con.setFillColor(shapeFillColor)
        con.fill(figureRect)
		con.setStrokeColor(UIColor.black.cgColor)
        con.setLineWidth(self.largeStrokeWidth)
        con.stroke(figureRect)

		con.setFillColor(UIColor.systemBlue.cgColor)
		con.fillEllipse(in: markerRect)
		con.setStrokeColor(UIColor.black.cgColor)
		con.setLineWidth(self.smallStrokeWidth)
		con.strokeEllipse(in: markerRect)
    }

	override func layoutSublayers() {
		if !didSetup {
			self.setup()
			self.didSetup = true
		}
		self.shapeFillColor = vc.useLargeContainer ? largeFillColor : smallFillColor
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.setNeedsDisplay()
	}
}
