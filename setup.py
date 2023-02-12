# coding: utf-8

from __future__ import with_statement, print_function, absolute_import

from setuptools import setup, find_packages, Extension
from distutils.version import LooseVersion

import numpy as np
import os
from glob import glob
from os.path import join


min_cython_ver = '0.21.0'
try:
    import Cython
    ver = Cython.__version__
    _CYTHON_INSTALLED = ver >= LooseVersion(min_cython_ver)
except ImportError:
    _CYTHON_INSTALLED = False

try:
    if not _CYTHON_INSTALLED:
        raise ImportError('No supported version of Cython installed.')
    from Cython.Distutils import build_ext
    cython = True
except ImportError:
    cython = False

if cython:
    ext = '.pyx'
    cmdclass = {'build_ext': build_ext}
else:
    ext = '.cpp'
    cmdclass = {}
    if not os.path.exists(join("pyreaper", "creaper" + ext)):
        raise RuntimeError("Cython is required to generate C++ wrapper.")

# REAPER source location
src_top = join("lib", "REAPER")

src = glob(join(src_top, "core", "*.cc")) \
    + glob(join(src_top, "epoch_tracker", "*.cc"))
print(src)


# define core cython module
ext_modules = [Extension(
    name="pyreaper.creaper",
    sources=[join("pyreaper", "creaper" + ext)] + src,
    include_dirs=[np.get_include(), join(os.getcwd(), "lib", "REAPER")],
    extra_compile_args=[],
    language="c++",
)]

with open('README.md', 'r') as fd:
    long_description = fd.read()

setup(
    name='pyreaper',
    version='0.0.9',
    description='A python wrapper for REAPER (Robust Epoch And Pitch EstimatoR)',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Ryuichi Yamamoto',
    author_email='zryuichi@gmail.com',
    url='https://github.com/r9y9/pyreaper',
    license='MIT',
    packages=find_packages(),
    ext_modules=ext_modules,
    cmdclass=cmdclass,
    install_requires=[
        'numpy >= 1.8.0',
    ],
    tests_require=['nose', 'coverage'],
    extras_require={
        'test': ['nose', 'scipy'],
        'develop': ['cython >= ' + min_cython_ver],
    },
    classifiers=[
        "Operating System :: POSIX",
        "Operating System :: Unix",
        "Operating System :: MacOS",
        "Programming Language :: Cython",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "License :: OSI Approved :: MIT License",
        "Topic :: Scientific/Engineering",
        "Topic :: Software Development",
        "Intended Audience :: Science/Research",
        "Intended Audience :: Developers",
    ],
    keywords=["REAPER"]
)
