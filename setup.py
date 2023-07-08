from setuptools import setup, find_packages
from setuptools.extension import Extension
from setuptools.command.build_py import build_py as _build_py
from distutils.sysconfig import get_python_inc

from Cython.Build import cythonize

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name="quadkey",
    version="0.0.1",
    author="Prashant Singh",
    description="Python library that provides a powerful set of tools and functions for working with quadkeys. Built on top of C it offers lightning-fast calculations, ensuring optimal performance even with large-scale datasets.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/ls-da3m0ns/pyquadkey-boosted",
    ext_modules=cythonize(
        [ 
            Extension("quadkey.utils", 
                sources=["quadkey/utils.pyx"], 
                language="c", optional=False, include_dirs=[get_python_inc()]) ]),
    packages=find_packages(),
    include_dirs=[get_python_inc()],
    install_requires=[
        "Cython",
    ]
)