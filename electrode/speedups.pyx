# -*- coding: utf8 -*-
#
#   electrode: numeric tools for Paul traps
#
#   Copyright (C) 2011-2012 Robert Jordens <jordens@phys.ethz.ch>
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>.

from __future__ import division
import cython
import numpy as np

cimport numpy as np
np.import_array()

from libc.math cimport atan2, sqrt, fabs, M_PI

dtype = np.double
ctypedef np.double_t dtype_t

@cython.boundscheck(False)
@cython.wraparound(False)
def point_value(np.ndarray[dtype_t, ndim=2] x not None,
                np.ndarray[dtype_t, ndim=1] a not None,
                np.ndarray[dtype_t, ndim=2] p not None,
                *d):
    cdef int xmax = x.shape[0], pmax = p.shape[0], i, j
    cdef int dd0 = False, dd1 = False, dd2 = False, dd3 = False
    cdef double x0, y0, z0, a0, r0
    cdef list ret = []

    cdef np.ndarray[dtype_t, ndim=2, mode="c"] d0
    cdef np.ndarray[dtype_t, ndim=3, mode="c"] d1, d2, d3

    if 0 in d:
        d0 = np.empty([pmax, xmax], dtype=dtype)
        dd0 = True
        ret.append(d0)
    if 1 in d:
        d1 = np.empty([pmax, xmax, 3], dtype=dtype)
        dd1 = True
        ret.append(d1)
    if 2 in d:
        d2 = np.empty([pmax, xmax, 5], dtype=dtype)
        dd2 = True
        ret.append(d2)
    if 3 in d:
        d3 = np.empty([pmax, xmax, 7], dtype=dtype)
        dd3 = True
        ret.append(d3)

    for i in range(pmax):
        for j in range(xmax):
            x0 = x[j, 0] - p[i, 0]
            y0 = x[j, 1] - p[i, 1]
            z0 = x[j, 2] - p[i, 2]
            r0 = sqrt(x0**2+y0**2+z0**2)
            a0 = a[i]
            if dd0:
                point_value_0(x0, y0, z0, r0, a0, &d0[i, j])
            if dd1:
                point_value_1(x0, y0, z0, r0, a0, &d1[i, j, 0])
            if dd2:
                point_value_2(x0, y0, z0, r0, a0, &d2[i, j, 0])
            if dd3:
                point_value_3(x0, y0, z0, r0, a0, &d3[i, j, 0])
    return ret

cdef inline point_value_0(double x, double y, double z, double r,
                          double a, double *d):
    cdef double n = a/(2*M_PI*r**3)
    d[0] = z*n

cdef inline point_value_1(double x, double y, double z, double r,
                          double a, double *d):
    cdef double n = a/(2*M_PI*r**5)
    d[0] = -3*x*z*n
    d[1] = -3*y*z*n
    d[2] = (x**2+y**2-2*z**2)*n

cdef inline point_value_2(double x, double y, double z, double r,
                          double a, double *d):
    cdef double n = a/(2*M_PI*r**7)
    d[0] = -3*z*(-4*x**2+y**2+z**2)*n
    d[1] = 15*x*y*z*n
    d[2] = -3*x*(x**2+y**2-4*z**2)*n
    d[3] = -3*z*(x**2-4*y**2+z**2)*n
    d[4] = -3*y*(x**2+y**2-4*z**2)*n

cdef inline point_value_3(double x, double y, double z, double r,
                          double a, double *d):
    cdef double n = a/(2*M_PI*r**9)
    d[0] = 15*y*z*(-6*x**2+y**2+z**2)*n
    d[1] = 3*(4*x**4-y**4+3*y**2*z**2+4*z**4+3*x**2*(y**2-9*z**2))*n
    d[2] = 3*(-x**4+4*y**4-27*y**2*z**2+4*z**4+3*x**2*(y**2+z**2))*n
    d[3] = 15*x*z*(x**2-6*y**2+z**2)*n
    d[4] = (45*x*(x**2+y**2)*z-60*x*z**3)*n
    d[5] = (45*y*(x**2+y**2)*z-60*y*z**3)*n
    d[6] = 15*x*y*(x**2+y**2-6*z**2)*n


