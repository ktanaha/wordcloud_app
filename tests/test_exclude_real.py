#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""統合テスト：実際に抽出される単語を除外"""

import sys
from src.wordcloud_generator import JapaneseWordCloudGenerator

def test_exclude_real_words():
    """実際に抽出される単語を除外するテスト"""
    print("=== 実際に抽出される単語を除外するテスト ===\n")

    # ジェネレーターを初期化
    generator = JapaneseWordCloudGenerator()

    # テストテキスト
    test_text = """
    犬が好きです。猫も好きです。鳥も好きです。
    犬はかわいいです。猫もかわいいです。
    犬と遊びました。猫と遊びました。鳥を見ました。
    犬は元気です。猫は静かです。鳥は自由です。
    犬、猫、鳥、すべて素晴らしい動物です。
    """

    # 単語を抽出
    print("1. 単語を抽出中...")
    words = generator.extract_words(test_text)
    print(f"   抽出された単語: {words}\n")

    # 除外なしで頻度を計算
    print("2. 除外なしで頻度を計算...")
    word_freq = generator.create_word_frequency(words, min_freq=1)
    print(f"   頻度: {word_freq}\n")

    # 「好き」を除外して頻度を計算
    print("3. 「好き」を除外して頻度を計算...")
    generator.set_exclude_words(["好き"])
    word_freq_excluded = generator.create_word_frequency(words, min_freq=1)
    print(f"   頻度: {word_freq_excluded}")

    # 検証
    if "好き" in word_freq_excluded:
        print("   ❌ エラー: 「好き」が除外されていません")
        return False
    else:
        print("   ✅ 成功: 「好き」が正しく除外されました")
        # 除外前後での単語数を確認
        count_before = len(word_freq)
        count_after = len(word_freq_excluded)
        print(f"   除外前の単語数: {count_before}")
        print(f"   除外後の単語数: {count_after}\n")

    # 複数の単語を除外
    print("4. 「好き」と「遊び」を除外して頻度を計算...")
    generator.set_exclude_words(["好き", "遊び"])
    word_freq_excluded_multi = generator.create_word_frequency(words, min_freq=1)
    print(f"   頻度: {word_freq_excluded_multi}")

    # 検証
    if "好き" in word_freq_excluded_multi or "遊び" in word_freq_excluded_multi:
        print("   ❌ エラー: 除外が正しく機能していません")
        return False
    else:
        print("   ✅ 成功: 複数の単語が正しく除外されました")
        count_multi = len(word_freq_excluded_multi)
        print(f"   除外後の単語数: {count_multi}\n")

    print("=== すべてのテストが成功しました ===")
    return True

if __name__ == "__main__":
    success = test_exclude_real_words()
    sys.exit(0 if success else 1)
