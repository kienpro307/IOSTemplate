// MARK: - Preview Templates
// Templates cho SwiftUI Previews - Code tiếng Anh, comment tiếng Việt

import SwiftUI
import ComposableArchitecture

// MARK: - Basic Preview
/// Preview mặc định
#Preview("Default") {
    FeatureNameView(
        store: Store(initialState: FeatureNameReducer.State()) {
            FeatureNameReducer()
        }
    )
}

// MARK: - Loading State Preview
/// Preview trạng thái đang tải
#Preview("Loading") {
    FeatureNameView(
        store: Store(
            initialState: FeatureNameReducer.State(loadingState: .loading)
        ) {
            FeatureNameReducer()
        }
    )
}

// MARK: - Loaded State Preview
/// Preview khi có dữ liệu
#Preview("With Data") {
    FeatureNameView(
        store: Store(
            initialState: FeatureNameReducer.State(
                items: Item.mockList,
                loadingState: .loaded
            )
        ) {
            FeatureNameReducer()
        }
    )
}

// MARK: - Error State Preview
/// Preview trạng thái lỗi
#Preview("Error") {
    FeatureNameView(
        store: Store(
            initialState: FeatureNameReducer.State(
                loadingState: .failed("Không thể tải dữ liệu"),
                error: "Không thể tải dữ liệu"
            )
        ) {
            FeatureNameReducer()
        }
    )
}

// MARK: - Preview with Mock Dependencies
/// Preview với mock dependencies
#Preview("Mock Dependencies") {
    FeatureNameView(
        store: Store(initialState: FeatureNameReducer.State()) {
            FeatureNameReducer()
        } withDependencies: {
            $0.itemService = MockItemService(items: Item.mockList)
        }
    )
}

// MARK: - Dark Mode Preview
/// Preview chế độ tối
#Preview("Dark Mode") {
    FeatureNameView(
        store: Store(
            initialState: FeatureNameReducer.State(
                items: Item.mockList,
                loadingState: .loaded
            )
        ) {
            FeatureNameReducer()
        }
    )
    .preferredColorScheme(.dark)
}
