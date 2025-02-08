#!/bin/bash

# 配置常量
BRANCH_NAME="master"

# 检查当前是否有远程仓库
REMOTE_URL=$(git config --get remote.origin.url 2>/dev/null)
if [ -z "$REMOTE_URL" ]; then
  echo "未包含远程仓库，结束。"
  exit 1
fi

# 检查当前分支是否为BRANCH_NAME分支
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ "$CURRENT_BRANCH" != "$BRANCH_NAME" ]; then
  echo "当前分支非$BRANCH_NAME，开始切换..."
  # 尝试切换到指定分支
  git checkout "$BRANCH_NAME" 2>/dev/null
  if [ $? -ne 0 ]; then
    echo "切换分支失败，请检查分支名称是否正确或是否有权限访问该分支。"
    exit 1
  fi
else
  echo "当前分支已是$BRANCH_NAME。"
fi

# 拉取变更
echo "开始拉取远程变更..."
git pull origin "$BRANCH_NAME" 2>&1
if [ $? -eq 0 ]; then
  echo "更新变更成功。"
else
  echo "拉取变更失败，错误原因：$?"
  # 这里$?会返回上一个命令的退出状态码，但通常错误信息已经通过2>&1重定向到标准输出了
  # 如果需要更详细的错误信息，可以考虑使用git pull的--rebase选项并捕获其输出进行分析
fi