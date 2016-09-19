from distutils.core import setup

setup(
    name='datamirror',
    version='1.0',
    py_modules=["datamirror"],
    scripts=['download_data.sh'],
    license='Creative Commons Attribution-Noncommercial-Share Alike license',
    long_description=open('README.md').read(),
)
