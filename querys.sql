-- 1
SELECT s.IdSucursal, s.Sucursal, SUM(v.precio * v.Cantidad - g.monto) as Gan
FROM venta v
INNER JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
INNER JOIN gasto g ON (s.IdSucursal = g.IdSucursal)
WHERE YEAR(v.fecha) = 2020
GROUP BY s.IdSucursal
ORDER BY Gan DESC LIMIT 1;

-- 2
SELECT 
    COUNT(Clientes2020_1suc.Idcliente) / Clientes2020.Cantidad AS Promedio
FROM (  # Clientes que compraron en una sola sucursal en 2020.
    SELECT IdCliente, count(IdSucursal) as IdSucursal
    FROM (
        SELECT DISTINCT v.IdCliente, v.IdSucursal
        FROM venta v
        WHERE YEAR(v.Fecha) = 2020
        ) cliente_sucursal_distinto
    GROUP BY IdCliente
    HAVING IdSucursal = 1
    ) Clientes2020_1suc
INNER JOIN ( #Total clientes que compraron en 2020.
    SELECT COUNT(IdCliente) AS Cantidad
    FROM ( #Clientes que compraron en 2020.
        SELECT DISTINCT v.IdCliente
        FROM venta v
        WHERE YEAR(v.Fecha) = 2020
        ) tabla
    ) Clientes2020 ;

-- 3

SELECT COUNT(IdCliente) / Clientes2020.Cantidad As Prom 
FROM (#Clientes que compraron en 2020 pero no en 2019.
    SELECT t2020.IdCliente
    FROM(#Clientes que compraron en 2020.
        SELECT DISTINCT v.IdCliente
        FROM venta v
        WHERE YEAR(v.Fecha) = 2020) t2020
    LEFT JOIN (#Clientes que compraron en 2019.
        SELECT DISTINCT v.IdCliente
        FROM venta v
        WHERE YEAR(v.Fecha) = 2019) t2019 ON (t2020.IdCliente = t2019.IdCliente)
    WHERE t2019.IdCliente IS NULL) t2020Not2019
INNER JOIN (
    SELECT COUNT(IdCliente) AS Cantidad
    FROM (#Clientes que compraron en 2020.
        SELECT DISTINCT v.IdCliente
        FROM venta v
        WHERE YEAR(v.Fecha) = 2020
        ) tabla
    ) Clientes2020;

-- 4
SELECT dif_ventas.Mes, dif_ventas.Ventas - Dif_Gastos.Gastos - Dif_Compras.Compras as Balance
FROM ( #Diferencia de ventas entre 2020 y 2019 por mes.
    SELECT 
		vent2020.Mes as Mes,
        vent2020.Venta - vent2019.Venta as Ventas
    FROM( #Venta de 2020 por mes.
        SELECT 
			MONTH(fecha) as Mes,
            SUM(Precio * Cantidad) as Venta
        FROM venta v
        WHERE YEAR(Fecha) = 2020
        GROUP BY Mes
        ) vent2020
    INNER JOIN( #Venta de 2019 por mes.
        SELECT 
            MONTH(fecha) as Mes, 
            SUM(Precio * Cantidad) as Venta
        FROM venta v
        WHERE YEAR(Fecha) = 2019
        GROUP BY Mes
        ) vent2019 ON (vent2020.Mes = vent2019.Mes)
    ) dif_ventas
INNER JOIN ( #Diferencia de compra entre 2020 y 2019 por mes.
    SELECT 
        comp2020.Mes as Mes,
        comp2020.Compra - comp2019.Compra as Compras
    FROM( #Compra de 2020 por mes.
        SELECT 
            MONTH(fecha) as Mes,
            SUM(Precio * Cantidad) as Compra
        FROM compra c
        WHERE YEAR(Fecha) = 2020
        GROUP BY Mes
        ) comp2020
    INNER JOIN(#Compra de 2019 por mes.
        SELECT 
            MONTH(fecha) as Mes, 
            SUM(Precio * Cantidad) as Compra
        FROM compra c
        WHERE YEAR(Fecha) = 2019
        GROUP BY Mes
        ) comp2019 ON (comp2020.Mes = comp2019.Mes)
    ) dif_compras ON (dif_ventas.Mes = dif_compras.Mes)
