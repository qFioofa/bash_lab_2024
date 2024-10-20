import subprocess
import unittest
print(123)
class TestScript(unittest.TestCase):
    
    def test_simple(self):
        self.assertEqual(subprocess.call(["./myskript.ps1","./folder","70","5"]),0) 
        self.assertEqual(subprocess.call(["./smyskript.ps1","./folder","10","50"]),0) 
        self.assertEqual(subprocess.call(["./myskript.ps1","./folder","1","1"]),0) 
        self.assertEqual(subprocess.call(["./myskript.ps1","./folder","100","100"]),0) 