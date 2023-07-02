from distutils.core import setup
from Cython.Build import cythonize
from distutils.core import Extension

from setuptools import setup, Extension
from Cython.Build import cythonize

# Define the extension module
extensions = [
    Extension("quadkey.utils", ["quadkey/utils.pyx"])
]

# Configure the setup
setup(
    name='quadkey',
    version='0.1',
    description='A Python package for quadkey manipulation',
    author='Prashant singh',
    author_email='mail.prashantsingh.41@gmail.com',
    packages=['quadkey'],
    ext_modules=cythonize(extensions),
    classifiers=[
        'Development Status :: 3 - Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
    ],
)
