//
//  ContainerView.swift
//  SO62945414
//
//  Created by Paul Bryan on 7/17/20.
//  Copyright © 2020 Paul Bryan. All rights reserved.
//

import UIKit

class ContainerView: UIView {

	var drawingView = DrawingView()

	override init(frame: CGRect) {
		super.init(frame: frame)

		self.drawingView.contentScaleFactor = UIScreen.main.scale
		self.drawingView.translatesAutoresizingMaskIntoConstraints = false
		self.drawingView.backgroundColor = UIColor.green
		self.addSubview(drawingView)
		self.addSubviewConstraints()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	override func layoutSubviews() {
		super.layoutSubviews()
	}

	func addSubviewConstraints() {
		self.drawingView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
		self.drawingView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
		self.drawingView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
		self.drawingView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
	}
}
