
//
//  KSMMaths.h
//
//  Created by Keith Staines on 05/09/2011.
//  Copyright 2011 Object Computing Solutions LTD. All rights reserved.
//
    

#ifndef KSMVector
#define KSMVector
#include <math.h>
#include <float.h>

const double      PI           = 4.0 * atan(1.0); 
const double      PIBY2        = PI / 2.0;
const double      TWOPI        = PI * 2.0;
const double      FOURPIBY3    = PI * 4.0 / 3.0;
const double      FOURPI       = PI * 4.0;
const double      ONEOVERROOT2 = 1.0 / sqrt(2.0);
const double      ROOT2        = sqrt(2.0);

class KSMMatrix4;
class KSMMatrix3Rot;
class KSMVector3;

extern const KSMVector3 KSM_X;
extern const KSMVector3 KSM_Y;
extern const KSMVector3 KSM_Z;
extern const KSMVector3 KSM_UP;
extern const KSMVector3 KSM_RIGHT;
extern const KSMVector3 KSM_OUT;


////////////////////////////////////////////////////////////////////////////////
// utility functions

// swap functions of various types
inline void swap(int &a, int &b)         {int  c = a; a = b; b = c;}
inline void swap(float &a, float &b)     {float c = a; a = b; b = c;}
inline void swap(double &a, double &b)   {double  c = a; a = b; b = c;}
inline void swap(unsigned short &a, unsigned short &b) 
{unsigned short c = a; a = b; b = c;}

// angle conversions
inline double degTorad(const double angleInDeg) {return angleInDeg * PI / 180.0;}
inline double radToDeg(const double angleInRad) {return angleInRad * 180.0 / PI;}

// Double array to float array. The elements of an array of doubles are cast to 
// floats and copied to a new array of floats
float * floatsFromDoubles(const double * doubles, int count);

// floating point comparisons
bool fequalzero(float a);// { return fabs(a) < FLT_EPSILON; }
bool fequal(float a, float b);// { return fabs( (a) - (b)) < FLT_EPSILON; }
bool fequalzero(double a);
bool fequal(double a, double b);// { return fabs(a - b) < FLT_EPSILON; }

////////////////////////////////////////////////////////////////////////////////
// class implementations 

class KSMVector4 {
public:    
    union
    {
        struct
        {
            double x;
            double y;
            double z;
            double w;
        };
        double d[4];
    };
    
public:
    // default constructor
    KSMVector4();
    
    // constructor initialises components to specified values
    KSMVector4(const double x, const double y, const double z, const double w);
    
    // scale this vector by the specified value (equivelant to scaleBy)
    void operator*=(const double scaleFactor);
    
    // return a copy of this vector scaled by the appropriate value
    KSMVector4 operator*(const double scaleFactor) const;
    
    // Adds the specified vector to this instance
    void operator+=(const KSMVector4 &vectorToAdd);
    
    // return a copy of this vector added to the specified vector
    KSMVector4 operator+(const KSMVector4 &vectorToAdd) const;
    
    // Subtracts the specified vector from this instance
    void operator-=(const KSMVector4 &vectorToSubtract);
    
    // return a copy of this vector - the specified vector
    KSMVector4 operator-(const KSMVector4 &vectorToSubtract) const; 
    
    // return the dot product of this vector with another
    double operator*(const KSMVector4 &otherVector) const;    
    
    // return the dot product of this vector with another
    double scalarProduct(const KSMVector4 &otherVector) const;   
    
    // return the vector product of this vector with another
    KSMVector4 operator%(const KSMVector4 &otherVector) const;     
    
    // return this vector to be the vector product of itself with another
    void operator%=(const KSMVector4 &otherVector);     
    
    // return the vector product of this vector with another
    KSMVector4 vectorProduct(const KSMVector4 &otherVector) const; 
    
    // add the specified vector to this instance
    void add(KSMVector4 &vectorToAdd);
    
    // Subtracts the specified vector from this instance
    void subtract(const KSMVector4 &vectorToSubtract);
    
    // reverse the direction of the vector (equivalent to scaling by -1)
    void reverse();
    
    // multiply each component of this vectory by the scalefactor
    void scaleBy(const double scaleFactor);
    
    // return a copy copy of this vector scaled by the specified value
    KSMVector4 copyAndScale(const double scaleFactor) const;
    
    // return the square of the magnitude of the vector
    double length2();
    
    // return the length of the vector
    double length();
    
    // return the magnitude of the vector (same as getLength)
    double magnitude();
    
    // Normalise this vector (divides by magnitude)
    void normalise();
    
    // return a unit vector in the direction of this vector
    KSMVector4 unitVector();
    
    // add a scaled vector (this = this + scalefactor * vector) 
    void addScaledVector(const KSMVector4 &vector, const double scaleFactor);
    
