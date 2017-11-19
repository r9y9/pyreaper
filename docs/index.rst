.. pyreaper documentation master file, created by
   sphinx-quickstart on Fri Sep  4 18:38:55 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

pyreaper
========

.. automodule:: pyreaper


Installation guide
------------------

The latest release is availabe on pypi. You can install it by:

.. code::

    pip install pyreaper

Note that you have to install ``numpy`` to build C-extensions.

If yout want the latest development version, assuming you have ``cython`` installed,
run:

.. code::

   pip install git+https://github.com/r9y9/pyreaper

or:

.. code::

   git clone https://github.com/r9y9/pyreaper
   cd pyreaper
   git submodule update --init --recursive
   python setup.py develop # or install

This should resolve the package dependencies and install ``pyreaper`` property.


API
---

.. autosummary::
   :toctree: generated/

   pyreaper.reaper


Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
