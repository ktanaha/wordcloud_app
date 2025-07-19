#!/bin/bash

# WordCloud Generator 署名付きインストーラービルドスクリプト

set -e

echo "署名付きインストーラーパッケージを作成しています..."

# パッケージ情報
PACKAGE_NAME="WordCloudGenerator"
PACKAGE_VERSION="1.0.0"
PACKAGE_IDENTIFIER="com.ktanaha.wordcloud-generator"
PACKAGE_TITLE="Japanese WordCloud Generator"

# 署名証明書情報（環境変数または引数で指定）
# Apple Developer ID証明書の名前を指定
DEVELOPER_ID_INSTALLER="${DEVELOPER_ID_INSTALLER:-Developer ID Installer: Your Name (TEAM_ID)}"
DEVELOPER_ID_APPLICATION="${DEVELOPER_ID_APPLICATION:-Developer ID Application: Your Name (TEAM_ID)}"

# Apple IDとApp-Specific Password（公証用）
APPLE_ID="${APPLE_ID:-your-email@example.com}"
APP_SPECIFIC_PASSWORD="${APP_SPECIFIC_PASSWORD:-xxxx-xxxx-xxxx-xxxx}"
TEAM_ID="${TEAM_ID:-YOUR_TEAM_ID}"

# ディレクトリの準備
INSTALLER_DIR="installer"
PAYLOAD_DIR="$INSTALLER_DIR/payload"
SCRIPTS_DIR="$INSTALLER_DIR/scripts"
DIST_DIR="dist"

# 出力ディレクトリの作成
mkdir -p "$DIST_DIR"

# 証明書の確認
echo "利用可能な証明書を確認しています..."
security find-identity -v -p codesigning

echo ""
echo "署名に使用する証明書:"
echo "  Application: $DEVELOPER_ID_APPLICATION"
echo "  Installer: $DEVELOPER_ID_INSTALLER"
echo ""

# アプリケーションバンドルの署名（既に存在する場合）
if [ -d "$PAYLOAD_DIR/Applications/WordCloudApp.app" ]; then
    echo "アプリケーションバンドルに署名しています..."
    codesign --force --deep --sign "$DEVELOPER_ID_APPLICATION" \
        --options runtime \
        --entitlements entitlements.plist \
        "$PAYLOAD_DIR/Applications/WordCloudApp.app"
    
    # 署名の確認
    echo "アプリケーション署名を確認しています..."
    codesign --verify --deep --strict --verbose=2 "$PAYLOAD_DIR/Applications/WordCloudApp.app"
fi

# 1. コンポーネントパッケージの作成（署名付き）
echo "署名付きコンポーネントパッケージを作成中..."
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --scripts "$SCRIPTS_DIR" \
    --identifier "$PACKAGE_IDENTIFIER" \
    --version "$PACKAGE_VERSION" \
    --install-location "/" \
    --sign "$DEVELOPER_ID_INSTALLER" \
    "$DIST_DIR/${PACKAGE_NAME}-component.pkg"

# 2. 配布パッケージの作成用XML設定ファイル
cat > "$DIST_DIR/distribution.xml" << EOF
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
    <title>$PACKAGE_TITLE</title>
    <organization>com.ktanaha</organization>
    <domains enable_localSystem="true" enable_currentUserHome="true" enable_anywhere="true"/>
    <options customize="always" require-scripts="false" rootVolumeOnly="false" hostArchitectures="x86_64,arm64"/>
    
    <!-- 背景とウェルカムメッセージ -->
    <welcome file="welcome.html" mime-type="text/html"/>
    <readme file="readme.html" mime-type="text/html"/>
    <license file="license.html" mime-type="text/html"/>
    <installation-check file="install-check.html" mime-type="text/html"/>
    
    <pkg-ref id="$PACKAGE_IDENTIFIER"/>
    
    <choices-outline>
        <line choice="default">
            <line choice="$PACKAGE_IDENTIFIER"/>
        </line>
    </choices-outline>
    
    <choice id="default" title="標準インストール" description="WordCloud Generatorをインストールします">
        <pkg-ref id="$PACKAGE_IDENTIFIER"/>
    </choice>
    
    <choice id="$PACKAGE_IDENTIFIER" title="WordCloud Generator" description="日本語ワードクラウド生成アプリケーション" start_selected="true" start_enabled="true" start_visible="true">
        <pkg-ref id="$PACKAGE_IDENTIFIER"/>
    </choice>
    
    <pkg-ref id="$PACKAGE_IDENTIFIER" version="$PACKAGE_VERSION" onConclusion="none" installKBytes="150000">${PACKAGE_NAME}-component.pkg</pkg-ref>
    
    <!-- インストール先パス表示用のスクリプト -->
    <script>
    function installationCheckRAM() {
        return true;
    }
    
    function volumeCheckCriteria() {
        return true;
    }
    
    function installCheckScript() {
        var installLocation = my.target.mountpoint + "/Applications";
        system.log("インストール先: " + installLocation);
        return true;
    }
    </script>
