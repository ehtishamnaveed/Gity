import os
import subprocess
import shutil
from pathlib import Path

# Color constants
RED = "\033[0;31m"
GREEN = "\033[0;32m"
YELLOW = "\033[1;33m"
BLUE = "\033[0;34m"
NC = "\033[0m"

REQUIRED_DEPS = ["git", "fzf", "lazygit"]

def check_deps():
    missing = []
    for dep in REQUIRED_DEPS:
        if not shutil.which(dep):
            missing.append(dep)
    
    if missing:
        print(f"{RED}Missing dependencies: {', '.join(missing)}{NC}")
        print(f"{YELLOW}Please install them and try again.{NC}")
        return False
    return True

def find_repos(search_path):
    repos = []
    for root, dirs, files in os.walk(search_path):
        if '.git' in dirs:
            repos.append(root)
            dirs.remove('.git') # Don't search inside .git
    return repos

def run_fzf(options, header="Select a repository"):
    process = subprocess.Popen(
        ['fzf', '--header', header, '--height', '40%', '--border'],
        stdin=subprocess.PIPE,
        stdout=subprocess.PIPE,
        text=True
    )
    stdout, _ = process.communicate(input='\n'.join(options))
    return stdout.strip()

def main():
    if not check_deps():
        return

    home = str(Path.home())
    print(f"{BLUE}Scanning for repositories in {home}...{NC}")
    
    # Simple scan for demo purposes
    # In a real app, you'd want to cache this or use a more efficient scan
    repos = find_repos(home)
    
    if not repos:
        print(f"{YELLOW}No repositories found.{NC}")
        return

    repo_names = [os.path.basename(r) + f"  ({r})" for r in repos]
    selected = run_fzf(repo_names)
    
    if selected:
        # Extract path from selection "name  (/path/to/repo)"
        repo_path = selected.split("  (")[-1].rstrip(")")
        print(f"{GREEN}Opening {repo_path} in lazygit...{NC}")
        subprocess.run(['lazygit', '-p', repo_path])

if __name__ == "__main__":
    main()
