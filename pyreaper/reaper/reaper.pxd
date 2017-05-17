# distutils: language=c++

from libc.stdint cimport int16_t, int32_t
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

cdef extern from "core/track.h":
    cdef cppclass Track:
        Track()
        int num_frames() const
        int num_channels() const

        float & a(int f, int c=0)
        # float a(int f, int c=0) const
        float & t(int f)
        # float t(int f) const

        void set_v(int f, bool value)
        bool v(int f) const

        void resize(int n, int c)


cdef extern from "epoch_tracker/epoch_tracker.h":
    cdef cppclass EpochTracker:
        EpochTracker()
        void SetParameters()
        bool Init(const int16_t * input, int32_t n_input, float sample_rate,
                  float min_f0_search, float max_f0_search,
                  bool do_highpass, bool do_hilbert_transform)
        void set_debug_name(const string & debug_name)
        string debug_name()

        bool ComputeFeatures()
        bool TrackEpochs()

        bool ResampleAndReturnResults(float resample_interval,
                                      vector[float] * f0,
                                      vector[float] * correlations)

        void GetFilledEpochs(float unvoiced_pm_interval, vector[float] * times,
                             vector[int16_t] * voicing)

        void set_do_hilbert_transform(bool v)
        void set_do_highpass(bool v)
        void set_external_frame_interval(float v)
        void set_unvoiced_pulse_interval(float v)
        void set_min_f0_search(float v)
        void set_max_f0_search(float v)
