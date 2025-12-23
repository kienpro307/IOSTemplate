import SwiftUI

/// Button để show rewarded ad
public struct RewardedAdButton: View {
    @StateObject private var adManager = AdMobManager()

    let title: String
    let rewardDescription: String
    let onReward: (Int) -> Void

    public init(
        title: String = "Watch Ad",
        rewardDescription: String = "Get 100 coins",
        onReward: @escaping (Int) -> Void
    ) {
        self.title = title
        self.rewardDescription = rewardDescription
        self.onReward = onReward
    }

    public var body: some View {
        Button {
            showRewardedAd()
        } label: {
            HStack {
                Image(systemName: "play.circle.fill")

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)

                    Text(rewardDescription)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                if adManager.rewardedLoadState == .loading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "chevron.right")
                }
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [Color.purple, Color.blue],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(adManager.rewardedLoadState != .loaded)
        .onAppear {
            if !adManager.isInitialized {
                adManager.initialize()
            }
            adManager.loadRewardedAd()
        }
    }

    private func showRewardedAd() {
        adManager.showRewardedAd { success, amount in
            if success {
                onReward(amount)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RewardedAdButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            RewardedAdButton { amount in
                print("Rewarded: \(amount) coins")
            }
            .padding()
        }
    }
}
#endif