@cython.boundscheck(False)
@cython.wraparound(False)
def polygon_value(np.ndarray[dtype_t, ndim=2] x not None,
                  list ps not None,
                  *d):
    cdef int xmax = x.shape[0], psmax = len(ps), pmax, i, j, k
    cdef int dd0 = False, dd1 = False, dd2 = False, dd3 = False
    cdef double x0, y0, z0, r0, x1, y1, z1, r1, x2, y2, z2, r2, l2
    cdef list ret = []
    cdef np.ndarray[dtype_t, ndim=2] p
    cdef np.ndarray[dtype_t, ndim=2, mode="c"] d0
    cdef np.ndarray[dtype_t, ndim=3, mode="c"] d1, d2, d3

    if 0 in d:
        d0 = np.zeros([psmax, xmax], dtype=dtype)
        dd0 = True
        ret.append(d0)
    if 1 in d:
        d1 = np.zeros([psmax, xmax, 3], dtype=dtype)
        dd1 = True
        ret.append(d1)
    if 2 in d:
        d2 = np.zeros([psmax, xmax, 5], dtype=dtype)
        dd2 = True
        ret.append(d2)
    if 3 in d:
        d3 = np.zeros([psmax, xmax, 7], dtype=dtype)
        dd3 = True
        ret.append(d3)

    for i in range(psmax):
        p = ps[i]
        pmax = p.shape[0]
        for j in range(xmax):
            for k in range(pmax):
                if k == 0:
                    x0 = x1 = x[j, 0] - p[0, 0]
                    y0 = y1 = x[j, 1] - p[0, 1]
                    z0 = z1 = x[j, 2] - p[0, 2]
                    r0 = r1 = sqrt(x0**2+y0**2+z0**2)
                else:
                    x1 = x2
                    y1 = y2
                    z1 = z2
                    r1 = r2
                if k == pmax-1:
                    x2 = x0
                    y2 = y0
                    z2 = z0
                    r2 = r0
                else:
                    x2 = x[j, 0] - p[k+1, 0]
                    y2 = x[j, 1] - p[k+1, 1]
                    z2 = x[j, 2] - p[k+1, 2]
                    r2 = sqrt(x2**2+y2**2+z2**2)
                l2 = (x1-x2)**2+(y1-y2)**2
                if dd0:
                    polygon_value_0(x1, x2, y1, y2, r1, r2, l2, z1,
                            &d0[i, j])
                if dd1:
                    polygon_value_1(x1, x2, y1, y2, r1, r2, l2, z1,
                            &d1[i, j, 0])
                if dd2:
                    polygon_value_2(x1, x2, y1, y2, r1, r2, l2, z1,
                            &d2[i, j, 0])
                if dd3:
                    polygon_value_3(x1, x2, y1, y2, r1, r2, l2, z1,
                            &d3[i, j, 0])
    return ret

cdef inline polygon_value_0(double x1, double x2, double y1, double y2,
                            double r1, double r2, double l2, double z,
                            double *d):
    cdef double zs = fabs(z)
    d[0] += atan2(z*(x1*y2-y1*x2),
                zs*(r1*r2+x1*x2+y1*y2+zs*(zs+r1+r2)))/M_PI

cdef inline polygon_value_1(double x1, double x2, double y1, double y2,
                            double r1, double r2, double l2, double z,
                            double *d):
    cdef double n = (r1+r2)/(r1*r2*((r1+r2)**2-l2))/M_PI
    d[0] += -(y1-y2)*z*n
    d[1] += (x1-x2)*z*n
    d[2] += (x2*y1-x1*y2)*n

cdef inline polygon_value_2(double x1, double x2, double y1, double y2,
                            double r1, double r2, double l2, double z,
                            double *d):
    cdef double n = (r1*r2)**3*((r1+r2)**2-l2)**2*M_PI
    d[0] += ((l2*(r2**3*x1+r1**3*x2)-(r1+r2)**2*(r2**2*(2*r1+r2)*x1
            +r1**2*(r1+2*r2)*x2))*(-y1+y2)*z)/n
    d[1] += ((-y1+y2)*(l2*(r2**3*y1+r1**3*y2)
            -(r1+r2)**2*(r2**2*(2*r1+r2)*y1+r1**2*(r1+2*r2)*y2))*z)/n
    d[2] += ((r1+r2)*(-y1+y2)*(-(l2*r1**2*r2**2)+
              l2*(r1**2-r1*r2+r2**2)*z**2+(r1+r2)**2*(r1**2*r2**2-
              (r1**2+r1*r2+r2**2)*z**2)))/n
    d[3] += ((x1-x2)*(l2*(r2**3*y1+r1**3*y2)-
              (r1+r2)**2*(r2**2*(2*r1+r2)*y1+r1**2*(r1+2*r2)*y2))*z)/n
    d[4] += ((r1+r2)*(-x1+x2)*(l2*r1**2*r2**2-l2*(r1**2-r1*r2+r2**2)*z**2+
              (r1+r2)**2*(-(r1**2*r2**2)+(r1**2+r1*r2+r2**2)*z**2)))/n

