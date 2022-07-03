//
//  RowView.swift
//  MensaWatch WatchKit Extension
//
//  Created by David Klopp on 03.07.22.
//

import SwiftUI

let kDefaultFont = Font.system(size: 13)
let kDefaultTitleFont = Font.system(size: 15)

struct SectionHeaderView: View {
    var title: String

    var body: some View {
        Text(title)
            .font(kDefaultTitleFont)
            .foregroundColor(Color(uiColor: .defaultBlue))
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CounterTitleView: View {
    var title: String

    var body: some View {
        Text(self.title)
            .font(kDefaultTitleFont)
            .foregroundColor(Color(uiColor: .defaultGreen))
            .frame(maxWidth: .infinity, alignment: .leading)
            .listRowBackground(Color.clear)
    }
}

struct FoodEntryView: View {
    var data: Row

    var body: some View {
        let data = self.data
        VStack {
            // Food description
            Text(data.description)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .font(kDefaultFont)
            // Food price and additives
            HStack(alignment: .top, spacing: 2) {
                if let priceString = data.getPriceString() {
                    Text(priceString)
                        .font(kDefaultFont)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.secondary)
                }
                let additivesText = data.getAdditivesText(short: true)
                if !additivesText.isEmpty {
                    Spacer()
                    Text(additivesText)
                        .font(kDefaultFont)
                        .frame(maxWidth: 44, alignment: .trailing)
                }
            }
        }
    }
}

struct CounterListView: View {
    var location: Location

    @State private var data = [Date: [Row]]()

    func getData() async -> [Date: [Row]] {
        var data: [Row] = (try? await API.fetchRows()) ?? []

        // Filter data based on location and current date
        data = data.filter { row in
            let today = Calendar.current.startOfDay(for: .now)
            let targetDate = Calendar.current.startOfDay(for: row.date)
            return row.consumeLocation == location && targetDate.timeIntervalSince(today) >= 0
        }

        return Dictionary(grouping: data) { $0.date }
    }

    var body: some View {
        List() {
            let sortedData = self.data.sorted() {
                $0.0 < $1.0
            }
            ForEach(sortedData, id: \.key) { date, rows in
                let dateString = date.formatted(date: .complete, time: .omitted)
                let validCounterOrderIndices = (0..<self.location.numberOfCounters).compactMap {
                    return OrderIndex(rawValue: $0)
                } + [OrderIndex.side]

                // Repeat for each date
                Section(header: SectionHeaderView(title: dateString)) {
                    // Repeat for each counter
                    ForEach(validCounterOrderIndices, id: \.self) { index in
                        let rowsForCounter = rows.filter {
                            $0.counter.orderIndex == index
                        }.sorted { (lhs, rhs) in
                            return lhs.counter.name < rhs.counter.name
                        }

                        if rowsForCounter.isEmpty {
                            // Add a "Keine Ausgabe" entry if there is no food at this counter
                            let row = Row(location: self.location, consumeLocation: self.location,
                                          counter: index.defaultCounter, date: Date(),
                                          description: "Keine Ausgabe heute.")
                            CounterTitleView(title: "\(row.counter.name)")
                            FoodEntryView(data: row)
                        } else {
                            // Repeat for each entry per counter
                            ForEach((0..<rowsForCounter.count), id: \.self) { i in
                                let row = rowsForCounter[i]
                                let lastRow = rowsForCounter[safe: i-1]
                                if row.counter.name != lastRow?.counter.name {
                                    CounterTitleView(title: "\(row.counter.name)")
                                }
                                FoodEntryView(data: row)
                            }
                        }
                    }

                }
            }
        }.task {
            self.data = await self.getData()
        }
    }
}


struct CounterListView_Previews: PreviewProvider {
    static var previews: some View {
        CounterListView(location: Location.mensaria)
    }
}
