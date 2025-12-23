import SwiftUI
import UIKit

/// SwiftUI wrapper cho banner ads
/// Note: Requires Google Mobile Ads SDK
public struct BannerAdView: View {
    let adUnitID: String
    let adSize: BannerAdSize

    public init(
        adUnitID: String = AdMobConfiguration.bannerAdUnitID,
        adSize: BannerAdSize = .banner
    ) {
        self.adUnitID = adUnitID
        self.adSize = adSize
    }

    public var body: some View {
        BannerAdViewRepresentable(adUnitID: adUnitID, adSize: adSize)
            .frame(width: adSize.size.width, height: adSize.size.height)
    }
}

/// Banner ad sizes
public enum BannerAdSize {
    case banner           // 320x50
    case largeBanner      // 320x100
    case mediumRectangle  // 300x250
    case fullBanner       // 468x60
    case leaderboard      // 728x90
    case adaptive(width: CGFloat)

    var size: CGSize {
        switch self {
        case .banner:
            return CGSize(width: 320, height: 50)
        case .largeBanner:
            return CGSize(width: 320, height: 100)
        case .mediumRectangle:
            return CGSize(width: 300, height: 250)
        case .fullBanner:
            return CGSize(width: 468, height: 60)
        case .leaderboard:
            return CGSize(width: 728, height: 90)
        case .adaptive(let width):
            return CGSize(width: width, height: 50)
        }
    }
}

/// UIViewRepresentable for banner ad
struct BannerAdViewRepresentable: UIViewRepresentable {
    let adUnitID: String
    let adSize: BannerAdSize

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .systemGray6

        // Mock ad view
        let label = UILabel()
        label.text = "Banner Ad"
        label.textAlignment = .center
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        // Real implementation:
        // let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        // bannerView.adUnitID = adUnitID
        // bannerView.rootViewController = getRootViewController()
        // bannerView.load(GADRequest())
        // return bannerView

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // Update if needed
    }
}

// MARK: - Preview

#if DEBUG
struct BannerAdView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Content above")
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            BannerAdView()

            Text("Content below")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
#endif
