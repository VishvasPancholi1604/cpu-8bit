import os, subprocess, re, sys, argparse

dbg_mode = False
script_path = os.path.dirname(__file__)
compile_check = True

def get_args():
    parser = argparse.ArgumentParser(description="Script to automate git version control process.")
    parser.add_argument('-r', '--reset', action='store_true', help="Reset the working directory to the latest branch.")
    parser.add_argument('-p', '--push', action='store_true', help="Push changes to the current branch.")
    parser.add_argument('--push_all', action='store_true', help="Push all changes to the current branch.")
    parser.add_argument('-nc', '--no_comment', action='store_true', help='Commit without any comments.')
    parser.add_argument('-cc', '--compile_check', action='store_true', help='Push after compilation check.')
    parser.add_argument('-ncc', '--no_compile_check', action='store_true', help='Push without compilation check.')
    parser.add_argument('-dbg', '--debug', action='store_true', help='Enable debug mode.')
    parser.add_argument('-ig', '--ignore', nargs='+', help='Untrack files/directories and add them to .gitignore.')
    parser.add_argument('-pl', '--pull', action='store_true', help="Pull the latest changes from the remote repository.")
    return parser.parse_args()

def clean_terminal():
    print("\033[2J\033[H", end="")

def terminal(command, print_output=False, execute_anyways=True):
    if dbg_mode and not execute_anyways:
        print(f' > {command}')
        print('Debug mode enabled, command not fired.')
        return None, None, None
    print(f' > {command}')
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    output, error_output = [], []
    for stdout_line in process.stdout:
        if print_output:
            print(stdout_line, end="")
        output.append(stdout_line)
    for stderr_line in process.stderr:
        if print_output:
            print(stderr_line, end="")
        error_output.append(stderr_line)
    process.wait()
    return process.returncode, ''.join(output), ''.join(error_output)

def select_elements_from_list(items):
    if not items:
        print("[*ERROR] The input list is empty.")
        return []
    if len(items) == 1:
        return items
    print('Select elements from below list:')
    for i, item in enumerate(items):
        print(f"  {i}. {item}")
    user_input = input("Enter indices or ranges (e.g., '0,1,3:5,$,all'): ").strip()
    if not user_input:
        print("[*ERROR] No selection was made.")
        return []
    user_input = user_input.lower().replace(' ', '')
    if user_input in ["all", "a"]:
        return items
    elif user_input == "$":
        return [items[-1]]
    selected_indices = set()
    for part in user_input.split(","):
        if ":" in part:
            start, end = part.split(":")
            start = int(start) if start.isdigit() else (len(items) - 1 if start == "$" else None)
            end = int(end) if end.isdigit() else (len(items) - 1 if end == "$" else None)
            if start is None or end is None or start > end or start < 0 or end >= len(items):
                print(f"[*ERROR] Invalid range: {part}")
                return []
            selected_indices.update(range(start, end + 1))
        else:
            try:
                index = int(part) if part.isdigit() else (len(items) - 1 if part == "$" else None)
                if index is None or index < 0 or index >= len(items):
                    print(f"[*ERROR] Invalid index: {part}")
                    return []
                selected_indices.add(index)
            except ValueError:
                print(f"[*ERROR] Invalid index: {part}")
                return []
    return [items[i] for i in sorted(selected_indices)]

def pull_latest_changes():
    print('Pulling latest changes from remote..')
    ret, out, err = terminal('git pull origin HEAD')
    
    if ret != 0 and 'commit or stash them' in err:
        print('Unstaged changes detected. Auto-stashing before pull...')
        ret_stash, _, _ = terminal('git stash')
        
        if ret_stash == 0:
            ret_pull, out_pull, err_pull = terminal('git pull origin HEAD')
            if ret_pull != 0:
                print(f"[*ERROR] Failed to pull changes after stash:\n{err_pull}")
                print('Restoring stashed changes...')
                terminal('git stash pop')
            else:
                print("[SUCCESS] Successfully pulled latest changes.")
                print('Restoring stashed changes...')
                ret_pop, out_pop, err_pop = terminal('git stash pop')
                if ret_pop != 0:
                    print(f"[*WARNING] Merge conflicts occurred during stash pop. Please resolve manually in your editor.\n{err_pop}")
                else:
                    print("[SUCCESS] Local changes restored.")
        else:
            print("[*ERROR] Failed to stash changes. Pull aborted.")
            
    elif ret != 0:
        print(f"[*ERROR] Failed to pull changes:\n{err}")
    else:
        print("[SUCCESS] Successfully pulled latest changes.")

