-- Ejecutar en Supabase SQL Editor

-- ============================================
-- Dominios
-- ============================================
create table if not exists public.countries (
  code text primary key, -- ISO2/ISO3
  name text not null
);

create table if not exists public.categories (
  id bigint generated always as identity primary key,
  name text not null unique
);

-- ============================================
-- Comercial
-- ============================================
create table if not exists public.products (
  id bigint generated always as identity primary key,
  name text not null,
  category_id bigint not null references public.categories(id),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  created_at timestamptz default now()
);

create table if not exists public.customers (
  id bigint generated always as identity primary key,
  name text not null,
  email text,
  country_code text not null references public.countries(code),
  created_at timestamptz default now()
);

create table if not exists public.invoices (
  id bigint generated always as identity primary key,
  customer_id bigint not null references public.customers(id),
  invoice_date date not null default current_date,
  total_amount numeric(14,2) not null default 0,
  created_at timestamptz default now()
);

create table if not exists public.invoice_lines (
  id bigint generated always as identity primary key,
  invoice_id bigint not null references public.invoices(id) on delete cascade,
  product_id bigint not null references public.products(id),
  quantity numeric(12,2) not null check (quantity > 0),
  unit_price numeric(12,2) not null check (unit_price >= 0),
  line_total numeric(14,2) not null check (line_total >= 0)
);

-- ============================================
-- Tablas de autorización (para RLS)
-- ============================================
create table if not exists public.user_allowed_country (
  user_id uuid not null references auth.users(id),
  country_code text not null references public.countries(code),
  primary key (user_id, country_code)
);

create table if not exists public.user_allowed_category (
  user_id uuid not null references auth.users(id),
  category_id bigint not null references public.categories(id),
  primary key (user_id, category_id)
);

-- ============================================
-- RLS
-- ============================================
-- Habilitar RLS en tablas donde aplica
-- ============================================
alter table public.products      enable row level security;
alter table public.customers     enable row level security;
alter table public.invoices      enable row level security;
alter table public.invoice_lines enable row level security;

-- ============================================
-- PRODUCTS: RLS por categoría (user_allowed_category)
-- ============================================
create policy "products_by_user_category_select"
on public.products for select
to authenticated
using (
  exists (
    select 1
    from public.user_allowed_category u
    where u.user_id = auth.uid()
      and u.category_id = products.category_id
  )
);

create policy "products_by_user_category_insert"
on public.products for insert
to authenticated
with check (
  exists (
    select 1
    from public.user_allowed_category u
    where u.user_id = auth.uid()
      and u.category_id = products.category_id
  )
);

create policy "products_by_user_category_update"
on public.products for update
to authenticated
using (
  exists (
    select 1
    from public.user_allowed_category u
    where u.user_id = auth.uid()
      and u.category_id = products.category_id
  )
)
with check (
  exists (
    select 1
    from public.user_allowed_category u
    where u.user_id = auth.uid()
      and u.category_id = products.category_id
  )
);

create policy "products_by_user_category_delete"
on public.products for delete
to authenticated
using (
  exists (
    select 1
    from public.user_allowed_category u
    where u.user_id = auth.uid()
      and u.category_id = products.category_id
  )
);

-- ============================================
-- CUSTOMERS: RLS por país (user_allowed_country)
-- ============================================
create policy "customers_by_user_country_select"
on public.customers for select
to authenticated
using (
  exists (
    select 1
    from public.user_allowed_country u
    where u.user_id = auth.uid()
      and u.country_code = customers.country_code
  )
);

create policy "customers_by_user_country_insert"
on public.customers for insert
to authenticated
with check (
  exists (
    select 1
    from public.user_allowed_country u
    where u.user_id = auth.uid()
      and u.country_code = customers.country_code
  )
);

create policy "customers_by_user_country_update"
on public.customers for update
to authenticated
using (
  exists (
    select 1
    from public.user_allowed_country u
    where u.user_id = auth.uid()
      and u.country_code = customers.country_code
  )
)
with check (
  exists (
    select 1
    from public.user_allowed_country u
    where u.user_id = auth.uid()
      and u.country_code = customers.country_code
  )
);

create policy "customers_by_user_country_delete"
on public.customers for delete
to authenticated
using (
  exists (
    select 1
    from public.user_allowed_country u
    where u.user_id = auth.uid()
      and u.country_code = customers.country_code
  )
);

-- ============================================
-- INVOICES: RLS por país del cliente (vía customers)
-- ============================================
create policy "invoices_by_user_country_select"
on public.invoices for select
to authenticated
using (
  exists (
    select 1
    from public.customers c
    join public.user_allowed_country u
      on u.country_code = c.country_code
     and u.user_id = auth.uid()
    where c.id = invoices.customer_id
  )
);

