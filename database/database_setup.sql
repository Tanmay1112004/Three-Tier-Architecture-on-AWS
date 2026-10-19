CREATE DATABASE IF NOT EXISTS hello_world
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE hello_world;

CREATE TABLE IF NOT EXISTS service_requests (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    title VARCHAR(120) NOT NULL,
    category VARCHAR(40) NOT NULL,
    description VARCHAR(1000) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'Open',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    INDEX idx_service_requests_created_at (created_at)
);

-- Keep first-run sample data from being duplicated as backend instances start.
SELECT GET_LOCK('campus_helpdesk_seed', 120);
INSERT INTO service_requests (title, category, description)
SELECT seed.title, seed.category, seed.description
FROM (
    SELECT 'Wi-Fi in the library' AS title, 'Technology' AS category,
           'The student Wi-Fi connection drops near the study area.' AS description
    UNION ALL
    SELECT 'Study room projector', 'Facilities',
           'The projector in room 204 does not turn on.'
    UNION ALL
    SELECT 'Course registration help', 'Student Services',
           'I need help finding the registration dates for next term.'
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM service_requests LIMIT 1);
SELECT RELEASE_LOCK('campus_helpdesk_seed');
