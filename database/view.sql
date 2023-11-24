CREATE VIEW v_hotel_overview AS
SELECT
    u.nazev AS HotelName,
    u.pocet_hvezd AS HotelStars,
    a.ulice || ', ' || a.mesto AS HotelAddress,
    z.cena_osoba AS PricePerPerson,
    s.nazev AS MealOption,
    o.obrazek_url AS HotelImage
FROM UBYTOVANI u
JOIN ADRESA a ON u.adresa_id = a.adresa_id
JOIN ZAJEZD z ON u.ubytovani_id = z.ubytovani_id
JOIN OBRAZKY_UBYTOVANI o ON u.ubytovani_id = o.ubytovani_id
JOIN STRAVA s ON z.strava_id = s.strava_id
WHERE z.zobrazit = 1;