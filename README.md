# Volusia County School Proximity Analysis

PostGIS-based geospatial analysis calculating the nearest elementary, middle, and high schools to every parcel in Volusia County, Florida.

**Author**: Timothy Elvira

## Overview

This project uses PostgreSQL/PostGIS to perform K-Nearest Neighbor (KNN) spatial analysis on Volusia County parcel data, identifying the closest public school at each education level and calculating distances in miles. Results are stored directly in the parcel table for real estate and demographic analysis.

## Technology Stack

- **Database**: PostgreSQL with PostGIS extension
- **Language**: SQL with PL/pgSQL stored procedures
- **Spatial Operations**: KNN operator (`<->`), ST_Distance
- **Data Source**: Volusia County GIS layers

## Data Schema

### Input Tables
- `volusia.gis_schools` - School locations with geometry, names, addresses, and types
- `volusia.parcel` - Property parcel data with geometry
- `volusia.gis_address` - Address reference data

### Added Columns to Parcel Table
```sql
nearest_Elem_School VARCHAR
distance_To_Elem_School DOUBLE PRECISION
nearest_Middle_School VARCHAR
distance_To_Middle_School DOUBLE PRECISION
nearest_High_School VARCHAR
distance_To_High_School DOUBLE PRECISION
```

## Project Files

- `SQLProject.txt` - Main setup queries and schema modifications
- `CS540_Elementaries_Analysis.sql` - PL/pgSQL procedure for elementary school KNN
- `CS540_Middle_Analysis.sql` - PL/pgSQL procedure for middle school KNN
- `CS540_High_Analysis.sql` - PL/pgSQL procedure for high school KNN

## Methodology

### 1. Schema Preparation
Add columns to parcel table to store nearest school names and distances for each education level.

### 2. KNN Spatial Search
For each parcel:
- Use PostGIS KNN operator (`<->`) to find the nearest public school of each type
- Calculate straight-line distance using `ST_Distance()`
- Convert distance from feet to miles (÷ 5280)
- Update parcel record with school name and distance

### 3. Processing
PL/pgSQL stored procedures loop through all parcels with NULL values and populate school proximity data.

## Key Features

### Spatial Indexing
Uses PostGIS spatial indexes with KNN operator for efficient nearest neighbor queries:
```sql
ORDER BY s.geom <-> (parcel_geometry)
LIMIT 1
```

### Distance Calculation
Converts PostGIS distance (feet) to miles:
```sql
ST_Distance(s.geom, parcel.geom) / 5280
```

### School Filtering
- Only public schools included (`s.theme = 'PUBLIC'`)
- Pattern matching for school types (`ILIKE '%elem%'`, `'%middle%'`, `'%high%'`)
- Excludes records without valid addresses

## Applications

- **Real Estate Valuation**: School proximity significantly impacts property values
- **Educational Planning**: Analyze school coverage and accessibility
- **Demographic Studies**: Understand spatial distribution of educational resources
- **Property Analysis**: Enhance parcel data with educational context

## Performance

The KNN operator provides efficient spatial queries on large datasets without requiring full distance calculations for all records. PL/pgSQL loops allow batch processing of all parcels with progress tracking via `RAISE NOTICE`.

## Sample Query

Find parcels with complete school proximity data:
```sql
SELECT parid, 
       nearest_elem_school, distance_to_elem_school,
       nearest_middle_school, distance_to_middle_school, 
       nearest_high_school, distance_to_high_school
FROM volusia.parcel 
WHERE nearest_elem_school IS NOT NULL 
  AND nearest_middle_school IS NOT NULL 
  AND nearest_high_school IS NOT NULL;
```

## Requirements

- PostgreSQL 9.5+
- PostGIS 2.0+
- Volusia County GIS data layers

## Contact

For questions or collaboration:
- Timothy Elvira: elvirat@my.erau.edu
