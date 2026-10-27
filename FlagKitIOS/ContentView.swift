import SwiftUI

private enum Theme {
    static let background = Color(red: 0.035, green: 0.03, blue: 0.05)
    static let sidebar = Color(red: 0.055, green: 0.047, blue: 0.07)
    static let panel = Color(red: 0.085, green: 0.075, blue: 0.105)
    static let panel2 = Color(red: 0.115, green: 0.09, blue: 0.14)
    static let purple = Color(red: 0.61, green: 0.31, blue: 0.91)
    static let lavender = Color(red: 0.78, green: 0.57, blue: 1.0)
    static let accent = Color(red: 0.68, green: 0.20, blue: 0.48)
    static let text = Color(red: 0.91, green: 0.89, blue: 0.94)
    static let muted = Color(red: 0.62, green: 0.58, blue: 0.67)
    static let border = Color.white.opacity(0.09)
}

private enum AppPage: String, CaseIterable, Identifiable {
    case integrations = "Integrations"
    case behavior = "Behavior"
    case fastFlags = "FastFlags"
    case mods = "Mods"
    case appearance = "Appearance"
    case misc = "Misc"
    case info = "Info"
    var id: String { rawValue }
    var icon: String {
        switch self {
        case .integrations: return "link"
        case .behavior: return "square.dashed"
        case .fastFlags: return "flag.fill"
        case .mods: return "puzzlepiece.extension.fill"
        case .appearance: return "paintbrush.pointed.fill"
        case .misc: return "wrench.and.screwdriver.fill"
        case .info: return "info.circle.fill"
        }
    }
    var subtitle: String {
        switch self {
        case .integrations: return "Configure integrations and activity display"
        case .behavior: return "Roblox application settings and launcher behavior"
        case .fastFlags: return "Advanced engine and interface preferences"
        case .mods: return "Custom textures and interface enhancements"
        case .appearance: return "Personalize the look of the launcher"
        case .misc: return "Extra tools and convenience options"
        case .info: return "About this independent project"
        }
    }
}

