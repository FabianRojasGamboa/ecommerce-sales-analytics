import csv
import random
from pathlib import Path
from itertools import accumulate
from datetime import date, timedelta

random.seed(42)

# Carpeta de salida
DATA_DIR = Path(__file__).resolve().parent.parent / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)

def guardar_csv(nombre_archivo, encabezados, filas):
    with open(DATA_DIR / nombre_archivo, "w", newline="", encoding="utf-8") as archivo:
        escritor = csv.writer(archivo)
        escritor.writerow(encabezados)
        escritor.writerows(filas)

def fecha_aleatoria(inicio, fin):
    dias = (fin - inicio).days
    return inicio + timedelta(days=random.randint(0, dias))

# 1. Categorías
categorias = [
    (1, "Electrónica"),
    (2, "Hogar"),
    (3, "Deportes"),
    (4, "Ropa"),
    (5, "Libros"),
    (6, "Belleza"),
    (7, "Juguetes"),
    (8, "Accesorios")
]

guardar_csv("categorias.csv", ["categoria_id", "nombre"], categorias)

# 2. Productos
tipos_productos = {
    1: ["Teclado", "Mouse", "Monitor", "Audífonos", "Webcam"],
    2: ["Lámpara", "Cafetera", "Silla", "Mesa", "Organizador"],
    3: ["Balón", "Mancuerna", "Colchoneta", "Bicicleta", "Botella deportiva"],
    4: ["Polera", "Pantalón", "Chaqueta", "Zapatillas", "Polerón"],
    5: ["Novela", "Manual", "Biografía", "Libro técnico", "Cuentos"],
    6: ["Crema", "Perfume", "Shampoo", "Protector solar", "Jabón"],
    7: ["Rompecabezas", "Muñeco", "Juego de mesa", "Bloques", "Auto de juguete"],
    8: ["Mochila", "Cartera", "Reloj", "Billetera", "Lentes"]
}

productos = []
for producto_id in range(1, 201):
    categoria_id = random.randint(1, 8)
    tipo = random.choice(tipos_productos[categoria_id])
    nombre = f"{tipo} Modelo {producto_id}"
    precio = random.randrange(3000, 150001, 500)

    productos.append((producto_id, nombre, precio, categoria_id))

guardar_csv(
    "productos.csv",
    ["producto_id", "nombre", "precio_actual", "categoria_id"],
    productos
)

# 3. Clientes
nombres = ["Ana", "Pedro", "Camila", "Juan", "Francisca", "Diego",
           "Valentina", "Matías", "Catalina", "Felipe", "Sofía", "Javiera"]

apellidos = ["González", "Muñoz", "Rojas", "Soto", "Pérez", "Silva",
             "Contreras", "Morales", "Ramírez", "Torres", "Flores", "Vargas"]

ciudades = ["Santiago", "Valparaíso", "Concepción", "Temuco",
            "La Serena", "Antofagasta", "Rancagua", "Talca"]

clientes = []
fecha_registro_por_cliente = {}

for cliente_id in range(1, 5001):
    nombre = f"{random.choice(nombres)} {random.choice(apellidos)}"
    ciudad = random.choice(ciudades)
    fecha_registro = fecha_aleatoria(date(2023, 1, 1), date(2025, 6, 30))

    clientes.append((cliente_id, nombre, ciudad, fecha_registro))
    fecha_registro_por_cliente[cliente_id] = fecha_registro

guardar_csv(
    "clientes.csv",
    ["cliente_id", "nombre", "ciudad", "fecha_registro"],
    clientes
)

# 4. Pedidos
# Algunos clientes compran más que otros.
pesos_clientes = list(accumulate(random.uniform(0.2, 3.0) for _ in range(5000)))
clientes_ids = list(range(1, 5001))

pedidos = []

for pedido_id in range(1, 30001):
    cliente_id = random.choices(clientes_ids, cum_weights=pesos_clientes, k=1)[0]

    fecha_pedido = fecha_aleatoria(
        fecha_registro_por_cliente[cliente_id],
        date(2025, 12, 31)
    )

    # Probabilidad de compra algo mayor en noviembre y diciembre
    while fecha_pedido.month not in (11, 12) and random.random() < 0.20:
        fecha_pedido = fecha_aleatoria(
            fecha_registro_por_cliente[cliente_id],
            date(2025, 12, 31)
        )

    estado = random.choices(
        ["completado", "pendiente", "cancelado"],
        weights=[85, 8, 7],
        k=1
    )[0]

    pedidos.append((pedido_id, cliente_id, fecha_pedido, estado))

guardar_csv(
    "pedidos.csv",
    ["pedido_id", "cliente_id", "fecha_pedido", "estado"],
    pedidos
)

# 5. Detalle de pedidos
detalles = []
detalle_id = 1

# Productos populares y menos populares
pesos_productos = [random.uniform(0.2, 5.0) for _ in range(200)]
productos_ids = list(range(1, 201))
precios = {p[0]: p[2] for p in productos}

for pedido_id in range(1, 30001):
    cantidad_productos = random.choices(
        [1, 2, 3, 4, 5],
        weights=[25, 35, 25, 10, 5],
        k=1
    )[0]

    # Muestreo ponderado sin reemplazo: evita productos duplicados por pedido.
    productos_elegidos = sorted(
        productos_ids,
        key=lambda pid: random.expovariate(pesos_productos[pid - 1])
    )[:cantidad_productos]

    for producto_id in productos_elegidos:
        cantidad = random.randint(1, 4)
        precio_base = precios[producto_id]

        # Descuentos ocasionales sobre el precio de catálogo
        descuento = random.choice([0, 0, 0, 0.05, 0.10, 0.15])
        precio_unitario = round(precio_base * (1 - descuento), 2)

        detalles.append((
            detalle_id,
            pedido_id,
            producto_id,
            cantidad,
            precio_unitario
        ))
        detalle_id += 1

guardar_csv(
    "detalle_pedido.csv",
    ["detalle_id", "pedido_id", "producto_id", "cantidad", "precio_unitario"],
    detalles
)

print("Datasets generados correctamente:")
for archivo in DATA_DIR.glob("*.csv"):
    print(f" - {archivo.name}")
