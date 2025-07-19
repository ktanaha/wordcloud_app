# macOS アプリ署名・公証ガイド

このガイドでは、WordCloud Generator アプリケーションを Apple Developer ID で署名し、公証するプロセスを説明します。

## 前提条件

### 1. Apple Developer Program への登録
- [Apple Developer Program](https://developer.apple.com/programs/) に登録（年額 $99）
- Team ID を取得

### 2. 証明書の取得
以下の証明書をキーチェーンにインストールする必要があります：

1. **Developer ID Application** 証明書
   - アプリケーションバンドルの署名用
   
2. **Developer ID Installer** 証明書
   - インストーラーパッケージの署名用

### 3. App-Specific Password の生成
1. [Apple ID アカウント管理ページ](https://appleid.apple.com/) にログイン
2. 「セキュリティ」セクションで「App-Specific Password」を生成
3. `notarytool` 用にパスワードを保存

## 環境変数の設定

署名スクリプトを実行する前に、以下の環境変数を設定してください：

```bash
# 証明書名（キーチェーンで確認）
export DEVELOPER_ID_APPLICATION="Developer ID Application: Your Name (TEAM_ID)"
export DEVELOPER_ID_INSTALLER="Developer ID Installer: Your Name (TEAM_ID)"

# 公証用の情報
export APPLE_ID="your-email@example.com"
export APP_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
export TEAM_ID="YOUR_TEAM_ID"
```

### 証明書名の確認方法

```bash
# インストールされている証明書の確認
security find-identity -v -p codesigning
```

出力例：
```
1) ABCD1234EFGH5678 "Developer ID Application: John Doe (XYZ123456)"
2) IJKL9012MNOP3456 "Developer ID Installer: John Doe (XYZ123456)"
```

## 署名・公証の実行

### 1. 実行権限の付与

```bash
chmod +x build_signed_installer.sh
```

### 2. 署名付きインストーラーの作成

```bash
./build_signed_installer.sh
```

このスクリプトは以下の処理を実行します：

1. **アプリケーションバンドルの署名**
   - ハードニングランタイムを有効化
   - entitlements.plist を適用

2. **コンポーネントパッケージの作成・署名**
   - pkgbuild で署名付きパッケージを作成

3. **配布パッケージの作成・署名**
   - productbuild で最終的なインストーラーを作成・署名

4. **公証（Notarization）**
   - Apple のサーバーに送信してマルウェアスキャン
   - 通常 5-30分程度で完了

5. **ステープル（Stapling）**
   - 公証証明書をパッケージに埋め込み

## トラブルシューティング

### 証明書が見つからない場合

```bash
# キーチェーンアクセスで証明書を確認
open -a "Keychain Access"

# または、コマンドラインで確認
security find-identity -v -p codesigning
```

### 公証が失敗する場合

```bash
# 公証履歴の確認
xcrun notarytool history --apple-id "$APPLE_ID" --password "$APP_SPECIFIC_PASSWORD" --team-id "$TEAM_ID"

# 特定の送信の詳細確認
xcrun notarytool log --apple-id "$APPLE_ID" --password "$APP_SPECIFIC_PASSWORD" --team-id "$TEAM_ID" [SUBMISSION_ID]
```

### よくある問題と解決法

1. **署名証明書の期限切れ**
   - Apple Developer Portal で新しい証明書を作成
   - 古い証明書をキーチェーンから削除

2. **entitlements エラー**
   - `entitlements.plist` の権限設定を確認
   - 不要な権限を削除

3. **公証の拒否**
   - すべてのバイナリが署名されているか確認
   - ハードニングランタイムが有効になっているか確認

## セキュリティ確認

署名・公証済みパッケージの検証：

```bash
# パッケージ署名の確認
pkgutil --check-signature "dist/WordCloudGenerator-Installer-Signed.pkg"

# ステープルの確認
xcrun stapler validate "dist/WordCloudGenerator-Installer-Signed.pkg"

# アプリケーション署名の確認（展開後）
codesign --verify --deep --strict --verbose=2 "/Applications/WordCloudApp.app"
```

## 配布

署名・公証済みパッケージは：

- ✅ Gatekeeper をバイパス
- ✅ 隔離属性を自動解除
- ✅ 他のmacで安全にインストール可能
- ✅ macOS のセキュリティ警告なし

## 注意事項

1. **証明書の管理**
   - 秘密鍵の安全な保管
   - 証明書の期限管理（通常3年）

2. **公証の要件**
   - macOS 10.15 以降では公証が必須
   - ハードニングランタイムの有効化が必要

3. **コスト**
   - Apple Developer Program: $99/年
   - 公証自体は無料（API使用制限あり）

## 参考資料

- [Apple Developer Documentation - Notarizing macOS Software](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Code Signing Guide](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/)
- [Hardened Runtime](https://developer.apple.com/documentation/security/hardened_runtime)