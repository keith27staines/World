//
//  KSPConstants.h
//  World
//
//  Created by Keith Staines on 12/12/2011.
//  Copyright (c) 2011 Object Computing Solutions LTD. All rights reserved.
//

#ifndef World_KSPConstants_h
#define World_KSPConstants_h

////////////////////////////////////////////////////////////////////////////////
// Fundamental physical constants all in base metric units (kg, s, m, etc)

// speed of light
const double kspcLightSpeed                                  = 3.0E8;

// Universal gravitational constant
const double kspcGravitationalConstant                       = 6.673E-11;

////////////////////////////////////////////////////////////////////////////////
// conversion factors
const double kspcAstronomy1AU                                = 1.49598E11;
const double kspcAstronomy1Parsec                            = 3.08568025E16;
const double kspcAstronomy1LightYear                         = 9.4605284E15;


////////////////////////////////////////////////////////////////////////////////
// particle physics


////////////////////////////////////////////////////////////////////////////////
// astronomical bodies (absolute values in metres, kg, etc)

const double kspcAstronomyRadiusOfEarth                      = 6.3781E6;
const double kspcAstronomyRadiusOfSun                        = 6.9500E8;
const double kspcAstronomyMassOfEarth                        = 5.9742E24;
const double kspcAstronomyMassOfSun                          = 1.98892E30;


enum SolarSystemBody 
{
    Sun = 0,
    Jupiter,
    Io_Jupiter_I,
    Europa_Jupiter_II,
    Ganymede_Jupiter_III,
    Callisto_Jupiter_IV,
    Saturn,
    Titan_Saturn_VI,
    Uranus,
    Neptune,
    Triton_Neptune_I,
    Earth,
    Moon_Earth_I,
    Venus,
    Mars,
    Mercury
};


////////////////////////////////////////////////////////////////////////////////
// Earth's properties
// Magnitude of the acceleration due to gravity at Earth's surface in meters per
// second squared
const double kspc1G = 9.81; 

// acceleration due to gravity on Earth's surface
const KSMVector3 kspcEarthGravity = KSMVector3(0, -kspc1G, 0);

////////////////////////////////////////////////////////////////////////////////
// Material densities in kg per m3

// Density of water at STP
const double kspcDensityLiquidWater   = 1000.0;

// Density of air at STP
const double kspcDensityGasAir                = kspcDensityLiquidWater *  0.0012;

// Density of aluminium
const double kspcDensityAluminium             = kspcDensityLiquidWater *  2.700;

// Density of titanium 
const double kspcDensityMetalTitanium         = kspcDensityLiquidWater *  4.540;

// Density of iron
const double kspcDensityMetalIron             = kspcDensityLiquidWater *  7.890;

// density of mercury
const double kspcDensityMetalMercury          = kspcDensityLiquidWater * 13.546;

// density of gold
const double kspcDensityMetalGold             = kspcDensityLiquidWater * 19.320;

// density of plastic (representative value)
const double kspcDensityPlastic               = kspcDensityLiquidWater *  1.000;

// density of ice
const double kspcDensityIce                   = kspcDensityLiquidWater *  0.917;

// density of sea water
const double kspcDensitySea                   = kspcDensityLiquidWater *  1.300;

// density of cork 
const double kspcDensityCork                  = kspcDensityLiquidWater *  0.240;

// density of oak wood (representative)
const double kspcDensityWoodOak               = kspcDensityLiquidWater *  0.700;

// density of balsa wood
const double kspcDensityWoodBalsa             = kspcDensityLiquidWater *  0.170;

// density of ebony wood
const double kspcDensityWoodEbony             = kspcDensityLiquidWater *  1.200;

// density of pine wood (representative)
const double kspcDensityWoodPine              = kspcDensityLiquidWater *  0.530;

// density of granite
const double kspcDensityMineralGranite        = kspcDensityLiquidWater *  2.600;

// density of basalt
const double kspcDensityMineralBasalt         = kspcDensityLiquidWater *  2.900;

// density of marble
const double kspcDensityMineralMarble         = kspcDensityLiquidWater *  2.400;

// density of glass
const double kspcBuildingMaterialGlass        = kspcDensityLiquidWater *  2.600;

// density of brick
const double kspcBuildingMaterialBrick        = kspcDensityLiquidWater *  2.000;

// density of concrete
const double kspcBuildingMaterialConcrete     = kspcDensityLiquidWater *  2.300;

// density of rubber
const double kspcBuildingMaterialRubber       = kspcDensityLiquidWater *  1.500;


#endif
