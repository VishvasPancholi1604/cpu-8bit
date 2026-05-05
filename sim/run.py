import os, subprocess, argparse, sys
from datetime import datetime

# constants
timescale = '1ns/1ns'

# script path
script_path = os.path.dirname(os.path.realpath(__file__))
project_dir = os.path.dirname(script_path)
results_dir = os.path.join(script_path, 'sim_data')
svcf_path = os.path.join(script_path, 'cpu.svcf')
os.makedirs(results_dir, exist_ok=True)
waves_dir = os.path.join(results_dir, 'waves.shm')
# hex_dir = os.path.join(script_path, 'asm')
hex_dir = os.path.join(script_path, 'assembler', 'hex')

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
top_module_path = os.path.join(project_dir, 'top.sv')

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
    parser.add_argument('--hex', action='store_true', help='select hex file to load')
    parser.add_argument('-k', '--kill', action='store_true', help='')
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

def select_hex_file(path, choose_hex=False):
    os.makedirs(path, exist_ok=True)
    hex_files = [file for file in os.listdir(path) if file.endswith('.hex')]
    if not hex_files:
        print(f"No '.hex' files found in {path}")
        sys.exit(1)
    hex_paths = [os.path.join(path, file) for file in hex_files]
    if not choose_hex:
        latest_file = max(hex_paths, key=os.path.getmtime)
        print(f"Using default hex file: {latest_file}")
        return latest_file
    print_list_with_idx(hex_files)
    selected_idx = get_integer_input('Select index of \'.hex\' file', 0, len(hex_files)-1)
    if selected_idx is None:
        print(f'Invalid input. Defaulting to 0.')
        selected_idx = 0
    print(f'Selected hex file: {hex_paths[selected_idx]}')
    return hex_paths[selected_idx]

def main():
    args = get_args()
    if args.kill: # use at own risk, may terminate all simvision sessions..
        terminal('pkill -9 -f simvision')
        if not (args.compile or args.no_compile or args.waves or args.hex):
            sys.exit(0)
    selected_hex = select_hex_file(hex_dir, choose_hex=args.hex)
    # compile_args = f'{includes} -uvm +UVM_NO_RELNOTES +define+UVM_REPORT_DISABLE_FILE -licqueue +access+r'
    compile_args = f'{includes} -licqueue +access+r'
    shm_path = os.path.join(script_path, 'shm.tcl')
    command = f"xrun {top_module_path} -licqueue {compile_args} +HEX_FILE=\"{selected_hex}\""
    compile_file_path = os.path.join(results_dir, f'xcelium.d/')
    if args.compile:
        command += ' -compile'
    if args.no_compile:
        command = f'xrun -xmlibdirname {compile_file_path} -R +HEX_FILE=\"{selected_hex}\"'
    if args.waves:
        command += f' -input {shm_path} -access +rwc'
    _, output = terminal(command)
    if args.waves:
        if not os.path.exists(waves_dir):
            print(f'could not locate waveforms at waveform dir: {waves_dir}')
            sys.exit(1)
        command = f'simvision -input {svcf_path} {waves_dir}/waves* &'
        print(f'>> {command}\n')
        subprocess.Popen(command, shell=True, cwd=results_dir, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        sys.exit(0)
        
if __name__ == '__main__':
    main()