struct ContentView: View {
    @Environment(\.openURL) private var openURL
    @State private var selectedPage: AppPage = .fastFlags
    @State private var unlockFPS = false
    @State private var graphicsAPI = "Default"
    @State private var lighting = "Default"
    @State private var disableShadows = false
    @State private var separateQuality = false
    @State private var quality = 5.0
    @State private var visualEffects = true
    @State private var textureQuality = "Default"
    @State private var serverLocation = true
    @State private var enableSDK = true
    @State private var discordRPC = true
    @State private var richPresence = true
    @State private var gameActivity = true
    @State private var delegateLaunch = true
    @State private var returnToWebsite = false
    @State private var exitWhenClosed = false
    @State private var disableDesktop = false
    @State private var multiInstance = false
    @State private var enableMods = true
    @State private var legacyResolution = false
    @State private var animations = true
    @State private var compactUI = false
    @State private var toast = ""

    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                sidebar
                    .frame(width: geo.size.width < 700 ? 158 : 205)
                Rectangle().fill(Theme.border).frame(width: 1)
                VStack(spacing: 0) {
                    titleBar
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            pageBody
                        }
                        .padding(.horizontal, geo.size.width < 700 ? 16 : 24)
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .background(Theme.background)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Theme.border, lineWidth: 1))
            .padding(geo.size.width < 700 ? 6 : 16)
            .background(Color.black.ignoresSafeArea())
        }
        .overlay(alignment: .top) {
            if !toast.isEmpty {
                Text(toast).font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Theme.panel2, in: Capsule())
                    .overlay(Capsule().stroke(Theme.purple.opacity(0.65)))
                    .padding(.top, 14)
            }
        }
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("FlagKit")
                .font(.system(size: 23, weight: .heavy, design: .rounded))
                .foregroundStyle(Theme.accent)
                .padding(.horizontal, 15).padding(.top, 25).padding(.bottom, 17)
            Rectangle().fill(Theme.border).frame(height: 1).padding(.horizontal, 10)
            VStack(spacing: 3) {
                ForEach(AppPage.allCases) { item in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) { selectedPage = item }
                    } label: {
                        HStack(spacing: 11) {
                            Image(systemName: item.icon).font(.system(size: 13, weight: .semibold)).frame(width: 15)
                            Text(item.rawValue).font(.system(size: 12, weight: selectedPage == item ? .semibold : .medium))
                                .lineLimit(1)
                            Spacer(minLength: 0)
                        }
                        .foregroundStyle(selectedPage == item ? Theme.accent : Theme.text.opacity(0.84))
                        .padding(.horizontal, 12).padding(.vertical, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(selectedPage == item ? Theme.panel2 : Color.clear, in: RoundedRectangle(cornerRadius: 7))
                    }.buttonStyle(.plain)
                }
            }.padding(.horizontal, 8).padding(.top, 10)
            Spacer(minLength: 12)
            Text("v0.1.0 • iOS")
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .foregroundStyle(Theme.muted)
                .frame(maxWidth: .infinity).padding(.bottom, 12)
            Button(action: launchRoblox) {
                HStack(spacing: 7) {
                    Image(systemName: "play.fill").font(.system(size: 11, weight: .black))
                    Text("Play Roblox").font(.system(size: 12, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(LinearGradient(colors: [Theme.purple, Theme.accent], startPoint: .topLeading, endPoint: .bottomTrailing), in: RoundedRectangle(cornerRadius: 7))
            }.buttonStyle(.plain).padding(.horizontal, 10).padding(.bottom, 12)
        }
        .background(Theme.sidebar)
    }

    private var titleBar: some View {
        HStack(spacing: 8) {
            Circle().fill(Color(red: 1, green: 0.35, blue: 0.39)).frame(width: 8, height: 8)
            Circle().fill(Color(red: 1, green: 0.72, blue: 0.25)).frame(width: 8, height: 8)
            Circle().fill(Color.white.opacity(0.2)).frame(width: 8, height: 8)
            Spacer()
            Text("FlagKit").font(.system(size: 11, weight: .semibold)).foregroundStyle(Theme.muted)
            Spacer()
            Image(systemName: "ellipsis").font(.system(size: 14, weight: .bold)).foregroundStyle(Theme.muted)
        }
        .padding(.horizontal, 12).frame(height: 30)
        .background(Theme.panel.opacity(0.75))
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.border).frame(height: 1) }
    }

    @ViewBuilder private var pageBody: some View {
        switch selectedPage {
        case .fastFlags: fastFlagsPage
        case .behavior: behaviorPage
        case .integrations: integrationsPage
        case .mods: modsPage
        case .appearance: appearancePage
        case .misc: miscPage
        case .info: infoPage
        }
    }

    private var fastFlagsPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Fast Flags", subtitle: selectedPage.subtitle)
            sectionTitle("Graphics Engine", subtitle: "Core graphics and performance preferences")
            settingRow("Unlock FPS", detail: "Target higher frame rates where supported", value: $unlockFPS)
            choiceRow("Graphics API", detail: "Select rendering backend", value: $graphicsAPI, options: ["Default", "Vulkan", "OpenGL", "Metal"])
            choiceRow("Lighting Technology", detail: "Choose a lighting preference", value: $lighting, options: ["Default", "Voxel", "ShadowMap", "Future"])
            settingRow("Disable Voxel Shadows", detail: "Prefer fewer shadows in supported settings", value: $disableShadows)
            settingRow("Separate Quality & Distance", detail: "Expose separate graphics-quality preferences", value: $separateQuality)
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Graphics Quality").font(.system(size: 12, weight: .semibold))
                        Text("Preferred quality level").font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.muted)
                    }
                    Spacer()
                    Text("\(Int(quality))").font(.system(size: 12, design: .monospaced)).foregroundStyle(Theme.text)
                }
                Slider(value: $quality, in: 1...10, step: 1).tint(Theme.accent).disabled(!separateQuality).opacity(separateQuality ? 1 : 0.45)
            }.padding(.vertical, 3)
            settingRow("Visual Effects", detail: "Prefer visual effects where available", value: $visualEffects)
            choiceRow("Texture Quality", detail: "Preferred texture detail", value: $textureQuality, options: ["Default", "Low", "Medium", "High"])
            disclaimer
        }
    }

    private var behaviorPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Roblox", subtitle: selectedPage.subtitle)
            sectionTitle("Multiple Instances", subtitle: "Launcher preferences")
            HStack(spacing: 8) {
                actionButton("Enable Multi-Instance", icon: "rectangle.on.rectangle", prominent: true) { multiInstance = true; notify("Preference enabled") }
                actionButton("New Instance", icon: "plus.square", prominent: false) { notify("Roblox launch requested") }
            }
            actionButton("Close All", icon: "xmark.app.fill", prominent: false) { notify("iOS does not allow this app to close Roblox") }
            sectionTitle("Launcher Behavior", subtitle: "Choose what this app should remember")
            settingRow("Delegate launching", detail: "Open Roblox when you press Play", value: $delegateLaunch)
            settingRow("Return to website", detail: "Open Roblox website when leaving a game", value: $returnToWebsite)
            settingRow("Exit FlagKit when Roblox closes", detail: "Close this interface automatically", value: $exitWhenClosed)
            settingRow("Disable desktop app", detail: "Desktop-only preference; no effect on iOS", value: $disableDesktop)
            disclaimer
        }
    }

    private var integrationsPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Integrations", subtitle: selectedPage.subtitle)
            sectionTitle("Game Activity", subtitle: "In-game information display")
            settingRow("Server Location", detail: "Display server geographic location when available", value: $serverLocation)
            sectionTitle("Launcher SDK", subtitle: "Integration compatibility preferences")
            settingRow("Enable SDK", detail: "Enable integration compatibility options", value: $enableSDK)
            settingRow("Discord RPC Control", detail: "Allow game activity to customize presence", value: $discordRPC)
            sectionTitle("Discord Rich Presence", subtitle: "Show your Roblox activity on Discord")
            settingRow("Enable Rich Presence", detail: "Display game activity on profile", value: $richPresence)
            settingRow("Game Activity", detail: "Show which game you're currently playing", value: $gameActivity)
            infoNote("Discord integration is a future placeholder in this iOS prototype.")
        }
    }

    private var modsPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Mods", subtitle: selectedPage.subtitle)
            sectionTitle("Built-in", subtitle: "Default interface preferences")
            settingRow("Enable Mods", detail: "Preference for supported mod systems", value: $enableMods)
            settingRow("Legacy Resolution", detail: "Use lower-resolution assets where supported", value: $legacyResolution)
            sectionTitle("Custom Mods", subtitle: "Mod file support is not implemented yet")
            infoNote("The iOS app cannot install desktop Roblox mods or write to Roblox's private app files. File import and a mod manager can be added later where iOS permits.")
            actionButton("Installation Guide", icon: "book.closed", prominent: false) { notify("Guide page planned for a future version") }
        }
    }

    private var appearancePage: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Appearance", subtitle: selectedPage.subtitle)
            sectionTitle("Interface", subtitle: "Dark purple and black")
            settingRow("Animations", detail: "Use subtle interface transitions", value: $animations)
            settingRow("Compact UI", detail: "Reduce spacing in the settings layout", value: $compactUI)
            sectionTitle("Accent Preview", subtitle: "Current theme")
            HStack(spacing: 10) {
                swatch("Purple", color: Theme.purple)
                swatch("Lavender", color: Theme.lavender)
                swatch("Magenta", color: Theme.accent)
                swatch("Black", color: Theme.background)
            }
            infoNote("The dark purple palette is applied throughout the current interface. Additional theme switching can be added later.")
        }
    }

    private var miscPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Misc", subtitle: selectedPage.subtitle)
            sectionTitle("Utilities", subtitle: "Small convenience actions")
            actionButton("Open Roblox", icon: "play.fill", prominent: true, action: launchRoblox)
            actionButton("Open Roblox Website", icon: "safari", prominent: false) {
                if let url = URL(string: "https://www.roblox.com/home") { openURL(url) }
            }
            actionButton("Reset UI preferences", icon: "arrow.counterclockwise", prominent: false) {
                unlockFPS = false; graphicsAPI = "Default"; lighting = "Default"; disableShadows = false
                separateQuality = false; quality = 5; visualEffects = true; textureQuality = "Default"
                notify("UI preferences reset")
            }
            disclaimer
        }
    }

    private var infoPage: some View {
        VStack(alignment: .leading, spacing: 18) {
            heading("Info", subtitle: selectedPage.subtitle)
            sectionTitle("FlagKit iOS", subtitle: "Version 0.1.0 • Prototype")
            infoNote("An independent iPad-friendly launcher-style interface inspired by desktop Roblox configuration tools. It is not affiliated with Roblox, AppleBlox, or Bloxstrap.")
            infoNote("This build focuses on the UI and a working Play button. FastFlag controls are UI preferences only and do not apply settings to Roblox yet.")
            infoNote("On a non-jailbroken iPad, iOS app sandboxing prevents this app from injecting code into Roblox or editing its private files.")
        }
    }

    private var disclaimer: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(Color.orange)
            Text("UI prototype only: these settings do not modify Roblox or guarantee FPS changes on iOS.")
                .font(.system(size: 10, design: .monospaced)).foregroundStyle(Color.orange.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }.padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.orange.opacity(0.07), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.orange.opacity(0.16)))
    }

    private func heading(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title).font(.system(size: 29, weight: .bold, design: .rounded)).foregroundStyle(Theme.text)
            Text(subtitle).font(.system(size: 11, design: .monospaced)).foregroundStyle(Theme.muted)
        }.padding(.bottom, 2)
    }

    private func sectionTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.system(size: 16, weight: .bold, design: .rounded)).foregroundStyle(Theme.accent)
            Text(subtitle).font(.system(size: 10, design: .monospaced)).foregroundStyle(Color(red: 0.57, green: 0.43, blue: 0.54))
            Rectangle().fill(Theme.border).frame(height: 1).padding(.top, 7)
        }
    }

    private func settingRow(_ title: String, detail: String, value: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.text)
                Text(detail).font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            Toggle("", isOn: value).labelsHidden().tint(Theme.accent).scaleEffect(0.83, anchor: .trailing)
                .frame(width: 42)
        }.padding(.vertical, 9)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.border).frame(height: 1) }
    }

    private func choiceRow(_ title: String, detail: String, value: Binding<String>, options: [String]) -> some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 12, weight: .semibold)).foregroundStyle(Theme.text)
                Text(detail).font(.system(size: 10, design: .monospaced)).foregroundStyle(Theme.muted)
            }
            Spacer(minLength: 5)
            Menu {
                ForEach(options, id: \.self) { option in
                    Button(option) { value.wrappedValue = option }
                }
            } label: {
                HStack(spacing: 8) {
                    Text(value.wrappedValue).font(.system(size: 11, design: .monospaced))
                    Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
                }.foregroundStyle(Theme.text).padding(.horizontal, 11).padding(.vertical, 9)
                    .background(Theme.panel2, in: RoundedRectangle(cornerRadius: 6))
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border))
            }
        }.padding(.vertical, 9)
        .overlay(alignment: .bottom) { Rectangle().fill(Theme.border).frame(height: 1) }
    }

    private func actionButton(_ title: String, icon: String, prominent: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Label(title, systemImage: icon).font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Theme.text)
                .padding(.horizontal, 12).padding(.vertical, 10)
                .background(prominent ? Theme.accent : Theme.panel2, in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.border))
        }.buttonStyle(.plain)
    }

    private func infoNote(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: "info.circle.fill").foregroundStyle(Theme.purple)
            Text(text).font(.system(size: 11, design: .monospaced)).foregroundStyle(Theme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }.padding(13).frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.panel, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Theme.border))
    }

    private func swatch(_ name: String, color: Color) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 7).fill(color).frame(height: 35)
                .overlay(RoundedRectangle(cornerRadius: 7).stroke(.white.opacity(0.12)))
            Text(name).font(.system(size: 9, weight: .medium)).foregroundStyle(Theme.muted)
        }.frame(maxWidth: .infinity)
    }

    private func launchRoblox() {
        guard let appURL = URL(string: "roblox://") else { return }
        openURL(appURL) { result in
            switch result {
            case .handled:
                notify("Opening Roblox…")
            case .discarded, .systemAction(_):
                if let webURL = URL(string: "https://www.roblox.com/home") {
                    openURL(webURL)
                }
            @unknown default:
                if let webURL = URL(string: "https://www.roblox.com/home") {
                    openURL(webURL)
                }
            }
        }
    }

    private func notify(_ message: String) {
        withAnimation(.easeInOut(duration: 0.15)) { toast = message }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.15)) { toast = "" }
        }
    }
}
