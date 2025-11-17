Update volusia.parcel
set nearest_high_school = null, distance_To_high_School = null;

select geom, parid, nearest_elem_school, distance_to_elem_school, nearest_middle_school, distance_to_middle_school, nearest_high_school, distance_to_high_school 
from volusia.parcel 
where nearest_elem_school IS NOT NULL AND nearest_middle_school IS NOT NULL AND nearest_high_school IS NOT NULL
limit 50;

DO
LANGUAGE plpgsql
$$
DECLARE
g1 geometry;
rec RECORD;
hs VARCHAR(45);
distanceFromHS float;



BEGIN
	for rec in select parid, geom from volusia.parcel 
		where nearest_high_School is NULL AND distance_To_high_School is NULL and geom IS NOT NULL loop
		g1:=rec.geom;
		
		select into hs s.name
			from volusia.gis_schools s 
			where s.address IS NOT NULL AND s.name ILIKE '%high%' AND s.theme = 'PUBLIC'
			order by s.geom <->(g1)
			limit 1;
		
	
		select into distanceFromHS ST_Distance(s.geom, (g1))/5280 as distance
			from volusia.gis_schools s 
			where s.address IS NOT NULL AND s.name ILIKE '%high%' AND s.theme = 'PUBLIC'
			order by s.geom <->(g1)
			limit 1;
		
		update volusia.parcel set nearest_high_School = hs, distance_To_high_School = distanceFromHS where parid=rec.parid ;
		RAISE NOTICE 'set to % % %', rec.parid, hs, distanceFromHS;
	END LOOP;
End;

$$;

