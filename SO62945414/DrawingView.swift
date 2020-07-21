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

	// Keep a reference to the ViewController for access to .useLargeContainer
	// In layoutSublayers() it is used like this:
	// 	self.shapeFillColor = vc.useLargeContainer ? largeFillColor : smallFillColor
	var vc: ViewController!

	var didSetup = false

	var diameter: CGFloat {min(self.bounds.width, self.bounds.height)}
	var radius: CGFloat {diameter/2}

	///
	/// All (or nearly all) of DrawingLayer's geometric drawing properties will be directly tied to DrawingLayer.bounds by being proportional in some way to "diameter"
	///
	/// The intentions are:
	/// 1a. Any sublayers of DrawingLayer should be self sufficient in displaying their content based solely (or mostly) on the dimensions of their own bounds rectangle.
	/// 1b. DrawingLayer should be entirely responsible for calculating each sublayer's bounds and position
	///
	///	My understanding of how this should work
	/// 2. Any time DrawingLayer needs to appear on the screen:
	/// 2a. Anything DrawingLayer needs to draw will have been updated for that moment
	/// 2b. All of DrawingLayer's sublayers will have had their bounds and positions set appropriately
	/// 2c. All of DrawingLayer's sublayers will have already finished updating their own drawing
	///
	/// 3. Any time the bounds of DrawingLayer is modified, and before it appears on the screen:
	///	3a. DrawingLayer should update all of its drawing
	///	3b. DrawingLayer should set the bounds and positions of all sublayers
	///	3c. All sublayers should finish updating their own drawing
	///

	// set the lineWidths for the stroke of "figure" and "marker" as a proportion of drawingLayer's bounds
	// -use ceil so it's always > 1
	var largeStrokeWidth: CGFloat {ceil(radius/15)}
	var smallStrokeWidth: CGFloat {ceil(largeStrokeWidth/5)}

	let smallFillColor: CGColor = UIColor.white.cgColor
	let largeFillColor: CGColor = UIColor.systemGray.cgColor
	@objc var shapeFillColor: CGColor!

	// for marker placement
	var angle: CGFloat = .zero

	// carve out a portion of drawingLayer's bounds and refer to it as "figure"
	// -set the placement of the figure arbitrarily but linked to drawingLayer's bounds in some way
	// -use an inset so if the figure has a stroke, it remains self contained
	var figureRect: CGRect {CGRect(x: self.bounds.midX, y: 0, width: figureDiameter, height: figureDiameter).insetBy(dx: largeStrokeWidth/2, dy: largeStrokeWidth/2)}

	// -set the overall size of the figure, arbitrarily but linked to drawingLayer's bounds in some way, here the figure is a square so I'm just deciding the size will be half of the drawingLayer's size, but I want the size accessible and I want it to play a deciding role in everything that follows
	var figureDiameter: CGFloat {radius}
	var figureRadius: CGFloat {figureDiameter/2}

	// "marker" properties define the size and location for placement of the "shape" layer
	// -define the size of the marker relative to figureDiameter with a minimum
	var markerMinDiameter: CGFloat = 10
	var markerDiameter: CGFloat {max(figureDiameter/4, markerMinDiameter)}
	var markerRadius: CGFloat {markerDiameter/2}

	// -distance of the marker from "figureCenter"
	var markerLocRadius: CGFloat {figureRadius - markerRadius - largeStrokeWidth - smallStrokeWidth/2}

	// -define the center point of the marker at a distance of "markerLocRadius" from "figureCenter" at "angle"
	var markerLoc: CGPoint {CGPoint(x: figureRect.center.x + cos(angle) * markerLocRadius, y: figureRect.center.y + sin(angle) * markerLocRadius)}

	// -make a rectangle to use as the marker's "bounds"
	var markerRect: CGRect {CGRect(x: markerLoc.x - markerRadius, y: markerLoc.y - markerRadius, width: markerDiameter, height: markerDiameter)}

	//---//
	weak var shape: ShapeLayer?

	override init() { // print("DrawingLayer.init()")
		super.init()
		let shape = ShapeLayer()
		shape.contentsScale = UIScreen.main.scale
		self.addSublayer(shape)
		self.shape = shape
	}

	override init(layer: Any) { //print("DrawingLayer.init(layer:)")
		//        self.shape = (layer as! ShapeLayer)
		super.init(layer: layer)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	//---//

	override class func needsDisplay(forKey key: String) -> Bool {
		if key == #keyPath(shapeFillColor) {
			return true
		}
		return super.needsDisplay(forKey: key)
	}

	override func layoutSublayers() { // print("DrawingLayer.layoutSublayers()")
		if !didSetup {
			self.setup()
			self.didSetup = true
		}
		self.shape?.dummy = 0
		self.shapeFillColor = vc.useLargeContainer ? largeFillColor : smallFillColor
	}

	func setup() {
		self.contentsScale = UIScreen.main.scale
		self.shape?.bounds = markerRect
		self.shape?.position = markerLoc
		self.setNeedsDisplay()
		self.shape?.setNeedsDisplay()
	}

	override func draw(in con: CGContext) { // print("DrawingLayer.draw(in:)")
		// outline the "figure" of the DrawingView (figureRect)
		con.setFillColor(shapeFillColor)
		con.fill(figureRect)
		con.setStrokeColor(UIColor.black.cgColor)
		con.setLineWidth(self.largeStrokeWidth)
		con.stroke(figureRect)

		// draw the marker (blue dot) at "3:00" within the "figure"
		// like (x: figureCenter.x + cos(0) * markerLocRadius, y: figureCenter.y + sin(0) * markerLocRadius)
		con.setFillColor(UIColor.systemBlue.cgColor)
		con.fillEllipse(in: markerRect)
		con.setStrokeColor(UIColor.black.cgColor)
		con.setLineWidth(self.smallStrokeWidth)
		con.strokeEllipse(in: markerRect)

		// This seems like a good spot to give ShapeLayer a position of markerLoc, and bounds of markerRect so it shows up right with the marker.
//		CATransaction.begin()
//		CATransaction.setDisableActions(true)
//		self.shape?.bounds = markerRect.insetBy(dx: 2, dy: 2)
//		self.shape?.position = markerLoc
//		self.shape?.setNeedsDisplay()
//		CATransaction.commit()
//		print("markerRect: \(markerRect), shapeFrame: \(shape?.bounds)")
		// Alas.


		// So instead, try to recalculate all drawing variables based on the presentation layer's bounds at the exact moment they are needed, right?

		if let b = self.presentation()?.bounds {
			let newDiameter: CGFloat = min(b.width, b.height)
			let newRadius: CGFloat = newDiameter/2

			let newFigureDiameter: CGFloat = newRadius
			let newFigureRadius: CGFloat = newFigureDiameter/2
			let newFigureRect: CGRect = CGRect(x: b.midX, y: 0, width: newFigureDiameter, height: newFigureDiameter).insetBy(dx: largeStrokeWidth/2, dy: largeStrokeWidth/2)

			let newMarkerDiameter: CGFloat = max(newFigureDiameter/4, markerMinDiameter)
			let newMarkerRadius: CGFloat = newMarkerDiameter/2

			let newMarkerLocRadius: CGFloat = newFigureRadius - newMarkerRadius - largeStrokeWidth - smallStrokeWidth/2
			let newMarkerLoc: CGPoint = CGPoint(x: newFigureRect.center.x + cos(0) * newMarkerLocRadius, y: newFigureRect.center.y + sin(0) * newMarkerLocRadius)

			let newMarkerRect: CGRect = CGRect(x: newMarkerLoc.x - newMarkerRadius, y: newMarkerLoc.y - newMarkerRadius, width: newMarkerDiameter, height: newMarkerDiameter)

			CATransaction.begin()
			CATransaction.setDisableActions(true)
			self.shape?.bounds = newMarkerRect.insetBy(dx: 2, dy: 2)
			self.shape?.position = newMarkerLoc
//			print("\(markerRect), \(newMarkerRect) from self.presentation.bounds")
	        CATransaction.commit()

		}


		//---//
		//		var b = (self.presentation() ?? self).bounds
		//		let unit = b.height/3
		//		b = CGRect(x: 5, y: unit, width: unit, height: unit)
		//		 print("layer draw", b)
		//		CATransaction.begin()
		//		CATransaction.setDisableActions(true)
		//		let path = UIBezierPath(ovalIn: b)
		//		self.shape?.path = path.cgPath
		//		self.shape?.frame = self.bounds
		//		CATransaction.commit()
		//---//
	}
}