create policy "invoices_by_user_country_insert"
on public.invoices for insert
to authenticated
with check (
  exists (
    select 1
    from public.customers c
    join public.user_allowed_country u
      on u.country_code = c.country_code
     and u.user_id = auth.uid()
    where c.id = invoices.customer_id
  )
);

create policy "invoices_by_user_country_update"
on public.invoices for update
to authenticated
using (
  exists (
    select 1
    from public.customers c
    join public.user_allowed_country u
      on u.country_code = c.country_code
     and u.user_id = auth.uid()
    where c.id = invoices.customer_id
  )
)
with check (
  exists (
    select 1
    from public.customers c
    join public.user_allowed_country u
      on u.country_code = c.country_code
     and u.user_id = auth.uid()
    where c.id = invoices.customer_id
  )
);

create policy "invoices_by_user_country_delete"
on public.invoices for delete
to authenticated
using (
  exists (
    select 1
    from public.customers c
    join public.user_allowed_country u
      on u.country_code = c.country_code
     and u.user_id = auth.uid()
    where c.id = invoices.customer_id
  )
);

-- ============================================
-- INVOICE_LINES: RLS por país (del cliente de la factura)
-- y por categoría (del producto de la línea)
-- ============================================
create policy "lines_by_country_and_category_select"
on public.invoice_lines for select
to authenticated
using (
  exists (
    select 1
    from public.invoices i
    join public.customers c on c.id = i.customer_id
    join public.user_allowed_country uc
      on uc.country_code = c.country_code
     and uc.user_id = auth.uid()
    where i.id = invoice_lines.invoice_id
  )
  and
  exists (
    select 1
    from public.products p
    join public.user_allowed_category ug
      on ug.category_id = p.category_id
     and ug.user_id = auth.uid()
    where p.id = invoice_lines.product_id
  )
);

create policy "lines_by_country_and_category_cud"
on public.invoice_lines for all
to authenticated
using (
  exists (
    select 1
    from public.invoices i
    join public.customers c on c.id = i.customer_id
    join public.user_allowed_country uc
      on uc.country_code = c.country_code
     and uc.user_id = auth.uid()
    where i.id = invoice_lines.invoice_id
  )
  and
  exists (
    select 1
    from public.products p
    join public.user_allowed_category ug
      on ug.category_id = p.category_id
     and ug.user_id = auth.uid()
    where p.id = invoice_lines.product_id
  )
)
with check (
  exists (
    select 1
    from public.invoices i
    join public.customers c on c.id = i.customer_id
    join public.user_allowed_country uc
      on uc.country_code = c.country_code
     and uc.user_id = auth.uid()
    where i.id = invoice_lines.invoice_id
  )
  and
  exists (
    select 1
    from public.products p
    join public.user_allowed_category ug
      on ug.category_id = p.category_id
     and ug.user_id = auth.uid()
    where p.id = invoice_lines.product_id
  )
);

-- ============================================
-- Funciones
-- ============================================

-- ============================================
-- RPC transaccional: public.create_invoice(customer_id, items)
-- • Inserta la factura y todas sus líneas en UNA sola transacción
-- • security invoker: respeta RLS del usuario llamante
-- • unit_price opcional: si no viene, se toma de products.unit_price
-- • line_total = round(quantity * unit_price, 2)
-- • total_amount = suma de line_total
-- • retorna JSON: { invoice: {...}, lines: [...] }
-- ============================================

create or replace function public.create_invoice(
  customer_id bigint,
  items jsonb
)
returns jsonb
language plpgsql
security invoker
as $$
declare
  v_invoice_id bigint;
  v_len        int;
  v_pid        bigint;
  v_qty        numeric(12,2);
  v_price      numeric(12,2);
