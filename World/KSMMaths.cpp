//
//  KSMMaths.cpp
//
//  Created by Keith Staines on 05/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//

#include <iostream>
#include <cmath>
#include "KSMMaths.h"

using namespace std;

extern const KSMVector3 KSM_X =            KSMVector3(1, 0, 0);
extern const KSMVector3 KSM_Y =            KSMVector3(0, 1, 0);
extern const KSMVector3 KSM_Z =            KSMVector3(0, 0, 1);

extern const KSMVector3 KSM_UP =           KSMVector3(0, 1, 0);
extern const KSMVector3 KSM_RIGHT =        KSMVector3(1, 0, 0);
extern const KSMVector3 KSM_OUT =          KSMVector3(0, 0, 1);

////////////////////////////////////////////////////////////////////////////////
// utility functions

bool fequalzero(double a) { return fabs(a) < FLT_EPSILON; }
bool fequalzero(float a)  { return fabs(a) < FLT_EPSILON; }
bool fequal(float a, float b) { return fabs( (a) - (b)) < FLT_EPSILON; }
bool fequal(double a, double b) { return fabs(a - b) < FLT_EPSILON; }

float * floatsFromDoubles(const double * doubles, int count)
{
    // allocate a new array of floats
    float * floats = new float[count];
    
    // copy data from doubles array, casting to float in the process
    for (int i = 0; i < count; i++) 
    {
        floats[i] = (float)doubles[i];
    }
    return floats;
}

////////////////////////////////////////////////////////////////////////////////
// class implementations 


// default constructor makes a zero vector
KSMVector3::KSMVector3() : x(0), y(0), z(0) {}

// constructor initialises components to specified values
KSMVector3::KSMVector3(const double x, const double y, const double z)
    : x(x), y(y), z(z)
{}

// reverses the direction of the vector (equivalent to scaling by -1)
void KSMVector3::reverse()
{
    x = -x;
    y = -y;
    z = -z;
}
   
// multiplies each component of this vector by the scalefactor
void KSMVector3::scaleBy(const double scaleFactor)
{
    x *= scaleFactor;
    y *= scaleFactor;
    z *= scaleFactor;
}

// returns the length of the vector
double KSMVector3::length() const
{
    return sqrt(length2());
}

// returns the length of the vector
double KSMVector3::magnitude() const
{
    return sqrt(length2());
}

// returns the square of the magnitude of the vector
double KSMVector3::length2() const
{
    return (x*x + y*y + z*z);
}

// Normalise the vector
void KSMVector3::normalise()
{
    // prevent divide by zero error at expense of a little accuracy
    double l = 1.0 / ( length() + DBL_EPSILON );
    
    x *= l;
    y *= l;
    z *= l;
}

// zero all components
void KSMVector3::zero()
{
    x = 0;
    y = 0;
    z = 0;
}

// return a unit vector in the same direction as this vector
KSMVector3 KSMVector3::unitVector() const
{
    KSMVector3 returnVector(*this);
    returnVector.normalise();
    return  returnVector;
}

// return a copy copy of this vector scaled by the specified value
KSMVector3 KSMVector3::copyAndScale(const double scaleFactor) const
{
    return KSMVector3(x*scaleFactor, y * scaleFactor, z * scaleFactor);
}

// return a copy copy of this vector scaled by the specified value
KSMVector3 KSMVector3::operator*(const double scaleFactor) const
{
    return KSMVector3(x*scaleFactor, y * scaleFactor, z * scaleFactor);
}

// scale this vector by the specified value (equivelant to scaleBy)
void KSMVector3::operator*=(const double scaleFactor)
{
    x *= scaleFactor;
    y *= scaleFactor;
    z *= scaleFactor;
}

// Adds the specified vector to this instance
void KSMVector3::operator+=(const KSMVector3 &vectorToAdd)
{
    x += vectorToAdd.x;
    y += vectorToAdd.y;
    z += vectorToAdd.z;
}

// return a copy of this vector added to the specified vector
KSMVector3 KSMVector3::operator+(const KSMVector3 &vectorToAdd) const
{
    return KSMVector3(x + vectorToAdd.x, 
                      y + vectorToAdd.y, 
                      z + vectorToAdd.z);
}

// add the specified vector to this instance (equivelant to add)
void KSMVector3::add(KSMVector3 &vectorToAdd)
{
    x += vectorToAdd.x;
    y += vectorToAdd.y;
    z += vectorToAdd.z;
}

// Subtracts the specified vector from this instance
void KSMVector3::operator-=(const KSMVector3 &vectorToSubtract)
{
    x -= vectorToSubtract.x;
    y -= vectorToSubtract.y;
    z -= vectorToSubtract.z; 
}

// return a copy of this vector - the specified vector
KSMVector3 KSMVector3::operator-(const KSMVector3 &vectorToSubtract) const
{
    return KSMVector3(x - vectorToSubtract.x, 
                      y - vectorToSubtract.y, 
                      z - vectorToSubtract.z);
}

// Subtracts the specified vector from this instance (equivelant to subtract)
void KSMVector3::subtract(const KSMVector3 &vectorToSubtract)
{
    x -= vectorToSubtract.x;
    y -= vectorToSubtract.y;
    z -= vectorToSubtract.z;    
}

// rarely used component wise product
KSMVector3 KSMVector3::componentProduct(const KSMVector3 &v1, 
                                        const KSMVector3 &v2)
{
    return KSMVector3(v1.x * v2.x, v1.y * v2.y, v1.z * v2.z);
}

// return the dot product of this vector with another
double KSMVector3::operator*(const KSMVector3 &otherVector) const
{
    return (x * otherVector.x + y * otherVector.y + z * otherVector.z);
}

// return the vector product of this vector with another
KSMVector3 KSMVector3::vectorProduct(const KSMVector3 &otherVector) const
{
    return (*this) % otherVector;
}

