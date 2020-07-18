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

	var didSetup = false

	var oldBounds: CGRect!
	var oldPath: CGPath!
	var oldLineWidth: CGFloat!
	var animGroupDuration: TimeInterval = .zero

	override var bounds: CGRect {
		willSet {
			self.oldBounds = self.bounds
			self.oldPath = self.path
			self.oldLineWidth = self.srokeWidth
		}
	}

	var diameter: CGFloat { return min(self.bounds.width, self.bounds.height) }
	var srokeWidth: CGFloat { return ceil(diameter/30) }

	override func layoutSublayers() {

		if !didSetup {
			self.setup()
			self.didSetup = true
		}

		self.path = CGPath(rect: CGRect(x: self.bounds.midX, y: 0, width: self.bounds.width/2, height: self.bounds.height/2), transform: nil)
		self.lineWidth = self.srokeWidth
		self.animate()
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.strokeColor = UIColor.black.cgColor
		self.fillColor = UIColor.lightGray.cgColor
	}

	func animate() {
		let animBounds = CABasicAnimation(keyPath: "bounds")
		animBounds.fromValue = self.oldBounds
		animBounds.toValue = self.bounds

		let animPath = CABasicAnimation(keyPath: "path")
		animPath.fromValue = self.oldPath
		animPath.toValue = self.path

		let animLineWidth = CABasicAnimation(keyPath: "lineWidth")
		animLineWidth.fromValue = self.oldLineWidth
		animLineWidth.toValue = self.srokeWidth

		let animGroup = CAAnimationGroup()
		animGroup.animations = [ animBounds, animPath, animLineWidth ]
		animGroup.duration = animGroupDuration

		self.add(animGroup, forKey: nil)
	}
}
