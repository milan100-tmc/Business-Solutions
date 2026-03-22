-- Bronze: raw data as-is
SELECT * FROM {{ source('raw', 'raw_orders') }}