# Japanese WordCloud Generator

MeCabを使用した日本語テキストからワードクラウドを生成するPythonアプリケーションです。

## 機能

- **日本語形態素解析**: MeCabを使用して日本語テキストを解析
- **品詞フィルタリング**: 名詞、動詞、形容詞のみを抽出
- **カスタマイズ可能**: 画像サイズ、最小出現回数、出力ファイル名を指定可能
- **高品質出力**: PNG形式で高解像度のワードクラウド画像を生成

## 必要な環境

- Python 3.7以上
- macOS（Homebrewを使用）
- MeCab（日本語形態素解析エンジン）

## セットアップ手順

### 1. リポジトリをクローン

```bash
git clone https://github.com/ktanaha/wordcloud_app.git
cd wordcloud_app
```

### 2. MeCabのインストール

#### macOSの場合：

```bash
# Homebrewでインストール
brew install mecab mecab-ipadic
```

#### Linuxの場合（Ubuntu/Debian）：

```bash
sudo apt-get update
sudo apt-get install mecab mecab-ipadic-utf8 libmecab-dev
```

#### Linuxの場合（CentOS/RHEL）：

```bash
sudo yum install mecab mecab-ipadic mecab-devel
```

### 3. Python仮想環境の作成

```bash
python3 -m venv venv
source venv/bin/activate  # Linux/macOS
# または
venv\\Scripts\\activate   # Windows
```

### 4. Pythonパッケージのインストール

```bash
pip install -r requirements.txt
```

もしくは手動でインストール：

```bash
pip install mecab-python3 wordcloud matplotlib
```

## 使用方法

### 基本的な使用方法

```bash
# 仮想環境をアクティベート
source venv/bin/activate

# サンプルテキストでワードクラウドを生成
python wordcloud_generator.py sample_text.txt
```

### コマンドラインオプション

```bash
python wordcloud_generator.py [入力ファイル] [オプション]
```

#### 必須引数
- `input_file`: 入力テキストファイルのパス

#### オプション引数
- `-o, --output`: 出力画像ファイルのパス（デフォルト: `{入力ファイル名}_wordcloud.png`）
- `--min-freq`: 最小出現回数（デフォルト: 2）
- `--width`: 画像の幅（デフォルト: 800）
- `--height`: 画像の高さ（デフォルト: 600）

### 使用例

```bash
# 基本的な使用
python wordcloud_generator.py my_text.txt

# 出力ファイル名を指定
python wordcloud_generator.py my_text.txt -o my_wordcloud.png

# 最小出現回数と画像サイズを指定
python wordcloud_generator.py my_text.txt --min-freq 3 --width 1200 --height 800

# すべてのオプションを指定
python wordcloud_generator.py my_text.txt -o output.png --min-freq 2 --width 1000 --height 600
```

## ファイル構成

```
wordcloud_app/
├── README.md                    # このファイル
├── requirements.txt             # Python依存関係
├── .gitignore                  # Git除外設定
├── wordcloud_generator.py      # メインスクリプト
├── sample_text.txt             # サンプルテキスト
└── venv/                       # Python仮想環境（Git管理外）
```

## 入力テキストファイルについて

- **文字エンコーディング**: UTF-8
- **対応言語**: 日本語（ひらがな、カタカナ、漢字）
- **ファイル形式**: プレーンテキスト（.txt）

### テキスト処理の詳細

1. **前処理**: 数字と記号を除去
2. **形態素解析**: MeCabで単語に分割
3. **品詞フィルタリング**: 名詞、動詞、形容詞のみを抽出
4. **除外処理**: 
   - 1文字の単語
   - ひらがなのみの単語
   - 最小出現回数未満の単語

## 出力について

- **ファイル形式**: PNG
- **解像度**: 300 DPI
- **背景色**: 白
- **最大単語数**: 100語
- **カラーマップ**: viridis

## トラブルシューティング

### MeCabのエラーが発生する場合

#### エラー: `[ifs] no such file or directory: /usr/local/etc/mecabrc`

**解決方法**:
```bash
# MeCabの設定ファイルの場所を確認
mecab-config --sysconfdir

# 必要に応じてMeCabを再インストール
brew reinstall mecab mecab-ipadic
```

#### エラー: `ModuleNotFoundError: No module named 'MeCab'`

**解決方法**:
```bash
# 仮想環境がアクティベートされているか確認
source venv/bin/activate

# mecab-python3を再インストール
pip uninstall mecab-python3
pip install mecab-python3
```

### Python関連のエラー

#### エラー: `externally-managed-environment`

**解決方法**:
仮想環境を使用してください：
```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### エラー: フォント関連のエラー

**macOSの場合**: 通常は自動でシステムフォントを使用します。
**Linuxの場合**: 日本語フォントをインストール：
```bash
sudo apt-get install fonts-noto-cjk
```

### 権限エラー

```bash
# ファイルに実行権限を付与
chmod +x wordcloud_generator.py
```

## 開発環境

- **Python**: 3.13.0
- **MeCab**: 0.996
- **主要ライブラリ**:
  - mecab-python3: 1.0.10
  - wordcloud: 1.9.4
  - matplotlib: 3.10.3

## ライセンス

このプロジェクトは[MITライセンス](LICENSE)の下で公開されています。

## 貢献

バグ報告や機能要望は[Issues](https://github.com/ktanaha/wordcloud_app/issues)でお願いします。

## 参考資料

- [MeCab公式サイト](https://taku910.github.io/mecab/)
- [WordCloud Python Library](https://github.com/amueller/word_cloud)
- [mecab-python3](https://github.com/SamuraiT/mecab-python3)