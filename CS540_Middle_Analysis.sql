Update volusia.parcel
set nearest_elem_school = null, distance_To_Elem_School = null;

select geom, parid from volusia.parcel limit 50;

DO
LANGUAGE plpgsql
$$
DECLARE
g1 geometry;
rec RECORD;
es VARCHAR(45);
distanceFromES float;



BEGIN
	for rec in select parid, geom from volusia.parcel 
		where nearest_Elem_School is NULL AND distance_To_Elem_School is NULL and geom IS NOT NULL loop
		g1:=rec.geom;
		
		select into es s.name
			from volusia.gis_schools s 
			where s.address IS NOT NULL AND s.name ILIKE '%elem%' AND s.theme = 'PUBLIC'
			order by s.geom <->(g1)
			limit 1;
		
	
		select into distanceFromES ST_Distance(s.geom, (g1))/5280 as distance
			from volusia.gis_schools s 
			where s.address IS NOT NULL AND s.name ILIKE '%elem%' AND s.theme = 'PUBLIC'
			order by s.geom <->(g1)
			limit 1;
		
		update volusia.parcel set nearest_Elem_School = es, distance_To_Elem_School = distanceFromES where parid=rec.parid ;
		RAISE NOTICE 'set to % % %', rec.parid, es, distanceFromES;
	END LOOP;
End;

$$;

select nearest_Elem_School from volusia.parcel group by nearest_elem_school;
