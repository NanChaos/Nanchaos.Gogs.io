#!/bin/bash

# 设置提交信息
commit_message="Automated commit of all files in current directory and subdirectories"

# 设置远程分支名称（根据需要修改）
remote_branch="master"

# 检查是否在 Git 仓库中
if [ ! -d ".git" ]; then
  echo "当前目录不是一个Git仓库。"
  exit 1
fi

# 检查是否有未添加的文件
unadded_files=$(git status --porcelain | grep -E '^ M ')
if [ ! -z "$unadded_files" ]; then
  echo "发现未添加的文件，正在添加..."
  git add .
fi

# 检查是否有待提交的更改
if [ -z "$(git status --porcelain)" ]; then
  echo "没有待提交的更改。"
  # 如果没有待提交的更改，则直接退出，因为没有内容需要推送
  exit 0
fi

# 提交更改
echo "Committing changes with message: $commit_message"
git commit -m "$commit_message"

# 检查是否有未推送的更改
unpushed_commits=$(git log origin/$remote_branch..HEAD --oneline)
if [ -z "$unpushed_commits" ]; then
  echo "没有未推送的更改。"
  # 如果没有未推送的更改，则直接退出
  exit 0
else
  echo "发现未推送的更改，正在推送..."
  git push origin "$remote_branch"

  if [ $? -eq 0 ]; then
    echo "推送成功。"
  else
    echo "推送失败。"
    exit 1
  fi
fi

echo "操作完成。"