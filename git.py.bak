import os, subprocess, re, sys, argparse

dbg_mode = False
script_path = os.path.dirname(__file__)
compile_check = True


def get_args():
    parser = argparse.ArgumentParser(description="Script to automate git version control process..")
    parser.add_argument('-r', '--reset', action='store_true', help="Reset the working directory to the latest branch.")
    parser.add_argument('-p', '--push', action='store_true', help="Push changes to the current branch.")
    parser.add_argument('--push_all', action='store_true', help="Push all changes to the current branch.")
    parser.add_argument('-nc', '--no_comment', action='store_true', help='Commit without any comments.')
    parser.add_argument('-cc', '--compile_check', action='store_true', help='push after compilation check..')
    parser.add_argument('-ncc', '--no_compile_check', action='store_true', help='push without compilation check..')
    parser.add_argument('-dbg', '--debug', action='store_true', help='debug mode enable.')
    return parser.parse_args()

def clean_terminal():
    print("\033[2J\033[H", end="")

def terminal(command, print_output=False, execute_anyways=True):
    if dbg_mode and not execute_anyways:
        print(f' > {command}')
        print('debug mode enabled, command not fired..')
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

def reset_to_latest_branch():
    print(f'Moving to the Latest branch.. ')
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
    ret, _, err = terminal(f'git reset --hard origin/{branch}')
    if ret != 0:
        print(f"[ERROR] {err}")
        return
    print("[SUCCESS] Reset to the latest branch state.")

def extract_changed_files():
    print(f'Checking for updated files..')
    _, git_status, _= terminal('git fetch && git status')
    if 'Your branch is up to date' not in git_status:
        print(f'[*ERROR] Your branch is not up to date with the remote. Please pull the latest changes.')
        sys.exit(1)
    status_dict = {'modified': [], 'deleted': [], 'untracked': [], 'renamed': []}
    modified_files = re.findall(r'\s+modified:\s+(.*)', git_status)
    deleted_files = re.findall(r'\s+deleted:\s+(.*)', git_status)
    untracked_files = re.findall(r'\n\t(.*)', git_status.split('Untracked files:')[1].split('\n\n')[0]) if 'Untracked files:' in git_status else []
    renamed_files = re.findall(r'\s+renamed:\s+(.*)', git_status)
    status_dict['modified'].extend(modified_files)
    status_dict['deleted'].extend(deleted_files)
    status_dict['untracked'].extend(untracked_files)
    status_dict['renamed'].extend(renamed_files)
    return status_dict


def display_and_return_modified_list(status):
    modified_list = []
    if status:
        print(f'\n------------------------------------------------')
        for section in status:
            section_list = status[section]
            if section_list:
                print(f'- {section} files:')
                for l_file in section_list:
                    print(f'  - {l_file}')
                modified_list += section_list
        print(f'------------------------------------------------\n')
    return modified_list


def check_compilation_status():
    print(f'\nChecking for compilation..')
    sim_path = os.path.join(script_path, 'sim')
    _, _, _ =terminal(f"python3 {os.path.join(sim_path, 'run.py')} --compile")
    compile_log = os.path.join(sim_path, 'xrun.log') # FIXME: will not work with other simulators..
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


status = extract_changed_files()
if status: modified_list = display_and_return_modified_list(status)


if args.reset:
    reset_to_latest_branch()
    sys.exit(0)

if args.push or args.push_all:
    if not status: sys.exit(0)
    if not modified_list: sys.exit(0)
    selected_files = modified_list if args.push_all else select_elements_from_list(modified_list)
    if selected_files and compile_check and any(file.endswith(('.sv', '.v')) for file in selected_files):
        compiled = check_compilation_status()
        if not compiled:
            print(f'Compilation failed, will not push \'.sv\' or \'.v\' files.')
            selected_files = [file for file in selected_files if not file.endswith(('.sv', '.v'))]
    if not selected_files: sys.exit(0)
    print(f'\nAdding selected files..')
    _, _, _ = terminal(f"git add {' '.join(selected_files)}", execute_anyways=False)
    commit_msg = input('\nEnter comments for git commit: ') if not args.no_comment else ""
    _, _, _ = terminal(f"git commit --allow-empty-message -m \"{commit_msg}\"", execute_anyways=False)
    print('\nPushing changes..')
    _, _, _ = terminal('git push origin main', execute_anyways=False)

