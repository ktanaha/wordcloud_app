#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Japanese WordCloud Generator - エントリポイント
"""

import tkinter as tk
from src.wordcloud_gui import WordCloudGUI


def main():
    root = tk.Tk()
    app = WordCloudGUI(root)
    root.mainloop()


if __name__ == "__main__":
    main()
