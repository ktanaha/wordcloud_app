#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import unittest
import os
import tkinter as tk


class TestPreviewFeature(unittest.TestCase):
    """プレビュー機能のテストクラス"""

    @classmethod
    def setUpClass(cls):
        """テストクラス全体の前処理: tkinter rootを作成"""
        cls.root = tk.Tk()
        cls.root.withdraw()  # ウィンドウを非表示にする

    @classmethod
    def tearDownClass(cls):
        """テストクラス全体の後処理: tkinter rootを破棄"""
        cls.root.destroy()

    def test_サンプルテキストファイルのパス取得(self):
        """サンプルテキストファイルのパスを正しく取得できることを確認"""
        from src.wordcloud_gui import WordCloudGUI

        # 実際のルートウィンドウを使用
        app = WordCloudGUI(self.root)

        # サンプルテキストファイルのパスを取得
        sample_path = app.get_sample_text_path()

        # パスが存在することを確認
        self.assertTrue(os.path.exists(sample_path),
                      f"サンプルテキストファイルが存在しません: {sample_path}")

        # ファイル名がsample_text.txtであることを確認
        self.assertTrue(sample_path.endswith("sample_text.txt"),
                      f"ファイル名が正しくありません: {sample_path}")

    def test_入力ファイル未指定時にサンプルテキストを使用(self):
        """入力ファイルが指定されていない場合、サンプルテキストを使用することを確認"""
        from src.wordcloud_gui import WordCloudGUI

        app = WordCloudGUI(self.root)

        # 入力ファイルパスが空の状態
        app.input_file_path.set("")

        # 使用する入力ファイルを取得
        input_file = app.get_input_file_for_processing()

        # サンプルテキストファイルのパスが返されることを確認
        self.assertTrue(input_file.endswith("sample_text.txt"),
                      f"サンプルテキストが使用されていません: {input_file}")
        # ファイルが実際に存在することを確認
        self.assertTrue(os.path.exists(input_file),
                      f"サンプルテキストファイルが存在しません: {input_file}")

    def test_入力ファイル指定時にそのファイルを使用(self):
        """入力ファイルが指定されている場合、そのファイルを使用することを確認"""
        from src.wordcloud_gui import WordCloudGUI

        app = WordCloudGUI(self.root)

        # 実際に存在するファイルパスを設定（sample_text.txtを使用）
        sample_path = app.get_sample_text_path()
        app.input_file_path.set(sample_path)

        # 使用する入力ファイルを取得
        input_file = app.get_input_file_for_processing()

        # 指定したファイルパスが返されることを確認
        self.assertEqual(input_file, sample_path,
                       f"指定したファイルが使用されていません")


if __name__ == '__main__':
    unittest.main()
