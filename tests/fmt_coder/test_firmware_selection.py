"""Integration tests against the current Firmware SCons configuration."""

import importlib.util
from pathlib import Path
import sys
import tempfile
import types
import unittest
from unittest.mock import patch

MODEL_ROOT = Path(__file__).resolve().parents[2]
FIRMWARE_ROOT = MODEL_ROOT.parent / 'FMT-Firmware'
HELPER = MODEL_ROOT / 'script' / 'fmt_coder' / 'fmt_resolve_modules.py'
spec = importlib.util.spec_from_file_location('fmt_resolve_modules', HELPER)
resolver = importlib.util.module_from_spec(spec)
spec.loader.exec_module(resolver)


class FirmwareSelectionTests(unittest.TestCase):
    def test_multicopter_normal_uses_all_four_generated_models(self):
        self.assertEqual(resolver.resolve_modules(FIRMWARE_ROOT, 'sieon/s1',
                                                 'Multicopter', 'None'),
                         ['plant/multicopter', 'ins/cf_ins', 'fms/mc_fms',
                          'control/mc_controller'])

    def test_hil_uses_external_ins_and_template_plant(self):
        modules = resolver.resolve_modules(FIRMWARE_ROOT, 'sieon/s1',
                                           'Multicopter', 'HIL')
        self.assertIn('ins/external_ins', modules)
        self.assertIn('plant/template_plant', modules)
        self.assertNotIn('ins/cf_ins', modules)

    def test_board_capability_is_not_invented_by_the_adapter(self):
        self.assertIn('control/vtol_controller', resolver.resolve_modules(
            FIRMWARE_ROOT, 'sieon/s1', 'VTOL', 'None'))
        with self.assertRaises(Exception):
            resolver.resolve_modules(FIRMWARE_ROOT, 'pixhawk/fmu-v5', 'VTOL', 'None')

    def test_unknown_vehicle_is_rejected_and_building_namespace_is_restored(self):
        sentinel = types.ModuleType('building')
        with patch.dict(sys.modules, {'building': sentinel}):
            with self.assertRaises(Exception):
                resolver.resolve_modules(FIRMWARE_ROOT, 'sieon/s1', 'Invalid', 'None')
            self.assertIs(sys.modules['building'], sentinel)

    def test_path_escape_is_rejected(self):
        with self.assertRaises(ValueError):
            resolver.resolve_modules(FIRMWARE_ROOT, '../../FMT-Model', 'Multicopter', 'None')


    def test_supported_vehicles_follow_the_s1_configuration(self):
        for vehicle, control in [('Fixwing', 'fw'), ('VTOL', 'vtol'),
                                 ('Boat', 'boat'), ('Car', 'car')]:
            with self.subTest(vehicle=vehicle):
                modules = resolver.resolve_modules(FIRMWARE_ROOT, 'sieon/s1',
                                                   vehicle, 'None')
                self.assertIn(f'control/{control}_controller', modules)
                self.assertIn(f'fms/{control}_fms', modules)
        self.assertIn('plant/template_plant', resolver.resolve_modules(
            FIRMWARE_ROOT, 'sieon/s1', 'Car', 'None'))

    def test_absolute_board_is_rejected_even_inside_target(self):
        with self.assertRaises(ValueError):
            resolver.resolve_modules(FIRMWARE_ROOT,
                                     str(FIRMWARE_ROOT / 'target' / 'sieon' / 's1'),
                                     'Multicopter', 'None')

    def test_simulation_modes_keep_original_board_selection(self):
        for mode in ['None', 'SIH', 'VR', 'Plant']:
            with self.subTest(mode=mode):
                self.assertIn('plant/multicopter', resolver.resolve_modules(
                    FIRMWARE_ROOT, 'sieon/s1', 'Multicopter', mode))

    def test_airframe_reaches_the_original_selection_script(self):
        with tempfile.TemporaryDirectory() as folder:
            root = Path(folder)
            board = root / 'target' / 'mock' / 'board'
            (board / 'config').mkdir(parents=True)
            (board / 'SConstruct').touch()
            (board / 'config' / 'model.py').write_text(
                "from building import GetOption\n"
                "MODELS = ['seven' if GetOption('airframe') == 7 else 'one']\n",
                encoding='utf-8')
            for module in ['one', 'seven']:
                location = root / 'src' / 'model' / module
                location.mkdir(parents=True)
                (location / 'SConscript').touch()
            self.assertEqual(resolver.resolve_modules(root, 'mock/board',
                                                     'Multicopter', 'None', 7),
                             ['seven'])


if __name__ == '__main__':
    unittest.main()
