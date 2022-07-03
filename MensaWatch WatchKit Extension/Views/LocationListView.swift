//
//  LocationListView.swift
//  MensaWatch WatchKit Extension
//
//  Created by David Klopp on 03.07.22.
//

import SwiftUI

struct LocationCellView: View {
    var location: Location

    var body: some View {
        HStack {
            if let icon = location.icon {
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 15.0, height: 15.0)
                    .foregroundColor(.init(uiColor: .defaultGreen))
            }
            Text("\(location.name)")
        }
    }
}

struct LocationsListView: View {
    var body: some View {
        List {
            ForEach(Location.allCases, id: \.self) { location in
                let detailedView = CounterListView(location: location)
                NavigationLink(destination: detailedView) {
                    LocationCellView(location: location)
                }
            }
        }.navigationTitle("Mensa")
    }
}

struct LocationsListView_Previews: PreviewProvider {
    static var previews: some View {
        LocationsListView()
    }
}
