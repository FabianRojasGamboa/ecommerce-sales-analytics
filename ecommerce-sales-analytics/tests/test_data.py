"""Validación de los CSV generados; ejecutar después del generador."""
import csv
import unittest
from pathlib import Path
from collections import Counter
from decimal import Decimal

DATA = Path(__file__).resolve().parents[1] / 'data'


def read(name):
    with (DATA / f'{name}.csv').open(encoding='utf-8', newline='') as f:
        return list(csv.DictReader(f))


class DatasetTests(unittest.TestCase):
    def test_integrity(self):
        sizes = {'categorias': 8, 'productos': 200, 'clientes': 5000, 'pedidos': 30000}
        keys = {'categorias': 'categoria_id', 'productos': 'producto_id',
                'clientes': 'cliente_id', 'pedidos': 'pedido_id', 'detalle_pedido': 'detalle_id'}
        tables = {name: read(name) for name in keys}
        for name, rows in tables.items():
            self.assertTrue(rows)
            self.assertEqual(len(rows), len({r[keys[name]] for r in rows}))
            if name in sizes:
                self.assertEqual(len(rows), sizes[name])
        categories = {r['categoria_id'] for r in tables['categorias']}
        products = {r['producto_id'] for r in tables['productos']}
        clients = {r['cliente_id']: r['fecha_registro'] for r in tables['clientes']}
        orders = {r['pedido_id'] for r in tables['pedidos']}
        for r in tables['productos']:
            self.assertIn(r['categoria_id'], categories)
            self.assertGreaterEqual(Decimal(r['precio_actual']), 0)
        for r in tables['pedidos']:
            self.assertIn(r['cliente_id'], clients)
            self.assertGreaterEqual(r['fecha_pedido'], clients[r['cliente_id']])
            self.assertIn(r['estado'], {'completado', 'pendiente', 'cancelado'})
        pairs = set()
        counts = Counter()
        for r in tables['detalle_pedido']:
            self.assertIn(r['pedido_id'], orders)
            self.assertIn(r['producto_id'], products)
            self.assertGreater(int(r['cantidad']), 0)
            self.assertGreaterEqual(Decimal(r['precio_unitario']), 0)
            pair = (r['pedido_id'], r['producto_id'])
            self.assertNotIn(pair, pairs)
            pairs.add(pair)
            counts[r['pedido_id']] += 1
        self.assertEqual(set(counts), orders)
        self.assertTrue(all(1 <= n <= 5 for n in counts.values()))


if __name__ == '__main__':
    unittest.main()
