-- Create table for repair tracking states
CREATE TABLE repair_tracking (
    id SERIAL PRIMARY KEY,
    repair_id INT NOT NULL,
    state INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (repair_id) REFERENCES repairs(id) ON DELETE CASCADE
);

-- Example of linking with other tables
-- Assuming 'repairs' table exists with 'id' as primary key
-- Add any additional constraints or indexes as needed
