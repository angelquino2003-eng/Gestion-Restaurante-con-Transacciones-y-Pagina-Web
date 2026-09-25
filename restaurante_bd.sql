-- MySQL dump 10.13  Distrib 8.0.44, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: restaurante_ventas
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `asignacionmesa`
--

DROP TABLE IF EXISTS `asignacionmesa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `asignacionmesa` (
  `id_asignacion` int NOT NULL AUTO_INCREMENT,
  `id_mesa` int NOT NULL,
  `id_venta` int NOT NULL,
  `id_empleado` int NOT NULL,
  `fecha_inicio` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_fin` datetime DEFAULT NULL,
  PRIMARY KEY (`id_asignacion`),
  UNIQUE KEY `id_venta` (`id_venta`),
  KEY `fk_asigmesa_mesa` (`id_mesa`),
  KEY `fk_asigmesa_empleado` (`id_empleado`),
  CONSTRAINT `fk_asigmesa_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `fk_asigmesa_mesa` FOREIGN KEY (`id_mesa`) REFERENCES `mesa` (`id_mesa`),
  CONSTRAINT `fk_asigmesa_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `asignacionmesa`
--

LOCK TABLES `asignacionmesa` WRITE;
/*!40000 ALTER TABLE `asignacionmesa` DISABLE KEYS */;
INSERT INTO `asignacionmesa` VALUES (1,1,1,2,'2026-09-22 12:50:27','2026-09-22 12:50:27'),(2,2,3,2,'2026-09-24 23:19:13','2026-09-25 00:14:13'),(3,105,108,100,'2026-09-24 23:57:14',NULL),(4,107,109,101,'2026-09-25 00:17:14',NULL);
/*!40000 ALTER TABLE `asignacionmesa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bitacora`
--

DROP TABLE IF EXISTS `bitacora`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bitacora` (
  `id_bitacora` int NOT NULL AUTO_INCREMENT,
  `id_empleado` int NOT NULL,
  `tipo_accion` enum('venta','cancelacion','apertura_caja','cierre_caja','cambio_precio','pedido_listo','entrega','pago_confirmado','pago_rechazado','emision_comprobante','otro') NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_bitacora`),
  KEY `fk_bitacora_empleado` (`id_empleado`),
  CONSTRAINT `fk_bitacora_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bitacora`
--

LOCK TABLES `bitacora` WRITE;
/*!40000 ALTER TABLE `bitacora` DISABLE KEYS */;
INSERT INTO `bitacora` VALUES (1,1,'apertura_caja','Apertura de caja con S/ 50.00','2026-09-22 12:50:27'),(2,2,'venta','Orden presencial #1 tomada en mesa 1','2026-09-22 12:50:27'),(3,3,'pedido_listo','Venta #1 lista para entregar en mesa 1','2026-09-22 12:50:27'),(4,2,'entrega','Venta #1 entregada en mesa 1','2026-09-22 12:50:27'),(5,1,'pago_confirmado','Pago en efectivo de la venta #1','2026-09-22 12:50:27'),(6,1,'emision_comprobante','Comprobante B001-1 de la venta #1','2026-09-22 12:50:27'),(7,1,'pago_confirmado','Pago Yape de la venta #2 (operación 48213765)','2026-09-22 12:50:27'),(8,1,'emision_comprobante','Comprobante B001-2 de la venta #2','2026-09-22 12:50:27'),(9,3,'pedido_listo','Venta delivery #2 lista para el repartidor','2026-09-22 12:50:27'),(10,1,'entrega','Venta delivery #2 entregada por el repartidor Adrian Angel','2026-09-22 12:50:27'),(11,1,'cierre_caja','Cierre de caja #1','2026-09-22 12:50:27');
/*!40000 ALTER TABLE `bitacora` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `caja`
--

DROP TABLE IF EXISTS `caja`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `caja` (
  `id_caja` int NOT NULL AUTO_INCREMENT,
  `id_empleado` int NOT NULL,
  `fecha_apertura` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_cierre` datetime DEFAULT NULL,
  `monto_inicial` decimal(8,2) NOT NULL,
  `monto_final` decimal(8,2) DEFAULT NULL,
  `estado` enum('abierta','cerrada') NOT NULL DEFAULT 'abierta',
  PRIMARY KEY (`id_caja`),
  KEY `fk_caja_empleado` (`id_empleado`),
  CONSTRAINT `fk_caja_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `chk_caja_estado` CHECK ((((`estado` = _utf8mb4'abierta') and (`fecha_cierre` is null)) or ((`estado` = _utf8mb4'cerrada') and (`fecha_cierre` is not null) and (`monto_final` is not null))))
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `caja`
--

LOCK TABLES `caja` WRITE;
/*!40000 ALTER TABLE `caja` DISABLE KEYS */;
INSERT INTO `caja` VALUES (1,1,'2026-09-22 12:50:27','2026-09-22 12:50:27',50.00,75.00,'cerrada'),(100,103,'2026-09-25 00:22:14',NULL,200.00,NULL,'abierta');
/*!40000 ALTER TABLE `caja` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `carrocompras`
--

DROP TABLE IF EXISTS `carrocompras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `carrocompras` (
  `id_carrito` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `estado` enum('vacio','activo','abandonado','guardado','convertido') NOT NULL DEFAULT 'activo',
  PRIMARY KEY (`id_carrito`),
  KEY `fk_carrito_cliente` (`id_cliente`),
  CONSTRAINT `fk_carrito_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `carrocompras`
--

LOCK TABLES `carrocompras` WRITE;
/*!40000 ALTER TABLE `carrocompras` DISABLE KEYS */;
INSERT INTO `carrocompras` VALUES (1,1,'2026-09-22 12:50:27','2026-09-22 12:50:27','convertido'),(100,100,'2026-09-25 00:22:14','2026-09-25 00:22:14','convertido'),(101,101,'2026-09-25 00:22:14','2026-09-25 00:22:14','convertido'),(102,102,'2026-09-25 00:22:14','2026-09-25 00:22:14','activo'),(103,103,'2026-09-25 00:22:14','2026-09-25 00:22:14','abandonado'),(104,105,'2026-09-25 00:22:14','2026-09-25 00:22:14','convertido');
/*!40000 ALTER TABLE `carrocompras` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `categoria`
--

DROP TABLE IF EXISTS `categoria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categoria` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categoria`
--

LOCK TABLES `categoria` WRITE;
/*!40000 ALTER TABLE `categoria` DISABLE KEYS */;
INSERT INTO `categoria` VALUES (1,'Bebidas'),(8,'Bebidas Tradicionales'),(5,'Entradas Criollas'),(100,'Especialidades Marinas'),(103,'Guarniciones Extra'),(6,'Platos de Fondo'),(101,'Pollos a la Brasa'),(2,'Postres'),(102,'Postres Criollos'),(3,'Salados'),(7,'Sopas y Caldos'),(4,'Waffles');
/*!40000 ALTER TABLE `categoria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `password_hash` varchar(255) DEFAULT NULL,
  `direccion_default` varchar(200) DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `email` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cliente`
--

LOCK TABLES `cliente` WRITE;
/*!40000 ALTER TABLE `cliente` DISABLE KEYS */;
INSERT INTO `cliente` VALUES (1,'María López','912345678','maria@example.com','hash_demo','Av. Siempre Viva 123','2026-09-22 12:50:27'),(2,'Carlos Ruiz','923456789',NULL,NULL,NULL,'2026-09-22 12:50:27'),(3,'Julio César Vargas','934567812','julio.v@example.com',NULL,'Sector 3 Grupo 15, Villa El Salvador','2026-09-25 00:19:13'),(4,'Andrea Pineda','987123654','andrea.p@example.com',NULL,'Ovalo Oasis, Villa El Salvador','2026-09-25 00:19:13'),(100,'Fernando Vilca','912111222','fer.vilca@gmail.com',NULL,'Sector 1 Grupo 7, Villa El Salvador','2026-09-25 00:22:14'),(101,'Gabriela Torres','933444555','gaby.t@hotmail.com',NULL,'Ruta A, Paradero 5, VES','2026-09-25 00:22:14'),(102,'Hugo Paredes','955666777',NULL,NULL,'Ruta B, Paradero 12, VES','2026-09-25 00:22:14'),(103,'Isabel Ramos','977888999','isa_ramos@gmail.com',NULL,'Av. Pastor Sevilla con Av. El Sol, VES','2026-09-25 00:22:14'),(104,'Juan Carlos Cruz','922333444',NULL,NULL,'Sector 3 Grupo 14, Villa El Salvador','2026-09-25 00:22:14'),(105,'Katherine Silva','944555666','katy.silva@yahoo.com',NULL,'Parque Industrial de VES, Manzana B','2026-09-25 00:22:14'),(106,'Luis Alva','966777888','luis.alva88@gmail.com',NULL,'Ovalo de la Mujer, VES','2026-09-25 00:22:14'),(107,'Milagros Cueva','988999000','mili.cueva@gmail.com',NULL,'Av. 200 Millas, VES','2026-09-25 00:22:14');
/*!40000 ALTER TABLE `cliente` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comprobante`
--

DROP TABLE IF EXISTS `comprobante`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comprobante` (
  `id_comprobante` int NOT NULL AUTO_INCREMENT,
  `id_venta` int NOT NULL,
  `serie` char(4) NOT NULL DEFAULT 'B001',
  `numero` int NOT NULL,
  `fecha_emision` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `subtotal` decimal(10,2) NOT NULL,
  `igv` decimal(10,2) NOT NULL,
  `total` decimal(10,2) NOT NULL,
  `id_empleado` int NOT NULL,
  PRIMARY KEY (`id_comprobante`),
  UNIQUE KEY `id_venta` (`id_venta`),
  UNIQUE KEY `uq_comprobante_serie_numero` (`serie`,`numero`),
  KEY `fk_comprobante_empleado` (`id_empleado`),
  CONSTRAINT `fk_comprobante_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `fk_comprobante_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`),
  CONSTRAINT `chk_comprobante_total` CHECK ((`total` = (`subtotal` + `igv`)))
) ENGINE=InnoDB AUTO_INCREMENT=108 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comprobante`
--

LOCK TABLES `comprobante` WRITE;
/*!40000 ALTER TABLE `comprobante` DISABLE KEYS */;
INSERT INTO `comprobante` VALUES (1,1,'B001',1,'2026-09-22 12:50:27',21.19,3.81,25.00,1),(2,2,'B001',2,'2026-09-22 12:50:27',24.58,4.42,29.00,1),(3,3,'B001',3,'2026-09-25 00:19:13',65.25,11.75,77.00,1),(100,100,'B002',100,'2026-09-25 00:22:14',59.32,10.68,70.00,103),(101,101,'B002',101,'2026-09-25 00:22:14',55.08,9.92,65.00,103),(102,102,'B002',102,'2026-09-25 00:22:14',98.31,17.69,116.00,103),(103,103,'B002',103,'2026-09-25 00:22:14',22.03,3.97,26.00,103),(104,104,'B002',104,'2026-09-25 00:22:14',30.51,5.49,36.00,103),(105,105,'B002',105,'2026-09-25 00:22:14',76.27,13.73,90.00,103),(106,106,'B002',106,'2026-09-25 00:22:14',77.12,13.88,91.00,103),(107,107,'B002',107,'2026-09-25 00:22:14',61.86,11.14,73.00,103);
/*!40000 ALTER TABLE `comprobante` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `delivery`
--

DROP TABLE IF EXISTS `delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `delivery` (
  `id_delivery` int NOT NULL AUTO_INCREMENT,
  `id_venta` int NOT NULL,
  `direccion_entrega` varchar(200) NOT NULL,
  `referencia` varchar(150) DEFAULT NULL,
  `telefono_contacto` varchar(15) NOT NULL,
  `costo_delivery` decimal(6,2) NOT NULL DEFAULT '0.00',
  `hora_estimada_entrega` datetime DEFAULT NULL,
  `hora_entrega_real` datetime DEFAULT NULL,
  PRIMARY KEY (`id_delivery`),
  UNIQUE KEY `id_venta` (`id_venta`),
  CONSTRAINT `fk_delivery_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`),
  CONSTRAINT `chk_delivery_costo` CHECK ((`costo_delivery` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `delivery`
--

LOCK TABLES `delivery` WRITE;
/*!40000 ALTER TABLE `delivery` DISABLE KEYS */;
INSERT INTO `delivery` VALUES (1,2,'Av. Siempre Viva 123','Frente al parque','912345678',5.00,'2026-09-22 13:20:27','2026-09-22 12:50:27'),(2,4,'Ovalo Oasis, Villa El Salvador',NULL,'987123654',5.00,'2026-09-25 00:49:13',NULL),(100,105,'Sector 1 Grupo 7, Villa El Salvador',NULL,'912111222',5.00,'2026-09-25 00:02:14','2026-09-25 00:07:14'),(101,106,'Ruta A, Paradero 5, VES',NULL,'933444555',6.00,'2026-09-25 00:12:14','2026-09-25 00:17:14'),(102,107,'Parque Industrial de VES, Manzana B',NULL,'944555666',5.00,'2026-09-25 00:32:14','2026-09-25 00:22:14'),(103,110,'Av. 200 Millas, VES',NULL,'988999000',4.00,'2026-09-25 01:07:14',NULL);
/*!40000 ALTER TABLE `delivery` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detallecarrito`
--

DROP TABLE IF EXISTS `detallecarrito`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detallecarrito` (
  `id_detalle_carrito` int NOT NULL AUTO_INCREMENT,
  `id_carrito` int NOT NULL,
  `id_producto` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(8,2) NOT NULL,
  PRIMARY KEY (`id_detalle_carrito`),
  UNIQUE KEY `uq_carrito_producto` (`id_carrito`,`id_producto`),
  KEY `fk_detcarrito_producto` (`id_producto`),
  CONSTRAINT `fk_detcarrito_carrito` FOREIGN KEY (`id_carrito`) REFERENCES `carrocompras` (`id_carrito`),
  CONSTRAINT `fk_detcarrito_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  CONSTRAINT `chk_detcarrito_cantidad` CHECK ((`cantidad` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detallecarrito`
--

LOCK TABLES `detallecarrito` WRITE;
/*!40000 ALTER TABLE `detallecarrito` DISABLE KEYS */;
INSERT INTO `detallecarrito` VALUES (1,1,12,1,12.00),(2,1,2,1,12.00),(3,100,106,1,65.00),(4,100,107,2,10.00),(5,101,100,2,35.00),(6,101,103,1,15.00),(7,102,104,1,18.00),(8,102,112,1,4.00),(9,103,110,4,8.00),(10,104,101,1,38.00),(11,104,102,1,30.00);
/*!40000 ALTER TABLE `detallecarrito` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalleventa`
--

DROP TABLE IF EXISTS `detalleventa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalleventa` (
  `id_detalle` int NOT NULL AUTO_INCREMENT,
  `id_venta` int NOT NULL,
  `id_producto` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(8,2) NOT NULL,
  `subtotal` decimal(8,2) NOT NULL,
  PRIMARY KEY (`id_detalle`),
  KEY `fk_detventa_venta` (`id_venta`),
  KEY `fk_detventa_producto` (`id_producto`),
  CONSTRAINT `fk_detventa_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  CONSTRAINT `fk_detventa_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`),
  CONSTRAINT `chk_detventa_cantidad` CHECK ((`cantidad` > 0)),
  CONSTRAINT `chk_detventa_subtotal` CHECK ((`subtotal` = (`cantidad` * `precio_unitario`)))
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalleventa`
--

LOCK TABLES `detalleventa` WRITE;
/*!40000 ALTER TABLE `detalleventa` DISABLE KEYS */;
INSERT INTO `detalleventa` VALUES (1,1,3,2,5.00,10.00),(2,1,16,2,5.00,10.00),(3,1,8,1,5.00,5.00),(4,2,12,1,12.00,12.00),(5,2,2,1,12.00,12.00),(6,3,18,1,12.00,12.00),(7,3,21,1,28.00,28.00),(8,3,23,1,25.00,25.00),(9,3,27,1,12.00,12.00),(10,4,22,2,22.00,44.00),(11,4,28,2,4.50,9.00),(12,100,100,2,35.00,70.00),(13,101,106,1,65.00,65.00),(14,102,101,2,38.00,76.00),(15,102,102,1,30.00,30.00),(16,102,107,1,10.00,10.00),(17,103,110,2,8.00,16.00),(18,103,107,1,10.00,10.00),(19,104,104,2,18.00,36.00),(20,105,106,1,65.00,65.00),(21,105,107,2,10.00,20.00),(22,106,100,2,35.00,70.00),(23,106,103,1,15.00,15.00),(24,107,101,1,38.00,38.00),(25,107,102,1,30.00,30.00),(26,108,106,1,65.00,65.00),(27,108,107,4,10.00,40.00),(28,109,111,1,12.00,12.00),(29,109,107,1,10.00,10.00),(30,110,101,1,38.00,38.00);
/*!40000 ALTER TABLE `detalleventa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleado`
--

DROP TABLE IF EXISTS `empleado`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleado` (
  `id_empleado` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `rol` enum('cajero','mesero','cocina','admin') NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_empleado`)
) ENGINE=InnoDB AUTO_INCREMENT=105 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleado`
--

LOCK TABLES `empleado` WRITE;
/*!40000 ALTER TABLE `empleado` DISABLE KEYS */;
INSERT INTO `empleado` VALUES (1,'Ana Torres','cajero',1),(2,'Luis Mendoza','mesero',1),(3,'Rosa Quispe','cocina',1),(100,'Martín Chumpitaz','mesero',1),(101,'Elena Rivas','mesero',1),(102,'José Mamani','cocina',1),(103,'Carmen Sulca','cajero',1),(104,'Roberto Sánchez','admin',1);
/*!40000 ALTER TABLE `empleado` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mesa`
--

DROP TABLE IF EXISTS `mesa`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mesa` (
  `id_mesa` int NOT NULL AUTO_INCREMENT,
  `numero` int NOT NULL,
  `capacidad` int NOT NULL DEFAULT '4',
  `estado` enum('libre','ocupada') NOT NULL DEFAULT 'libre',
  PRIMARY KEY (`id_mesa`),
  UNIQUE KEY `numero` (`numero`),
  CONSTRAINT `chk_mesa_capacidad` CHECK ((`capacidad` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mesa`
--

LOCK TABLES `mesa` WRITE;
/*!40000 ALTER TABLE `mesa` DISABLE KEYS */;
INSERT INTO `mesa` VALUES (1,1,4,'libre'),(2,2,4,'libre'),(3,3,2,'libre'),(100,4,2,'libre'),(101,5,2,'libre'),(102,6,4,'libre'),(103,7,4,'libre'),(104,8,6,'libre'),(105,9,6,'ocupada'),(106,10,8,'libre'),(107,11,2,'ocupada'),(108,12,4,'libre');
/*!40000 ALTER TABLE `mesa` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `metodopago`
--

DROP TABLE IF EXISTS `metodopago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `metodopago` (
  `id_metodo` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(30) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_metodo`),
  UNIQUE KEY `nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `metodopago`
--

LOCK TABLES `metodopago` WRITE;
/*!40000 ALTER TABLE `metodopago` DISABLE KEYS */;
INSERT INTO `metodopago` VALUES (1,'efectivo',1),(2,'yape',1),(3,'plin',1),(4,'tarjeta',1);
/*!40000 ALTER TABLE `metodopago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pago`
--

DROP TABLE IF EXISTS `pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pago` (
  `id_pago` int NOT NULL AUTO_INCREMENT,
  `id_venta` int NOT NULL,
  `id_metodo` int NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `estado` enum('pendiente','confirmado','rechazado') NOT NULL DEFAULT 'pendiente',
  `codigo_operacion` varchar(30) DEFAULT NULL,
  `motivo_rechazo` varchar(100) DEFAULT NULL,
  `id_empleado` int DEFAULT NULL,
  `fecha_pago` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_revision` datetime DEFAULT NULL,
  PRIMARY KEY (`id_pago`),
  KEY `fk_pago_venta` (`id_venta`),
  KEY `fk_pago_metodo` (`id_metodo`),
  KEY `fk_pago_empleado` (`id_empleado`),
  CONSTRAINT `fk_pago_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `fk_pago_metodo` FOREIGN KEY (`id_metodo`) REFERENCES `metodopago` (`id_metodo`),
  CONSTRAINT `fk_pago_venta` FOREIGN KEY (`id_venta`) REFERENCES `venta` (`id_venta`),
  CONSTRAINT `chk_pago_monto` CHECK ((`monto` > 0)),
  CONSTRAINT `chk_pago_rechazo` CHECK (((`estado` <> _utf8mb4'rechazado') or (`motivo_rechazo` is not null))),
  CONSTRAINT `chk_pago_revision` CHECK (((`estado` = _utf8mb4'pendiente') or ((`id_empleado` is not null) and (`fecha_revision` is not null))))
) ENGINE=InnoDB AUTO_INCREMENT=109 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pago`
--

LOCK TABLES `pago` WRITE;
/*!40000 ALTER TABLE `pago` DISABLE KEYS */;
INSERT INTO `pago` VALUES (1,1,1,25.00,'confirmado',NULL,NULL,1,'2026-09-22 12:50:27','2026-09-22 12:50:27'),(2,2,2,29.00,'confirmado','48213765',NULL,1,'2026-09-22 12:50:27','2026-09-22 12:50:27'),(3,3,4,77.00,'confirmado','REF-987654',NULL,1,'2026-09-25 00:19:13','2026-09-25 00:19:13'),(4,4,2,58.00,'confirmado','YAPE-112233',NULL,1,'2026-09-25 00:19:13','2026-09-25 00:19:13'),(100,100,1,70.00,'confirmado',NULL,NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(101,101,2,65.00,'confirmado','YP-1234',NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(102,102,4,116.00,'confirmado','OP-8888',NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(103,103,1,26.00,'confirmado',NULL,NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(104,104,3,36.00,'confirmado','PL-7777',NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(105,105,2,90.00,'confirmado','YP-5555',NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(106,106,3,91.00,'confirmado','PL-4444',NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(107,107,2,73.00,'confirmado','YP-3333',NULL,103,'2026-09-25 00:22:14','2026-09-25 00:22:14'),(108,110,2,42.00,'pendiente','YP-9999',NULL,NULL,'2026-09-25 00:22:14',NULL);
/*!40000 ALTER TABLE `pago` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `id_categoria` int NOT NULL,
  `precio` decimal(8,2) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_producto`),
  KEY `fk_producto_categoria` (`id_categoria`),
  CONSTRAINT `fk_producto_categoria` FOREIGN KEY (`id_categoria`) REFERENCES `categoria` (`id_categoria`),
  CONSTRAINT `chk_producto_precio` CHECK ((`precio` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=114 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `producto`
--

LOCK TABLES `producto` WRITE;
/*!40000 ALTER TABLE `producto` DISABLE KEYS */;
INSERT INTO `producto` VALUES (1,'Néctar',1,4.00,1),(2,'Frapuccino',1,12.00,1),(3,'Café con leche',1,5.00,1),(4,'Café sin leche',1,5.00,1),(5,'Agua',1,2.00,1),(6,'Inca Kola',1,4.00,1),(7,'Coca Cola',1,4.00,1),(8,'Porción de torta de chocolate',2,5.00,1),(9,'Gelatina de piña',2,2.00,1),(10,'Gelatina de fresa',2,2.00,1),(11,'Gelatina de manzana',2,2.00,1),(12,'Waffle con fruta',4,12.00,1),(13,'Waffle con queso',4,12.00,1),(14,'Empanada de pollo',3,4.00,1),(15,'Empanada de carne',3,4.00,1),(16,'Pan con pollo',3,5.00,1),(17,'Pan con chorizo',3,5.00,1),(18,'Causa Limeña de Pollo',5,12.00,1),(19,'Papa a la Huancaína',5,10.00,1),(20,'Porción de Anticuchos (3 palitos)',5,18.00,1),(21,'Lomo Saltado',6,28.00,1),(22,'Ají de Gallina',6,22.00,1),(23,'Seco de Res con Frijoles',6,25.00,1),(24,'Arroz con Pollo',6,20.00,1),(25,'Sopa a la Minuta',7,16.00,1),(26,'Sustancia de Carne',7,12.00,1),(27,'Jarra de Chicha Morada 1L',8,12.00,1),(28,'Inka Kola Personal 500ml',8,4.50,1),(100,'Ceviche Mixto',100,35.00,1),(101,'Arroz con Mariscos',100,38.00,1),(102,'Chicharrón de Pescado',100,30.00,1),(103,'Leche de Tigre',100,15.00,1),(104,'1/4 de Pollo + Papas y Ensalada',101,18.00,1),(105,'1/2 Pollo + Papas y Ensalada',101,34.00,1),(106,'1 Pollo Entero + Papas, Ensalada y Gaseosa 1.5L',101,65.00,1),(107,'Picarones (4 aros con miel)',102,10.00,1),(108,'Arroz con Leche',102,6.00,1),(109,'Mazamorra Morada',102,6.00,1),(110,'Clásico (Arroz con leche y mazamorra)',102,8.00,1),(111,'Suspiro a la Limeña',102,12.00,1),(112,'Porción de Arroz Blanco',103,4.00,1),(113,'Porción de Papas Fritas',103,8.00,1);
/*!40000 ALTER TABLE `producto` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `repartidor`
--

DROP TABLE IF EXISTS `repartidor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `repartidor` (
  `id_repartidor` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(15) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_repartidor`)
) ENGINE=InnoDB AUTO_INCREMENT=103 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `repartidor`
--

LOCK TABLES `repartidor` WRITE;
/*!40000 ALTER TABLE `repartidor` DISABLE KEYS */;
INSERT INTO `repartidor` VALUES (1,'Adrian Angel','987654321',1),(2,'William','976543210',1),(100,'Raúl MotoDelivery','999111222',1),(101,'Kevin VES Delivery','988777666',1),(102,'Jairo Express','911222333',1);
/*!40000 ALTER TABLE `repartidor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `v_mesas_libres`
--

DROP TABLE IF EXISTS `v_mesas_libres`;
/*!50001 DROP VIEW IF EXISTS `v_mesas_libres`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_mesas_libres` AS SELECT 
 1 AS `id_mesa`,
 1 AS `numero`,
 1 AS `capacidad`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_pedidos_cocina`
--

DROP TABLE IF EXISTS `v_pedidos_cocina`;
/*!50001 DROP VIEW IF EXISTS `v_pedidos_cocina`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_pedidos_cocina` AS SELECT 
 1 AS `id_venta`,
 1 AS `tipo_venta`,
 1 AS `mesa`,
 1 AS `estado`,
 1 AS `fecha`,
 1 AS `pedido`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `v_pedidos_listos`
--

DROP TABLE IF EXISTS `v_pedidos_listos`;
/*!50001 DROP VIEW IF EXISTS `v_pedidos_listos`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_pedidos_listos` AS SELECT 
 1 AS `id_venta`,
 1 AS `tipo_venta`,
 1 AS `mesa`,
 1 AS `mesero`,
 1 AS `hora_listo`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `venta`
--

DROP TABLE IF EXISTS `venta`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `venta` (
  `id_venta` int NOT NULL AUTO_INCREMENT,
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `id_cliente` int DEFAULT NULL,
  `id_empleado` int DEFAULT NULL,
  `id_mesa` int DEFAULT NULL,
  `id_caja` int NOT NULL,
  `id_repartidor` int DEFAULT NULL,
  `id_carrito` int DEFAULT NULL,
  `tipo_venta` enum('presencial','delivery') NOT NULL,
  `estado` enum('pendiente_pago','pendiente','en_proceso','listo','entregado','cancelado') NOT NULL DEFAULT 'pendiente',
  `hora_listo` datetime DEFAULT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  PRIMARY KEY (`id_venta`),
  UNIQUE KEY `uq_venta_carrito` (`id_carrito`),
  KEY `idx_venta_estado` (`estado`,`fecha`),
  KEY `fk_venta_cliente` (`id_cliente`),
  KEY `fk_venta_empleado` (`id_empleado`),
  KEY `fk_venta_mesa` (`id_mesa`),
  KEY `fk_venta_caja` (`id_caja`),
  KEY `fk_venta_repartidor` (`id_repartidor`),
  CONSTRAINT `fk_venta_caja` FOREIGN KEY (`id_caja`) REFERENCES `caja` (`id_caja`),
  CONSTRAINT `fk_venta_carrito` FOREIGN KEY (`id_carrito`) REFERENCES `carrocompras` (`id_carrito`),
  CONSTRAINT `fk_venta_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_cliente`),
  CONSTRAINT `fk_venta_empleado` FOREIGN KEY (`id_empleado`) REFERENCES `empleado` (`id_empleado`),
  CONSTRAINT `fk_venta_mesa` FOREIGN KEY (`id_mesa`) REFERENCES `mesa` (`id_mesa`),
  CONSTRAINT `fk_venta_repartidor` FOREIGN KEY (`id_repartidor`) REFERENCES `repartidor` (`id_repartidor`),
  CONSTRAINT `chk_venta_tipo` CHECK ((((`tipo_venta` = _utf8mb4'presencial') and (`id_mesa` is not null) and (`id_empleado` is not null) and (`id_carrito` is null) and (`id_repartidor` is null)) or ((`tipo_venta` = _utf8mb4'delivery') and (`id_mesa` is null) and (`id_cliente` is not null)))),
  CONSTRAINT `chk_venta_total` CHECK ((`total` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=111 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `venta`
--

LOCK TABLES `venta` WRITE;
/*!40000 ALTER TABLE `venta` DISABLE KEYS */;
INSERT INTO `venta` VALUES (1,'2026-09-22 12:50:27',2,2,1,1,NULL,NULL,'presencial','entregado','2026-09-22 12:50:27',25.00),(2,'2026-09-22 12:50:27',1,NULL,NULL,1,1,1,'delivery','entregado','2026-09-22 12:50:27',29.00),(3,'2026-09-25 00:19:13',NULL,2,2,1,NULL,NULL,'presencial','entregado','2026-09-24 23:34:13',77.00),(4,'2026-09-25 00:19:13',4,NULL,NULL,1,NULL,NULL,'delivery','en_proceso',NULL,58.00),(100,'2026-09-25 00:22:14',NULL,100,100,100,NULL,NULL,'presencial','entregado','2026-09-24 22:22:14',70.00),(101,'2026-09-25 00:22:14',NULL,101,102,100,NULL,NULL,'presencial','entregado','2026-09-24 22:52:14',65.00),(102,'2026-09-25 00:22:14',NULL,100,103,100,NULL,NULL,'presencial','entregado','2026-09-24 23:22:14',116.00),(103,'2026-09-25 00:22:14',NULL,101,104,100,NULL,NULL,'presencial','entregado','2026-09-24 23:37:14',26.00),(104,'2026-09-25 00:22:14',NULL,100,108,100,NULL,NULL,'presencial','entregado','2026-09-24 23:52:14',36.00),(105,'2026-09-25 00:22:14',100,NULL,NULL,100,100,100,'delivery','entregado','2026-09-24 23:32:14',90.00),(106,'2026-09-25 00:22:14',101,NULL,NULL,100,101,101,'delivery','entregado','2026-09-24 23:42:14',91.00),(107,'2026-09-25 00:22:14',105,NULL,NULL,100,102,104,'delivery','entregado','2026-09-25 00:02:14',73.00),(108,'2026-09-25 00:22:14',NULL,100,105,100,NULL,NULL,'presencial','en_proceso',NULL,105.00),(109,'2026-09-25 00:22:14',NULL,101,107,100,NULL,NULL,'presencial','pendiente',NULL,22.00),(110,'2026-09-25 00:22:14',107,NULL,NULL,100,NULL,NULL,'delivery','pendiente_pago',NULL,42.00);
/*!40000 ALTER TABLE `venta` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Final view structure for view `v_mesas_libres`
--

/*!50001 DROP VIEW IF EXISTS `v_mesas_libres`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_mesas_libres` AS select `mesa`.`id_mesa` AS `id_mesa`,`mesa`.`numero` AS `numero`,`mesa`.`capacidad` AS `capacidad` from `mesa` where (`mesa`.`estado` = 'libre') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pedidos_cocina`
--

/*!50001 DROP VIEW IF EXISTS `v_pedidos_cocina`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pedidos_cocina` AS select `v`.`id_venta` AS `id_venta`,`v`.`tipo_venta` AS `tipo_venta`,`m`.`numero` AS `mesa`,`v`.`estado` AS `estado`,`v`.`fecha` AS `fecha`,group_concat(concat(`dv`.`cantidad`,' x ',`p`.`nombre`) order by `p`.`nombre` ASC separator ', ') AS `pedido` from (((`venta` `v` join `detalleventa` `dv` on((`dv`.`id_venta` = `v`.`id_venta`))) join `producto` `p` on((`p`.`id_producto` = `dv`.`id_producto`))) left join `mesa` `m` on((`m`.`id_mesa` = `v`.`id_mesa`))) where (`v`.`estado` in ('pendiente','en_proceso')) group by `v`.`id_venta`,`v`.`tipo_venta`,`m`.`numero`,`v`.`estado`,`v`.`fecha` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `v_pedidos_listos`
--

/*!50001 DROP VIEW IF EXISTS `v_pedidos_listos`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_pedidos_listos` AS select `v`.`id_venta` AS `id_venta`,`v`.`tipo_venta` AS `tipo_venta`,`m`.`numero` AS `mesa`,`e`.`nombre` AS `mesero`,`v`.`hora_listo` AS `hora_listo` from ((`venta` `v` left join `mesa` `m` on((`m`.`id_mesa` = `v`.`id_mesa`))) left join `empleado` `e` on((`e`.`id_empleado` = `v`.`id_empleado`))) where (`v`.`estado` = 'listo') */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-09-25  0:40:26