// returns the vector product of this vector with another
KSMVector3 KSMVector3::operator%(const KSMVector3 &vector) const
{
    return KSMVector3(y * vector.z - z * vector.y, 
                      z * vector.x - x * vector.z, 
                      x * vector.y - y * vector.x);
}

// return this vector to be the vector product of itself with another
void KSMVector3::operator%=(const KSMVector3 &otherVector)
{
    // are we leaking memory here?
    *this = vectorProduct(otherVector);
}

// add a scaled vector
void KSMVector3::addScaledVector(const KSMVector3 &vector, 
                                 const double scaleFactor)
{
    x += x + vector.x * scaleFactor;
    y += y + vector.x * scaleFactor;
    z += z + vector.x * scaleFactor;
}

//returns a vector4 with same x,y, and z components as this, and w = 1
KSMVector4 KSMVector3::vector4Position() const
{
    return KSMVector4(x, y, z, 1.0f);
}

// returns a vector4 with same x,y,z components as this and w = 0
KSMVector4 KSMVector3::vector4Direction() const
{
    return KSMVector4(x, y, z, 0.0f);
}

// KSMVector4 default constructor
KSMVector4::KSMVector4() : x(0.0), y(0.0), z(0.0), w(1.0) {}

// constructor initialises components to specified values
KSMVector4::KSMVector4(const double x, 
                       const double y, 
                       const double z, 
                       const double w) : x(x), y(y), z(z), w(w) {}


// scale this vector by the specified value (equivelant to scaleBy)
void KSMVector4::operator*=(const double scaleFactor)
{
    x *= scaleFactor;
    y *= scaleFactor;
    z *= scaleFactor;
}

// return a copy of this vector scaled by the appropriate value
KSMVector4 KSMVector4::operator*(const double scaleFactor) const
{
    return KSMVector4(x * scaleFactor,
                      y * scaleFactor,
                      z * scaleFactor,
                      w);
}

// Adds the specified vector to this instance
void KSMVector4::operator+=(const KSMVector4 &vectorToAdd)
{
    x += vectorToAdd.x;
    y += vectorToAdd.y;
    z += vectorToAdd.z;
}

// return a copy of this vector added to the specified vector
KSMVector4 KSMVector4::operator+(const KSMVector4 &vectorToAdd) const
{
    return KSMVector4(x + vectorToAdd.x,
                      y + vectorToAdd.y,
                      z + vectorToAdd.z, 
                      w);
}

// Subtracts the specified vector from this instance
void KSMVector4::operator-=(const KSMVector4 &vectorToSubtract)
{
    x += vectorToSubtract.x;
    y += vectorToSubtract.y;
    z += vectorToSubtract.z;    
}

// return a copy of this vector - the specified vector
KSMVector4 KSMVector4::operator-(const KSMVector4 &vectorToSubtract) const
{
    return KSMVector4(x - vectorToSubtract.x,
                      y - vectorToSubtract.y,
                      z - vectorToSubtract.z,
                      w);
}

// return the dot product of this vector with another
double KSMVector4::operator*(const KSMVector4 &otherVector) const
{
    return  x * otherVector.x +
            y * otherVector.y +
            z * otherVector.z;
}

// return the dot product of this vector with another
double KSMVector4::scalarProduct(const KSMVector4 &otherVector) const
{
    return (*this) * otherVector;
}

// return the vector product of this vector with another
KSMVector4 KSMVector4::operator%(const KSMVector4 &otherVector) const
{
    return KSMVector4( y * otherVector.z - z * otherVector.y,
                       z * otherVector.x - x * otherVector.z,
                       x * otherVector.y - y * otherVector.x,
                       w);
}

// return this vector to be the vector product of itself with another
void KSMVector4::operator%=(const KSMVector4 &otherVector)
{
    x =  y * otherVector.z - z * otherVector.y;
    y =  z * otherVector.x - x * otherVector.z;
    z =  x * otherVector.y - y * otherVector.x;
}

// return the vector product of this vector with another
KSMVector4 KSMVector4::vectorProduct(const KSMVector4 &otherVector) const
{
    return (*this) % otherVector;
}

// add the specified vector to this instance
void KSMVector4::add(KSMVector4 &vectorToAdd)
{
    x += vectorToAdd.x;
    y += vectorToAdd.y;
    z += vectorToAdd.z;
}

// Subtracts the specified vector from this instance
void KSMVector4::subtract(const KSMVector4 &vectorToSubtract)
{
    x -= vectorToSubtract.x;
    y -= vectorToSubtract.y;
    z -= vectorToSubtract.z;    
}

// reverse the direction of the vector (equivalent to scaling by -1)
void KSMVector4::reverse()
{
    x = -x;
    y = -y;
    z = -z;
}

// multiply each component of this vectory by the scalefactor
void KSMVector4::scaleBy(const double scaleFactor)
{
    x *= scaleFactor;
    y *= scaleFactor;
    z *= scaleFactor;
}

// return a copy copy of this vector scaled by the specified value
KSMVector4 KSMVector4::copyAndScale(const double scaleFactor) const
{
    return KSMVector4( x * scaleFactor, y * scaleFactor, z * scaleFactor, 1.0);
}

// return the square of the magnitude of the vector
double KSMVector4::length2()
{
    return (x*x + y*y + z*z);
}

// return the length of the vector
double KSMVector4::length()
{
    return pow(length2(), 0.5);
}

// return the magnitude of the vector (same as getLength)
double KSMVector4::magnitude()
{
    return length();
}

// Normalise this vector (divides by magnitude)
void KSMVector4::normalise()
{
    double inverseLength = 1.0 / ( length() + DBL_EPSILON);
    scaleBy(inverseLength);
}

// return a unit vector in the direction of this vector
KSMVector4 KSMVector4::unitVector()
{
    KSMVector4 v(*this);
    v.normalise();
    return v;
}

