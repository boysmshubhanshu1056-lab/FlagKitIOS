import SwiftUI

struct FlagEntry: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var value: String
    var enabled: Bool = true

    enum CodingKeys: String, CodingKey {
        case name, value, enabled
    }
}

struct FlagProfile: Codable {
    var profileName: String
    var createdAt: String
    var flags: [String: JSONValue]
}

// Small JSON value enum so exported flag values can be bool, number, or string.
enum JSONValue: Codable {
    case string(String)
    case number(Double)
    case bool(Bool)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(Bool.self) { self = .bool(value); return }
        if let value = try? container.decode(Double.self) { self = .number(value); return }
        self = .string(try container.decode(String.self))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value): try container.encode(value)
        case .number(let value): try container.encode(value)
        case .bool(let value): try container.encode(value)
        }
    }
}

struct ContentView: View {
    @State private var profileName = "My FPS Profile"
    @State private var flags: [FlagEntry] = [
        FlagEntry(name: "DFFlagTextureQualityOverrideEnabled", value: "true"),
        FlagEntry(name: "DFIntTextureQualityOverride", value: "0")
    ]
    @State private var newName = ""
    @State private var newValue = ""
    @State private var showExport = false
    @State private var exportText = ""
    @State private var showInfo = false

    private var enabledCount: Int { flags.filter(\.enabled).count }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Profile name", text: $profileName)
                    HStack {
                        Label("\(enabledCount) enabled", systemImage: "checkmark.circle")
                        Spacer()
                        Text("\(flags.count) total")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Profile")
                }

                Section {
                    ForEach($flags) { $flag in
                        VStack(alignment: .leading, spacing: 8) {
                            Toggle(isOn: $flag.enabled) {
                                Text(flag.name)
                                    .font(.system(.subheadline, design: .monospaced))
                                    .textSelection(.enabled)
                            }
                            TextField("Value (true, false, number, or text)", text: $flag.value)
                                .font(.system(.body, design: .monospaced))
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { flags.remove(atOffsets: $0) }
                } header: {
                    Text("Flags")
                } footer: {
                    Text("Swipe left on a flag to remove it. Flag names and values are not verified by Roblox.")
                }

                Section("Add flag") {
                    TextField("Flag name", text: $newName)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    TextField("Value (e.g. true, 0, or text)", text: $newValue)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Button {
                        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                        let value = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !name.isEmpty, !value.isEmpty,
                              !flags.contains(where: { $0.name == name }) else { return }
                        flags.append(FlagEntry(name: name, value: value))
                        newName = ""
                        newValue = ""
                    } label: {
                        Label("Add flag", systemImage: "plus.circle.fill")
                    }
                    .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                              newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                Section {
                    Button {
                        exportText = makeJSON()
                        showExport = true
                    } label: {
                        Label("Preview / Share JSON", systemImage: "square.and.arrow.up")
                    }

                    Button {
                        showInfo = true
                    } label: {
                        Label("What this app can do", systemImage: "info.circle")
                    }
                }
            }
            .navigationTitle("FlagKit iOS")
            .toolbar {
                EditButton()
            }
            .sheet(isPresented: $showExport) {
                NavigationStack {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exported profile JSON")
                            .font(.headline)
                        Text("This is a profile export only. It does not install or apply flags to Roblox on iPadOS.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                        ScrollView {
                            Text(exportText)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                                .padding()
                        }
                        ShareLink(item: exportText) {
                            Label("Share JSON text", systemImage: "square.and.arrow.up")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .navigationTitle("Export")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Done") { showExport = false }
                        }
                    }
                }
            }
            .alert("About FlagKit iOS", isPresented: $showInfo) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This starter app edits and exports a JSON profile. iPadOS sandboxing prevents a normal app from editing Roblox's private files or injecting custom FastFlags into the official Roblox app. Exported flags may be ignored by Roblox.")
            }
        }
    }

    private func makeJSON() -> String {
        var output: [String: JSONValue] = [:]
        for flag in flags where flag.enabled {
            let raw = flag.value.trimmingCharacters(in: .whitespacesAndNewlines)
            if raw.lowercased() == "true" {
                output[flag.name] = .bool(true)
            } else if raw.lowercased() == "false" {
                output[flag.name] = .bool(false)
            } else if let number = Double(raw) {
                output[flag.name] = .number(number)
            } else {
                output[flag.name] = .string(raw)
            }
        }

        let formatter = ISO8601DateFormatter()
        let profile = FlagProfile(
            profileName: profileName,
            createdAt: formatter.string(from: Date()),
            flags: output
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        guard let data = try? encoder.encode(profile),
              let json = String(data: data, encoding: .utf8) else {
            return "{ }"
        }
        return json
    }
}
