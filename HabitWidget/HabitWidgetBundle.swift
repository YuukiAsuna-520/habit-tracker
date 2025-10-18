//
//  HabitWidgetBundle.swift
//  HabitWidget
//
//  Created by Soorya Narayanan Sanand on 18/10/2025.
//

import WidgetKit
import SwiftUI

@main
struct HabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitWidget()
        SimpleWidget()
        MinimalWidget()
    }
}
