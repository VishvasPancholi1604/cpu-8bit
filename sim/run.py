import os, subprocess, argparse
from datetime import datetime

# script path
script_path = os.path.dirname(os.path.realpath(__file__))
project_dir = os.path.dirname(script_path)
results_dir = os.path.join(script_path, 'sim_data')
os.makedirs(results_dir, exist_ok=True)

# keep this on for Xcelium Simulator
is_xcelium = True

# project specifics
include_list = [
        'rtl'
        # 'verif', 
        # 'verif/src/', 
        # 'verif/tests/', 
        # 'verif/ref_model/'
]
includes = ' '.join([(f'-incdir {os.path.join(project_dir, include)}') for include in include_list])
# top_module_path = os.path.join(project_dir, 'top.sv')
top_module_path = os.path.join(project_dir, 'rtl', 'cpu.sv')
timescale = '1ns/1ns'


# Fire command on terminal..
def terminal(command, working_dir=results_dir):
    print(f'>> {command}\n')
    output = []
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, cwd=working_dir)
    for line in process.stdout:
        print(line, end="") 
        output.append(line)
    process.wait()
    return process.returncode, ''.join(output)


# Argument parser
def get_args():
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('--compile', action='store_true', help='compile only, do not simulate')
    parser.add_argument('-noc', '--no_compile', action='store_true', help='do not compile, simulate only')
    parser.add_argument('-w', '--waves', action='store_true', help='')
    parser.add_argument('--asm', action='store_true', help='select asm file to load')
    args = parser.parse_args()
    return args


# clear the terminal
def clean_terminal():
    print("\033[2J\033[H", end="")


# returns date-time in "dd_mm_yyyy_hr_min_sec" format
def get_custom_datetime():
    return datetime.now().strftime("%d_%m_%Y_%H_%M_%S")


# print list elements with index
def print_list_with_idx(l_list=None, print_idx=True, start_from_one=False, whitespaces=2):
    if l_list is None:
        l_list = []
    for idx, name in enumerate(l_list):
        count = idx + 1 if start_from_one else idx
        if print_idx:
            print(f'{" " * whitespaces}{count}. {name}')
        else:
            print(f'{" " * whitespaces}{name}')


# get integer output from user input string 
def get_integer_input(prompt_message, min_value=None, max_value=None):
    global console
    try:
        user_input = input(f"{prompt_message}: ")
        user_input = int(user_input)
        if min_value is not None and max_value is not None:
            if min_value <= user_input <= max_value:
                return user_input
            else:
                return None
        else:
            return user_input
    except ValueError:
        return None


def select_and_load_asm_file(path, choose_asm=False):
    if not choose_asm and 'memory.list' in os.listdir(script_path): 
        print(f'Using the existing \'memory.list\' file..')
        return
    if choose_asm or 'memory.list' not in os.listdir(results_dir):
        asm_files, asm_paths = zip(*[(file, os.path.join(path, file)) for file in os.listdir(path) if file.endswith('.asm')])
        print_list_with_idx(asm_files)
        selected_idx = get_integer_input('Select index of \'.asm\' file', 0, len(asm_files)-1)
        if selected_idx==None:
            print(f'Invalid input provided..')
            print(f'Selected asm file: {asm_paths[0]}')
            selected_idx = 0
        asm_file = asm_files[selected_idx]
        asm_path = asm_paths[selected_idx]
        status, _ = terminal(f"python3 {os.path.join(script_path, 'asm.py')} {asm_path}")
        if status:
            print(f'Failed to generate \'memory.list\' file..')
        else:
            print(f'generated \'memory.list\' file in \'sim\' directory..')


def main():
    args = get_args()
    compile_args = f'-uvm {includes} +UVM_NO_RELNOTES +define+UVM_REPORT_DISABLE_FILE -licqueue +access+r'
    shm_path = os.path.join(script_path, 'shm.tcl')
    command = f"xrun {top_module_path} -licqueue {compile_args} -input {shm_path} +UVM_TESTNAME=cpu_base_test_c"
    compile_file_path = os.path.join(results_dir, f'xcelium.d/')
    if args.compile:
        command += ' -compile'
    if args.no_compile:
        command = f'xrun -xmlibdirname {compile_file_path} -R -input {shm_path} +UVM_TESTNAME=cpu_base_test_c'
    if args.waves:
        command += ' -access +rwc -gui &'
    # select_and_load_asm_file(asm_files_path, choose_asm=True if args.asm else False)
    _, output = terminal(command)
    

if __name__ == '__main__':
    main()
