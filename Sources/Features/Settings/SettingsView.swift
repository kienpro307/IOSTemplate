import SwiftUI
import ComposableArchitecture
import UI

/// Settings view - App configuration
public struct SettingsView: View {
    @Perception.Bindable var store: StoreOf<SettingsReducer>

    public init(store: StoreOf<SettingsReducer>) {
        self.store = store
    }

    public var body: some View {
        WithPerceptionTracking {
            List {
                // Preferences Section
                preferencesSection

                // Notifications Section
                notificationsSection

                // About Section
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                store.send(.onAppear)
            }
        }
    }

    // MARK: - Sections

    private var preferencesSection: some View {
        Section("Preferences") {
            // Theme
            Picker("Theme", selection: themeBinding) {
                ForEach(ThemeMode.allCases, id: \.self) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }

            // Language
            NavigationLink {
                LanguageSettingsView(store: store)
            } label: {
                HStack {
                    Text("Language")
                    Spacer()
                    Text(store.preferences.languageCode.uppercased())
                        .foregroundColor(.theme.textSecondary)
                }
            }
        }
    }

    private var notificationsSection: some View {
        Section("Notifications") {
            Toggle("Push Notifications", isOn: notificationsBinding)

            NavigationLink("Notification Settings") {
                NotificationSettingsView(store: store)
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            SettingsRow(icon: "info.circle", title: "Version", value: store.appConfig.appVersion)
            SettingsRow(icon: "number", title: "Build", value: store.appConfig.buildNumber)

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            NavigationLink {
                TermsOfServiceView()
            } label: {
                Label("Terms of Service", systemImage: "doc.text")
            }

            Button {
                // Open support
            } label: {
                Label("Support", systemImage: "questionmark.circle")
            }
        }
    }

    // MARK: - Bindings

    private var themeBinding: Binding<ThemeMode> {
        Binding(
            get: { store.preferences.themeMode },
            set: { store.send(.changeThemeMode($0)) }
        )
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { store.preferences.notificationsEnabled },
            set: { store.send(.toggleNotifications($0)) }
        )
    }
}

// MARK: - Settings Row

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack {
            Label(title, systemImage: icon)
            Spacer()
            Text(value)
                .foregroundColor(.theme.textSecondary)
        }
    }
}

// MARK: - Placeholder Views

struct LanguageSettingsView: View {
    @Perception.Bindable var store: StoreOf<SettingsReducer>

    var body: some View {
        WithPerceptionTracking {
            List {
                ForEach(["en", "vi", "es", "fr"], id: \.self) { lang in
                    Button {
                        store.send(.changeLanguage(lang))
                    } label: {
                        HStack {
                            Text(languageName(lang))
                            Spacer()
                            if store.preferences.languageCode == lang {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.theme.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Language")
        }
    }

    private func languageName(_ code: String) -> String {
        switch code {
        case "en": return "English"
        case "vi": return "Tiếng Việt"
        case "es": return "Español"
        case "fr": return "Français"
        default: return code
        }
    }
}

struct NotificationSettingsView: View {
    let store: StoreOf<SettingsReducer>

    var body: some View {
        List {
            Text("Notification settings coming soon...")
                .foregroundColor(.theme.textSecondary)
        }
        .navigationTitle("Notifications")
    }
}

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text("Privacy Policy")
                .font(.theme.headlineLarge)
                .padding()

            Text("Your privacy policy content here...")
                .font(.theme.bodyMedium)
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            Text("Terms of Service")
                .font(.theme.headlineLarge)
                .padding()

            Text("Your terms of service content here...")
                .font(.theme.bodyMedium)
                .padding()
        }
        .navigationTitle("Terms of Service")
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SettingsView(
            store: Store(initialState: SettingsState()) {
                SettingsReducer()
            }
        )
    }
}

