from scipy.io import wavfile
from pyreaper import reaper


def test_reaper():
    fs, x = wavfile.read("test16k.wav")
    pm_times, pm, f0_times, f0, corr = reaper(x, fs)