def reset_to_latest_branch():
    print('Moving to the Latest branch..')
    commands = [
        'git reset --hard HEAD', 'git clean -fdx', 'git fetch origin', 
        'git rev-parse --abbrev-ref HEAD'
    ]
    for cmd in commands:
        ret, _, err = terminal(cmd)
        if ret != 0:
            print(f"[ERROR] {err}")
            return
    ret, branch, _ = terminal('git rev-parse --abbrev-ref HEAD')
    if ret != 0:
        print("[ERROR] Failed to get current branch.")
        return
    ret, _, err = terminal(f'git reset --hard origin/{branch.strip()}')
    if ret != 0:
        print(f"[ERROR] {err}")
        return
    print("[SUCCESS] Reset to the latest branch state.")

def extract_changed_files():
    print('Checking for updated files..')
    _, git_status, _= terminal('git fetch && git status')
    if 'branch is behind' in git_status or 'have diverged' in git_status:
        print('[*ERROR] Your branch is behind the remote or diverged. Please pull the latest changes.')
        return None 
    status_dict = {'modified': [], 'deleted': [], 'untracked': [], 'renamed': []}
    modified_files = re.findall(r'\s+modified:\s+(.*)', git_status)
    deleted_files = re.findall(r'\s+deleted:\s+(.*)', git_status)
    untracked_files = re.findall(r'\n\t(.*)', git_status.split('Untracked files:')[1].split('\n\n')[0]) if 'Untracked files:' in git_status else []
    renamed_files = [f.split(' -> ')[-1] for f in re.findall(r'\s+renamed:\s+(.*)', git_status)]
    status_dict['modified'].extend(modified_files)
    status_dict['deleted'].extend(deleted_files)
    status_dict['untracked'].extend(untracked_files)
    status_dict['renamed'].extend(renamed_files)
    return status_dict

def display_and_return_modified_list(status):
    modified_list = []
    if status:
        print('\n------------------------------------------------')
        for section in status:
            section_list = status[section]
            if section_list:
                print(f'- {section} files:')
                for l_file in section_list:
                    print(f'  - {l_file}')
                modified_list += section_list
        print('------------------------------------------------\n')
    return modified_list

def check_compilation_status():
    print('\nChecking for compilation..')
    sim_path = os.path.join(script_path, 'sim')
    _, _, _ = terminal(f"python3 {os.path.join(sim_path, 'run.py')} --compile")
    compile_log = os.path.join(sim_path, 'xrun.log')
    if os.path.exists(compile_log):
        with open(compile_log, 'r') as file:
            data = file.read()
            if '*E' in data:
                return False
    return True

args = get_args()
dbg_mode = args.debug or dbg_mode
compile_check = True if args.compile_check else compile_check
compile_check = False if args.no_compile_check else compile_check
clean_terminal()

if args.pull:
    pull_latest_changes()
    if not (args.push or args.push_all or args.ignore or args.reset):
        sys.exit(0)

if args.ignore:
    for item in args.ignore:
        terminal(f"git rm -r --cached {item}")
        with open(".gitignore", "a") as f:
            f.write(f"{item}\n")
    terminal("git add .gitignore")
    if not (args.push or args.push_all):
        sys.exit(0)

if args.reset:
    reset_to_latest_branch()
    sys.exit(0)

modified_list = []
status = extract_changed_files()
if status is None:
    sys.exit(1)
if status: modified_list = display_and_return_modified_list(status)

if args.push or args.push_all:
    if not status: sys.exit(0)
    if not modified_list: sys.exit(0)
    selected_files = modified_list if args.push_all else select_elements_from_list(modified_list)
    if selected_files and compile_check and any(file.endswith(('.sv', '.v')) for file in selected_files):
        compiled = check_compilation_status()
        if not compiled:
            print('Compilation failed, will not push \'.sv\' or \'.v\' files.')
            selected_files = [file for file in selected_files if not file.endswith(('.sv', '.v'))]
    if not selected_files: sys.exit(0)
    print('\nAdding selected files..')
    _, _, _ = terminal(f"git add {' '.join(selected_files)}", execute_anyways=False)
    commit_msg = input('\nEnter comments for git commit: ') if not args.no_comment else ""
    _, _, _ = terminal(f"git commit --allow-empty-message -m \"{commit_msg}\"", execute_anyways=False)
    print('\nPushing changes..')
    _, _, _ = terminal('git push -u origin HEAD', execute_anyways=False)
