from scipy.io import wavfile
from pyreaper import reaper

from os.path import dirname, join
try:
    from tqdm import tqdm
except:
    def tqdm(x): return x


def test_reaper():
    N = 10
    for n in tqdm(range(N)):
        fs, x = wavfile.read(join(dirname(__file__), "test16k.wav"))
        pm_times, pm, f0_times, f0, corr = reaper(x, fs)
