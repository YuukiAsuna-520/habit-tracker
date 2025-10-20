//
//  HabitTrackerWidgetBundle.swift
//  HabitTrackerWidget
//
//  Created by grace cen on 20/10/2025.
//

import WidgetKit
import SwiftUI

@main
struct HabitTrackerWidgetBundle: WidgetBundle {
    var body: some Widget {
        HabitTrackerWidget()
        HabitTrackerWidgetControl()
        HabitTrackerWidgetLiveActivity()
    }
}