// add a scaled vector (this = this + scalefactor * vector) 
void KSMVector4::addScaledVector(const KSMVector4 &vector, 
                                 const double scaleFactor)
{
    x += scaleFactor * vector.x; 
    y += scaleFactor * vector.y; 
    z += scaleFactor * vector.z; 
}

// returns an appropriately scaled vector3 (x,y,z components scaled by 1/w)
KSMVector3 KSMVector4::vector3() const
{
    if (!fequalzero(w)) 
    {
        return KSMVector3(x/w, y/w, z/w);
    }
    return KSMVector3(x, y, z);
}

// default constructor
KSMMatrix4::KSMMatrix4()
{
    // construct the identity matrix in column major fashion
    d[0] = 1.0;  d[4] = 0.0;  d[8]  = 0.0; d[12] = 0.0;
    d[1] = 0.0;  d[5] = 1.0;  d[9]  = 0.0; d[13] = 0.0;
    d[2] = 0.0;  d[6] = 0.0;  d[10] = 1.0; d[14] = 0.0;
    d[3] = 0.0;  d[7] = 0.0;  d[11] = 0.0; d[15] = 1.0;
}

// default constructor
KSMMatrix3::KSMMatrix3()
{
    // construct the identity matrix in column major fashion
    d[0] = 1.0;  d[3] = 0.0;  d[6]  = 0.0;
    d[1] = 0.0;  d[4] = 1.0;  d[7]  = 0.0;
    d[2] = 0.0;  d[5] = 0.0;  d[8]  = 1.0;
}

// Add 4d matrix to 4d matrix
KSMMatrix4 KSMMatrix4::add(const KSMMatrix4 &addMatrix) const
{
    // get a copy of this matrix
    KSMMatrix4 sum = KSMMatrix4(*this);
    
    
    double *sumData = sum.d; 
    const double *addValue = addMatrix.d;

    *sumData++ += *addValue++;  //  0
    *sumData++ += *addValue++;  //  1
    *sumData++ += *addValue++;  //  2
    *sumData++ += *addValue++;  //  3
    *sumData++ += *addValue++;  //  4
    *sumData++ += *addValue++;  //  5
    *sumData++ += *addValue++;  //  6
    *sumData++ += *addValue++;  //  7
    *sumData++ += *addValue++;  //  8
    *sumData++ += *addValue++;  //  9
    *sumData++ += *addValue++;  //  10
    *sumData++ += *addValue++;  //  11
    *sumData++ += *addValue++;  //  12
    *sumData++ += *addValue++;  //  13
    *sumData++ += *addValue++;  //  14
    *sumData++ += *addValue++;  //  15
        
    return sum;
}

// add 3d matrix to 3d matrix
KSMMatrix3 KSMMatrix3::add(const KSMMatrix3 &addMatrix) const
{
    // get a copy of this matrix
    KSMMatrix3 sum = KSMMatrix3(*this);
    
    double *sumData = sum.d; 
    const double *addValue = addMatrix.d;
    
    *sumData++ += *addValue++;  //  0
    *sumData++ += *addValue++;  //  1
    *sumData++ += *addValue++;  //  2
    *sumData++ += *addValue++;  //  3
    *sumData++ += *addValue++;  //  4
    *sumData++ += *addValue++;  //  5
    *sumData++ += *addValue++;  //  6
    *sumData++ += *addValue++;  //  7
    *sumData++ += *addValue++;  //  8
    *sumData++ += *addValue++;  //  9
    *sumData++ += *addValue++;  //  10
    *sumData++ += *addValue++;  //  11
    *sumData++ += *addValue++;  //  12
    *sumData++ += *addValue++;  //  13
    *sumData++ += *addValue++;  //  14
    *sumData++ += *addValue++;  //  15
    
    return sum;
}

// set the elements of the matrix from three column vectors
void KSMMatrix3::setColumnsFromVectors(const KSMVector3 & column1,
                                       const KSMVector3 & column2,
                                       const KSMVector3 & column3)
{
    // set elements in column 1
    d[0] = column1.d[0];
    d[1] = column1.d[1];
    d[2] = column1.d[2];

    // column 2
    d[3] = column2.d[0];
    d[4] = column2.d[1];
    d[5] = column2.d[2];

    // column 3
    d[6] = column3.d[0];
    d[7] = column3.d[1];
    d[8] = column3.d[2];
}

// set the elements of the matrix from three row vectors
void KSMMatrix3::setRowsFromVectors(const KSMVector3 & row1,
                                    const KSMVector3 & row2,
                                    const KSMVector3 & row3)
{
    // set elements in row 1
    d[0] = row1.d[0];
    d[3] = row1.d[1];
    d[6] = row1.d[2];
    
    // row 2
    d[1] = row2.d[0];
    d[4] = row2.d[1];
    d[7] = row2.d[2];
    
    // row 3
    d[2] = row3.d[0];
    d[5] = row3.d[1];
    d[8] = row3.d[2];    
}

// return a copy of this vector added to the specified vector
KSMMatrix4 KSMMatrix4::operator+(const KSMMatrix4 &matrixToAdd) const
{
    KSMMatrix4 sum = *this;

    sum.d[0]  += matrixToAdd.d[0];
    sum.d[1]  += matrixToAdd.d[1];
    sum.d[2]  += matrixToAdd.d[2];
    sum.d[3]  += matrixToAdd.d[3];
    
    sum.d[4]  += matrixToAdd.d[4];
    sum.d[5]  += matrixToAdd.d[5];
    sum.d[6]  += matrixToAdd.d[6];
    sum.d[7]  += matrixToAdd.d[7];
    
    sum.d[8]  += matrixToAdd.d[8];
    sum.d[9]  += matrixToAdd.d[9];
    sum.d[10] += matrixToAdd.d[10];
    sum.d[11] += matrixToAdd.d[11];
    
    sum.d[12] += matrixToAdd.d[12];
    sum.d[13] += matrixToAdd.d[13];
    sum.d[14] += matrixToAdd.d[14];
    sum.d[15] += matrixToAdd.d[15];
    
    return sum;
}

