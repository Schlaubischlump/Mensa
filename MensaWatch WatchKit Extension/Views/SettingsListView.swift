//
//  SettingsListView.swift
//  MensaWatch WatchKit Extension
//
//  Created by David Klopp on 04.07.22.
//

import SwiftUI

struct CheckBoxList: View {
    let title: String

    let values: [String]

    @Binding var selectedIndex: Int

    var body: some View {
        List {
            Section(self.title) {
                ForEach(0..<self.values.count, id: \.self) { i in
                    let isChecked = self.selectedIndex == i
                    Button(action: {
                        self.selectedIndex = i
                    }, label: {
                        HStack {
                            Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                            Text(self.values[i])
                        }
                    }).foregroundColor(isChecked ? Color(uiColor: .defaultGreen) : Color.secondary)
                }
            }
        }
    }
}

struct SettingsListView: View {

    @State var selectedIndex: Int = 0

    var body: some View {
        CheckBoxList(title: "Filter", values: ["Alle", "Veggi", "Vegan"], selectedIndex: $selectedIndex)
            .onChange(of: selectedIndex) { newValue in
                // Update the current filter value
                UserDefaults.standard.filter = FoodFilter(rawValue: newValue) ?? .all
            }
            .task {
                // Load the correct index on view appearance
                self.selectedIndex = UserDefaults.standard.filter.rawValue
            }
    }
}

struct SettingsListView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsListView()
    }
}
