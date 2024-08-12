// The Swift Programming Language
// https://docs.swift.org/swift-book
import SwiftUI
import Foundation

@available(iOS 17.0.0, *)
public struct CustomTabBarView: View {
    @Binding var selectedTab: Int
    let tabItems: [TabItem]
    var configuration: TabbarConfig = TabbarConfig(bgColor: .gray.opacity(0.4),
                                                   tintColor: .red, circleColor: (bg: .cyan, border: .white, lineWidth: 2))
    
    @State private var selectedItem: Int = 1
    @State private var showCircle: Bool = true
    public var body: some View {
        GeometryReader { proxy in
            ZStack {
                let position = getCirclePosition(frame: proxy.size)
                HStack() {
                    ForEach(tabItems, id: \.tag) { item in
                        TabbarItem(item: item,
                                   selectedItem: $selectedItem,
                                   showCircle: $showCircle,
                                   configuration: configuration)
                        .frame(maxWidth: .infinity)
                        .onTapGesture {
                            self.showCircle = false
                            self.selectedTab = item.tag
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                                self.showCircle = true
                                self.selectedItem = self.selectedTab
                            }
                        }
                    }
                }
                .background(configuration.bgColor)
                Circle()
                    .size(CGSize(width: 50, height: 50))
                    .fill(configuration.circleColor.bg)
                    .stroke(configuration.circleColor.border, lineWidth: configuration.circleColor.lineWidth)
                    .offset(x: position.x,
                            y: -25)
                    .animation(Animation.linear(duration: 0.5), value: selectedTab)
                    .opacity(selectedItem == selectedTab ? 0: 1)
            }
            .frame(height: 68)
        }
    }

    func getCirclePosition(frame: CGSize) -> (x: CGFloat, y: CGFloat) {
        let chosenTab = CGFloat(selectedTab)
        let singleItemWidth = frame.width / itemCount
        let itemWidth = singleItemWidth * chosenTab
        let itemCenter = (itemWidth - singleItemWidth) + ((singleItemWidth/2) - 25)
        return (x: itemCenter, y: -6)
    }
    
    var itemCount: CGFloat {
        CGFloat(tabItems.count)
    }
}

@available(iOS 17.0.0, *)
public struct TabbarItem: View {
    let item: TabItem
    @Binding var selectedItem: Int
    @Binding var showCircle: Bool
    var configuration: TabbarConfig = TabbarConfig(bgColor: .gray.opacity(0.4),
                                                   tintColor: .red, circleColor: (bg: .cyan, border: .white, lineWidth: 2))
    public var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 8) {
                ZStack {
                    let position = itemPosition(proxy: proxy.frame(in: .local))
                    Circle()
                        .size(CGSize(width: 50, height: 50))
                        .fill(configuration.circleColor.bg)
                        .stroke(configuration.circleColor.border, lineWidth: configuration.circleColor.lineWidth)
                        .offset(x: position.x,
                                y: position.y)
                        .opacity(isTabSelected ? 1: 0)
                    if let systemIcon = self.getSystemImage() {
                        
                        Image(systemName: systemIcon)
                            .renderingMode(.template)
                            .offset(y: isTabSelected ? -25: 0)
                            .foregroundStyle(isTabSelected ? configuration.tintColor: .black)
                            .animation(Animation.linear(duration: 0.2), value: selectedItem)

                    } else if let customIcon = getCustomImage() {
                        Image(customIcon)
                            .renderingMode(.template)
                            .offset(y: isTabSelected ? -25: 0)
                            .foregroundStyle(isTabSelected ? configuration.tintColor: .black)
                            .animation(Animation.linear(duration: 0.2), value: selectedItem)

                    }
                }
                Text(item.name)
                    .font(isTabSelected ? .footnote: .caption)
                    .bold(isTabSelected ? true: false)
                    .foregroundStyle(isTabSelected ? configuration.tintColor: .black)
            }
            .padding(.vertical)
        }
    }
    
    func itemPosition(proxy: CGRect) -> (x: CGFloat, y: CGFloat) {
        isTabSelected ? (x: proxy.width/2 - 25, y: -40): (x: proxy.width/2 - 25, y: 0)
    }
    
    var isTabSelected: Bool {
        item.tag == selectedItem && showCircle
    }
    
    func getSystemImage() -> String? {
        isTabSelected ? item.systemImage?.selected: item.systemImage?.unSelected
    }
    
    func getCustomImage() -> String? {
        isTabSelected ? item.customImage?.selected: item.customImage?.unSelected
    }
}

struct TabItem {
    let name: String
    let systemImage: (selected: String, unSelected: String)?
    let customImage: (selected: String, unSelected: String)?
    let tag: Int
    
    static let allTabItems = [
        TabItem(name: "Home", systemImage: (selected: "house.fill", unSelected: "house"), customImage: nil, tag: 1),
        TabItem(name: "Folder", systemImage: (selected: "folder.fill", unSelected: "folder"), customImage: nil, tag: 2),
        TabItem(name: "Calendar", systemImage: (selected: "calendar.circle.fill", unSelected: "calendar"), customImage: nil, tag: 3),
        TabItem(name: "Calendar", systemImage: (selected: "calendar.circle.fill", unSelected: "calendar"), customImage: nil, tag: 4),
        TabItem(name: "Bookmark", systemImage: (selected: "bookmark.fill", unSelected: "bookmark"), customImage: nil, tag: 5)
    ]
}

@available(iOS 17.0.0, *)
public struct TabbarConfig {
    let bgColor: Color
    let tintColor: Color
    let circleColor: (bg: Color, border: Color, lineWidth: CGFloat)
}

