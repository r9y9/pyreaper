# coding: utf-8

"""
A python wrapper for `REAPER (Robust Epoch And Pitch EstimatoR)
<https://github.com/google/REAPER>`_.

https://github.com/r9y9/pyreaper
"""

from __future__ import division, print_function, absolute_import

import pkg_resources

__version__ = pkg_resources.get_distribution('pyreaper').version

from .creaper import reaper
