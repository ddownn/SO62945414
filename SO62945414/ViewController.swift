//
//  ViewController.swift
//  SO62945414
//
//  Created by Paul Bryan on 7/17/20.
//  Copyright © 2020 Paul Bryan. All rights reserved.
//

import UIKit

extension CGRect {
	var center: CGPoint {
		return CGPoint(x: self.midX, y: self.midY)
	}
}

class ViewController: UIViewController {

	var containerView: ContainerView!	
	var smallContainerWidthConstraint: NSLayoutConstraint!
	var largeContainerWidthConstraint: NSLayoutConstraint!

	var drawingLayer: DrawingLayer!

	var useLargeContainer: Bool!

	override func loadView() {
		super.loadView()

		self.containerView = ContainerView(frame: CGRect.zero)
		self.containerView.translatesAutoresizingMaskIntoConstraints = false
		self.containerView.backgroundColor = UIColor.systemPurple
		self.view.addSubview(containerView)

		self.drawingLayer = self.containerView.drawingView.layer as? DrawingLayer
		self.drawingLayer.vc = self

		self.setupConstraints()
		self.useLargeContainer = self.view.bounds.width < self.view.bounds.height
		self.smallContainerWidthConstraint.priority = self.useLargeContainer ? .defaultHigh-1 : .defaultHigh+1
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		self.view.layoutIfNeeded()
		coordinator.animate(alongsideTransition: { _ in

			let lay = self.drawingLayer!

			let oldColor = lay.shapeFillColor
			let newColor: CGColor = self.useLargeContainer ? lay.largeFillColor : lay.smallFillColor
			
			lay.shapeFillColor = newColor

			let ba = CABasicAnimation(keyPath: #keyPath(DrawingLayer.shapeFillColor))
			ba.fromValue = oldColor
			lay.add(ba, forKey: nil)

			self.toggleContainerSize()
			self.view.layoutIfNeeded()
		}, completion: nil)
	}

	func toggleContainerSize() {
		self.useLargeContainer.toggle()
		self.smallContainerWidthConstraint.priority = self.useLargeContainer ? .defaultHigh-1 : .defaultHigh+1
	}

	func setupConstraints() {

		// MARK:- container small and large width
		let smallVal: CGFloat = 50
		let largeVal: CGFloat = min(self.view.bounds.width, self.view.bounds.height) - 10

		self.smallContainerWidthConstraint = NSLayoutConstraint(item: self.containerView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: smallVal)
		self.smallContainerWidthConstraint.priority = UILayoutPriority(rawValue: 750)
		self.smallContainerWidthConstraint.isActive = true

		self.largeContainerWidthConstraint = NSLayoutConstraint(item: self.containerView!, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: largeVal)
		self.largeContainerWidthConstraint.priority = UILayoutPriority(rawValue: 750)
		self.largeContainerWidthConstraint.isActive = true

		// MARK:- container aspect
		self.containerView.heightAnchor.constraint(equalTo: self.containerView.widthAnchor).isActive = true

		// MARK:- container center
		self.containerView.centerXAnchor.constraint(equalTo: self.containerView.superview!.centerXAnchor).isActive = true
		self.containerView.centerYAnchor.constraint(equalTo: self.containerView.superview!.centerYAnchor).isActive = true

		// MARK:- container top
		let topHighPriority = NSLayoutConstraint(item: self.containerView!, attribute: .top, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: 50)
		topHighPriority.priority = UILayoutPriority(rawValue: 750)
		topHighPriority.isActive = true

		self.containerView.topAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive = true

		// MARK:- container leading
		let leadingHighPriority = NSLayoutConstraint(item: self.containerView!, attribute: .leading, relatedBy: .equal, toItem: self.view.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: 50)
		leadingHighPriority.priority = UILayoutPriority(rawValue: 750)
		leadingHighPriority.isActive = true

		self.containerView.leadingAnchor.constraint(greaterThanOrEqualTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 50).isActive = true
	}
}