begin
  -- Validaciones básicas de entrada
  if items is null or jsonb_typeof(items) <> 'array' then
    raise exception 'items debe ser un arreglo JSON';
  end if;

  v_len := jsonb_array_length(items);
  if v_len = 0 then
    raise exception 'items no puede estar vacío';
  end if;

  -- Verificar que el cliente exista y sea visible (se aplica RLS por invoker)
  perform 1 from public.customers c where c.id = customer_id;
  if not found then
    raise exception 'Cliente % no existe o no es visible por RLS', customer_id;
  end if;

  -- Crear factura
  insert into public.invoices(customer_id)
  values (customer_id)
  returning id into v_invoice_id;

  -- Insertar cada línea
  for v_pid, v_qty, v_price in
    select
      (e->>'product_id')::bigint,
      (e->>'quantity')::numeric,
      nullif(e->>'unit_price','')::numeric
    from jsonb_array_elements(items) e
  loop
    if v_pid is null then
      raise exception 'Falta product_id en un item';
    end if;
    if v_qty is null or v_qty <= 0 then
      raise exception 'quantity inválida para product_id=%', v_pid;
    end if;

    -- Si no viene unit_price, se toma del producto (RLS por categoría)
    if v_price is null then
      select p.unit_price::numeric(12,2)
      into v_price
      from public.products p
      where p.id = v_pid;

      if v_price is null then
        raise exception 'Producto % no existe o no es visible por RLS', v_pid;
      end if;
    end if;

    insert into public.invoice_lines (
      invoice_id, product_id, quantity, unit_price, line_total
    )
    values (
      v_invoice_id,
      v_pid,
      v_qty::numeric(12,2),
      v_price::numeric(12,2),
      round(v_qty * v_price, 2)::numeric(14,2)
    );
    -- Si RLS falla (país/categoría), esta inserción levanta error y hace rollback.
  end loop;

  -- Totalizar factura
  update public.invoices i
  set total_amount = (
    select coalesce(sum(line_total), 0)::numeric(14,2)
    from public.invoice_lines
    where invoice_id = v_invoice_id
  )
  where i.id = v_invoice_id;

  -- Devolver JSON: factura + líneas
  return (
    select jsonb_build_object(
      'invoice', to_jsonb(i),
      'lines', coalesce(
        (
          select jsonb_agg(to_jsonb(l) order by l.id)
          from public.invoice_lines l
          where l.invoice_id = i.id
        ),
        '[]'::jsonb
      )
    )
    from public.invoices i
    where i.id = v_invoice_id
  );
exception
  when others then
    -- Repropaga para asegurar rollback
    raise;
end;
$$;

grant execute on function public.create_invoice(bigint, jsonb) to authenticated;

-- ============================================
-- Vistas
-- ============================================

-- ============================================
-- v_sales_fact: grano por línea, con joins a cliente/país y producto/categoría
-- ============================================
create or replace view public.v_sales_fact as
select
  l.id                           as line_id,
  i.id                           as invoice_id,
  i.invoice_date,
  i.created_at                   as invoice_created_at,
  i.customer_id,
  c.name                         as customer_name,
  c.country_code,
  co.name                        as country_name,
  l.product_id,
  p.name                         as product_name,
  p.category_id,
  cat.name                       as category_name,
  l.quantity,
  l.unit_price,
  l.line_total
from public.invoice_lines l
join public.invoices  i   on i.id = l.invoice_id
join public.customers c   on c.id = i.customer_id
left join public.countries   co  on co.code = c.country_code
join public.products  p   on p.id = l.product_id
left join public.categories  cat on cat.id = p.category_id;

-- ============================================
-- v_sales_by_category: agregación por categoría
-- ============================================
create or replace view public.v_sales_by_category as
select
  f.category_id,
  f.category_name,
  sum(f.quantity)   as total_quantity,
  sum(f.line_total) as total_amount
from public.v_sales_fact f
group by f.category_id, f.category_name
order by total_amount desc, total_quantity desc;

-- ============================================
-- v_sales_by_country: agregación por país
-- ============================================
create or replace view public.v_sales_by_country as
select
  f.country_code,
  f.country_name,
  sum(f.quantity)   as total_quantity,
  sum(f.line_total) as total_amount
from public.v_sales_fact f
group by f.country_code, f.country_name
order by total_amount desc, total_quantity desc;

-- ============================================
-- v_top_products_30d: top 10 productos últimos 30 días
-- ============================================
create or replace view public.v_top_products_30d as
select
  f.product_id,
  f.product_name,
  sum(f.quantity)   as total_quantity,
  sum(f.line_total) as total_amount
from public.v_sales_fact f
where f.invoice_date >= current_date - interval '30 days'
group by f.product_id, f.product_name
order by total_amount desc, total_quantity desc
limit 10;

grant select on public.v_sales_fact,
               public.v_sales_by_category,
               public.v_sales_by_country,
               public.v_top_products_30d
to authenticated;

-- ============================================
-- Inserciones
-- ============================================

-- ============================================
-- countries: códigos y nombres de países
-- ============================================
INSERT INTO "public"."countries" ("code", "name") 
VALUES
  ('AR', 'Argentina'),
  ('BR', 'Brazil'),
  ('CA', 'Canada'),
  ('CL', 'Chile'),
  ('CO', 'Colombia'),
  ('CR', 'Costa Rica'),
  ('CU', 'Cuba'),
  ('EC', 'Ecuador'),
  ('GT', 'Guatemala'),
  ('MX', 'Mexico'),
  ('PA', 'Panama'),
  ('PE', 'Peru'),
  ('US', 'United States'),
  ('UY', 'Uruguay'),
  ('VE', 'Venezuela');

