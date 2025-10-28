#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import unittest
from unittest.mock import MagicMock, patch
from wordcloud_generator import JapaneseWordCloudGenerator


class TestExcludeWords(unittest.TestCase):
    """除外単語機能のテストクラス"""

    def setUp(self):
        """各テストの前処理"""
        # MeCabのモックを作成してテストを高速化
        with patch('MeCab.Tagger'):
            self.generator = JapaneseWordCloudGenerator()

    def test_除外単語リストの初期化(self):
        """除外単語リストが空のリストとして初期化されることを確認"""
        self.assertEqual(self.generator.exclude_words, [])

    def test_除外単語の追加(self):
        """除外単語を追加できることを確認"""
        self.generator.add_exclude_word("テスト")
        self.assertIn("テスト", self.generator.exclude_words)

    def test_複数の除外単語の追加(self):
        """複数の除外単語を追加できることを確認"""
        words = ["単語1", "単語2", "単語3"]
        self.generator.set_exclude_words(words)
        self.assertEqual(self.generator.exclude_words, words)

    def test_除外単語のクリア(self):
        """除外単語リストをクリアできることを確認"""
        self.generator.set_exclude_words(["単語1", "単語2"])
        self.generator.clear_exclude_words()
        self.assertEqual(self.generator.exclude_words, [])

    def test_頻度計算時に除外単語が除かれる(self):
        """頻度計算時に除外単語が除かれることを確認"""
        # テスト用の単語リスト
        words = ["犬", "猫", "鳥", "犬", "猫", "犬"]

        # "犬"を除外単語に設定
        self.generator.set_exclude_words(["犬"])

        # 頻度計算
        word_freq = self.generator.create_word_frequency(words, min_freq=1)

        # "犬"が除外されていることを確認
        self.assertNotIn("犬", word_freq)
        # "猫"と"鳥"は含まれることを確認
        self.assertIn("猫", word_freq)
        self.assertIn("鳥", word_freq)
        # 頻度が正しいことを確認
        self.assertEqual(word_freq["猫"], 2)
        self.assertEqual(word_freq["鳥"], 1)

    def test_除外単語が空の場合は全て含まれる(self):
        """除外単語リストが空の場合、すべての単語が含まれることを確認"""
        words = ["犬", "猫", "鳥", "犬", "猫", "犬"]

        # 除外単語なし
        self.generator.set_exclude_words([])

        # 頻度計算
        word_freq = self.generator.create_word_frequency(words, min_freq=1)

        # すべての単語が含まれることを確認
        self.assertIn("犬", word_freq)
        self.assertIn("猫", word_freq)
        self.assertIn("鳥", word_freq)
        self.assertEqual(word_freq["犬"], 3)
        self.assertEqual(word_freq["猫"], 2)
        self.assertEqual(word_freq["鳥"], 1)

    def test_複数の除外単語が正しく除外される(self):
        """複数の除外単語が正しく除外されることを確認"""
        words = ["犬", "猫", "鳥", "魚", "犬", "猫", "犬", "鳥"]

        # "犬"と"鳥"を除外
        self.generator.set_exclude_words(["犬", "鳥"])

        # 頻度計算
        word_freq = self.generator.create_word_frequency(words, min_freq=1)

        # 除外単語が除かれていることを確認
        self.assertNotIn("犬", word_freq)
        self.assertNotIn("鳥", word_freq)
        # 除外されていない単語は含まれることを確認
        self.assertIn("猫", word_freq)
        self.assertIn("魚", word_freq)

    def test_除外単語と最小頻度フィルタの併用(self):
        """除外単語と最小頻度フィルタが併用できることを確認"""
        words = ["犬", "猫", "鳥", "魚", "犬", "猫", "犬"]

        # "犬"を除外、最小頻度2
        self.generator.set_exclude_words(["犬"])
        word_freq = self.generator.create_word_frequency(words, min_freq=2)

        # "犬"は除外されている
        self.assertNotIn("犬", word_freq)
        # "猫"は頻度2で含まれる
        self.assertIn("猫", word_freq)
        # "鳥"と"魚"は頻度1なので除外される
        self.assertNotIn("鳥", word_freq)
        self.assertNotIn("魚", word_freq)


if __name__ == "__main__":
    unittest.main()
