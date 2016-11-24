import unittest

class DataMirrorTest(unittest.TestCase):

    def test_download(self):
        import datamirror
        datamirror.ensure_data(scw="175000220010.001")
        self.assertEqual('foo'.upper(), 'FOO')

   # def test_isupper(self):
   #     self.assertTrue('FOO'.isupper())
   #     self.assertFalse('Foo'.isupper())

    #def test_split(self):
    #    s = 'hello world'
    #    self.assertEqual(s.split(), ['hello', 'world'])
        # check that s.split fails when the separator is not a string
   #     with self.assertRaises(TypeError):
   #         s.split(2)

if __name__ == '__main__':
    unittest.main()
