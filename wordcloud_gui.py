#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
import threading
import os
import sys
from PIL import Image, ImageTk
import matplotlib.pyplot as plt
from wordcloud_generator import JapaneseWordCloudGenerator
from collections import Counter

class WordCloudGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("Japanese WordCloud Generator")
        self.root.geometry("900x700")
        
        # 変数の初期化
        self.input_file_path = tk.StringVar()
        self.output_file_path = tk.StringVar(value="wordcloud_output.png")
        self.dict_file_path = tk.StringVar()
        
        # パラメータ変数
        self.width = tk.IntVar(value=800)
        self.height = tk.IntVar(value=600)
        self.min_freq = tk.IntVar(value=1)
        self.max_words = tk.IntVar(value=100)
        self.background_color = tk.StringVar(value="white")
        self.colormap = tk.StringVar(value="viridis")
        
        # ワードクラウドジェネレーター
        self.generator = None
        
        # GUI構築
        self.create_widgets()
        
    def create_widgets(self):
        # メインフレーム
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # ファイル選択セクション
        self.create_file_section(main_frame)
        
        # パラメータ設定セクション
        self.create_parameter_section(main_frame)
        
        # 実行ボタンとプログレスバー
        self.create_control_section(main_frame)
        
        # プレビューとログセクション
        self.create_preview_section(main_frame)
        
        # グリッド設定
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        
    def create_file_section(self, parent):
        # ファイル選択フレーム
        file_frame = ttk.LabelFrame(parent, text="ファイル設定", padding="10")
        file_frame.grid(row=0, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # 入力ファイル
        ttk.Label(file_frame, text="入力テキストファイル:").grid(row=0, column=0, sticky=tk.W, pady=2)
        ttk.Entry(file_frame, textvariable=self.input_file_path, width=50).grid(row=0, column=1, sticky=(tk.W, tk.E), padx=(5, 5), pady=2)
        ttk.Button(file_frame, text="参照", command=self.browse_input_file).grid(row=0, column=2, pady=2)
        
        # 出力ファイル
        ttk.Label(file_frame, text="出力画像ファイル:").grid(row=1, column=0, sticky=tk.W, pady=2)
        ttk.Entry(file_frame, textvariable=self.output_file_path, width=50).grid(row=1, column=1, sticky=(tk.W, tk.E), padx=(5, 5), pady=2)
        ttk.Button(file_frame, text="参照", command=self.browse_output_file).grid(row=1, column=2, pady=2)
        
        # 辞書ファイル（オプション）
        ttk.Label(file_frame, text="MeCab辞書ファイル (オプション):").grid(row=2, column=0, sticky=tk.W, pady=2)
        ttk.Entry(file_frame, textvariable=self.dict_file_path, width=50).grid(row=2, column=1, sticky=(tk.W, tk.E), padx=(5, 5), pady=2)
        ttk.Button(file_frame, text="参照", command=self.browse_dict_file).grid(row=2, column=2, pady=2)
        
        file_frame.columnconfigure(1, weight=1)
        
    def create_parameter_section(self, parent):
        # パラメータ設定フレーム
        param_frame = ttk.LabelFrame(parent, text="ワードクラウド設定", padding="10")
        param_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # 左側のパラメータ
        left_frame = ttk.Frame(param_frame)
        left_frame.grid(row=0, column=0, sticky=(tk.W, tk.N), padx=(0, 20))
        
        # 画像サイズ
        ttk.Label(left_frame, text="画像幅:").grid(row=0, column=0, sticky=tk.W, pady=2)
        width_spinbox = ttk.Spinbox(left_frame, from_=200, to=2000, textvariable=self.width, width=10)
        width_spinbox.grid(row=0, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        ttk.Label(left_frame, text="画像高さ:").grid(row=1, column=0, sticky=tk.W, pady=2)
        height_spinbox = ttk.Spinbox(left_frame, from_=200, to=2000, textvariable=self.height, width=10)
        height_spinbox.grid(row=1, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        ttk.Label(left_frame, text="最小出現回数:").grid(row=2, column=0, sticky=tk.W, pady=2)
        freq_spinbox = ttk.Spinbox(left_frame, from_=1, to=10, textvariable=self.min_freq, width=10)
        freq_spinbox.grid(row=2, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        ttk.Label(left_frame, text="最大単語数:").grid(row=3, column=0, sticky=tk.W, pady=2)
        words_spinbox = ttk.Spinbox(left_frame, from_=10, to=500, textvariable=self.max_words, width=10)
        words_spinbox.grid(row=3, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        # 右側のパラメータ
        right_frame = ttk.Frame(param_frame)
        right_frame.grid(row=0, column=1, sticky=(tk.W, tk.N))
        
        ttk.Label(right_frame, text="背景色:").grid(row=0, column=0, sticky=tk.W, pady=2)
        bg_combo = ttk.Combobox(right_frame, textvariable=self.background_color, width=15)
        bg_combo['values'] = ('white', 'black', 'lightgray', 'lightblue', 'lightgreen')
        bg_combo.grid(row=0, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
        ttk.Label(right_frame, text="カラーマップ:").grid(row=1, column=0, sticky=tk.W, pady=2)
        color_combo = ttk.Combobox(right_frame, textvariable=self.colormap, width=15)
        color_combo['values'] = ('viridis', 'plasma', 'inferno', 'magma', 'coolwarm', 'rainbow', 'tab10')
        color_combo.grid(row=1, column=1, sticky=tk.W, padx=(5, 0), pady=2)
        
    def create_control_section(self, parent):
        # 制御フレーム
        control_frame = ttk.Frame(parent)
        control_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # 実行ボタン
        self.generate_btn = ttk.Button(control_frame, text="ワードクラウド生成", command=self.generate_wordcloud)
        self.generate_btn.grid(row=0, column=0, padx=(0, 10))
        
        # プレビューボタン
        self.preview_btn = ttk.Button(control_frame, text="プレビュー", command=self.preview_wordcloud)
        self.preview_btn.grid(row=0, column=1, padx=(0, 10))
        
        # プログレスバー
        self.progress = ttk.Progressbar(control_frame, mode='indeterminate')
        self.progress.grid(row=0, column=2, sticky=(tk.W, tk.E), padx=(10, 0))
        
        control_frame.columnconfigure(2, weight=1)
        
    def create_preview_section(self, parent):
        # プレビューとログのノートブック
        notebook = ttk.Notebook(parent)
        notebook.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        
        # プレビュータブ
        preview_frame = ttk.Frame(notebook)
        notebook.add(preview_frame, text="プレビュー")
        
        # プレビュー用キャンバス
        self.preview_canvas = tk.Canvas(preview_frame, bg='white', width=400, height=300)
        self.preview_canvas.pack(expand=True, fill=tk.BOTH, padx=10, pady=10)
        
        # ログタブ
        log_frame = ttk.Frame(notebook)
        notebook.add(log_frame, text="ログ")
        
        # ログ表示用テキストウィジェット
        self.log_text = scrolledtext.ScrolledText(log_frame, height=15)
        self.log_text.pack(expand=True, fill=tk.BOTH, padx=10, pady=10)
        
        parent.rowconfigure(3, weight=1)
        
    def browse_input_file(self):
        filename = filedialog.askopenfilename(
            title="入力テキストファイルを選択",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")]
        )
        if filename:
            self.input_file_path.set(filename)
            
    def browse_output_file(self):
        filename = filedialog.asksaveasfilename(
            title="出力画像ファイルを保存",
            defaultextension=".png",
            filetypes=[("PNG files", "*.png"), ("JPEG files", "*.jpg"), ("All files", "*.*")]
        )
        if filename:
            self.output_file_path.set(filename)
            
    def browse_dict_file(self):
        filename = filedialog.askopenfilename(
            title="MeCab辞書ファイルを選択",
            filetypes=[("Dictionary files", "*.dic"), ("All files", "*.*")]
        )
        if filename:
            self.dict_file_path.set(filename)
            
    def log_message(self, message):
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        self.root.update()
        
    def init_generator(self):
        try:
            dict_path = self.dict_file_path.get().strip()
            if dict_path and os.path.exists(dict_path):
                self.log_message(f"カスタム辞書を使用: {dict_path}")
                # カスタム辞書を使用する場合の実装は後で追加
                self.generator = JapaneseWordCloudGenerator()
            else:
                self.generator = JapaneseWordCloudGenerator()
            return True
        except Exception as e:
            self.log_message(f"MeCabの初期化に失敗: {e}")
            messagebox.showerror("エラー", f"MeCabの初期化に失敗しました:\n{e}")
            return False
            
    def generate_wordcloud_thread(self, preview_mode=False):
        try:
            self.progress.start()
            
            if not self.init_generator():
                return
                
            input_file = self.input_file_path.get()
            if not input_file or not os.path.exists(input_file):
                self.root.after(0, lambda: messagebox.showerror("エラー", "入力ファイルを選択してください"))
                return
                
            self.log_message("テキストファイルを読み込み中...")
            text = self.generator.read_text_file(input_file)
            
            self.log_message("形態素解析を実行中...")
            # デバッグファイルの出力先を設定
            debug_file = f"{os.path.splitext(input_file)[0]}_debug.txt"
            words = self.generator.extract_words(text, debug_output=debug_file)
            self.log_message(f"抽出された単語数: {len(words)}")
            self.log_message(f"デバッグ情報を出力: {debug_file}")
            
            self.log_message("単語の頻度を計算中...")
            word_freq = self.generator.create_word_frequency(words, self.min_freq.get())
            self.log_message(f"有効な単語数: {len(word_freq)}")
            
            if word_freq:
                word_counter = Counter(word_freq)
                top_words = dict(word_counter.most_common(10))
                self.log_message(f"上位10単語: {top_words}")
                
                self.log_message("ワードクラウドを生成中...")
                
                # カスタムパラメータでワードクラウドを生成
                output_file = "preview_temp.png" if preview_mode else self.output_file_path.get()
                success = self.generate_custom_wordcloud(word_freq, output_file)
                
                if success:
                    if preview_mode:
                        self.show_preview(output_file)
                        # テンポラリファイルを削除
                        if os.path.exists(output_file):
                            os.remove(output_file)
                    else:
                        self.log_message(f"ワードクラウドを保存しました: {output_file}")
                        # メインスレッドでメッセージボックスを表示
                        self.root.after(0, lambda: messagebox.showinfo("完了", f"ワードクラウドの生成が完了しました:\n{output_file}"))
                else:
                    self.root.after(0, lambda: messagebox.showerror("エラー", "ワードクラウドの生成に失敗しました"))
            else:
                self.root.after(0, lambda: messagebox.showwarning("警告", "有効な単語が見つかりませんでした"))
                
        except Exception as e:
            self.log_message(f"エラー: {e}")
            # メインスレッドでメッセージボックスを表示
            self.root.after(0, lambda: messagebox.showerror("エラー", f"処理中にエラーが発生しました:\n{e}"))
        finally:
            # メインスレッドでUI更新
            self.root.after(0, self.reset_ui_state)
            
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
                self.log_message(f"日本語フォントを検出: {path}")
                return path
        
        self.log_message("警告: 日本語フォントが見つかりませんでした。英数字のみ表示される可能性があります。")
        return None

    def generate_custom_wordcloud(self, word_freq, output_path):
        try:
            from wordcloud import WordCloud
            
            # 日本語フォントを検出
            font_path = self.find_japanese_font()
            
            # WordCloudのパラメータ設定
            wordcloud_params = {
                'width': self.width.get(),
                'height': self.height.get(),
                'background_color': self.background_color.get(),
                'max_words': self.max_words.get(),
                'colormap': self.colormap.get(),
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
            
            # 画像として保存（Matplotlibを使わずに直接保存）
            wordcloud.to_file(output_path)
            
            return True
            
        except Exception as e:
            self.log_message(f"ワードクラウド生成エラー: {e}")
            return False
            
    def show_preview(self, image_path):
        try:
            # 画像を読み込み
            image = Image.open(image_path)
            
            # キャンバスサイズに合わせてリサイズ
            canvas_width = self.preview_canvas.winfo_width()
            canvas_height = self.preview_canvas.winfo_height()
            
            if canvas_width > 1 and canvas_height > 1:
                image.thumbnail((canvas_width-20, canvas_height-20), Image.Resampling.LANCZOS)
                
                # PhotoImageに変換
                photo = ImageTk.PhotoImage(image)
                
                # キャンバスに表示
                self.preview_canvas.delete("all")
                x = canvas_width // 2
                y = canvas_height // 2
                self.preview_canvas.create_image(x, y, anchor=tk.CENTER, image=photo)
                
                # 参照を保持（ガベージコレクション防止）
                self.preview_canvas.image = photo
                
                self.log_message("プレビューを更新しました")
                
        except Exception as e:
            self.log_message(f"プレビュー表示エラー: {e}")
            
    def reset_ui_state(self):
        self.progress.stop()
        self.generate_btn.config(state='normal')
        self.preview_btn.config(state='normal')
            
    def generate_wordcloud(self):
        self.generate_btn.config(state='disabled')
        self.preview_btn.config(state='disabled')
        threading.Thread(target=self.generate_wordcloud_thread, daemon=True).start()
        
    def preview_wordcloud(self):
        self.generate_btn.config(state='disabled')
        self.preview_btn.config(state='disabled')
        threading.Thread(target=self.generate_wordcloud_thread, args=(True,), daemon=True).start()

def main():
    root = tk.Tk()
    app = WordCloudGUI(root)
    root.mainloop()

if __name__ == "__main__":
    main()