    // permit expressions such as vec4b = scalar * vec4a    
    friend KSMVector4 operator*(const double scaleFactor, 
                                const KSMVector4 &vec4) ;
    
    // returns an appropriately scaled vector3 (x,y,z components scaled by 1/w)
    KSMVector3 vector3() const;

};

class KSMVector3
{
    
public:
    
    union
    {
        struct
        {
            double x;    // x component of vector
            double y;    // y component of vector
            double z;    // z component of vector
        };
        double d[3];  // components may also be referenced by index
    };
    
    // "rarely used" component wise product. Do not mistake for dot product
    static KSMVector3 componentProduct(const KSMVector3 &v1, 
                                       const KSMVector3 &v2);
    
    // default constructor makes a zero vector
    KSMVector3();
    
    // constructor initialises components to specified values
    KSMVector3(const double x, const double y, const double z);
    
    // scale this vector by the specified value (equivelant to scaleBy)
    void operator*=(const double scaleFactor);
    
    // return a copy of this vector scaled by the appropriate value
    KSMVector3 operator*(const double scaleFactor) const;

    // Adds the specified vector to this instance
    void operator+=(const KSMVector3 &vectorToAdd);
    
    // return a copy of this vector added to the specified vector
    KSMVector3 operator+(const KSMVector3 &vectorToAdd) const;
    
    // Subtracts the specified vector from this instance
    void operator-=(const KSMVector3 &vectorToSubtract);
    
    // return a copy of this vector - the specified vector
    KSMVector3 operator-(const KSMVector3 &vectorToSubtract) const; 
    
    // return the dot product of this vector with another
    double operator*(const KSMVector3 &otherVector) const;    
    
    // zero all components
    void zero();

    // return the dot product of this vector with another
    double scalarProduct(const KSMVector3 &otherVector) const;   
    
    // return the vector product of this vector with another
    KSMVector3 operator%(const KSMVector3 &otherVector) const;     
    
    // return this vector to be the vector product of itself with another
    void operator%=(const KSMVector3 &otherVector);     
    
    // return the vector product of this vector with another
    KSMVector3 vectorProduct(const KSMVector3 &otherVector) const; 
    
    // add the specified vector to this instance
    void add(KSMVector3 &vectorToAdd);
    
    // Subtracts the specified vector from this instance
    void subtract(const KSMVector3 &vectorToSubtract);
    
    // reverse the direction of the vector (equivalent to scaling by -1)
    void reverse();
    
    // multiply each component of this vectory by the scalefactor
    void scaleBy(const double scaleFactor);
    
    // return a copy copy of this vector scaled by the specified value
    KSMVector3 copyAndScale(const double scaleFactor) const;
    
    // return the square of the magnitude of the vector
    double length2() const;
    
    // return the length of the vector
    double length() const;
    
    // return the magnitude of the vector (same as getLength)
    double magnitude() const;
    
    // Normalise this vector (divides by magnitude)
    void normalise();
    
    // return a unit vector in the direction of this vector
    KSMVector3 unitVector() const;
    
    // add a scaled vector (this = this + scalefactor * vector) 
    void addScaledVector(const KSMVector3 &vector, const double scaleFactor);
    
    //returns a vector4 with same x,y, and z components as this, and w = 1
    KSMVector4 vector4Position() const;
    
    // returns a vector4 with same x,y,z components as this and w = 0
    KSMVector4 vector4Direction() const;
    
    // permit expressions such as vec3b = mat3 * vec3a
    friend KSMVector3 operator*(const double scaleFactor, 
                                const KSMVector3 &vec3) ;
     
protected:
    
private:
    
};

class KSMMatrix3 {
public:
    double d[9];
    
public:
    // default constructor creates the identity matrix
    KSMMatrix3();
    
    // returns the transpose of this instance
    KSMMatrix3 transpose() const;
    
    // returns the inverse of this instance
    virtual KSMMatrix3 inverse() const;
    
    // inverts the current instance
    virtual void invert(void);
    
    // returns the determinant of this instance
    double determinant() const;
    
    // returns the matrix sum of this matrix and the specified matrix
    KSMMatrix3 add(const KSMMatrix3 &mat3) const;
    
    // set the elements of the matrix from three column vectors
    void setColumnsFromVectors(const KSMVector3 & column1,
                               const KSMVector3 & column2,
                               const KSMVector3 & column3);
    
    // set the elements of the matrix from three row vectors
    void setRowsFromVectors(const KSMVector3 & row1,
                            const KSMVector3 & row2,
                            const KSMVector3 & row3);
    
    // multiply this matrix onto the specified vector
    virtual KSMVector3 operator*(const KSMVector3 &vec3) const;
    
    // return a copy of this vector added to the specified vector
    KSMMatrix3 operator+(const KSMMatrix3 &matrixToAdd) const;
    
