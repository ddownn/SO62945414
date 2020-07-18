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

    @objc var midX : CGFloat = 0

    override class func needsDisplay(forKey key: String) -> Bool {
        if key == #keyPath(midX) {
            return true
        }
        return super.needsDisplay(forKey:key)
    }

    override func draw(in con: CGContext) {
		print(midX)
		let r = CGRect(x: self.bounds.midX, y: 0, width: self.bounds.width/2, height: self.bounds.height/2)
		con.setFillColor(self.fillColor!)
        con.fill(r)
        con.setLineWidth(self.strokeWidth)
        con.stroke(r)
    }

	var didSetup = false

//	var oldBounds: CGRect!
//	var oldPath: CGPath!
//	var oldLineWidth: CGFloat!
//	var animGroupDuration: TimeInterval = .zero

	override var bounds: CGRect {
		willSet {
//			self.oldBounds = self.bounds
//			self.oldPath = self.path
//			self.oldLineWidth = self.strokeWidth
		}
	}

	var diameter: CGFloat { return min(self.bounds.width, self.bounds.height) }
	var strokeWidth: CGFloat { return ceil(diameter/30) }

	override func layoutSublayers() {

		if !didSetup {
			self.setup()
			self.didSetup = true
		}

//		self.path = CGPath(rect: CGRect(x: self.bounds.midX, y: 0, width: self.bounds.width/2, height: self.bounds.height/2), transform: nil)
//		self.lineWidth = self.strokeWidth
//		self.animate()
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.strokeColor = UIColor.black.cgColor
		self.fillColor = UIColor.lightGray.cgColor
	}

//	func animate() {
//		let animBounds = CABasicAnimation(keyPath: "bounds")
//		animBounds.fromValue = self.oldBounds
//		animBounds.toValue = self.bounds
//
//		let animPath = CABasicAnimation(keyPath: "path")
//		animPath.fromValue = self.oldPath
//		animPath.toValue = self.path
//
//		let animLineWidth = CABasicAnimation(keyPath: "lineWidth")
//		animLineWidth.fromValue = self.oldLineWidth
//		animLineWidth.toValue = self.strokeWidth
//
//		let animGroup = CAAnimationGroup()
//		animGroup.animations = [ animBounds, animPath, animLineWidth ]
//		animGroup.duration = animGroupDuration
//
//		self.add(animGroup, forKey: nil)
//	}
}