// return a copy of this vector with the specified vector subtracted
KSMMatrix4 KSMMatrix4::operator-(const KSMMatrix4 &matrixToSubtract) const
{
    KSMMatrix4 sum = *this;
    
    sum.d[0]  += matrixToSubtract.d[0];
    sum.d[1]  += matrixToSubtract.d[1];
    sum.d[2]  += matrixToSubtract.d[2];
    sum.d[3]  += matrixToSubtract.d[3];
    
    sum.d[4]  += matrixToSubtract.d[4];
    sum.d[5]  += matrixToSubtract.d[5];
    sum.d[6]  += matrixToSubtract.d[6];
    sum.d[7]  += matrixToSubtract.d[7];
    
    sum.d[8]  += matrixToSubtract.d[8];
    sum.d[9]  += matrixToSubtract.d[9];
    sum.d[10] += matrixToSubtract.d[10];
    sum.d[11] += matrixToSubtract.d[11];
    
    sum.d[12] += matrixToSubtract.d[12];
    sum.d[13] += matrixToSubtract.d[13];
    sum.d[14] += matrixToSubtract.d[14];
    sum.d[15] += matrixToSubtract.d[15];
    
    return sum;
}

// return a copy of this vector added to the specified vector
KSMMatrix3 KSMMatrix3::operator+(const KSMMatrix3 &matrixToAdd) const
{
    KSMMatrix3 sum = *this;
    
    sum.d[0]  += matrixToAdd.d[0];
    sum.d[1]  += matrixToAdd.d[1];
    sum.d[2]  += matrixToAdd.d[2];
    sum.d[3]  += matrixToAdd.d[3];
    sum.d[4]  += matrixToAdd.d[4];
    sum.d[5]  += matrixToAdd.d[5];
    sum.d[6]  += matrixToAdd.d[6];
    sum.d[7]  += matrixToAdd.d[7];    
    sum.d[8]  += matrixToAdd.d[8];
    
    return sum;
}

// return a copy of this vector with the specified vector subtracted
KSMMatrix3 KSMMatrix3::operator-(const KSMMatrix3 &matrixToSubtract) const
{
    KSMMatrix3 sum = *this;
    
    sum.d[0]  += matrixToSubtract.d[0];
    sum.d[1]  += matrixToSubtract.d[1];
    sum.d[2]  += matrixToSubtract.d[2];
    sum.d[3]  += matrixToSubtract.d[3];
    sum.d[4]  += matrixToSubtract.d[4];
    sum.d[5]  += matrixToSubtract.d[5];
    sum.d[6]  += matrixToSubtract.d[6];
    sum.d[7]  += matrixToSubtract.d[7];
    sum.d[8]  += matrixToSubtract.d[8];
    
    return sum;
}

// permit expressions such as vec3b = mat3 * vec3a
KSMVector3 KSMMatrix3::operator*(const KSMVector3 &vec3) const
{
    return KSMVector3(
                      d[0] * vec3.d[0] + d[3]*vec3.d[1] + d[6]*vec3.d[2],
                      d[1] * vec3.d[0] + d[4]*vec3.d[1] + d[7]*vec3.d[2],
                      d[2] * vec3.d[0] + d[5]*vec3.d[1] + d[8]*vec3.d[2]
    );
}

// permit expressions such as vec3b = rotMat3 * vec3a
KSMVector3 KSMMatrix3Rot::operator*(const KSMVector3 &vec3) const
{
    return KSMVector3(
                      d[0] * vec3.d[0] + d[3]*vec3.d[1] + d[6]*vec3.d[2],
                      d[1] * vec3.d[0] + d[4]*vec3.d[1] + d[7]*vec3.d[2],
                      d[2] * vec3.d[0] + d[5]*vec3.d[1] + d[8]*vec3.d[2]
                      );
}

// permit expressions such as vec4b = mat4 * vec4a
KSMVector4 KSMMatrix4::operator*(const KSMVector4 &vec4) const
{
    return KSMVector4(
        d[ 0] * vec4.d[ 0] + d[ 4]*vec4.d[ 1] + d[ 8]*vec4.d[ 2] + d[12] * vec4.d[ 3],
        d[ 1] * vec4.d[ 0] + d[ 5]*vec4.d[ 1] + d[ 9]*vec4.d[ 2] + d[13] * vec4.d[ 3],
        d[ 2] * vec4.d[ 0] + d[ 6]*vec4.d[ 1] + d[10]*vec4.d[ 2] + d[14] * vec4.d[ 3],
        d[ 3] * vec4.d[ 0] + d[ 7]*vec4.d[ 1] + d[11]*vec4.d[ 2] + d[15] * vec4.d[ 3]
        );
}

// permit expressions such as mat3b = scalar * mat3a
KSMMatrix3 operator*(const double scaleFactor, const KSMMatrix3 &mat3)
{
    
    KSMMatrix3 product = mat3;
    
    product.d[0]  *= scaleFactor;
    product.d[1]  *= scaleFactor;
    product.d[2]  *= scaleFactor;
    product.d[3]  *= scaleFactor;
    product.d[4]  *= scaleFactor;
    product.d[5]  *= scaleFactor;
    product.d[6]  *= scaleFactor;
    product.d[7]  *= scaleFactor;    
    product.d[8]  *= scaleFactor;

    return product;
}

