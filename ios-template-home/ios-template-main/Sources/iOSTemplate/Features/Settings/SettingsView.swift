import SwiftUI
import ComposableArchitecture

/// Settings view - App configuration
public struct SettingsView: View {
    let store: StoreOf<AppReducer>

    public init(store: StoreOf<AppReducer>) {
        self.store = store
    }

    public var body: some View {
        List {
            // Account Section
            accountSection

            // Preferences Section
            preferencesSection

            // Notifications Section
            notificationsSection

            // About Section
            aboutSection

            // Danger Zone
            dangerZoneSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Sections

    private var accountSection: some View {
        Section("Account") {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                    .foregroundColor(.theme.primary)

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(store.user.profile?.name ?? "User")
                        .font(.theme.bodyLarge)
                        .foregroundColor(.theme.textPrimary)

                    Text(store.user.profile?.email ?? "")
                        .font(.theme.caption)
                        .foregroundColor(.theme.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.theme.textTertiary)
            }
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            // Theme
            Picker("Theme", selection: themeBinding) {
                Text("Auto").tag(ThemeMode.auto)
                Text("Light").tag(ThemeMode.light)
                Text("Dark").tag(ThemeMode.dark)
            }

            // Language
            NavigationLink {
                LanguageSettingsView(store: store)
            } label: {
                HStack {
                    Text("Language")
                    Spacer()
                    Text(store.user.preferences.languageCode.uppercased())
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
            SettingsRow(icon: "info.circle", title: "Version", value: store.config.appVersion)
            SettingsRow(icon: "number", title: "Build", value: store.config.buildNumber)

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

    private var dangerZoneSection: some View {
        Section("Danger Zone") {
            Button {
                store.send(AppAction.user(.logout))
            } label: {
                Label("Log Out", systemImage: "arrow.right.square")
                    .foregroundColor(.theme.warning)
            }

            Button(role: .destructive) {
                // Handle delete account
            } label: {
                Label("Delete Account", systemImage: "trash")
            }
        }
    }

    // MARK: - Bindings

    private var themeBinding: Binding<ThemeMode> {
        Binding(
            get: { store.user.preferences.themeMode },
            set: { store.send(AppAction.user(.changeThemeMode($0))) }
        )
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { store.user.preferences.notificationsEnabled },
            set: { store.send(AppAction.user(.toggleNotifications($0))) }
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
    let store: StoreOf<AppReducer>

    var body: some View {
        List {
            ForEach(["en", "vi", "es", "fr"], id: \.self) { lang in
                Button {
                    store.send(AppAction.user(.changeLanguage(lang)))
                } label: {
                    HStack {
                        Text(languageName(lang))
                        Spacer()
                        if store.user.preferences.languageCode == lang {
                            Image(systemName: "checkmark")
                                .foregroundColor(.theme.primary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Language")
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
    let store: StoreOf<AppReducer>

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
            store: Store(
                initialState: AppState(
                    user: UserState(
                        profile: UserProfile(
                            id: "123",
                            email: "john.doe@example.com",
                            name: "John Doe"
                        )
                    )
                )
            ) {
                AppReducer()
            }
        )
    }
}