</installer-gui-script>
EOF

# HTMLファイルのコピー（既存のbuild_installer.shから流用）
# 3. HTMLファイルの作成
cat > "$DIST_DIR/welcome.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Japanese WordCloud Generator</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
        h1 { color: #1d1d1f; }
        p { line-height: 1.6; }
        .signature-info { 
            border: 1px solid #007AFF; 
            padding: 15px; 
            border-radius: 8px; 
            background-color: #F0F8FF;
            margin: 20px 0;
        }
    </style>
</head>
<body>
    <h1>Japanese WordCloud Generator へようこそ</h1>
    <p>このインストーラーは、日本語テキストからワードクラウドを生成するアプリケーションをインストールします。</p>
    
    <div class="signature-info">
        <h3>🔒 セキュリティについて</h3>
        <p>このインストーラーは Apple Developer ID で署名済みです。macOS によって検証され、安全にインストールできます。</p>
    </div>
    
    <h2>主な機能</h2>
    <ul>
        <li>MeCabを使用した日本語形態素解析</li>
        <li>カスタマイズ可能なワードクラウド生成</li>
        <li>直感的なGUIインターフェース</li>
        <li>高品質なPNG出力</li>
    </ul>
    
    <p>このアプリケーションを使用するには、事前にMeCabとmecab-ipadicがインストールされている必要があります。</p>
</body>
</html>
EOF

# readme.htmlとlicense.html、install-check.htmlも同様に作成
# （省略：元のスクリプトと同じ内容）

# 3. 署名付き配布パッケージの作成
echo "署名付き配布パッケージを作成中..."
productbuild \
    --distribution "$DIST_DIR/distribution.xml" \
    --package-path "$DIST_DIR" \
    --resources "$DIST_DIR" \
    --sign "$DEVELOPER_ID_INSTALLER" \
    "$DIST_DIR/${PACKAGE_NAME}-Installer-Signed.pkg"

# 4. パッケージの署名確認
echo "パッケージ署名を確認しています..."
pkgutil --check-signature "$DIST_DIR/${PACKAGE_NAME}-Installer-Signed.pkg"

# 5. 公証（Notarization）の実行
echo "Apple への公証を開始しています..."
echo "これには数分から数十分かかる場合があります..."

# xcrunを使用して公証を実行
xcrun notarytool submit "$DIST_DIR/${PACKAGE_NAME}-Installer-Signed.pkg" \
    --apple-id "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    --team-id "$TEAM_ID" \
    --wait

# 公証状況の確認
echo "公証状況を確認しています..."
xcrun notarytool history --apple-id "$APPLE_ID" --password "$APP_SPECIFIC_PASSWORD" --team-id "$TEAM_ID"

# 公証のステープル（公証証明書をパッケージに埋め込む）
echo "公証証明書をパッケージに埋め込んでいます..."
xcrun stapler staple "$DIST_DIR/${PACKAGE_NAME}-Installer-Signed.pkg"

# ステープルの確認
echo "ステープルを確認しています..."
xcrun stapler validate "$DIST_DIR/${PACKAGE_NAME}-Installer-Signed.pkg"

# 6. クリーンアップ
echo "一時ファイルをクリーンアップ中..."
rm -f "$DIST_DIR/${PACKAGE_NAME}-component.pkg"
rm -f "$DIST_DIR/distribution.xml"
rm -f "$DIST_DIR/welcome.html"

echo ""
echo "✅ 署名・公証済みインストーラーパッケージが作成されました!"
echo "📦 ファイル: $DIST_DIR/${PACKAGE_NAME}-Installer-Signed.pkg"
echo ""
echo "🔒 セキュリティ確認:"
echo "   ✓ Apple Developer ID で署名済み"
echo "   ✓ Apple による公証済み"
echo "   ✓ ステープル（公証証明書）埋め込み済み"
echo ""
echo "📦 インストーラーファイル:"
ls -la "$DIST_DIR/${PACKAGE_NAME}-Installer-Signed.pkg"
echo ""
echo "🚀 使用方法:"
echo "   1. ${PACKAGE_NAME}-Installer-Signed.pkg をダブルクリック"
echo "   2. macOS のセキュリティ警告なしでインストール可能"
echo "   3. /Applications にアプリケーションがインストールされます"
echo ""
echo "📤 配布方法:"
echo "   - このパッケージは他のmacでも安全にインストール可能"
echo "   - Gatekeeper によってブロックされません"
echo "   - ダウンロード時の隔離属性も自動的に解除されます"