#!/bin/bash
# 删除旧版本: nastools/shared/nas-tools
rm -rf shared/nas-tools
git clone https://github.com/hsuyelin/nas-tools shared/nas-tools
# 删除多余文件docker, .git, .github
rm -rf shared/nas-tools/docker
rm -rf shared/nas-tools/.git
rm -rf shared/nas-tools/.github