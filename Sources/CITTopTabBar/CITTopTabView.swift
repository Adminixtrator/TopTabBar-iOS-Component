//
//  CITTopTabView.swift
//  
//  MIT License
//
//  Copyright (c) 2022 Coffee IT
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import SwiftUI

/// The CITTopTabView is not meant for direct use. Please use the CITTopTabBarView for optimal results.
/// Mulitple instances of CITTopTabView will be displayed based on the amount of tabs passed to the CITTopTabBarView.
/// This class is still made public so it can be previewed using the Canvas if desired.
public struct CITTopTabView: View {
    public let index: Int
    public let item: CITTopTab
    public let config: CITTopTabBarView.Configuration
    public let tabsHaveAnyIcon: Bool
    public let namespace: Namespace.ID
    @Binding public var selectedTab: Int
    
    @State private var calculatedBackgroundHeight: CGFloat = 0
    
    var isSelected: Bool {
        index == selectedTab
    }
    
    var textColor: Color {
        isSelected ? config.selectedTextColor : config.textColor
    }
    
    var iconColors: (selected: Color, unselected: Color) {
        item.iconColors(in: config)
    }
    
    public var body: some View {
        Button {
            selectedTab = index
        } label: {
            ZStack {
                optionalFullSizeBackground
                
                VStack(spacing: 0) {
                    ZStack {
                        optionalContentBackground
                        content
                            .padding(config.tabContentInsets)
                            .background(optionalContentSizeReader)
                    }
                    optionalUnderline
                }
                .padding(isSelected ? config.selectedInsets : CITEdgeInsets.zero)
            }
            .animation(config.tabAnimation, value: $selectedTab.wrappedValue)
            .background(optionalFullSizeReader)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.title)
    }
    
    var content: some View {
        VStack(spacing: config.spacingBelowIcon) {
            optionalIcon
            
            HStack(spacing: config.titleToBadgeSpacing) {
                if let badge = item.badge, badge.style.position == .leading {
                    CITNotificationBadgeView(badge: badge)
                }
                
                Text(item.title)
                    .font(config.font)
                    .foregroundColor(.white)
                    .colorMultiply(textColor)
                    .animation(config.textAnimation)
                
                if let badge = item.badge, badge.style.position == .trailing {
                    CITNotificationBadgeView(badge: badge)
                }
            }
        }
    }
    
    // MARK: - Icon
    
    @ViewBuilder
    var optionalIcon: some View {
        if let icon = item.icon {
            icon.resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: config.iconSize.width, height: config.iconSize.height)
                .foregroundColor(isSelected ? iconColors.selected : iconColors.unselected)
        } else if tabsHaveAnyIcon {
            Color.clear
                .frame(width: config.iconSize.width, height: config.iconSize.height)
        }
    }
    
    
    // MARK: - Underline
    
    @ViewBuilder
    var optionalUnderline: some View {
        if isSelected && config.showUnderline {
            config.underlineColor
                .frame(height: config.underlineHeight)
                .cornerRadius(config.underlineCornerRadius)
                .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                .padding(config.underlineInsets)
        } else {
            Color.clear
                .frame(height: config.underlineHeight)
                .padding(config.underlineInsets)
        }
    }
    
    // MARK: - Background logic
    
    /// The following logic handles how the selected background is shown.
    /// - optionalFullSizeBackground: Encapsulates content and underline.
    /// - optionalContentBackground: Encapsulates only the content.
    ///
    /// The reason we use optional view with manual height calculation instead of simply using .background(color)
    /// is that "matchedGeometryEffect" does not work in a .background modifier at this point in time. iOS 14-16.
    /// Color fills its given size by default, and if unrestrained, will make the TopTabView much larger than it should be.
    ///
    /// To get the correct height, we use GeometryReader on invisible views.
    /// If selected and has an underline, the proxy height will be the correct size.
    /// For the unselected items, we add the vertical inset to keep the height equal for all tabs.
    /// The result is a smooth transition of the selectedBackground when switching tabs.
    ///

    @ViewBuilder
    var optionalFullSizeBackground: some View {
        if config.showUnderline {
            optionalBackground
        }
    }
    
    
    @ViewBuilder
    var optionalContentBackground: some View {
        if !config.showUnderline {
            optionalBackground
        }
    }
    
    @ViewBuilder
    var optionalBackground: some View {
        if isSelected {
            config.selectedBackgroundColor
                .frame(height: calculatedBackgroundHeight)
                .cornerRadius(config.selectedBackgroundCornerRadius)
                .padding(config.selectedBackgroundInsets)
                .matchedGeometryEffect(id: "background", in: namespace)
        }
    }
    
    @ViewBuilder
    var optionalFullSizeReader: some View {
        if config.showUnderline {
            reader
        }
    }
    
    @ViewBuilder
    var optionalContentSizeReader: some View {
        if !config.showUnderline {
            reader
        }
    }
    
    var reader: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    calculatedBackgroundHeight = isSelected && config.showUnderline ? proxy.size.height : proxy.size.height + config.verticalSelectedInset
                }
        }
    }
}

public struct CITTopTabView_Previews: PreviewProvider {
    @Namespace static var namespace
    
    public static var previews: some View {
        CITTopTabView(index: 0, item: .init(title: "Tab One"), config: .examplePillShaped, tabsHaveAnyIcon: false, namespace: namespace, selectedTab: .constant(0))
    }
}
