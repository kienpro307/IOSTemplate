import SwiftUI
import ComposableArchitecture

/// Permission request view for onboarding
public struct PermissionRequestView: View {
    let store: StoreOf<AppReducer>
    let onComplete: () -> Void

    @State private var permissions: [PermissionItem] = []
    @State private var permissionManager = PermissionManager()

    public init(store: StoreOf<AppReducer>, onComplete: @escaping () -> Void) {
        self.store = store
        self.onComplete = onComplete
    }

    public var body: some View {
        VStack(spacing: Spacing.xl) {
            // Header
            VStack(spacing: Spacing.md) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.theme.primary)
                    .padding(.bottom, Spacing.md)

                Text("Enable Permissions")
                    .font(.theme.displaySmall)
                    .foregroundColor(.theme.textPrimary)

                Text("Allow permissions to get the best experience")
                    .font(.theme.body)
                    .foregroundColor(.theme.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Spacing.xxxl)

            // Permission list
            VStack(spacing: Spacing.md) {
                ForEach(permissions) { permission in
                    PermissionRow(
                        permission: permission,
                        onRequest: {
                            await requestPermission(permission)
                        }
                    )
                }
            }
            .padding(.top, Spacing.xl)

            Spacer()

            // Continue button
            VStack(spacing: Spacing.sm) {
                Button {
                    onComplete()
                } label: {
                    Text(allPermissionsGranted ? "Get Started" : "Continue")
                        .frame(maxWidth: .infinity)
                        .padding(Spacing.md)
                        .background(Color.theme.primary)
                        .foregroundColor(.white)
                        .cornerRadius(CornerRadius.md)
                }

                if !allPermissionsGranted {
                    Button {
                        onComplete()
                    } label: {
                        Text("Skip for Now")
                            .font(.theme.body)
                            .foregroundColor(.theme.textSecondary)
                    }
                    .padding(.top, Spacing.xs)
                }
            }
            .padding(.bottom, Spacing.xl)
        }
        .padding(Spacing.xl)
        .background(Color.theme.background)
        .onAppear {
            setupPermissions()
        }
    }

    // MARK: - Computed Properties

    private var allPermissionsGranted: Bool {
        permissions.allSatisfy { $0.isGranted }
    }

    // MARK: - Setup

    private func setupPermissions() {
        permissions = [
            PermissionItem(
                type: .notifications,
                isRequired: false
            ),
            PermissionItem(
                type: .camera,
                isRequired: false
            ),
            PermissionItem(
                type: .photoLibrary,
                isRequired: false
            )
        ]
    }

    // MARK: - Actions

    @MainActor
    private func requestPermission(_ permission: PermissionItem) async {
        guard let index = permissions.firstIndex(where: { $0.id == permission.id }) else {
            return
        }

        permissions[index].isRequesting = true

        do {
            var granted = false

            switch permission.type {
            case .notifications:
                granted = try await permissionManager.requestNotificationPermission()
            case .camera:
                granted = try await permissionManager.requestCameraPermission()
            case .photoLibrary:
                granted = try await permissionManager.requestPhotoLibraryPermission()
            case .location:
                granted = try await permissionManager.requestLocationPermission()
            case .tracking:
                granted = try await permissionManager.requestTrackingPermission()
            }

            permissions[index].isGranted = granted
        } catch {
            print("Permission request failed: \(error)")
        }

        permissions[index].isRequesting = false
    }
}

// MARK: - Permission Item

struct PermissionItem: Identifiable {
    let id = UUID()
    let type: PermissionType
    let isRequired: Bool
    var isGranted: Bool = false
    var isRequesting: Bool = false
}

// MARK: - Permission Row

struct PermissionRow: View {
    let permission: PermissionItem
    let onRequest: () async -> Void

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Icon
            Image(systemName: permission.type.icon)
                .font(.title2)
                .foregroundColor(.theme.primary)
                .frame(width: 44, height: 44)
                .background(Color.theme.primary.opacity(0.1))
                .cornerRadius(CornerRadius.md)

            // Content
            VStack(alignment: .leading, spacing: Spacing.xs) {
                HStack {
                    Text(permission.type.title)
                        .font(.theme.bodyLargeBold)
                        .foregroundColor(.theme.textPrimary)

                    if permission.isRequired {
                        Text("Required")
                            .font(.theme.caption)
                            .foregroundColor(.theme.error)
                            .padding(.horizontal, Spacing.xs)
                            .padding(.vertical, 2)
                            .background(Color.theme.error.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                }

                Text(permission.type.description)
                    .font(.theme.caption)
                    .foregroundColor(.theme.textSecondary)
                    .lineLimit(2)
            }

            Spacer()

            // Action button
            if permission.isGranted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.theme.success)
            } else if permission.isRequesting {
                ProgressView()
            } else {
                Button {
                    Task {
                        await onRequest()
                    }
                } label: {
                    Text("Allow")
                        .font(.theme.captionBold)
                        .foregroundColor(.white)
                        .padding(.horizontal, Spacing.md)
                        .padding(.vertical, Spacing.xs)
                        .background(Color.theme.primary)
                        .cornerRadius(CornerRadius.sm)
                }
            }
        }
        .padding(Spacing.md)
        .background(Color.theme.backgroundSecondary)
        .cornerRadius(CornerRadius.md)
    }
}

// MARK: - Preview

#Preview {
    PermissionRequestView(
        store: Store(
            initialState: AppState()
        ) {
            AppReducer()
        },
        onComplete: {
            print("Permissions completed")
        }
    )
}
