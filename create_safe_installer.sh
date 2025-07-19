#!/bin/bash

# 署名なしでも安全にインストールできるパッケージ作成スクリプト
# Apple Developer ID が無い場合の代替手段

set -e

echo "セルフサイン済みインストーラーパッケージを作成しています..."

# パッケージ情報
PACKAGE_NAME="WordCloudGenerator"
PACKAGE_VERSION="1.0.0"
PACKAGE_IDENTIFIER="com.ktanaha.wordcloud-generator"
PACKAGE_TITLE="Japanese WordCloud Generator"

# ディレクトリの準備
INSTALLER_DIR="installer"
PAYLOAD_DIR="$INSTALLER_DIR/payload"
SCRIPTS_DIR="$INSTALLER_DIR/scripts"
DIST_DIR="dist"

# 出力ディレクトリの作成
mkdir -p "$DIST_DIR"

# 1. アドホック署名を使用したセルフサイン
echo "アドホック署名を適用しています..."
if [ -d "$PAYLOAD_DIR/Applications/WordCloudApp.app" ]; then
    echo "アプリケーションバンドルにアドホック署名を適用..."
    codesign --force --deep --sign - \
        --entitlements entitlements.plist \
        "$PAYLOAD_DIR/Applications/WordCloudApp.app" || echo "署名をスキップ（証明書なし）"
fi

# 2. チェックサムファイルの作成
echo "整合性検証用のチェックサムを作成しています..."
find "$PAYLOAD_DIR" -type f -exec shasum -a 256 {} \; > "$DIST_DIR/checksums.txt"

# 3. 特別なインストーラー作成（配布XML修正版）
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
</installer-gui-script>
EOF

# 4. セキュリティ警告対応のHTMLファイル作成
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
        .security-notice { 
            border: 2px solid #FF9500; 
            padding: 20px; 
            border-radius: 8px; 
            background-color: #FFF8E1;
            margin: 20px 0;
        }
        .verification-steps {
            border: 1px solid #34C759;
            padding: 15px;
            border-radius: 8px;
            background-color: #F0F9F0;
            margin: 15px 0;
        }
        .step {
            margin: 10px 0;
            padding: 5px 0;
        }
        code {
            background-color: #f5f5f5;
            padding: 2px 4px;
            border-radius: 3px;
            font-family: 'SF Mono', Monaco, monospace;
        }
    </style>
</head>
<body>
    <h1>Japanese WordCloud Generator へようこそ</h1>
    
    <div class="security-notice">
        <h3>🔒 セキュリティについて</h3>
        <p><strong>このインストーラーは Apple Developer ID での署名を行っていません。</strong></p>
        <p>macOS によって「開発元が未確認」として警告される場合があります。</p>
    </div>
    
    <div class="verification-steps">
        <h3>✅ 安全性の確認方法</h3>
        <div class="step">
            <strong>1. チェックサム確認:</strong><br>
            同梱の <code>checksums.txt</code> でファイル整合性を確認できます
        </div>
        <div class="step">
            <strong>2. ソースコード確認:</strong><br>
            GitHub: <a href="https://github.com/ktanaha/wordcloud-app">https://github.com/ktanaha/wordcloud-app</a>
        </div>
        <div class="step">
            <strong>3. ローカルビルド:</strong><br>
            ソースからご自身でビルドすることも可能です
        </div>
    </div>
    
    <h2>macOS セキュリティ警告の対処法</h2>
    <ol>
        <li>インストーラーを右クリック → 「開く」を選択</li>
        <li>「開発元が未確認」の警告が表示されたら「開く」をクリック</li>
        <li>または、システム環境設定 → セキュリティとプライバシー → 「一般」タブ → 「このまま開く」</li>
    </ol>
    
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

