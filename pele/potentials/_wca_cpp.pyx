"""
# distutils: language = C++
"""
cimport pele.potentials._pele as _pele
import numpy as np
cimport numpy as np
from cpython cimport bool
from ctypes import c_size_t as size_t

# use external c++ class
cdef extern from "pele/wca.h" namespace "pele":
    cdef cppclass  cWCA "pele::WCA":
        cWCA(double sig, double eps) except +
    cdef cppclass  cWCAPeriodic "pele::WCAPeriodic":
        cWCAPeriodic(double sig, double eps, double * boxvec) except +
    cdef cppclass  cWCANeighborList "pele::WCANeighborList":
        cWCANeighborList(_pele.Array[long] & ilist, double sig, double eps) except +
    cdef cppclass  cWCA2D "pele::WCA2D":
        cWCA2D(double sig, double eps) except +
    cdef cppclass  cWCAPeriodic2D "pele::WCAPeriodic2D":
        cWCAPeriodic2D(double sig, double eps, double * boxvec) except +

cdef class WCA(_pele.BasePotential):
    """define the python interface to the c++ WCA implementation
    """
    cpdef bool periodic 
    def __cinit__(self, sig=1.0, eps=1.0, ndim=3, boxvec=None, boxl=None):
        assert not (boxvec is not None and boxl is not None)
        if boxl is not None:
            boxvec = [boxl] * ndim
        cdef np.ndarray[double, ndim=1] bv
        if boxvec is None:
            self.periodic = False
            if ndim == 2:
                self.thisptr = <_pele.cBasePotential*>new cWCA2D(sig, eps)
            else:
                self.thisptr = <_pele.cBasePotential*>new cWCA(sig, eps)
        else:
            self.periodic = True
            assert(len(boxvec)==ndim)
            bv = np.array(boxvec, dtype=float)
            if ndim == 2:
                self.thisptr = <_pele.cBasePotential*>new cWCAPeriodic2D(sig, eps, <double*> bv.data)
            else:
                self.thisptr = <_pele.cBasePotential*>new cWCAPeriodic(sig, eps, <double*> bv.data)
            
cdef class WCANeighborList(_pele.BasePotential):
    """define the python interface to the c++ WCA implementation
    """
    def __cinit__(self, np.ndarray[long, ndim=1] ilist, eps=1.0, sigma=1.0):
        self.thisptr = <_pele.cBasePotential*>new cWCANeighborList( _pele.Array[long](<long*> ilist.data, <int> ilist.size),
                                                                     sigma, eps)

cdef class _ErrorPotential(_pele.BasePotential):
    """this is a test potential which should raise an exception when called
    """
    def __cinit__(self):
        self.thisptr = <_pele.cBasePotential*>new _pele.cBasePotential()
  
