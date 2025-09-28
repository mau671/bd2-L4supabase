import os

from supabase import create_client, Client
from dotenv import load_dotenv
import platform

# environment variables
load_dotenv()
URL = os.getenv("SUPABASE_URL")
KEY = os.getenv("SUPABASE_ANON_KEY")
EMAIL = os.getenv("USER_EMAIL")
PWD = os.getenv("USER_PASSWORD")

if not all([URL, KEY, EMAIL, PWD]):
    print("Error: Asegúrese de que todas las variables (URL, KEY, EMAIL, PWD) estén definidas en el archivo .env.")
    raise SystemExit(1)

def login() -> Client:
    sb: Client = create_client(URL, KEY)
    auth = sb.auth.sign_in_with_password({"email": EMAIL, "password": PWD})
    if not auth.session:
        raise SystemExit("Login failed")
    print("Logged in :", auth.user.email)
    return sb


def list_my_products(sb: Client):
    res = sb.table("products").select("*").execute()
    print("Products (RLS applied):")
    for a in res.data:
        print(a)


def list_my_customers(sb: Client):
    res = sb.table("customers").select("*").execute()
    print("Customers (RLS applied):")
    for a in res.data:
        print(a)


def create_invoice(sb: Client, customer_id: int):
    inv = sb.table("invoices").insert({"customer_id":customer_id}).execute()
    print("Invoice:", inv.data)
    return inv.data[0]["id"]


def add_line(sb: Client, invoice_id: int, product_id: int, qty: float, unit_price: float):
    line_total = round(qty * unit_price, 2)
    line = {
        "invoice_id": invoice_id,
        "product_id": product_id,
        "line_total": line_total,
        "quantity": qty,
        "unit_price": unit_price,
    }
    res = sb.table("invoice_line").insert(line).select("*").execute()
    print("Line:")
    for a in res.data:
        print(a)


def show_invoice_with_lines(sb: Client, invoice_id: int):
    inv = sb.table("invoices").select("*").eq("id",invoice_id).execute()
    lines = sb.table("invoice_lines").select("*").eq("invoice_id",invoice_id).execute()
    print("Invoice:", inv.data)
    for a in inv:
        print(a)
    print("Lines:")
    for b in lines:
        print(b)


# las nuevas
def list_products_by_category(sb: Client, cat_id: int):
    res = sb.table("products").select("*").eq("category_id", cat_id).execute()
    print(f"\n Productos de la categoría {cat_id}:")
    for p in res.data:
        print(p)


def list_customers_by_country(sb: Client, code: str):
    res = sb.table("customers").select("*").eq("country_code", code).execute()
    print(f"\n Clientes del país {code}:")
    for c in res.data:
        print(c)


def sales_by_country(sb: Client, code: str):
    res = sb.table("v_sales_by_country").select("*").eq("country_code", code).execute()
    print(f"\n💰 Ventas por país {code}:")
    for r in res.data:
        print(r)


def create_invoice_rpc(sb: Client, customer_id: int, items: list):
    """Llamada al RPC de SQL"""
    payload = {"customer_id": customer_id, "items": items}
    res = sb.rpc("create_invoice", payload).execute()
    print("\n Factura creada con RPC:")
    print(res.data)


def clear_console():
    """Limpia la consola basándose en el sistema operativo."""

    # Detecta el sistema operativo
    input("\nPulse ENTER para continuar...\n")
    system = platform.system()

    if system == "Windows":
        # Comando para Windows
        os.system('cls')
    else:
        # Comando para Linux/macOS (Unix)
        os.system('clear')

if __name__ == "__main__":
    sb = login()
    while True:
        print("\n=== MENÚ PRINCIPAL ===")
        print("1. Listar productos")
        print("2. Listar clientes")
        print("3. Crear factura manualmente")
        print("4. Filtrar productos por categoría")
        print("5. Filtrar clientes por país")
        print("6. Reprte: ventas por país (vista)")
        print("7. Crear factura con RPC")
        print("0. Salir")
        op = input("Opción: ")

        if op == "1":
            list_my_products(sb)
            clear_console()
        elif op == "2":
            list_my_customers(sb)
            clear_console()

        elif op == "3":
            list_my_customers(sb)
            cust_id = int(input("Ingrese ID del cliente: "))
            inv_id = create_invoice(sb, cust_id)
            while True:
                list_my_products(sb)
                prod_id = int(input("Ingrese ID del producto (0 para terminar): "))
                if prod_id == 0:
                    break
                qty = float(input("Cantidad: "))
                price = float(input("Precio unitario: "))
                add_line(sb, inv_id, prod_id, qty, price)

            show_invoice_with_lines(sb, inv_id)
            clear_console()
        elif op == "4":
            cat_id = int(input("ID categoría: "))
            list_products_by_category(sb, cat_id)
            clear_console()
        elif op == "5":
            code = input("Código país (ej: CR, US): ").upper()
            list_customers_by_country(sb, code)
            clear_console()
        elif op == "6":
            code = input("Código país (ej: CR, US): ").upper()
            sales_by_country(sb, code)
            clear_console()
        elif op == "7":
            cust_id = int(input("ID cliente: "))
            items = []
            while True:
                prod_id = int(input("Producto (0 para terminar): "))
                if prod_id == 0:
                    break
                qty = float(input("Cantidad: "))
                items.append({"product_id": prod_id, "quantity": qty})
            create_invoice_rpc(sb, cust_id, items)
            clear_console()
        elif op == "0":
            print("Saliendo...")
            clear_console()
            break
        else:
            print(" Opción inválida")
            clear_console()