// permit expressions such as mat4b = scalar * mat4a
KSMMatrix4 operator*(const double scaleFactor, const KSMMatrix4 &mat4)
{
    
    KSMMatrix4 product = mat4;
    
    product.d[0]  *= scaleFactor;
    product.d[1]  *= scaleFactor;
    product.d[2]  *= scaleFactor;
    product.d[3]  *= scaleFactor;
    
    product.d[4]  *= scaleFactor;
    product.d[5]  *= scaleFactor;
    product.d[6]  *= scaleFactor;
    product.d[7]  *= scaleFactor;
    
    product.d[8]  *= scaleFactor;
    product.d[9]  *= scaleFactor;
    product.d[10] *= scaleFactor;
    product.d[11] *= scaleFactor;
    
    product.d[12] *= scaleFactor;
    product.d[13] *= scaleFactor;
    product.d[14] *= scaleFactor;
    product.d[15] *= scaleFactor;
    
    return product;
}

// permit expressions such as vec3b = scalar * vec3a
KSMVector3 operator*(const double scaleFactor, const KSMVector3 &vec3) 
{
    KSMVector3 product = vec3;
    product.d[0] *= scaleFactor;
    product.d[1] *= scaleFactor;
    product.d[2] *= scaleFactor;
    return product;
}

// permit expressions such as vec4b = scalar * vec4a
KSMVector4 operator*(const double scaleFactor, const KSMVector4 &vec4) 
{
    KSMVector4 product = vec4;
    product.d[0] *= scaleFactor;
    product.d[1] *= scaleFactor;
    product.d[2] *= scaleFactor;
    return product;
}

// permit mat3Z = mat3x * mat3y
KSMMatrix3 KSMMatrix3::operator*(const KSMMatrix3 &mat3) const
{
    KSMMatrix3 prod;
    
    // first row by first column
    prod.d[0] = d[0] * mat3.d[0] + d[3] * mat3.d[1] + d[6] * mat3.d[2];
    
    // second row by first column
    prod.d[1] = d[1] * mat3.d[0] + d[4] * mat3.d[1] + d[7] * mat3.d[2];
    
    // third row by first colum
    prod.d[2] = d[2] * mat3.d[0] + d[5] * mat3.d[1] + d[8] * mat3.d[2];


    // first row by second column
    prod.d[3] = d[0] * mat3.d[3] + d[3] * mat3.d[4] + d[6] * mat3.d[5];
    
    // second row by second column
    prod.d[4] = d[1] * mat3.d[3] + d[4] * mat3.d[4] + d[7] * mat3.d[5];
    
    // third row by second colum
    prod.d[5] = d[2] * mat3.d[3] + d[5] * mat3.d[4] + d[8] * mat3.d[5];

    
    // first row by third column
    prod.d[6] = d[0] * mat3.d[6] + d[3] * mat3.d[7] + d[6] * mat3.d[8];
    
    // second row by third column
    prod.d[7] = d[1] * mat3.d[6] + d[4] * mat3.d[7] + d[7] * mat3.d[8];
    
    // third row by third colum
    prod.d[8] = d[2] * mat3.d[6] + d[5] * mat3.d[7] + d[8] * mat3.d[8];    
    
    return prod;
    
}

// permit mat4Z = mat4x * mat4y
KSMMatrix4 KSMMatrix4::operator*(const KSMMatrix4 &mat4) const
{
    KSMMatrix4 prod;
    
    // first row by first column
    prod.d[0]  = d[0] * mat4.d[0]  + d[4] * mat4.d[1]  + d[8]  * mat4.d[2]  + d[12] * mat4.d[3];    

    // second row by first column
    prod.d[1]  = d[1] * mat4.d[0]  + d[5] * mat4.d[1]  + d[9]  * mat4.d[2]  + d[13] * mat4.d[3]; 
    
    // third row by first column    
    prod.d[2]  = d[2] * mat4.d[0]  + d[6] * mat4.d[1]  + d[10] * mat4.d[2]  + d[14] * mat4.d[3];
    
    // fourth row by first column    
    prod.d[3]  = d[3] * mat4.d[0]  + d[7] * mat4.d[1]  + d[11] * mat4.d[2]  + d[15] * mat4.d[3]; 

    // first row by second column
    prod.d[4]  = d[0] * mat4.d[4]  + d[4] * mat4.d[5]  + d[8]  * mat4.d[6]  + d[12] * mat4.d[7];    
    
    // second row by second column
    prod.d[5]  = d[1] * mat4.d[4]  + d[5] * mat4.d[5]  + d[9]  * mat4.d[6]  + d[13] * mat4.d[7]; 
    
    // third row by second column
    prod.d[6]  = d[2] * mat4.d[4]  + d[6] * mat4.d[5]  + d[10] * mat4.d[6]  + d[14] * mat4.d[7];
    
    // fourth row by second column
    prod.d[7]  = d[3] * mat4.d[4]  + d[7] * mat4.d[5]  + d[11] * mat4.d[6]  + d[15] * mat4.d[7];     
    
    // first row by third column
    prod.d[8]  = d[0] * mat4.d[8]  + d[4] * mat4.d[9]  + d[8]  * mat4.d[10] + d[12] * mat4.d[11];    
    
    // second row by third column
    prod.d[9]  = d[1] * mat4.d[8]  + d[5] * mat4.d[9]  + d[9]  * mat4.d[10] + d[13] * mat4.d[11]; 
    
    // third row by third column
    prod.d[10] = d[2] * mat4.d[8]  + d[6] * mat4.d[9]  + d[10] * mat4.d[10] + d[14] * mat4.d[11];
    
    // fourth row by third column
    prod.d[11] = d[3] * mat4.d[8]  + d[7] * mat4.d[9]  + d[11] * mat4.d[10] + d[15] * mat4.d[11];     
    
    // first row by fourth column
    prod.d[12] = d[0] * mat4.d[12] + d[4] * mat4.d[13] + d[8]  * mat4.d[14] + d[12] * mat4.d[15];    
    
    // second row by fourth column
    prod.d[13] = d[1] * mat4.d[12] + d[5] * mat4.d[13] + d[9]  * mat4.d[14] + d[13] * mat4.d[15]; 
    
    // third row by fourth column
    prod.d[14] = d[2] * mat4.d[12] + d[6] * mat4.d[13] + d[10] * mat4.d[14] + d[14] * mat4.d[15];
    
    // fourth row by fourth column
    prod.d[15] = d[3] * mat4.d[12] + d[7] * mat4.d[13] + d[11] * mat4.d[14] + d[15] * mat4.d[15];     
    
    return prod;
}