cdef inline polygon_value_3(double x1, double x2, double y1, double y2,
                            double r1, double r2, double l2, double z,
                            double *d):
    cdef double n = (r1*r2)**5*((r1+r2)**2-l2)**3*M_PI
    d[0] += ((-y1+y2)*(3*l2**2*(r2**5*x1*y1+r1**5*x2*y2)+
              (r1+r2)**3*(9*r1*r2**5*x1*y1+3*r2**6*x1*y1+3*r1**6*x2*y2+
              9*r1**5*r2*x2*y2+6*r1**3*r2**3*(x2*y1+x1*y2)+
              2*r1**2*r2**4*(x2*y1+x1*(4*y1+y2))+
              2*r1**4*r2**2*(x1*y2+x2*(y1+4*y2)))-
              2*l2*(9*r1*r2**6*x1*y1+3*r2**7*x1*y1+3*r1**7*x2*y2+
              9*r1**6*r2*x2*y2+r1**2*r2**5*(x2*y1+x1*(6*y1+y2))+
              r1**5*r2**2*(x1*y2+x2*(y1+6*y2))))*z)/n
    d[1] += ((-y1+y2)*(-(l2**2*(r1**2*r2**5*x1-3*r2**5*x1*z**2+
              r1**5*x2*(r2**2-3*z**2)))+2*l2*(r1+r2)**3*(-3*r2**4*x1*z**2+
              r1**4*x2*(r2**2-3*z**2)+r1**2*r2**2*(r2**2*x1-(x1+x2)*z**2))-
              (r1+r2)**2*(-12*r1*r2**6*x1*z**2-3*r2**7*x1*z**2+
              r1**7*x2*(r2**2-3*z**2)+4*r1**6*r2*x2*(r2**2-3*z**2)+
              r1**4*r2**3*(r2**2*(5*x1+2*x2)-8*(x1+2*x2)*z**2)+
              r1**5*r2**2*(r2**2*(2*x1+5*x2)-(2*x1+19*x2)*z**2)+
              r1**2*r2**3*(r2**4*x1-r2**2*(19*x1+2*x2)*z**2-
              6*x1*((x1-x2)**2+(y1-y2)**2)*z**2)+
              2*r1**3*r2**2*(2*r2**4*x1-4*r2**2*(2*x1+x2)*z**2-3*x2*(
              (x1-x2)**2+(y1-y2)**2)*z**2))))/n
    d[2] += ((-x1+x2)*(l2**2*(r1**2*r2**5*y1-3*r2**5*y1*z**2+
              r1**5*y2*(r2**2-3*z**2))-2*l2*(r1+r2)**3*(-3*r2**4*y1*z**2+
              r1**4*y2*(r2**2-3*z**2)+r1**2*r2**2*(r2**2*y1-(y1+y2)*z**2))+
              (r1+r2)**2*(-12*r1*r2**6*y1*z**2-3*r2**7*y1*z**2+
              r1**7*y2*(r2**2-3*z**2)+4*r1**6*r2*y2*(r2**2-3*z**2)+
              2*r1**3*r2**2*(2*r2**4*y1-3*((x1-x2)**2+(y1-y2)**2)*y2*z**2-
              4*r2**2*(2*y1+y2)*z**2)+r1**4*r2**3*(r2**2*(5*y1+2*y2)-
              8*(y1+2*y2)*z**2)+r1**2*r2**3*(r2**4*y1-6*y1*((x1-x2)**2+
              (y1-y2)**2)*z**2-r2**2*(19*y1+2*y2)*z**2)+
              r1**5*r2**2*(r2**2*(2*y1+5*y2)-(2*y1+19*y2)*z**2))))/n
    d[3] += ((-y1+y2)*(2*l2*(r1**2*r2**2*(r1+r2)**3*(r1**2+r2**2)-
              3*r2**5*(r1+r2)*(2*r1+r2)*y1**2-2*r1**2*r2**2*(r1**3+
              r2**3)*y1*y2-3*r1**5*(r1+r2)*(r1+2*r2)*y2**2)-
              l2**2*(r1**2*r2**5-3*r2**5*y1**2+r1**5*(r2**2-3*y2**2))-
              (r1+r2)**3*(-9*r1*r2**5*y1**2-3*r2**6*y1**2+
              3*r1**3*r2**3*(r2**2-4*y1*y2)+r1**6*(r2**2-3*y2**2)+
              3*r1**5*r2*(r2**2-3*y2**2)+r1**2*r2**4*(r2**2-4*y1*(2*y1+y2))+
              4*r1**4*r2**2*(r2**2-y2*(y1+2*y2))))*z)/n
    d[4] += ((-r1-r2)*(-y1+y2)*z*(-2*l2*(r1+r2)**2*(3*r1**2*r2**2*(r1**2+
              r2**2)+(-3*r1**4+2*r1**3*r2+r1**2*r2**2+2*r1*r2**3-
              3*r2**4)*z**2)+3*l2**2*(r1**2*r2**2*(r1**2-r1*r2+r2**2)-
              (r1**4-r1**3*r2+r1**2*r2**2-r1*r2**3+r2**4)*z**2)+
              (r1+r2)**2*(-3*r2**6*z**2+r1*r2**3*(-9*r2**2+4*((x1-x2)**2+
              (y1-y2)**2))*z**2+3*r1**2*r2**4*(r2**2-4*z**2)+
              3*r1**6*(r2**2-z**2)+9*r1**5*r2*(r2**2-z**2)+
              12*r1**4*r2**2*(r2**2-z**2)+r1**3*r2*(9*r2**4-12*r2**2*z**2+
              4*((x1-x2)**2+(y1-y2)**2)*z**2))))/n
    d[5] += ((r1+r2)*(-x1+x2)*z*(-2*l2*(r1+r2)**2*(3*r1**2*r2**2*(r1**2+
              r2**2)+(-3*r1**4+2*r1**3*r2+r1**2*r2**2+2*r1*r2**3-
              3*r2**4)*z**2)+3*l2**2*(r1**2*r2**2*(r1**2-r1*r2+r2**2)-
              (r1**4-r1**3*r2+r1**2*r2**2-r1*r2**3+r2**4)*z**2)+
              (r1+r2)**2*(-3*r2**6*z**2+r1*r2**3*(-9*r2**2+4*((x1-x2)**2+
              (y1-y2)**2))*z**2+3*r1**2*r2**4*(r2**2-4*z**2)+
              3*r1**6*(r2**2-z**2)+9*r1**5*r2*(r2**2-z**2)+
              12*r1**4*r2**2*(r2**2-z**2)+r1**3*r2*(9*r2**4-12*r2**2*z**2+
              4*((x1-x2)**2+(y1-y2)**2)*z**2))))/n
    d[6] += ((y1-y2)*(l2**2*(r1**2*r2**5*y1-3*r2**5*y1*z**2+
              r1**5*y2*(r2**2-3*z**2))-2*l2*(r1+r2)**3*(-3*r2**4*y1*z**2+
              r1**4*y2*(r2**2-3*z**2)+r1**2*r2**2*(r2**2*y1-(y1+y2)*z**2))+
              (r1+r2)**2*(-12*r1*r2**6*y1*z**2-3*r2**7*y1*z**2+
              r1**7*y2*(r2**2-3*z**2)+4*r1**6*r2*y2*(r2**2-3*z**2)+
              2*r1**3*r2**2*(2*r2**4*y1-3*((x1-x2)**2+
              (y1-y2)**2)*y2*z**2-4*r2**2*(2*y1+y2)*z**2)+
              r1**4*r2**3*(r2**2*(5*y1+2*y2)-8*(y1+2*y2)*z**2)+
              r1**2*r2**3*(r2**4*y1-6*y1*((x1-x2)**2+
              (y1-y2)**2)*z**2-r2**2*(19*y1+2*y2)*z**2)+
              r1**5*r2**2*(r2**2*(2*y1+5*y2)-(2*y1+19*y2)*z**2))))/n