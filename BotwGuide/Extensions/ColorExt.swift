//
//  ColorExt.swift
//  BotwGuide
//
//  Created by Hawken Rives on 2/9/23.
//

import SwiftUI

extension Color {
	static func randomColor(_ seed: String) -> Color {
		let total: Int = seed.unicodeScalars.reduce(0, { index, ch in Int(UInt32(ch)) })

		srand48(total * 200)
		let r = CGFloat(drand48())

		srand48(total)
		let g = CGFloat(drand48())

		srand48(total / 200)
		let b = CGFloat(drand48())

		return Color(red: r, green: g, blue: b)
	}

	func readableForeground() -> Color {
		Color(self.cgColor!.readableForeground())
	}
}
