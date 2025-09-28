# Pruebas con Postman

## Clientes por país

```bash
curl -L -g 'https://pntefwrxizxlwxadtepo.supabase.co/rest/v1/customers?select=*&country_code=eq.[country_code]' \
-H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI'
```

## Productos por categoria

```bash
curl -L -g 'https://pntefwrxizxlwxadtepo.supabase.co/rest/v1/products?select=*&category_id=eq.[category_code]' \
-H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI'
```

## Facturas con cliente embebido

```bash
curl -L 'https://pntefwrxizxlwxadtepo.supabase.co/rest/v1/invoices?select=*%2Ccustomers(*)' \
-H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI'
```

## Detalle con producto embebido
```bash
curl -L 'https://pntefwrxizxlwxadtepo.supabase.co/rest/v1/invoice_lines?select=*%2Cproducts(*)' \
-H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI'
```

## Creación de invoices
```bash
curl -L 'https://pntefwrxizxlwxadtepo.supabase.co/rest/v1/invoices' \
-H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Content-Type: application/json' \
-d '[{ "customer_id": 3,"invoice_date":"2025-09-28","total_amount":1 }, {  "customer_id": 4,"invoice_date":"2025-09-28","total_amount":3 }]'
```

## Creación de invoice_lines
``` bash
curl -L 'https://pntefwrxizxlwxadtepo.supabase.co/rest/v1/invoice_lines' \
-H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Content-Type: text/plain' \
-d '[{ "invoice_id": 1,"product_id":1,"quantity":1,"unit_price":100,"line_total":1 }, { "invoice_id": 2,"product_id":2,"quantity":2,"unit_price":100,"line_total":1 },{"invoice_id": 3,"product_id":3,"quantity":3,"unit_price":100,"line_total":3 }]'
 ```
## Login
```bash
curl -L 'https://pntefwrxizxlwxadtepo.supabase.co/auth/v1/token?grant_type=password' \
-H 'apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
-H 'Content-Type: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTAyNDYwOCwiZXhwIjoyMDc0NjAwNjA4fQ.ZjGtERZvvysa-4CAHZmOts5dQm_sNf5mm3aFMdAHnGI' \
--data-raw '{
  "email": "cliente2@example.com",
  "password": "cliente2"
}'
```
