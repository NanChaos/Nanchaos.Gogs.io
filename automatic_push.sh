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

# 添加当前目录及其子目录下的所有更改的文件
echo "Adding all changed files in current directory and subdirectories..."
git add .

# 检查是否有待提交的更改
if [ -z "$(git status --porcelain)" ]; then
  echo "没有待提交的更改。"
  exit 0
fi

# 提交更改
echo "Committing changes with message: $commit_message"
git commit -m "$commit_message"

# 推送更改到远程仓库
echo "Pushing changes to remote repository on branch $remote_branch..."
git push origin "$remote_branch"

echo "操作完成。"