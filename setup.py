from distutils.core import setup

setup(
    name='ddosadm',
    version='1.0',
    py_modules=["ddosadm","datamirror"],
    scripts=["download_data.sh"],
    license='Creative Commons Attribution-Noncommercial-Share Alike license',
    long_description=open('README.md').read(),
)
