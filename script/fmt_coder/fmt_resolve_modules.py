"""Read the board's existing SCons model selection without duplicating it."""

import argparse
import contextlib
import json
from pathlib import Path
import runpy
import sys
import types


def resolve_modules(firmware_root, board, vehicle, sim_mode):
    if Path(board).is_absolute() or '..' in Path(board).parts:
        raise ValueError('The board must be a relative path inside target/.')
    root = Path(firmware_root).resolve()
    target_root = (root / 'target').resolve()
    board_dir = (target_root / board).resolve()
    if target_root not in board_dir.parents:
        raise ValueError('The board must be a relative path inside target/.')
    if not (board_dir / 'SConstruct').is_file():
        raise ValueError(f'Board SConstruct not found: {board_dir}')
    config_file = board_dir / 'config' / 'model.py'
    options = {'vehicle': vehicle, 'sim': sim_mode}
    shim = types.ModuleType('building')
    shim.GetOption = lambda name: options[name]
    sentinel = object()
    previous = sys.modules.get('building', sentinel)
    sys.modules['building'] = shim
    try:
        with contextlib.redirect_stdout(sys.stderr):
            config = runpy.run_path(str(config_file))
    finally:
        if previous is sentinel:
            del sys.modules['building']
        else:
            sys.modules['building'] = previous
    modules = config.get('MODELS')
    if not isinstance(modules, list) or not all(isinstance(x, str) for x in modules):
        raise ValueError('The board config must define a list of model modules.')
    model_root = (root / 'src' / 'model').resolve()
    for module in modules:
        location = (model_root / module).resolve()
        if model_root not in location.parents or not (location / 'SConscript').is_file():
            raise ValueError(f'Model SConscript not found: {module}')
    return modules


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--firmware-root', required=True)
    parser.add_argument('--board', required=True)
    parser.add_argument('--vehicle', required=True)
    parser.add_argument('--sim', default='None')
    args = parser.parse_args()
    try:
        print(json.dumps(resolve_modules(args.firmware_root, args.board, args.vehicle, args.sim)))
    except Exception as exc:
        print(f'FMT model selection failed: {exc}', file=sys.stderr)
        sys.exit(1)
