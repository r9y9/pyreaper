# coding: utf-8

"""
A python wrapper for `REAPER (Robust Epoch And Pitch EstimatoR)
<https://github.com/google/REAPER>`_.

https://github.com/r9y9/pyreaper
"""

from __future__ import division, print_function, absolute_import

import pkg_resources

__version__ = pkg_resources.get_distribution('pyreaper').version

from pyreaper.creaper import reaper_internal


def reaper(x, fs, minf0=40.0, maxf0=500.0, do_high_pass=True,
           do_hilbert_transform=False, inter_pulse=0.01,
           frame_period=0.005, unvoiced_cost=0.9):
    """REAPER (Robust Epoch And Pitch EstimatoR)

    Perform REAPER analysis given an audio signal

    Parameters
    ----------
    x : np.ndarray, dtype=np.int16
        Input audio signal

    fs : int
        Sampling frequency

    minf0 : float
        Min f0. Default is 40.0.

    maxf0 : float
        Max f0. Default is 500.0.

    do_high_pass : Bool
        Enable Rumble-removel highpass filter. Default is True.

    do_hilbert_transform : Bool
        Enable Hilbert transform that may reduce phase distortion.
        Default is False.

    inter_pulse : float
        Regular inter-mark interval to use in UV pitchmark regions.
        Default is 0.01 (sec)

    frame_period : float
        Frame period. Default is 0.005 (sec).

    unvoiced_cost : float
        Set the cost for unvoiced segments. Default is 0.9, the higher the value
        the more f0 estimates in noise.

    Returns
    -------
    pm_times : np.ndarray, dtype=np.float32
        Pitch mark time series in seconds

    pm : np.ndarray, dtype=np.int32
        Pitch mark. Value 1 and 0 means voiced frame and unvoiced frame,
        respectively.

    f0_times : np.ndarray, dtype=np.float32
        F0 time series in seconds

    f0 : np.ndarray, dtype=np.float32
        F0 contour

    corr : np.ndarray, dtype=np.float32
        Correlations

    Raises
    ------
    RuntimeError
        - if EpochTracker Init failed
        - if EpochTracker ComputeFeatures failed
        - if EpochTracker TrackEpochs failed
        - if EpochTracker ResampleAndReturnResults failed

    Examples
    --------
    >>> from scipy.io import wavfile
    >>> import pysptk
    >>> import pyreaper
    >>> fs, x = wavfile.read(pysptk.util.example_audio_file())
    >>> pm_times, pm, f0_times, f0, corr = pyreaper.reaper(x, fs)

    """
    return reaper_internal(x, fs, minf0, maxf0, do_high_pass,
                           do_hilbert_transform, inter_pulse, frame_period,
                           unvoiced_cost)
