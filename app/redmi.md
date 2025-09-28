App Cliente de Backend de Ventas Supabase (Python)
Este es el cliente de consola en Python para interactuar con el backend de ventas desarrollado en Supabase, centrado en validar la Autenticación y las Políticas de Seguridad a Nivel de Fila (RLS).

El script realiza la autenticación, lista los datos permitidos por RLS (clientes por país, productos por categoría) e intenta crear una factura con sus líneas, verificando la doble restricción de RLS.

Requisitos Previos para usar la aplicacion


Python 3.10+

Conocer uno de los usuarios creados en Supabase Auth con permisos asignados en las tablas user_allowed_country y user_allowed_category.

# 1. Instalación de Dependencias
se deben instalar supabase y dotenv, puede usar el siguiente comando en el directorio raíz de la aplicación para instalar dichas librerías:

        pip install supabase python-dotenv

# 2. Configuración de Variables de Entorno (.env)
Debes crear un archivo llamado .env en el mismo directorio que main.py para almacenar de forma segura las credenciales del proyecto y del usuario de prueba.

-----------------------------------------------------
Credenciales del proyecto de Supabase

    SUPABASE_URL="https://pntefwrxizxlwxadtepo.supabase.co"
    SUPABASE_ANON_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBudGVmd3J4aXp4bHd4YWR0ZXBvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTkwMjQ2MDgsImV4cCI6MjA3NDYwMDYwOH0.GmH8LMZSlP9gfHWyq3fxDFSyWT_yWVGFydDgPj6XbMA"
-----------------------------------------------------
Credenciales del Usuario de Prueba RLS


    USER_EMAIL="usuario@dominio.com"

    USER_PASSWORD="password"

# 3. Ejecución de la Aplicación
Ejecuta el script principal desde su terminal:

python app/main.py

Se mostrará un menú

    === MENÚ PRINCIPAL ===
    1. Listar productos
    2. Listar clientes
    3. Crear factura manualmente
    4. Filtrar productos por categoría
    5. Filtrar clientes por país
    6. Reporte: ventas por país (vista)
    7. Crear factura con RPC (cuando esté lista)
    0. Salir


 Ejemplo de uso (flujo manual)

    Listar clientes y anotar un ID de cliente.
    Crear factura para ese cliente.
    Listar productos, seleccionar uno y anotar el ID de producto.
    Agregar línea indicando cantidad y precio.
    Repetir hasta terminar y mostrar la factura

# 4. Funcionalidades

    1. Autenticación: login con Supabase Auth (email y password).

    2. Listados:
        2.1 Productos (con RLS por categoría).
        2.2 Clientes (con RLS por país).

    3. Facturación manual:
        3.1 Crear factura seleccionando cliente. 
        3.2 Agregar productos y cantidades como líneas.
        3.3 Mostrar la factura completa con sus líneas.
    4. Filtros:
        4.1 Productos por categoría.
        4.1 Clientes por país. 
    5. Reportes:
        5.1 Ventas por país (vista SQL v_sales_by_country).
        5.2 RPC (pendiente en SQL):
        5.3 Crear factura + líneas en una sola transacción (create_invoice).