// returns the transpose of this instance
KSMMatrix3 KSMMatrix3::transpose() const
{
    KSMMatrix3 t = KSMMatrix3(*this);
    swap(t.d[1], t.d[3]);
    swap(t.d[2], t.d[6]);
    swap(t.d[5], t.d[7]);
    
    return t;
}

// returns the transpose of this instance
KSMMatrix4 KSMMatrix4::transpose() const
{
    KSMMatrix4 t = KSMMatrix4(*this);
    swap(t.d[1],  t.d[4]);
    swap(t.d[2],  t.d[8]);
    swap(t.d[3],  t.d[12]);
    swap(t.d[6],  t.d[9]);
    swap(t.d[7],  t.d[13]);
    swap(t.d[11], t.d[14]);
    
    return t;
}

// returns the determinant of this instance
double KSMMatrix3::determinant() const
{
    return
    (
        + d[0] * ( d[4] * d[8] - d[7] * d[5] )
        - d[3] * ( d[1] * d[8] - d[7] * d[2] )
        + d[6] * ( d[1] * d[5] - d[4] * d[2] )
    );
}

// returns the inverse of this instance
KSMMatrix3 KSMMatrix3::inverse() const
{
    KSMMatrix3 inverse = KSMMatrix3();
    inverse.d[0] = + d[4] * d[8] - d[7] * d[5];
    inverse.d[1] = - d[3] * d[8] + d[6] * d[5];
    inverse.d[2] = + d[3] * d[7] - d[6] * d[4];
    inverse.d[3] = - d[1] * d[8] + d[7] * d[2];
    inverse.d[4] = + d[0] * d[8] - d[6] * d[2];
    inverse.d[5] = - d[0] * d[7] + d[6] * d[1];
    inverse.d[6] = + d[1] * d[5] - d[4] * d[2];
    inverse.d[7] = - d[0] * d[5] + d[3] * d[2];
    inverse.d[8] = + d[0] * d[4] - d[3] * d[1];
    return 1.0 / determinant() * inverse;
}

// invert this instance
void KSMMatrix3::invert()
{
    KSMMatrix3 inverse = (*this).inverse();
    *this = inverse;
}

// the inverse of a rotation matrix is its transpose
KSMMatrix3 KSMMatrix3Rot::inverse() const
{
    return transpose();
}


// inverts the current instance
void KSMMatrix3Rot::invert()
{
    swap(d[1], d[3]);
    swap(d[2], d[6]);
    swap(d[5], d[7]);    
}

// extracts a 3x3 matrix form this 4x4 matrix
KSMMatrix3Rot KSMMatrix4::extract3x3() const
{
    KSMMatrix3Rot mat3;
    mat3.d[0] = d[0];
    mat3.d[1] = d[1];
    mat3.d[2] = d[2];
    mat3.d[3] = d[4];
    mat3.d[4] = d[5];
    mat3.d[5] = d[6];
    mat3.d[6] = d[8];
    mat3.d[7] = d[9];
    mat3.d[8] = d[10];
    
    return mat3;
}

// Extract position vector
KSMVector3 KSMMatrix4::extractPositionVector() const
{
    KSMVector3 positionVector;
    positionVector.d[0] = d[12];
    positionVector.d[1] = d[13];
    positionVector.d[2] = d[14];
    return positionVector;
}

// Extract position vector4
KSMVector4 KSMMatrix4::extractPositionVector4() const
{
    KSMVector4 positionVector;
    positionVector.d[0] = d[12];
    positionVector.d[1] = d[13];
    positionVector.d[2] = d[14];
    positionVector.d[3] = d[15];
    return positionVector;
}

// injects the 3x3 matrix into this 4x4 matrix
void KSMMatrix4::inject3x3(const KSMMatrix3Rot &mat3)
{
    d[0]  = mat3.d[0];
    d[1]  = mat3.d[1];
    d[2]  = mat3.d[2];
    d[4]  = mat3.d[3];
    d[5]  = mat3.d[4];
    d[6]  = mat3.d[5];
    d[8]  = mat3.d[6];
    d[9]  = mat3.d[7];
    d[10] = mat3.d[8];
}

// returns a new matrix that represents a rotation of the specified
// angle in radians about the direction represented by the direction/
// Note that there is no need to normalise direction, but its length
// must not be zero
KSMMatrix3Rot KSMMatrix3Rot::createRotationAboutDirection(const double angleRadians, 
                                                  const KSMVector3 &direction)
{
    // for this operation it is critical that the direction vector be normalised
    // so we do that here
    KSMVector3 v = direction.unitVector();
    
    double s = sin(angleRadians);
    double c = cos(angleRadians);
    double t = 1.0 - c;
    
    KSMMatrix3Rot r =  KSMMatrix3Rot();
    r.d[0] = v.x * v.x * t + c;        
    r.d[1] = v.x * v.y * t + v.z * s;
    r.d[2] = v.x * v.z * t - v.y * s;
    
    r.d[3] = v.x * v.y * t - v.z * s;
    r.d[4] = v.y * v.y * t + c;
    r.d[5] = v.y * v.z * t + v.x * s;
    
    r.d[6] = v.x * v.z * t + v.y * s;
    r.d[7] = v.y * v.z * t - v.x * s;
    r.d[8] = v.z * v.z * t + c;
    
    return r;
}

// creates a new mat4 that represents a translation with no rotation
KSMMatrix4 KSMMatrix4::CreateTranslation(const KSMVector3 &translation)
{
    // copy the components of the translation vector into
    // the appropriate slots in the new matrix
    KSMMatrix4 trans = KSMMatrix4();
    trans.d[12] = translation.d[0];
    trans.d[13] = translation.d[1];
    trans.d[14] = translation.d[2];
    return trans;
}

