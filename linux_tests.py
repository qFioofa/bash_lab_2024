import subprocess
import unittest
class TestScript(unittest.TestCase):

    def test_simple(self):
        self.assertEqual(subprocess.call(["./script.sh","./folder","70","5"]),0)
        self.assertEqual(subprocess.call(["./script.sh","./folder","10","50"]),0)
        self.assertEqual(subprocess.call(["./script.sh","./folder","1","1"]),0)
        self.assertEqual(subprocess.call(["./script.sh","./folder","100","100"]),0)
    def test_name(self):
        self.assertEqual(subprocess.call(["./script.sh","./filder","70","5"]),1)
    def test_precents(self):
        self.assertEqual(subprocess.call(["./script.sh","./folder","120","5"]),1)
        self.assertEqual(subprocess.call(["./script.sh","./folder","-30","5"]),1)
        self.assertEqual(subprocess.call(["./script.sh","./folder","nigger","5"]),1)
    def test_arg2(self):
        self.assertEqual(subprocess.call(["./script.sh","./folder","70","-3"]),1)
    def test_create_file_1GB(self):
        f=open("folder/test.txt","wb")
        f.seek(1024*1024*1024)
        f.write(b"\0")
        f.close()
    def test_create_10_files_120MB(self):
        for count in range(1,11):
            f=open("folder/test"+str(count)+".txt","wb")
            f.seek(1024*1024*120)
            f.write(b"\0")
            f.close()
    def test_create_100_files_12MB(self):
        for count in range(1,101):
            f=open("folder/test"+str(count)+".txt","wb")
            f.seek(1024*1024*12)
            f.write(b"\0")
            f.close()
    def test_create_10000_files_1MB(self):
        for count in range(1,10001):
            f=open("folder/test"+str(count)+".txt","wb")
            f.seek(1024*1024)
            f.write(b"\0")
            f.close()


if __name__=='__main__':
    unittest.main()