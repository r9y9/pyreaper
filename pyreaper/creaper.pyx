# coding: utf-8
# cython: boundscheck=True, wraparound=True

import numpy as np

cimport numpy as np
np.import_array()

cimport cython

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

from libcpp.cast cimport reinterpret_cast
from libc.stdint cimport int16_t, int32_t

from reaper cimport reaper as _reaper

cdef class Track:
    cdef _reaper.Track * ptr

    def __cinit__(self):
        self.ptr = new _reaper.Track()

    def __dealloc__(self):
        del self.ptr

    def num_frames(self):
        return self.ptr.num_frames()

    def num_channels(self):
        return self.num_channels()

    def set_v(self, int f, bool value):
        self.set_v(f, value)

    def resize(self, int n, int c=1):
        self.ptr.resize(n, c)


cdef class EpochTracker:
    """EpochTracker


    .. note::

        This isn't intended to be used directly in general. Use wrapper function instead
        unless if you don't want to understand internals.
    """
    cdef _reaper.EpochTracker * ptr

    def __cinit__(self):
        self.ptr = new _reaper.EpochTracker()

    def __dealloc__(self):
        del self.ptr

    def Init(self, np.ndarray[np.int16_t, ndim=1, mode="c"] input,
             float sample_rate, float min_f0_search, float max_f0_search,
             bool do_highpass, bool do_hilbert_transform):
        cdef int32_t n_input = len(input)
        return self.ptr.Init( & input[0], n_input, sample_rate, min_f0_search,
                             max_f0_search, do_highpass, do_hilbert_transform)

    def CleanUp(self):
        self.ptr.CleanUp()

    def set_debug_name(self, string name):
        self.ptr.set_debug_name(name)

    def debug_name(self):
        return self.ptr.debug_name()

    def ComputeFeatures(self):
        return self.ptr.ComputeFeatures()

    def TrackEpochs(self):
        return self.ptr.TrackEpochs()

    def set_unvoiced_cost(self, float v):
        self.ptr.set_unvoiced_cost(v)

    cdef ResampleAndReturnResults(self, float resample_interval,
                                  vector[float] * f0,
                                  vector[float] * correlations):
        return self.ptr.ResampleAndReturnResults(resample_interval, f0,
                                                 correlations)

    cdef GetFilledEpochs(self, float unvoiced_pm_interval,
                         vector[float] * times,
                         vector[int16_t] * voicing):
        self.ptr.GetFilledEpochs(unvoiced_pm_interval, times, voicing)

    # Convenient wrapper methods
    cdef GetEpochTrack(self, float inter_pulse, _reaper.Track * pm_track):
        cdef vector[float] times
        cdef vector[int16_t] voicing

        self.ptr.GetFilledEpochs(inter_pulse, & times, & voicing)

        pm_track.resize(times.size(), 1)

        cdef int32_t i
        for i in range(0, times.size()):
            ( & pm_track.t(i))[0] = times[i]
            pm_track.set_v(i, voicing[i])

        return True

    cdef GetTrackVoicedFlags(self, _reaper.Track * track,
                             int32_t * voiced_flags):
        cdef int32_t i
        for i in range(0, track.num_frames()):
            voiced_flags[i] = 1 if track.v(i) else 0

    cdef GetTrackTimes(self, _reaper.Track * track, float * times):
        cdef int32_t i
        for i in range(0, track.num_frames()):
            times[i] = track.t(i)

    cdef GetTrackValues(self, _reaper.Track * track, float * values):
        cdef int32_t i
        for i in range(0, track.num_frames()):
            values[i] = track.a(i)

    cdef GetF0AndCorrTrack(self, float external_frame_interval,
                           _reaper.Track * f0_track,
                           _reaper.Track * corr_track):
        cdef vector[float] f0
        cdef vector[float] corr
        if not self.ResampleAndReturnResults(external_frame_interval,
                                             & f0, & corr):
            return False

        f0_track.resize(f0.size(), 1)
        corr_track.resize(corr.size(), 1)
        cdef int32_t i
        cdef float t
        for i in range(0, f0.size()):
            t = external_frame_interval * i
            ( & f0_track.t(i))[0] = t
            ( & corr_track.t(i))[0] = t
            f0_track.set_v(i, True if f0[i] > 0.0 else False)
            corr_track.set_v(i, True if f0[i] > 0.0 else False)
            (& f0_track.a(i))[0] = f0[i] if f0[i] > 0.0 else -1.0;
            (& corr_track.a(i))[0] = corr[i]

        return True


def reaper_internal(np.ndarray[np.int16_t, ndim=1, mode="c"] x, fs,
                    float minf0=40.0,
                    float maxf0=500.0,
                    bool do_high_pass=True,
                    bool do_hilbert_transform=False,
                    float inter_pulse=0.01,
                    float frame_period=0.005,
                    float unvoiced_cost=0.9):
    et = EpochTracker()
    et.set_unvoiced_cost(unvoiced_cost)
    ok = et.Init(x, fs, minf0, maxf0, do_high_pass, do_hilbert_transform)
    if not ok:
        raise RuntimeError("EpochTracker init failed")

    ok = et.ComputeFeatures()
    if not ok:
        raise RuntimeError("EpochTracker ComputeFeatures failed")

    ok = et.TrackEpochs()
    if not ok:
        raise RuntimeError("EpochTracker TrackEpochs failed")

    # Get pitch mark
    pm_track = Track()
    et.GetEpochTrack(inter_pulse, pm_track.ptr)

    cdef int pN = pm_track.num_frames()
    cdef np.ndarray[np.int32_t, ndim = 1, mode = "c"] pm \
        = np.zeros(pN, dtype=np.int32)
    cdef np.ndarray[np.float32_t, ndim= 1, mode = "c"] pm_times \
        = np.zeros(pN, dtype=np.float32)
    et.GetTrackTimes(pm_track.ptr, & pm_times[0])
    et.GetTrackVoicedFlags(pm_track.ptr, & pm[0])

    # Get f0 and correlations
    f0_track = Track()
    corr_track = Track()
    ok = et.GetF0AndCorrTrack(frame_period, f0_track.ptr, corr_track.ptr)
    if not ok:
        raise RuntimeError("EpochTracker ResampleAndReturnResults failed")

    cdef int fN = f0_track.num_frames()
    assert fN == corr_track.num_frames()
    cdef np.ndarray[np.float32_t, ndim= 1, mode = "c"] f0 \
        = np.zeros(fN, dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim= 1, mode = "c"] corr \
        = np.zeros(fN, dtype=np.float32)
    cdef np.ndarray[np.float32_t, ndim= 1, mode = "c"] f0_times\
        = np.zeros(fN, dtype=np.float32)
    et.GetTrackTimes(f0_track.ptr, & f0_times[0])
    et.GetTrackValues(f0_track.ptr, & f0[0])
    et.GetTrackValues(corr_track.ptr, & corr[0])

    et.CleanUp()

    return pm_times, pm, f0_times, f0, corr
