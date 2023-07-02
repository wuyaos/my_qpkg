#!/bin/bash
# 删除旧版本: nastools/shared/nas-tools
rm -rf shared/*
wget https://github.com/coder/code-server/releases/download/v4.14.1/code-server-4.14.1-linux-amd64.tar.gz

# 解压
tar -zxvf code-server-4.14.1-linux-amd64.tar.gz -C shared/

cp vscode.sh vscode/shared/