    // return a copy of this vector with the specified vector subtracted
    KSMMatrix3 operator-(const KSMMatrix3 &matrixToSubtract) const;
    
    // permit mat3Z = mat3x * mat3y
    KSMMatrix3 operator*(const KSMMatrix3 &mat3) const;
    
    // permit expressions such as mat3b = scalar * mat3a
    friend KSMMatrix3 operator*(const double scaleFactor, 
                                const KSMMatrix3 &mat3) ;
        
};

class KSMMatrix3Rot : public KSMMatrix3 
{
                
public:
    //override the inverse function. For roation matrices, the inverse is
    // the transpose, which is much quicker to calculate
    virtual KSMMatrix3 inverse() const;
    
    // inverts the current instance (by transposing)
    void invert();
    
    // returns a new matrix that represents a rotation of the specified
    // angle in radians about the direction represented by the direction/
    // Note that there is no need to normalise direction, but its length
    // must not be zero
    static KSMMatrix3Rot createRotationAboutDirection(const double angleRadians, 
                                              const KSMVector3 &direction);
    
    // additional multiplication operation
    KSMMatrix3Rot operator*(const KSMMatrix3Rot &mat3);
    
    // multiply this matrix onto the specified vector
    virtual KSMVector3 operator*(const KSMVector3 &vec3) const;
    
};

class KSMMatrix4 {
public:
    double d[16];
    
public:
    // default constructor creates the identity matrix
    KSMMatrix4();
    
    // returns the transpose of this instance
    KSMMatrix4 transpose() const;
    
    // returns the inverse of this instance
    KSMMatrix4 inverse() const;
    
    // returns the determinant of this instance
    double determinant() const;
    
    // returns the matrix sum of this matrix and the specified matrix
    KSMMatrix4 add(const KSMMatrix4 &mat4) const;
    
    // return a copy of this vector added to the specified vector
    KSMMatrix4 operator+(const KSMMatrix4 &matrixToAdd) const;
    
    // return a copy of this vector with the specified vector subtracted
    KSMMatrix4 operator-(const KSMMatrix4 &matrixToSubtract) const;
    
    // multiply this matrix onto the specified vector
    KSMVector4 operator*(const KSMVector4 &vec4) const;    
    
    // permit mat4Z = mat4x * mat4y
    KSMMatrix4 operator*(const KSMMatrix4 &mat4) const;   
    
    // Extract a 3x3 matrix
    KSMMatrix3Rot extract3x3() const;
    
    // Extract position vector
    KSMVector3 extractPositionVector() const;

    // Extract position vector
    KSMVector4 extractPositionVector4() const;    
    
    // Inject a 3x3 matrix
    void inject3x3(const KSMMatrix3Rot &mat3);
    
    // permit expressions such as matY = 3 * matX
    friend KSMMatrix4 operator*(const double scaleFactor, 
                                const KSMMatrix4 &mat4) ;
    
    // creates a new mat4 that represents a translation with no rotation
    static KSMMatrix4 CreateTranslation(const KSMVector3 &translation);
    
    // creates a new mat4 that represents a rotation with no translation
    static KSMMatrix4 CreateRotation(const KSMMatrix3Rot &rotation);
    
    // add the specified translation to the current position vector 
    void translate(const KSMVector3 &translation);
    
    // concatenates the specified rotation with the current rotation matrix
    // note that axis is assumed to be specified in world coordinates
    void rotateAboutAxis(const double radians, const KSMVector3 &axisWorld);
    
    // concatenates the specified rotation with the current rotation matrix
    // note that axis is assumed to be specified in world coordinates, as is the
    // point through which the axis runs)
    void rotateAboutAxisAtPosition(const double radians, 
                                   const KSMVector3 &axisWorld,
                                   const KSMVector3 &pointWorld);
    
    // sets the current position vector leaving rotation unchanged
    void setPosition(const KSMVector3 &position);
    
    // sets the current position vector leaving rotation unchanged
    void setPosition(const KSMVector4 &position);
    
    // sets the current rotation matrix leaving position unchanged
    void setOrientation(const KSMMatrix3Rot &rotation);
    
    // quick inverse returns a new matrix representing the inverse of the
    // current instance (this method assumes the matrix only holds rotation and
    // translation information
    KSMMatrix4 quickInverse();
    
    
};

class KSMIntersections 
{    
public:
    
    // returns the offset along the ray direction, starting from the ray start-
    // point, of the point of intersection of the ray with the plane. The ray
    // direction is expected to be a unit vector, as is the plane normal.
    static double rayAndPlane(const KSMVector3 & rayStart,
                              const KSMVector3 & rayDirection,
                              const KSMVector3 & planeNormal, 
                              const double planeOffset);
};

#endif
    
