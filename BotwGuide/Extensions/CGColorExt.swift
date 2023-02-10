//
//  CGColor.swift
//  BotwGuide
//
//  Created by Hawken Rives on 2/9/23.
//

import CoreGraphics

extension CGColor {
	private func processForReadability(_ col: CGFloat) -> CGFloat {
		if col <= 0.03928 {
			return col / 12.92
		}

		return pow((col + 0.055) / 1.055, 2.4)
	}

	func readableForeground() -> CGColor {
		let r = processForReadability(self.components![0] / 255)
		let g = processForReadability(self.components![1] / 255)
		let b = processForReadability(self.components![2] / 255)

		let light = (0.2126 * r) + (0.7152 * g) + (0.0722 * b)
		return (light > 0.179) ? CGColor(gray: 0, alpha: 1) : CGColor(gray: 1, alpha: 1)
	}
}
