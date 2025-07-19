#!/bin/bash

# WordCloud Generator インストーラービルドスクリプト

set -e

echo "インストーラーパッケージを作成しています..."

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

# 1. コンポーネントパッケージの作成
echo "コンポーネントパッケージを作成中..."
pkgbuild \
    --root "$PAYLOAD_DIR" \
    --scripts "$SCRIPTS_DIR" \
    --identifier "$PACKAGE_IDENTIFIER" \
    --version "$PACKAGE_VERSION" \
    --install-location "/" \
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
    </style>
</head>
<body>
    <h1>Japanese WordCloud Generator へようこそ</h1>
    <p>このインストーラーは、日本語テキストからワードクラウドを生成するアプリケーションをインストールします。</p>
    
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

cat > "$DIST_DIR/readme.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>システム要件と使用方法</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
        h1, h2 { color: #1d1d1f; }
        p { line-height: 1.6; }
        code { padding: 2px 4px; border-radius: 3px; }
        .warning { border: 1px solid #ccc; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
    <h1>システム要件と使用方法</h1>
    
    <h2>システム要件</h2>
    <ul>
        <li>macOS 10.15 (Catalina) 以上</li>
        <li>MeCab (日本語形態素解析エンジン)</li>
        <li>mecab-ipadic (MeCab用の辞書)</li>
    </ul>
    
    <div class="warning">
        <h3>⚠️ 重要: MeCabのインストール</h3>
        <p>このアプリケーションを使用する前に、MeCabをインストールする必要があります：</p>
        <p><code>brew install mecab mecab-ipadic</code></p>
    </div>
    
    <h2>使用方法</h2>
    <ol>
        <li>アプリケーションフォルダからWordCloud Generatorを起動</li>
        <li>「ファイルを選択」ボタンでテキストファイルを選択</li>
        <li>必要に応じてパラメータを調整</li>
        <li>「ワードクラウド生成」ボタンをクリック</li>
        <li>生成された画像を保存</li>
    </ol>
    
    <h2>対応ファイル形式</h2>
    <ul>
        <li>テキストファイル (.txt)</li>
        <li>CSVファイル (.csv)</li>
        <li>文字エンコーディング: UTF-8</li>
    </ul>
</body>
</html>
EOF

cat > "$DIST_DIR/license.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>ライセンス</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, sans-serif; margin: 20px; }
        h1 { color: #1d1d1f; }
        p { line-height: 1.6; }
        .license-text { border: 1px solid #ccc; padding: 15px; border-radius: 5px; font-family: monospace; font-size: 12px; }
    </style>
</head>
<body>
    <h1>MITライセンス</h1>
    
    <div class="license-text">
        <p>Copyright (c) 2024 Takashi Tanahashi</p>
        
        <p>Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:</p>
        
        <p>The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.</p>
        
        <p>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.</p>
    </div>
</body>
</html>
EOF

# 4. インストール先確認画面のHTMLファイル作成
cat > "$DIST_DIR/install-check.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>インストール確認</title>
    <style>
        body { 
            font-family: -apple-system, BlinkMacSystemFont, sans-serif; 
            margin: 20px; 
            line-height: 1.6;
        }
        h1 { color: #1d1d1f; margin-bottom: 20px; }
        .install-info { 
            border: 1px solid #ccc; 
            padding: 20px; 
            border-radius: 8px; 
            margin: 20px 0;
        }
        .path-display {
            font-family: 'SF Mono', 'Monaco', 'Courier New', monospace;
            padding: 10px;
            border-radius: 4px;
            border: 1px solid #ccc;
            margin: 10px 0;
            font-size: 14px;
            color: #333;
        }
        .requirement-box {
            border: 1px solid #ccc;
            padding: 15px;
            border-radius: 5px;
            margin: 15px 0;
        }
        .size-info {
            color: #666;
            font-size: 14px;
            margin-top: 10px;
        }
        .feature-list {
            margin: 15px 0;
        }
        .feature-list li {
            margin: 5px 0;
        }
    </style>
    <script>
        function updateInstallPath() {
            try {
                // インストール先パスを取得して表示
                var pathElement = document.getElementById('install-path');
                if (pathElement) {
                    pathElement.textContent = '/Applications/WordCloudApp.app';
                }
                
                // ディスク容量情報を更新
                var sizeElement = document.getElementById('disk-size');
                if (sizeElement) {
                    sizeElement.textContent = '約 150 MB の空き容量が必要です';
                }
            } catch (e) {
                console.log('パス表示の更新に失敗しました: ' + e.message);
            }
        }
        
        // ページ読み込み時に実行
        window.onload = function() {
            updateInstallPath();
        };
    </script>
</head>
<body>
    <h1>📦 インストール準備完了</h1>
    
    <div class="install-info">
        <h2>🎯 インストール先</h2>
        <div class="path-display" id="install-path">/Applications/WordCloudApp.app</div>
        <div class="size-info" id="disk-size">約 150 MB の空き容量が必要です</div>
    </div>
    
    <div class="requirement-box">
        <h3>📋 インストール内容</h3>
        <ul class="feature-list">
            <li>✅ WordCloud Generator アプリケーション</li>
            <li>✅ MeCab 日本語形態素解析エンジン (内蔵)</li>
            <li>✅ Python ランタイム環境 (内蔵)</li>
            <li>✅ 必要なライブラリ一式 (matplotlib, wordcloud, etc.)</li>
            <li>✅ サンプルテキストファイル</li>
        </ul>
    </div>
    
    <div class="install-info">
        <h3>🚀 インストール後の使用方法</h3>
        <ol>
            <li>Finder で「アプリケーション」フォルダを開く</li>
            <li>「WordCloudApp」をダブルクリックして起動</li>
            <li>テキストファイルを選択してワードクラウドを生成</li>
        </ol>
    </div>
    
    <p><strong>「インストール」ボタンをクリックして続行してください。</strong></p>
</body>
</html>
EOF

# 5. 配布パッケージの作成
echo "配布パッケージを作成中..."
productbuild \
    --distribution "$DIST_DIR/distribution.xml" \
    --package-path "$DIST_DIR" \
    --resources "$DIST_DIR" \
    "$DIST_DIR/${PACKAGE_NAME}-Installer.pkg"

# 6. クリーンアップ
echo "一時ファイルをクリーンアップ中..."
rm -f "$DIST_DIR/${PACKAGE_NAME}-component.pkg"
rm -f "$DIST_DIR/distribution.xml"
rm -f "$DIST_DIR/welcome.html"
rm -f "$DIST_DIR/readme.html" 
rm -f "$DIST_DIR/license.html"
rm -f "$DIST_DIR/install-check.html"

echo "✅ インストーラーパッケージが作成されました: $DIST_DIR/${PACKAGE_NAME}-Installer.pkg"
echo ""
echo "📦 インストーラーファイル:"
ls -la "$DIST_DIR/${PACKAGE_NAME}-Installer.pkg"
echo ""
echo "🚀 使用方法:"
echo "   1. ${PACKAGE_NAME}-Installer.pkg をダブルクリック"
echo "   2. インストーラーの指示に従って進める"
echo "   3. /Applications にアプリケーションがインストールされます"