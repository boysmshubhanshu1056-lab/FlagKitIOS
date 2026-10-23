
import SwiftUI

@main
struct CloudWinApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @AppStorage("cloudWinURL")
    private var cloudWinURL = ""

    @Environment(\.openURL) private var openURL
    @State private var message = ""

    private var validURL: URL? {
        guard let url = URL(string: cloudWinURL),
              url.scheme?.lowercased() == "https",
              url.host != nil else {
            return nil
        }
        return url
    }

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.07, blue: 0.14)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "desktopcomputer")
                    .font(.system(size: 58))
                    .foregroundStyle(.cyan)

                Text("CloudWin")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Text("Your Windows desktop,\none tap away.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.75))

                TextField(
                    "Remote desktop HTTPS address",
                    text: $cloudWinURL
                )
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding()
                .background(.white)
                .foregroundStyle(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button {
                    guard let url = validURL else {
                        message = "Enter a valid HTTPS address first."
                        return
                    }

                    openURL(url)
                } label: {
                    Label(
                        "LAUNCH WINDOWS",
                        systemImage: "power"
                    )
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.white)
                    .background(.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Text(
                    "A remote desktop service is required. " +
                    "CloudWin does not host Windows itself."
                )
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.65))
                .multilineTextAlignment(.center)

                if !message.isEmpty {
                    Text(message)
                        .font(.footnote)
                        .foregroundStyle(.orange)
                }

                Spacer()
            }
            .padding(24)
            .padding(.top, 35)
        }
        .preferredColorScheme(.dark)
    }
}