// creates a new mat4 that represents a translation with no rotation
KSMMatrix4 KSMMatrix4::CreateRotation(const KSMMatrix3Rot &rotation)
{
    KSMMatrix4 rot = KSMMatrix4();
    rot.inject3x3(rotation);
    return rot;
}

// add the specified translation to the current position vector 
void KSMMatrix4::translate(const KSMVector3 &translation)
{
    d[12] += translation.d[0];
    d[13] += translation.d[1];
    d[14] += translation.d[2];    
}

// concatenates the specified rotation with the current rotation matrix
void KSMMatrix4::rotateAboutAxis(const double radians, const KSMVector3 &axis)
{
    if ( fequalzero(radians) ) 
    {
        return;
    }
    KSMMatrix3Rot rot = KSMMatrix3Rot::createRotationAboutDirection(radians, axis);
    KSMMatrix3Rot extract = extract3x3();

    extract = rot * extract;
    (*this).inject3x3(extract);
}

// sets the current position vector leaving rotation unchanged
void KSMMatrix4::setPosition(const KSMVector3 &position)
{
    d[12] = position.d[0];
    d[13] = position.d[1];
    d[14] = position.d[2];
}

// sets the current position vector leaving rotation unchanged
void KSMMatrix4::setPosition(const KSMVector4 &position)
{
    d[12] = position.d[0];
    d[13] = position.d[1];
    d[14] = position.d[2];
    d[15] = position.d[3];
}

// sets the current rotation matrix leaving position unchanged
void KSMMatrix4::setOrientation(const KSMMatrix3Rot &rotation)
{
    (*this).inject3x3(rotation);
}


// quick inverse (assumes matrix only holds rotation and translation
KSMMatrix4 KSMMatrix4::quickInverse()
{
    double a0 = d[ 0]*d[ 5] - d[ 1]*d[ 4];
    double a1 = d[ 0]*d[ 6] - d[ 2]*d[ 4];

    double a3 = d[ 1]*d[ 6] - d[ 2]*d[ 5];


    double b0 = d[ 8]*d[13] - d[ 9]*d[12];
    double b1 = d[ 8]*d[14] - d[10]*d[12];
    double b2 = d[ 8]*d[15];
    double b3 = d[ 9]*d[14] - d[10]*d[13];
    double b4 = d[ 9]*d[15];
    double b5 = d[10]*d[15];
    
    double det = a0*b5 - a1*b4 + a3*b2;
    
    KSMMatrix4 inverse;
    inverse.d[ 0] = + d[ 5]*b5 - d[ 6]*b4;
    inverse.d[ 4] = - d[ 4]*b5 + d[ 6]*b2;
    inverse.d[ 8] = + d[ 4]*b4 - d[ 5]*b2;
    inverse.d[12] = - d[ 4]*b3 + d[ 5]*b1 - d[ 6]*b0;
    inverse.d[ 1] = - d[ 1]*b5 + d[ 2]*b4;
    inverse.d[ 5] = + d[ 0]*b5 - d[ 2]*b2;
    inverse.d[ 9] = - d[ 0]*b4 + d[ 1]*b2;
    inverse.d[13] = + d[ 0]*b3 - d[ 1]*b1 + d[ 2]*b0;
    inverse.d[ 2] = + d[15]*a3;
    inverse.d[ 6] = - d[15]*a1;
    inverse.d[10] = + d[15]*a0;
    inverse.d[14] = - d[12]*a3 + d[13]*a1 - d[14]*a0;
    inverse.d[ 3] = - d[11]*a3;
    inverse.d[ 7] = + d[11]*a1;
    inverse.d[11] = - d[11]*a0;
    inverse.d[15] = + d[ 8]*a3 - d[ 9]*a1 + d[10]*a0;
    
    double invDet = (1.0)/det;
    inverse.d[ 0] *= invDet;
    inverse.d[ 1] *= invDet;
    inverse.d[ 2] *= invDet;
    inverse.d[ 3] *= invDet;
    inverse.d[ 4] *= invDet;
    inverse.d[ 5] *= invDet;
    inverse.d[ 6] *= invDet;
    inverse.d[ 7] *= invDet;
    inverse.d[ 8] *= invDet;
    inverse.d[ 9] *= invDet;
    inverse.d[10] *= invDet;
    inverse.d[11] *= invDet;
    inverse.d[12] *= invDet;
    inverse.d[13] *= invDet;
    inverse.d[14] *= invDet;
    inverse.d[15] *= invDet;
    
    return inverse;
}

// concatenates rotation matrices
KSMMatrix3Rot KSMMatrix3Rot::operator*(const KSMMatrix3Rot &mat3)
{
    KSMMatrix3Rot prod;
    
    // first row by first column
    prod.d[0] = d[0] * mat3.d[0] + d[3] * mat3.d[1] + d[6] * mat3.d[2];
    
    // second row by first column
    prod.d[1] = d[1] * mat3.d[0] + d[4] * mat3.d[1] + d[7] * mat3.d[2];
    
    // third row by first colum
    prod.d[2] = d[2] * mat3.d[0] + d[5] * mat3.d[1] + d[8] * mat3.d[2];
    
    
    // first row by second column
    prod.d[3] = d[0] * mat3.d[3] + d[3] * mat3.d[4] + d[6] * mat3.d[5];
    
    // second row by second column
    prod.d[4] = d[1] * mat3.d[3] + d[4] * mat3.d[4] + d[7] * mat3.d[5];
    
    // third row by second colum
    prod.d[5] = d[2] * mat3.d[3] + d[5] * mat3.d[4] + d[8] * mat3.d[5];
    
    
    // first row by third column
    prod.d[6] = d[0] * mat3.d[6] + d[3] * mat3.d[7] + d[6] * mat3.d[8];
    
    // second row by third column
    prod.d[7] = d[1] * mat3.d[6] + d[4] * mat3.d[7] + d[7] * mat3.d[8];
    
    // third row by third colum
    prod.d[8] = d[2] * mat3.d[6] + d[5] * mat3.d[7] + d[8] * mat3.d[8];    
    
    return prod;    
}

