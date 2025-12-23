#!/bin/bash

# Script để upload dSYM files lên Firebase Crashlytics
# Script này sẽ được chạy trong Xcode Build Phases sau khi build

# Lấy GoogleService-Info.plist path
GOOGLE_SERVICE_INFO_PLIST="${PROJECT_DIR}/${PRODUCT_NAME}/GoogleService-Info.plist"

# Kiểm tra file GoogleService-Info.plist có tồn tại không
if [ ! -f "$GOOGLE_SERVICE_INFO_PLIST" ]; then
    echo "⚠️ Warning: GoogleService-Info.plist not found at $GOOGLE_SERVICE_INFO_PLIST"
    echo "⚠️ Skipping dSYM upload. Please add GoogleService-Info.plist to your project."
    exit 0
fi

# Lấy Google App ID từ plist
GOOGLE_APP_ID=$(/usr/libexec/PlistBuddy -c "Print :GOOGLE_APP_ID" "$GOOGLE_SERVICE_INFO_PLIST" 2>/dev/null)

if [ -z "$GOOGLE_APP_ID" ]; then
    echo "⚠️ Warning: Could not find GOOGLE_APP_ID in GoogleService-Info.plist"
    echo "⚠️ Skipping dSYM upload."
    exit 0
fi

# Path đến dSYM file
DSYM_PATH="${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}"

# Kiểm tra dSYM file có tồn tại không
if [ ! -d "$DSYM_PATH" ]; then
    echo "⚠️ Warning: dSYM file not found at $DSYM_PATH"
    echo "⚠️ Skipping dSYM upload."
    exit 0
fi

# Path đến upload-symbols script từ Firebase SDK
# Firebase SDK sẽ được install qua SPM, script nằm trong .build/checkouts
FIREBASE_UPLOAD_SCRIPT=$(find "${PROJECT_DIR}/.build/checkouts/firebase-ios-sdk" -name "upload-symbols" -type f | head -1)

if [ -z "$FIREBASE_UPLOAD_SCRIPT" ]; then
    # Fallback: tìm trong DerivedData (nếu build bằng Xcode)
    FIREBASE_UPLOAD_SCRIPT=$(find "${BUILD_DIR}" -name "upload-symbols" -type f | head -1)
fi

if [ -z "$FIREBASE_UPLOAD_SCRIPT" ]; then
    echo "⚠️ Warning: Firebase upload-symbols script not found"
    echo "⚠️ Skipping dSYM upload. Please ensure Firebase SDK is installed."
    exit 0
fi

# Upload dSYM
echo "📤 Uploading dSYM to Firebase Crashlytics..."
"$FIREBASE_UPLOAD_SCRIPT" -gsp "$GOOGLE_SERVICE_INFO_PLIST" -p ios "$DSYM_PATH"

if [ $? -eq 0 ]; then
    echo "✅ dSYM uploaded successfully"
else
    echo "❌ Failed to upload dSYM"
    exit 1
fi

