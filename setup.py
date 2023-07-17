from setuptools import setup, find_packages
from setuptools.extension import Extension
from setuptools.command.build_py import build_py as _build_py
from distutils.sysconfig import get_python_inc

from Cython.Build import cythonize

with open("README.md", "r") as fh:
    long_description = fh.read()

setup(
    name="quadkey-boosted",
    version="1.0.4",
    author="Prashant Singh",
    author_email="mail.prashantsingh.41@gmail.com",
    description="Python library that provides a powerful set of tools and functions for working with quadkeys. Built on top of C it offers lightning-fast calculations, ensuring optimal performance even with large-scale datasets.",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/ls-da3m0ns/quadkey-boosted",
    ext_modules=cythonize(
        [ 
            Extension("quadkey.core.utils", 
                sources=["quadkey/core/utils.pyx"], 
                language="c", optional=False, include_dirs=[get_python_inc()]) ]),
    packages=find_packages('quadkey'),
    include_dirs=[get_python_inc()],
    install_requires=[
        "Cython",
    ],
    package_dir={'': 'quadkey'},
    classifiers=[
        "Programming Language :: Python :: 3",
        "Operating System :: OS Independent",
        "License :: OSI Approved :: Apache Software License",
        "Topic :: Scientific/Engineering :: GIS",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    python_requires='>=3.6',
    project_urls={
        'Documentation': 'https://github.com/ls-da3m0ns/quadkey-boosted',
        'Source Code': 'https://github.com/ls-da3m0ns/quadkey-boosted',
        'Bug Tracker': 'https://github.com/ls-da3m0ns/quadkey-boosted/issues',
    },
    entry_points={
        'console_scripts': [
            'quadkey = quadkey.__main__:main',
        ],
    },
    ext_package="quadkey",

)