-- ============================================
-- categories: categorías de productos
-- ============================================
INSERT INTO "public"."categories" ("name") 
VALUES
  ('Electronics'),
  ('Furniture'),
  ('Clothing'),
  ('Footwear'),
  ('Books'),
  ('Toys'),
  ('Groceries'),
  ('Appliances'),
  ('Beauty'),
  ('Sports Equipment'),
  ('Automotive'),
  ('Jewelry'),
  ('Office Supplies'),
  ('Pet Supplies');

-- ============================================
-- products: productos que ofrece la plataforma
-- ============================================
INSERT INTO "public"."products" ("name", "category_id", "unit_price") 
VALUES
  ('Smartphone', '1', '699.99'),
  ('Bluetooth Headphones', '1', '129.50'),
  ('Wooden Coffee Table', '2', '245.00'),
  ('Office Chair Ergonomic', '2', '180.00'),
  ('Men''s Polo Shirt', '3', '25.99'),
  ('Women''s Sneakers', '4', '59.90'),
  ('Remote Control Drone', '8', '89.99'),
  ('Organic Quinoa 1kg', '7', '4.75'),
  ('Refrigerator 300L', '8', '520.00'),
  ('Facial Cleanser Gel', '9', '12.50'),
  ('Tennis Racket', '10', '45.00'),
  ('Adjustable Dumbbells Set', '10', '65.00'),
  ('Car Engine Oil 4L', '11', '32.00'),
  ('Silver Bracelet', '12', '75.00'),
  ('Ballpoint Pen Pack (10)', '13', '3.99'),
  ('Cat Litter 10kg', '14', '11.25'),
  ('Gaming Laptop', '1', '1299.00'),
  ('Women''s Blouse', '3', '29.50'),
  ('Denim Jacket', '3', '49.99'),
  ('Lipstick', '9', '12.00'),
  ('Toner', '9', '15.00'),
  ('Silver Bracelet', '12', '75.00'),
  ('Pearl Necklace', '12', '150.00');
-- ============================================
-- customers: clientes de la plataforma
-- ============================================
INSERT INTO "public"."customers" ("name", "email", "country_code") 
VALUES
  ('Amanada Rivas','arivas@example.com','CR'),
  ('James Carter','jcarter@example.com','US'),
  ('Lucía Martínez','lmartinez@example.com','MX'),
  ('Sophie Tremblay','stremblay@example.com','CA'),
  ('Bruno Silva','bsilva@example.com','BR'),
  ('Valentina Gómez','vgomez@example.com','AR'),
  ('Camilo Torres','ctorres@example.com','CO'),
  ('Isidora Fuentes','ifuentes@example.com','CL'),
  ('Mateo Vargas','mvargas@example.com','PE'),
  ('Gabriela Ruiz','gruiz@example.com','VE'),
  ('Daniela Mora','dmora@example.com','EC'),
  ('José Ramírez','jramirez@example.com','GT'),
  ('Elena Castillo','ecastillo@example.com','CU'),
  ('Tomás Delgado','tdelgado@example.com','PA'),
  ('Martín Pereira','mpereira@example.com','UY'),
  ('Amanada Rivas','arivas@example.com','CR'),
  ('Daniela Mora','dmora@example.com','CR'),
  ('James Carter','jcarter@example.com','US'),
  ('Sophie Miller','smiller@example.com','US'),
  ('Lucía Martínez','lmartinez@example.com','MX'),
  ('José Ramírez','jramirez@example.com','MX');

-- ============================================
-- user_allowed_category: permisos de categoría
-- por usuario
-- ============================================
INSERT INTO "public"."user_allowed_category" ("user_id", "category_id") 
VALUES 
  ('66c5d855-3259-492a-b1fd-d6d5b69b5a02', '6'), 
  ('8493c1c8-ac41-4a10-8528-1b116a2f5587', '1'), 
  ('8493c1c8-ac41-4a10-8528-1b116a2f5587', '12'), 
  ('8e47f7aa-7aad-47e6-8959-d12a0451d26a', '3'), 
  ('8e47f7aa-7aad-47e6-8959-d12a0451d26a', '9');

-- ============================================
-- user_allowed_country: permisos de países por
-- usuario
-- ============================================
INSERT INTO "public"."user_allowed_country" ("user_id", "country_code") 
VALUES 
  ('66c5d855-3259-492a-b1fd-d6d5b69b5a02', 'UY'), 
  ('8493c1c8-ac41-4a10-8528-1b116a2f5587', 'CR'), 
  ('8493c1c8-ac41-4a10-8528-1b116a2f5587', 'US'), 
  ('8e47f7aa-7aad-47e6-8959-d12a0451d26a', 'MX'), 
  ('8e47f7aa-7aad-47e6-8959-d12a0451d26a', 'PA');