#!/bin/bash

# Japanese WordCloud Generator アンインストーラー

echo "Japanese WordCloud Generator をアンインストールしています..."

# アプリケーションの削除
if [ -d "/Applications/WordCloudApp.app" ]; then
    echo "アプリケーションを削除中..."
    rm -rf "/Applications/WordCloudApp.app"
    echo "✅ アプリケーションが削除されました"
else
    echo "⚠️  アプリケーションが見つかりません"
fi

# LaunchServicesの登録を削除
echo "システム登録を削除中..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -u "/Applications/WordCloudApp.app" 2>/dev/null || true

# ユーザーの設定ファイルがある場合は確認して削除
USER_PREFS="$HOME/Library/Preferences/com.ktanaha.wordcloud-generator.plist"
if [ -f "$USER_PREFS" ]; then
    read -p "ユーザー設定ファイルも削除しますか？ (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        rm -f "$USER_PREFS"
        echo "✅ ユーザー設定ファイルが削除されました"
    fi
fi

# Application Supportディレクトリの確認
APP_SUPPORT="$HOME/Library/Application Support/WordCloudApp"
if [ -d "$APP_SUPPORT" ]; then
    read -p "アプリケーションサポートファイルも削除しますか？ (y/N): " confirm
    if [[ $confirm == [yY] ]]; then
        rm -rf "$APP_SUPPORT"
        echo "✅ アプリケーションサポートファイルが削除されました"
    fi
fi

echo ""
echo "🗑️  Japanese WordCloud Generator のアンインストールが完了しました"
echo ""
echo "注意: このスクリプトはアプリケーション自体のみを削除します。"
echo "MeCabや他の依存関係は削除されません。"
echo "必要に応じて手動で削除してください："
echo "  brew uninstall mecab mecab-ipadic"