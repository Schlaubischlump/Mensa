//
//  MensaWidget.swift
//  MensaWidget
//
//  Created by David Klopp on 30.06.22.
//

import WidgetKit
import SwiftUI
import Intents


// MARK: - Provider

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> MensaEntry {
        MensaEntry(
            date: Date(),
            location: kSnapshotLocation,
            data: kSnapshotData,
            configuration: ConfigurationIntent()
        )
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (MensaEntry) -> ()) {
        let entry = MensaEntry(
            date: Date(),
            location: kSnapshotLocation,
            data: kSnapshotData,
            configuration: configuration
        )
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {

        let currentDate = Date()
        let reloadDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!

        let orderIndex = configuration.counter.orderIndex
        let location = configuration.mensa.location
        let includeOnlyVegan = Bool(truncating: configuration.vegan ?? 0)

        Task {
            var data: [Row] = []
            do {
                data = try await API.fetchRows()
            } catch {
                print(error)
            }
            let entry = MensaEntry(date: currentDate,
                                   location: location,
                                   counterOrder: orderIndex == .ignore ? nil : orderIndex,
                                   data: data,
                                   includeOnlyVegan: includeOnlyVegan,
                                   configuration: configuration)
            let timeline = Timeline(entries: [entry], policy: .after(reloadDate))
            completion(timeline)
        }
    }
}

// MARK: - MensaEntry

struct MensaEntry: TimelineEntry {
    var date: Date

    let location: Location
    var counterOrder: OrderIndex?
    let data: [Row]
    let includeOnlyVegan: Bool

    let configuration: ConfigurationIntent

    internal init(date: Date, location: Location, counterOrder: OrderIndex? = nil, data: [Row],
                  includeOnlyVegan: Bool = false, configuration: ConfigurationIntent) {
        self.date = date
        self.location = location
        self.counterOrder = counterOrder
        self.data = data
        self.includeOnlyVegan = includeOnlyVegan
        self.configuration = configuration
    }
}

// MARK: - Widget

struct MensaWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var widgetFamily

    func getDataForSupportedFamily() -> [Row] {
        // Filter data based on location and current date
        var data = self.entry.data.filter { row in
            let today = Calendar.current.startOfDay(for: entry.date)
            let targetDate = Calendar.current.startOfDay(for: row.date)
            return row.consumeLocation == self.entry.location && targetDate.timeIntervalSince(today) == 0
        }

        // Filter for vegan products if requested
        if self.entry.includeOnlyVegan {
            data = data.filter { $0.menuIndicators.contains("Vegan") }
        }

        // Sort based on the counter
        data.sort { (lhs, rhs) in
            if lhs.counter.orderIndex == rhs.counter.orderIndex {
                return lhs.counter.name < rhs.counter.name
            }
            return lhs.counter.orderIndex.rawValue < rhs.counter.orderIndex.rawValue
        }

        // Filter for specifc counters
        if let order = self.entry.counterOrder {
            data = data.filter { $0.counter.orderIndex == order }
        } else {
            data = data.filter { $0.counter.orderIndex != .ignore }
        }

        // Use a "Keine Ausgabe" placeholder if no data is found
        if data.isEmpty {
            let location = entry.location
            let counter = entry.counterOrder?.defaultCounter ?? .one(0)
            return [
                Row(location: location, consumeLocation: location, counter: counter, date: .now,
                    description: "Keine Ausgabe heute.")
            ]
        }

        // Only return the minimum amount of allowed rows depending on the widget family
        switch self.widgetFamily {
        case .systemSmall, .systemMedium:       return Array(data[safe: 0..<2])
        case .systemLarge, .systemExtraLarge:   return Array(data[safe: 0..<4])
        default:                                return data
        }
    }

    var body: some View {
        ZStack {
            // Create a green border around the widget
            Color(uiColor: .defaultGreen)

            VStack(alignment: .leading, spacing: 4) {

                let location = entry.location
                let data = self.getDataForSupportedFamily()
                let font = Font.system(size: 13)

                // Location Name
                Label(title: {
                    Text(location.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }, icon: {
                    Image(uiImage: location.icon!)
                        .renderingMode(.template)
                        .resizable()
                        .frame(width: 15.0, height: 15.0)
                }).foregroundColor(.init(uiColor: .defaultBlue))
                    .font(font.weight(.bold))
                    .lineLimit(1)
                    .padding([.bottom], 2)

                ForEach((0..<data.count), id:\.self) { i in
                    let row = data[i]
                    let lastRow = data[safe: i-1]
                    let insertTitle = row.counter.name != lastRow?.counter.name

                    if insertTitle {
                        // Counter name
                        Text(row.counter.name)
                            .font(font)
                            .foregroundColor(Color(uiColor: .defaultBlue))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        Divider()
                            .frame(height: 1.5)
                            .background(Color(uiColor: .defaultGreen))
                    }
                    // Food description
                    Text(row.description)
                        .foregroundColor(.secondary)
                        .font(font)
                    // Food price and additives
                    HStack(alignment: .top, spacing: 2) {
                        if let priceString = row.getPriceString() {
                            Text(priceString)
                                .font(font)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(uiColor: .tertiaryLabel))
                        }
                        Spacer()
                        Text(row.getAdditivesText(short: true))
                            .font(font)
                            .frame(maxWidth: 44, alignment: .trailing)
                    }
                }
                Spacer(minLength: 0)
            }.padding()
             .background(Color(uiColor: .defaultBackground))
             .clipShape(ContainerRelativeShape().inset(by: 4))
        }
    }
}

@main
struct MensaWidget: Widget {
    let kind: String = "MensaWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            MensaWidgetEntryView(entry: entry)
                .widgetURL(URL(string: "mensa://location/\(entry.location.rawValue)"))
        }
        .configurationDisplayName("Speiseplan")
        .description("Speiseplan der Mensa.")
    }
}

struct MensaWidget_Previews: PreviewProvider {
    static var previews: some View {
        MensaWidgetEntryView(entry: MensaEntry(
            date: Date(),
            location: kSnapshotLocation,
            data: kSnapshotData,
            configuration: ConfigurationIntent())
        ).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