// concatenates the specified rotation with the current rotation matrix
// note that axis is assumed to be specified in world coordinates, as is the
// point through which the axis runs)
void KSMMatrix4::rotateAboutAxisAtPosition(const double radians, 
                               const KSMVector3 &axisWorld,
                               const KSMVector3 &pointWorld)
{
    // trick here is to first translate, then rotate, then reverse out
    // the tranlsation
    
    // begin by translating such that pointWorld is at the origin
    KSMVector3 reverseTranslation = pointWorld;
    reverseTranslation.reverse();
    
    KSMMatrix4 doTranslation = KSMMatrix4::CreateTranslation(reverseTranslation);
    KSMMatrix4 undoTranslation = KSMMatrix4::CreateTranslation(pointWorld); 
    
    // setup the rotation bit
    KSMMatrix3Rot rot = KSMMatrix3Rot::createRotationAboutDirection(radians, 
                                                                     axisWorld);
    KSMMatrix4 doRotation;
    doRotation.inject3x3(rot);
    
    // create transform that combines the operations and assign to this
    (*this) = undoTranslation * doRotation * doTranslation * (*this);
    
}     

KSMMatrix4 KSMMatrix4::inverse() const
{
    double a0 = d[ 0]*d[ 5] - d[ 1]*d[ 4];
    double a1 = d[ 0]*d[ 6] - d[ 2]*d[ 4];
    double a2 = d[ 0]*d[ 7] - d[ 3]*d[ 4];
    double a3 = d[ 1]*d[ 6] - d[ 2]*d[ 5];
    double a4 = d[ 1]*d[ 7] - d[ 3]*d[ 5];
    double a5 = d[ 2]*d[ 7] - d[ 3]*d[ 6];
    double b0 = d[ 8]*d[13] - d[ 9]*d[12];
    double b1 = d[ 8]*d[14] - d[10]*d[12];
    double b2 = d[ 8]*d[15] - d[11]*d[12];
    double b3 = d[ 9]*d[14] - d[10]*d[13];
    double b4 = d[ 9]*d[15] - d[11]*d[13];
    double b5 = d[10]*d[15] - d[11]*d[14];
    
    double det = a0*b5 - a1*b4 + a2*b3 + a3*b2 - a4*b1 + a5*b0;

    KSMMatrix4 inverse;
    inverse.d[ 0] = + d[ 5]*b5 - d[ 6]*b4 + d[ 7]*b3;
    inverse.d[ 4] = - d[ 4]*b5 + d[ 6]*b2 - d[ 7]*b1;
    inverse.d[ 8] = + d[ 4]*b4 - d[ 5]*b2 + d[ 7]*b0;
    inverse.d[12] = - d[ 4]*b3 + d[ 5]*b1 - d[ 6]*b0;
    inverse.d[ 1] = - d[ 1]*b5 + d[ 2]*b4 - d[ 3]*b3;
    inverse.d[ 5] = + d[ 0]*b5 - d[ 2]*b2 + d[ 3]*b1;
    inverse.d[ 9] = - d[ 0]*b4 + d[ 1]*b2 - d[ 3]*b0;
    inverse.d[13] = + d[ 0]*b3 - d[ 1]*b1 + d[ 2]*b0;
    inverse.d[ 2] = + d[13]*a5 - d[14]*a4 + d[15]*a3;
    inverse.d[ 6] = - d[12]*a5 + d[14]*a2 - d[15]*a1;
    inverse.d[10] = + d[12]*a4 - d[13]*a2 + d[15]*a0;
    inverse.d[14] = - d[12]*a3 + d[13]*a1 - d[14]*a0;
    inverse.d[ 3] = - d[ 9]*a5 + d[10]*a4 - d[11]*a3;
    inverse.d[ 7] = + d[ 8]*a5 - d[10]*a2 + d[11]*a1;
    inverse.d[11] = - d[ 8]*a4 + d[ 9]*a2 - d[11]*a0;
    inverse.d[15] = + d[ 8]*a3 - d[ 9]*a1 + d[10]*a0;
    
    double invDet = (1.0)/det;
    inverse.d[ 0] *= invDet;
    inverse.d[ 1] *= invDet;
    inverse.d[ 2] *= invDet;
    inverse.d[ 3] *= invDet;
    inverse.d[ 4] *= invDet;
    inverse.d[ 5] *= invDet;
    inverse.d[ 6] *= invDet;
    inverse.d[ 7] *= invDet;
    inverse.d[ 8] *= invDet;
    inverse.d[ 9] *= invDet;
    inverse.d[10] *= invDet;
    inverse.d[11] *= invDet;
    inverse.d[12] *= invDet;
    inverse.d[13] *= invDet;
    inverse.d[14] *= invDet;
    inverse.d[15] *= invDet;
            
    return inverse;
}

double KSMIntersections::rayAndPlane(const KSMVector3 & rayStart,
                                    const KSMVector3 & rayDirection,
                                    const KSMVector3 & planeNormal, 
                                    const double planeOffset)
{
    // get the component of the ray in the direction parallel to the plane normal
    double perpendicularComponent = planeNormal * rayDirection;
    
    if ( fequalzero(perpendicularComponent) )
    {
        // ray and plane are close to being parallel, 
        // so return a huge number for the intersection point
        return DBL_MAX;
    }

    
    // as the ray and plane are not close to being parallel, we can calculate
    // the solution
    KSMVector3 pointInPlane = planeOffset * planeNormal;
    return planeNormal * (pointInPlane - rayStart) / perpendicularComponent;
    
}

