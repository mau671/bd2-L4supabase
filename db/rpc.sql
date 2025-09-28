-- NOTA MAURICIO: Hay que mover el contenido de este archivo a db/schema.sql una vez este completo

-- =========================================================
-- RPC transaccional: public.create_invoice(customer_id, items)
-- • Inserta la factura y todas sus líneas en UNA sola transacción
-- • security invoker: respeta RLS del usuario llamante
-- • unit_price opcional: si no viene, se toma de products.unit_price
-- • line_total = round(quantity * unit_price, 2)
-- • total_amount = suma de line_total
-- • retorna JSON: { invoice: {...}, lines: [...] }
-- =========================================================

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