INNER JOIN (#Diferencia de gastos de 2020 y 2019 por mes.
        SELECT 
        gast2020.Mes as Mes,
        gast2020.Gasto - gast2019.Gasto as Gastos
    FROM(#Gastos de 2020 por mes.
        SELECT 
            MONTH(fecha) as Mes,
            SUM(Monto) as Gasto
        FROM gasto g
        WHERE YEAR(Fecha) = 2020
        GROUP BY Mes
        ) gast2020
    INNER JOIN(#Gastos de 2019 por mes.
        SELECT 
            MONTH(fecha) as Mes, 
            SUM(Monto) as Gasto
        FROM gasto g
        WHERE YEAR(Fecha) = 2019
        GROUP BY Mes
        ) gast2019 ON (gast2020.Mes = gast2019.Mes)
    ) dif_gastos ON (dif_ventas.Mes = dif_gastos.Mes)
ORDER BY Balance DESC LIMIT 1;

-- 5
SELECT
    tp.TipoProducto,
    SUM(v.Precio*c.Cantidad - c.Precio*c.Cantidad) as Gan
FROM venta v
INNER JOIN compra c ON (v.IdProducto = c.IdProducto)
INNER JOIN producto p ON (c.IdProducto = p.IdProducto)
INNER JOIN tipo_producto tp ON (p.IdTipoProducto = tp.IdTipoProducto)
WHERE YEAR(v.Fecha) = 2020 AND YEAR(c.Fecha) = 2020
GROUP BY TipoProducto
ORDER BY gan DESC LIMIT 1;

-- Creación de tabla y ingesta de CSV
DROP TABLE IF EXISTS comision;
CREATE TABLE IF NOT EXISTS comision (
  	CodigoEmpleado	INTEGER,
  	IdSucursal		INTEGER,
	Apellido_y_Nombre VARCHAR(200),
    Sucursal		VARCHAR(40),
	Anio			INTEGER,
    Mes				INTEGER,
    Porcentaje		INTEGER
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_spanish_ci;
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ComisionesCórdobaCentro.csv'
INTO TABLE comision
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1
LINES (CodigoEmpleado,IdSucursal,Apellido_y_Nombre,Sucursal,Anio,Mes,Porcentaje);
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ComisionesCórdobaCerrodelasRosas.csv'
INTO TABLE comision
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1
LINES (CodigoEmpleado,IdSucursal,Apellido_y_Nombre,Sucursal,Anio,Mes,Porcentaje);
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\ComisionesCórdobaQuiróz.csv'
INTO TABLE comision
FIELDS TERMINATED BY ',' ENCLOSED BY '"' ESCAPED BY '' 
LINES TERMINATED BY '\n' IGNORE 1
LINES (CodigoEmpleado,IdSucursal,Apellido_y_Nombre,Sucursal,Anio,Mes,Porcentaje);

-- ALTER TABLE comision ADD IdSucursal INT NOT NULL DEFAULT '0' AFTER ;
-- 6
SELECT 
	DISTINCT (v.IdEmpleado) AS IdEmpleado,
	sum((v.Precio * v.Cantidad)*(c.Porcentaje/100)) AS Comision
FROM venta v
INNER JOIN empleado e ON (v.IdEmpleado = e.IdEmpleado)
INNER JOIN ( select CodigoEmpleado, Porcentaje from comision where Anio = 2020 and Mes = 12) c ON (e.CodigoEmpleado = c.CodigoEmpleado)
WHERE year(v.Fecha) = '2020' AND month(v.Fecha) = '12' AND v.IdSucursal IN (25, 26, 27)
GROUP BY IdEmpleado
ORDER BY comision DESC LIMIT 1;

-- 7
SELECT s.IdSucursal, s.Sucursal, SUM(v.precio * v.Cantidad - g.monto - (c.Porcentaje/100) * v.precio * v.Cantidad) as Gan
FROM venta v
INNER JOIN sucursal s ON (v.IdSucursal = s.IdSucursal)
INNER JOIN gasto g ON (s.IdSucursal = g.IdSucursal)
INNER JOIN empleado e ON (v.IdEmpleado = e.IdEmpleado)
INNER JOIN ( select CodigoEmpleado, Porcentaje from comision where Anio = 2020) c ON (e.CodigoEmpleado = c.CodigoEmpleado)
WHERE YEAR(v.fecha) = 2020 AND v.IdSucursal IN (25, 26, 27)
GROUP BY v.IdSucursal, v.IdEmpleado
ORDER BY gan DESC LIMIT 1;