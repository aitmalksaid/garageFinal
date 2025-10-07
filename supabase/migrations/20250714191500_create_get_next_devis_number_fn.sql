CREATE OR REPLACE FUNCTION get_next_devis_number()
RETURNS TEXT AS $$
DECLARE
    next_number INTEGER;
    year_suffix TEXT;
    formatted_number TEXT;
BEGIN
    year_suffix := to_char(CURRENT_DATE, 'YY');

    SELECT COUNT(*) + 1 INTO next_number
    FROM devis
    WHERE numero_devis LIKE year_suffix || 'AF%';

    formatted_number := LPAD(next_number::TEXT, 5, '0');

    RETURN year_suffix || 'AF' || formatted_number;
END;
$$ LANGUAGE plpgsql;
