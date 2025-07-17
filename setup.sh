#!/bin/bash

# Japanese WordCloud Generator セットアップスクリプト
# macOS環境用の自動セットアップスクリプト

set -e  # エラーが発生した場合は即座に終了

# 色付きの出力用関数
print_info() {
    echo -e "\033[0;34m[INFO]\033[0m $1"
}

print_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

print_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

print_warning() {
    echo -e "\033[0;33m[WARNING]\033[0m $1"
}

# OSの確認
check_os() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "このスクリプトはmacOS専用です"
        exit 1
    fi
    print_success "macOS環境を確認しました"
}

# Homebrewの確認とインストール
install_homebrew() {
    if command -v brew &> /dev/null; then
        print_success "Homebrewは既にインストールされています"
        brew update
    else
        print_info "Homebrewをインストールしています..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Apple Silicon Macの場合、PATHを設定
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        print_success "Homebrewのインストールが完了しました"
    fi
}

# MeCabのインストール
install_mecab() {
    print_info "MeCabをインストールしています..."
    
    if brew list mecab &> /dev/null; then
        print_success "MeCabは既にインストールされています"
    else
        brew install mecab mecab-ipadic
        print_success "MeCabのインストールが完了しました"
    fi
    
    # MeCabの動作確認
    if mecab -v &> /dev/null; then
        print_success "MeCabの動作確認OK"
    else
        print_error "MeCabのインストールに失敗しました"
        exit 1
    fi
}

# Pythonの確認
check_python() {
    if command -v python3 &> /dev/null; then
        python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        print_success "Python $python_version が見つかりました"
        
        # Python 3.7以上かチェック
        if python3 -c 'import sys; exit(0 if sys.version_info >= (3, 7) else 1)'; then
            print_success "Pythonのバージョンは要件を満たしています"
        else
            print_error "Python 3.7以上が必要です。現在のバージョン: $python_version"
            print_info "Homebrewを使用してPythonをアップデートしてください: brew install python"
            exit 1
        fi
    else
        print_error "Python3が見つかりません"
        print_info "Homebrewを使用してPythonをインストールしています..."
        brew install python
    fi
}

# 仮想環境の作成とアクティベート
setup_virtual_environment() {
    print_info "Python仮想環境を作成しています..."
    
    # 既存の仮想環境があれば削除
    if [ -d "venv" ]; then
        print_warning "既存の仮想環境を削除しています..."
        rm -rf venv
    fi
    
    python3 -m venv venv
    source venv/bin/activate
    
    # pipのアップグレード
    pip install --upgrade pip
    
    print_success "仮想環境の作成が完了しました"
}

# Pythonパッケージのインストール
install_python_packages() {
    print_info "Pythonパッケージをインストールしています..."
    
    # 仮想環境がアクティブかチェック
    if [[ "$VIRTUAL_ENV" == "" ]]; then
        print_error "仮想環境がアクティブではありません"
        exit 1
    fi
    
    # requirements.txtが存在するかチェック
    if [ -f "requirements.txt" ]; then
        pip install -r requirements.txt
        print_success "requirements.txtからパッケージをインストールしました"
    else
        print_warning "requirements.txtが見つかりません。個別にパッケージをインストールします..."
        pip install mecab-python3 wordcloud matplotlib Pillow numpy pandas sudachipy
        print_success "必要なパッケージをインストールしました"
    fi
}

# MeCab Pythonバインディングのテスト
test_mecab_python() {
    print_info "MeCab Pythonバインディングをテストしています..."
    
    python3 -c "
import MeCab
tagger = MeCab.Tagger()
result = tagger.parse('これはテストです')
print('MeCabテスト結果:', result.strip())
" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        print_success "MeCab Pythonバインディングのテストが成功しました"
    else
        print_error "MeCab Pythonバインディングのテストが失敗しました"
        print_info "MeCabを再インストールしています..."
        brew reinstall mecab mecab-ipadic
        pip install --force-reinstall mecab-python3
    fi
}

# 実行権限の設定
set_permissions() {
    print_info "実行権限を設定しています..."
    
    # Pythonスクリプトに実行権限を付与
    find . -name "*.py" -exec chmod +x {} \;
    
    print_success "実行権限の設定が完了しました"
}

# サンプルテストの実行
run_sample_test() {
    print_info "サンプルテストを実行しています..."
    
    # sample_text.txtが存在するかチェック
    if [ -f "sample_text.txt" ]; then
        print_info "sample_text.txtでワードクラウドを生成しています..."
        
        if [ -f "wordcloud_generator.py" ]; then
            python wordcloud_generator.py sample_text.txt -o test_wordcloud.png
            
            if [ -f "test_wordcloud.png" ]; then
                print_success "サンプルワードクラウドの生成が成功しました: test_wordcloud.png"
                rm test_wordcloud.png  # テストファイルを削除
            else
                print_warning "ワードクラウド画像の生成に失敗しました"
            fi
        else
            print_warning "wordcloud_generator.pyが見つかりません"
        fi
    else
        print_warning "sample_text.txtが見つかりません。サンプルテストをスキップします"
    fi
}

# セットアップ完了メッセージ
print_completion_message() {
    echo ""
    print_success "==================================="
    print_success "セットアップが完了しました！"
    print_success "==================================="
    echo ""
    print_info "使用方法:"
    echo "  1. 仮想環境をアクティベート: source venv/bin/activate"
    echo "  2. ワードクラウドを生成: python wordcloud_generator.py [入力ファイル]"
    echo ""
    print_info "例:"
    echo "  python wordcloud_generator.py sample_text.txt"
    echo "  python wordcloud_generator.py my_text.txt -o my_wordcloud.png"
    echo ""
    print_info "詳細な使用方法はREADME.mdを参照してください"
    echo ""
}

# メイン実行部分
main() {
    echo ""
    print_info "Japanese WordCloud Generator セットアップを開始します..."
    echo ""
    
    # 各セットアップステップを実行
    check_os
    install_homebrew
    install_mecab
    check_python
    setup_virtual_environment
    install_python_packages
    test_mecab_python
    set_permissions
    run_sample_test
    print_completion_message
}

# スクリプトの実行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi