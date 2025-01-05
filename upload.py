import os
import subprocess

# 指定要操作的目录
directory = 'xxx'
commit_message = 'Automated commit of all files in directory'
remote_branch = 'main'  # 或者你使用的任何分支名称

# 检查是否在Git仓库中
git_dir = os.path.join(directory, '.git')
if not os.path.exists(git_dir):
    print(f"目录 {directory} 不是一个Git仓库。")
    exit(1)

# 切换到指定目录
os.chdir(directory)

try:
    # 添加所有更改的文件
    print(f"Adding all changed files in {directory}...")
    subprocess.run(['git', 'add', '.'], check=True)

    # 提交更改
    print(f"Committing changes with message: {commit_message}")
    subprocess.run(['git', 'commit', '-m', commit_message], check=True)

    # 推送更改到远程仓库
    print(f"Pushing changes to remote repository on branch {remote_branch}...")
    subprocess.run(['git', 'push', 'origin', remote_branch], check=True)

    print("操作完成。")
except subprocess.CalledProcessError as e:
    print(f"Git 命令执行失败: {e}")
    exit(1)