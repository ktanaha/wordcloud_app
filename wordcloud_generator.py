#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import MeCab
import re
from collections import Counter
from wordcloud import WordCloud
import matplotlib.pyplot as plt
import argparse
import os
import sys

class JapaneseWordCloudGenerator:
    def __init__(self):
        try:
            # HomebrewでインストールされたMeCabの設定ファイルパスを指定
            mecab_path = "/opt/homebrew/etc/mecabrc"
            if os.path.exists(mecab_path):
                self.mecab = MeCab.Tagger(f"-r {mecab_path} -Owakati")
            else:
                # デフォルトの設定で試行
                self.mecab = MeCab.Tagger("-Owakati")
        except Exception as e:
            print(f"MeCabの初期化に失敗しました: {e}")
            sys.exit(1)
    
    def read_text_file(self, file_path):
        """テキストファイルを読み込む"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                return f.read()
        except FileNotFoundError:
            print(f"ファイルが見つかりません: {file_path}")
            sys.exit(1)
        except Exception as e:
            print(f"ファイルの読み込みに失敗しました: {e}")
            sys.exit(1)
    
    def extract_words(self, text, debug_output=None):
        """MeCabを使って日本語テキストから単語を抽出"""
        # テキストの前処理
        original_text = text
        text = re.sub(r'[0-9０-９]+', '', text)  # 数字を除去
        text = re.sub(r'[!-/:-@\[-`{-~]', '', text)  # 記号を除去
        text = re.sub(r'[！-／：-＠［-｀｛-～]', '', text)  # 全角記号を除去
        text = re.sub(r'\s+', ' ', text)  # 連続する空白を1つに
        
        # デバッグ情報を記録
        debug_info = []
        debug_info.append("=== テキスト前処理 ===")
        debug_info.append(f"元のテキスト（最初の200文字）: {original_text[:200]}")
        debug_info.append(f"前処理後のテキスト（最初の200文字）: {text[:200]}")
        debug_info.append("\n=== MeCab解析結果 ===")
        
        # MeCabで形態素解析
        node = self.mecab.parseToNode(text)
        words = []
        node_count = 0
        
        while node:
            node_count += 1
            # 品詞情報を取得
            features = node.feature.split(',') if node.feature != '*' else []
            part_of_speech = features[0] if features else ''
            
            # デバッグ情報を記録（最初の50語のみ）
            if node_count <= 50:
                debug_info.append(f"単語: '{node.surface}' | 品詞: {part_of_speech} | 詳細: {node.feature}")
            
            # 名詞、動詞、形容詞のみを抽出（ただし代名詞、数詞、接続詞は除外）
            if (part_of_speech in ['名詞', '動詞', '形容詞'] and 
                len(node.surface) > 1 and  # 1文字の単語は除外
                not re.match(r'^[ぁ-ん]+$', node.surface)):  # ひらがなのみの単語も除外
                
                words.append(node.surface)
                debug_info.append(f"→ 採用: '{node.surface}'")
            
            node = node.next
        
        debug_info.append(f"\n=== 抽出結果 ===")
        debug_info.append(f"解析した総ノード数: {node_count}")
        debug_info.append(f"抽出された単語数: {len(words)}")
        debug_info.append(f"抽出された単語: {words}")
        
        # 単語の頻度を詳細表示
        from collections import Counter
        word_counter = Counter(words)
        debug_info.append(f"\n=== 単語頻度（全て） ===")
        for word, count in word_counter.most_common():
            debug_info.append(f"'{word}': {count}回")
        
        # デバッグ情報をファイルに出力
        if debug_output:
            try:
                with open(debug_output, 'w', encoding='utf-8') as f:
                    f.write('\n'.join(debug_info))
                print(f"デバッグ情報を出力しました: {debug_output}")
            except Exception as e:
                print(f"デバッグ情報の出力に失敗: {e}")
        
        return words
    
    def create_word_frequency(self, words, min_freq=2):
        """単語の頻度を計算"""
        word_freq = Counter(words)
        # 最小出現回数でフィルタリング
        filtered_freq = {word: freq for word, freq in word_freq.items() if freq >= min_freq}
        return filtered_freq
    
    def find_japanese_font(self):
        """日本語対応フォントを検出"""
        # macOSで利用可能な日本語フォントのパス（優先順）
        font_paths = [
            # ヒラギノフォント（macOS標準）
            '/System/Library/Fonts/ヒラギノ角ゴシック W3.ttc',
            '/System/Library/Fonts/Hiragino Sans W3.ttc',
            '/System/Library/Fonts/ヒラギノ丸ゴ ProN W4.ttc',
            '/System/Library/Fonts/Hiragino Sans GB.ttc',  # 中国語だが日本語も対応
            
            # Arial Unicode（多言語対応）
            '/System/Library/Fonts/Arial Unicode.ttf',
            '/Library/Fonts/Arial Unicode.ttf',
            
            # NotoフォントシリーズChrome/Linux環境で利用可能
            '/System/Library/Fonts/NotoSansCJK-Regular.ttc',
            '/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc',
            '/usr/share/fonts/noto-cjk/NotoSansCJK-Regular.ttc',
            
            # その他の一般的な日本語フォント
            '/System/Library/Fonts/PingFang.ttc',
            '/System/Library/Fonts/ArialHB.ttc',
        ]
        
        for path in font_paths:
            if os.path.exists(path):
                print(f"日本語フォントを検出: {path}")
                return path
        
        print("警告: 日本語フォントが見つかりませんでした。英数字のみ表示される可能性があります。")
        return None

    def generate_wordcloud(self, word_freq, output_path, width=800, height=600):
        """ワードクラウドを生成して保存"""
        if not word_freq:
            print("有効な単語が見つかりませんでした。")
            return False
        
        # 日本語フォントを検出
        font_path = self.find_japanese_font()
        
        try:
            # WordCloudのパラメータ設定
            wordcloud_params = {
                'width': width,
                'height': height,
                'background_color': 'white',
                'max_words': 100,
                'colormap': 'viridis',
                'relative_scaling': 0.5,
                'min_font_size': 10,
                'prefer_horizontal': 0.9,  # 横書きを優先
                'max_font_size': 100,
                'random_state': 42  # 再現性のため
            }
            
            # フォントパスが見つかった場合のみ設定
            if font_path:
                wordcloud_params['font_path'] = font_path
            
            wordcloud = WordCloud(**wordcloud_params).generate_from_frequencies(word_freq)
            
            # 画像として保存
            plt.figure(figsize=(width/100, height/100))
            plt.imshow(wordcloud, interpolation='bilinear')
            plt.axis('off')
            plt.tight_layout(pad=0)
            plt.savefig(output_path, dpi=300, bbox_inches='tight')
            plt.close()
            
            print(f"ワードクラウドを保存しました: {output_path}")
            return True
            
        except Exception as e:
            print(f"ワードクラウドの生成に失敗しました: {e}")
            return False
    
    def process_text_file(self, input_file, output_file=None, min_freq=1):
        """テキストファイルを処理してワードクラウドを生成"""
        # 出力ファイル名を自動生成
        if output_file is None:
            base_name = os.path.splitext(os.path.basename(input_file))[0]
            output_file = f"{base_name}_wordcloud.png"
        
        # テキストファイルを読み込み
        text = self.read_text_file(input_file)
        print(f"テキストファイルを読み込みました: {input_file}")
        
        # 単語を抽出（デバッグ出力付き）
        debug_file = f"{os.path.splitext(input_file)[0]}_debug.txt"
        words = self.extract_words(text, debug_output=debug_file)
        print(f"抽出された単語数: {len(words)}")
        
        # 単語の頻度を計算
        word_freq = self.create_word_frequency(words, min_freq)
        print(f"有効な単語数: {len(word_freq)}")
        
        if word_freq:
            # Counterオブジェクトを作成して上位単語を表示
            word_counter = Counter(word_freq)
            print(f"上位10単語: {dict(word_counter.most_common(10))}")
        
        # ワードクラウドを生成
        success = self.generate_wordcloud(word_freq, output_file)
        
        return success

def main():
    parser = argparse.ArgumentParser(description='日本語テキストからワードクラウドを生成')
    parser.add_argument('input_file', help='入力テキストファイルのパス')
    parser.add_argument('-o', '--output', help='出力画像ファイルのパス')
    parser.add_argument('--min-freq', type=int, default=1, help='最小出現回数（デフォルト: 1）')
    parser.add_argument('--width', type=int, default=800, help='画像の幅（デフォルト: 800）')
    parser.add_argument('--height', type=int, default=600, help='画像の高さ（デフォルト: 600）')
    
    args = parser.parse_args()
    
    # WordCloudGeneratorのインスタンスを作成
    generator = JapaneseWordCloudGenerator()
    
    # ワードクラウドを生成
    success = generator.process_text_file(
        args.input_file, 
        args.output, 
        args.min_freq
    )
    
    if success:
        print("ワードクラウドの生成が完了しました。")
    else:
        print("ワードクラウドの生成に失敗しました。")
        sys.exit(1)

if __name__ == "__main__":
    main()