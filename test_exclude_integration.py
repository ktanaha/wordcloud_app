#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""統合テスト：除外機能の動作確認"""

import sys
from wordcloud_generator import JapaneseWordCloudGenerator

def test_exclude_feature():
    """除外機能の統合テスト"""
    print("=== 除外機能の統合テスト ===\n")

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
    print(f"   抽出された単語数: {len(words)}")
    print(f"   抽出された単語: {words}\n")

    # 除外なしで頻度を計算
    print("2. 除外なしで頻度を計算...")
    word_freq = generator.create_word_frequency(words, min_freq=1)
    print(f"   頻度: {word_freq}\n")

    # 「犬」を除外して頻度を計算
    print("3. 「犬」を除外して頻度を計算...")
    generator.set_exclude_words(["犬"])
    word_freq_excluded = generator.create_word_frequency(words, min_freq=1)
    print(f"   頻度: {word_freq_excluded}")

    # 検証
    if "犬" in word_freq_excluded:
        print("   ❌ エラー: 「犬」が除外されていません")
        return False
    else:
        print("   ✅ 成功: 「犬」が正しく除外されました\n")

    # 複数の単語を除外
    print("4. 「犬」と「猫」を除外して頻度を計算...")
    generator.set_exclude_words(["犬", "猫"])
    word_freq_excluded_multi = generator.create_word_frequency(words, min_freq=1)
    print(f"   頻度: {word_freq_excluded_multi}")

    # 検証
    if "犬" in word_freq_excluded_multi or "猫" in word_freq_excluded_multi:
        print("   ❌ エラー: 除外が正しく機能していません")
        return False
    else:
        print("   ✅ 成功: 複数の単語が正しく除外されました\n")

    print("=== すべてのテストが成功しました ===")
    return True

if __name__ == "__main__":
    success = test_exclude_feature()
    sys.exit(0 if success else 1)
