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
    
    def extract_words(self, text):
        """MeCabを使って日本語テキストから単語を抽出"""
        # テキストの前処理
        text = re.sub(r'[0-9０-９]+', '', text)  # 数字を除去
        text = re.sub(r'[!-/:-@\[-`{-~]', '', text)  # 記号を除去
        text = re.sub(r'[！-／：-＠［-｀｛-～]', '', text)  # 全角記号を除去
        text = re.sub(r'\s+', ' ', text)  # 連続する空白を1つに
        
        # MeCabで形態素解析
        node = self.mecab.parseToNode(text)
        words = []
        
        while node:
            # 品詞情報を取得
            features = node.feature.split(',') if node.feature != '*' else []
            part_of_speech = features[0] if features else ''
            
            # 名詞、動詞、形容詞のみを抽出（ただし代名詞、数詞、接続詞は除外）
            if (part_of_speech in ['名詞', '動詞', '形容詞'] and 
                len(node.surface) > 1 and  # 1文字の単語は除外
                not re.match(r'^[ぁ-ん]+$', node.surface)):  # ひらがなのみの単語も除外
                
                words.append(node.surface)
            
            node = node.next
        
        return words
    
    def create_word_frequency(self, words, min_freq=2):
        """単語の頻度を計算"""
        word_freq = Counter(words)
        # 最小出現回数でフィルタリング
        filtered_freq = {word: freq for word, freq in word_freq.items() if freq >= min_freq}
        return filtered_freq
    
    def generate_wordcloud(self, word_freq, output_path, width=800, height=600):
        """ワードクラウドを生成して保存"""
        if not word_freq:
            print("有効な単語が見つかりませんでした。")
            return False
        
        # 日本語フォントのパスを設定（macOSの場合）
        font_paths = [
            '/System/Library/Fonts/Helvetica.ttc',
            '/System/Library/Fonts/Arial Unicode.ttf',
            '/Library/Fonts/Arial Unicode.ttf'
        ]
        
        font_path = None
        for path in font_paths:
            if os.path.exists(path):
                font_path = path
                break
        
        try:
            wordcloud = WordCloud(
                font_path=font_path,
                width=width,
                height=height,
                background_color='white',
                max_words=100,
                colormap='viridis',
                relative_scaling=0.5,
                min_font_size=10
            ).generate_from_frequencies(word_freq)
            
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
    
    def process_text_file(self, input_file, output_file=None, min_freq=2):
        """テキストファイルを処理してワードクラウドを生成"""
        # 出力ファイル名を自動生成
        if output_file is None:
            base_name = os.path.splitext(os.path.basename(input_file))[0]
            output_file = f"{base_name}_wordcloud.png"
        
        # テキストファイルを読み込み
        text = self.read_text_file(input_file)
        print(f"テキストファイルを読み込みました: {input_file}")
        
        # 単語を抽出
        words = self.extract_words(text)
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
    parser.add_argument('--min-freq', type=int, default=2, help='最小出現回数（デフォルト: 2）')
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