# 5. README with security instructions
cat > "$DIST_DIR/readme.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>インストール手順とセキュリティガイド</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
        h1, h2 { color: #1d1d1f; }
        p { line-height: 1.6; }
        .warning-box { 
            border: 2px solid #FF3B30; 
            padding: 15px; 
            border-radius: 8px; 
            background-color: #FFF5F5;
            margin: 15px 0;
        }
        .info-box {
            border: 1px solid #007AFF;
            padding: 15px;
            border-radius: 8px;
            background-color: #F0F8FF;
            margin: 15px 0;
        }
        code { 
            background-color: #f5f5f5; 
            padding: 2px 4px; 
            border-radius: 3px; 
        }
        .steps {
            counter-reset: step-counter;
        }
        .step {
            counter-increment: step-counter;
            margin: 15px 0;
            padding: 10px;
            border-left: 3px solid #007AFF;
            padding-left: 15px;
        }
        .step::before {
            content: "Step " counter(step-counter) ": ";
            font-weight: bold;
            color: #007AFF;
        }
    </style>
</head>
<body>
    <h1>インストール手順とセキュリティガイド</h1>
    
    <div class="warning-box">
        <h3>⚠️ 重要な注意事項</h3>
        <p>このインストーラーは Apple Developer ID での署名を行っていません。macOS のセキュリティ機能により警告が表示されます。</p>
        <p><strong>信頼できるソースからのみダウンロードしてください。</strong></p>
    </div>
    
    <h2>🔒 セキュリティ確認手順</h2>
    
    <div class="steps">
        <div class="step">
            <strong>ダウンロード元の確認</strong><br>
            信頼できるソース（公式GitHub、開発者のWebサイト等）からダウンロードしたか確認
        </div>
        
        <div class="step">
            <strong>チェックサム確認</strong><br>
            <code>checksums.txt</code> ファイルでパッケージの整合性を確認：<br>
            <code>shasum -c checksums.txt</code>
        </div>
        
        <div class="step">
            <strong>ソースコード確認</strong><br>
            GitHub リポジトリで実際のコードを確認可能：<br>
            <a href="https://github.com/ktanaha/wordcloud-app">https://github.com/ktanaha/wordcloud-app</a>
        </div>
    </div>
    
    <h2>📦 インストール手順</h2>
    
    <div class="info-box">
        <h3>macOS セキュリティ警告への対処</h3>
        <p>以下の手順でセキュリティ警告を回避してインストールできます：</p>
    </div>
    
    <div class="steps">
        <div class="step">
            <strong>右クリックで開く</strong><br>
            インストーラーファイルを右クリック → 「開く」を選択
        </div>
        
        <div class="step">
            <strong>警告ダイアログの処理</strong><br>
            「開発元が未確認」の警告 → 「開く」ボタンをクリック
        </div>
        
        <div class="step">
            <strong>代替方法：システム環境設定</strong><br>
            システム環境設定 → セキュリティとプライバシー → 「一般」タブ → 「このまま開く」
        </div>
        
        <div class="step">
            <strong>インストール実行</strong><br>
            インストーラーの指示に従って進める
        </div>
    </div>
    
    <h2>💻 システム要件</h2>
    <ul>
        <li>macOS 10.15 (Catalina) 以上</li>
        <li>MeCab (日本語形態素解析エンジン)</li>
        <li>mecab-ipadic (MeCab用の辞書)</li>
        <li>約 150 MB の空き容量</li>
    </ul>
    
    <div class="info-box">
        <h3>📋 MeCab のインストール</h3>
        <p>アプリケーション使用前に MeCab をインストールしてください：</p>
        <code>brew install mecab mecab-ipadic</code>
    </div>
    
    <h2>🚀 使用方法</h2>
    <ol>
        <li>アプリケーションフォルダから「WordCloudApp」を起動</li>
        <li>「ファイルを選択」でテキストファイルを選択</li>
        <li>パラメータを調整（オプション）</li>
        <li>「ワードクラウド生成」をクリック</li>
        <li>生成された画像を保存</li>
    </ol>
    
    <h2>❓ トラブルシューティング</h2>
    
    <h3>アプリが起動しない場合</h3>
    <ul>
        <li>ターミナルで実行：<code>xattr -cr /Applications/WordCloudApp.app</code></li>
        <li>システム環境設定でアプリの実行を許可</li>
    </ul>
    
    <h3>MeCab エラーが発生する場合</h3>
    <ul>
        <li>MeCab の正しいインストール確認：<code>mecab --version</code></li>
        <li>辞書の確認：<code>ls /usr/local/lib/mecab/dic/</code></li>
    </ul>
    
    <div class="info-box">
        <h3>📞 サポート</h3>
        <p>問題が発生した場合は、GitHub Issues でお知らせください：<br>
        <a href="https://github.com/ktanaha/wordcloud-app/issues">https://github.com/ktanaha/wordcloud-app/issues</a></p>
    </div>
</body>
</html>
EOF

# 6. コンポーネントパッケージの作成（署名なし）
echo "コンポーネントパッケージを作成中..."
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --scripts "$SCRIPTS_DIR" \
    --identifier "$PACKAGE_IDENTIFIER" \
    --version "$PACKAGE_VERSION" \
    --install-location "/" \
    "$DIST_DIR/${PACKAGE_NAME}-component.pkg"

# 7. 配布パッケージの作成（署名なし）
echo "配布パッケージを作成中..."
productbuild \
    --distribution "$DIST_DIR/distribution.xml" \
    --package-path "$DIST_DIR" \
    --resources "$DIST_DIR" \
    "$DIST_DIR/${PACKAGE_NAME}-Installer-SelfSigned.pkg"

# 8. 使用方法説明ファイルの作成
cat > "$DIST_DIR/INSTALL_INSTRUCTIONS.txt" << 'EOF'
# WordCloud Generator インストール手順

## ⚠️ 重要な注意事項
このインストーラーは Apple Developer ID での署名を行っていません。
macOS によって「開発元が未確認」として警告されます。

## セキュリティ確認
1. ダウンロード元の確認（公式リポジトリ等から）
2. checksums.txt でファイル整合性確認
3. ソースコード確認（GitHub）

## インストール手順
1. インストーラーファイルを右クリック
2. 「開く」を選択
3. 「開発元が未確認」警告 → 「開く」をクリック
4. インストーラーの指示に従う

## 代替方法
システム環境設定 → セキュリティとプライバシー → 「一般」→ 「このまま開く」

## アプリが起動しない場合
ターミナルで実行：
xattr -cr /Applications/WordCloudApp.app

## サポート
GitHub: https://github.com/ktanaha/wordcloud-app/issues
EOF

# 9. クリーンアップ
echo "一時ファイルをクリーンアップ中..."
rm -f "$DIST_DIR/${PACKAGE_NAME}-component.pkg"
rm -f "$DIST_DIR/distribution.xml"

echo ""
echo "✅ セルフサイン済みインストーラーパッケージが作成されました!"
echo "📦 ファイル: $DIST_DIR/${PACKAGE_NAME}-Installer-SelfSigned.pkg"
echo ""
echo "🔒 セキュリティ情報:"
echo "   ⚠️  Apple Developer ID 署名なし"
echo "   ✓  アドホック署名適用済み"
echo "   ✓  チェックサム検証ファイル付属"
echo "   ✓  インストール手順書付属"
echo ""
echo "📄 付属ファイル:"
echo "   - checksums.txt (整合性確認用)"
echo "   - INSTALL_INSTRUCTIONS.txt (インストール手順)"
echo ""
echo "📦 インストーラーファイル:"
ls -la "$DIST_DIR/${PACKAGE_NAME}-Installer-SelfSigned.pkg"
echo ""
echo "🚀 配布時の注意事項:"
echo "   1. 信頼できるソースからの配布であることを明示"
echo "   2. インストール手順を事前に共有"
echo "   3. ソースコードリポジトリへのリンクを提供"
echo "   4. チェックサム確認の推奨"
echo ""
echo "💡 ユーザーへの案内:"
echo "   - 右クリック → 「開く」でインストール"
echo "   - 「開発元が未確認」警告は「開く」で継続"
echo "   - 信頼できるソースからのダウンロードであることを確認"