-- =====================================================================
-- restaurante_ventas_v2  |  MySQL 8.0.16+ (usa CHECK y columnas generadas)
-- Esquema completo: tablas, vistas, procedimientos y triggers.
--
-- Convenciones
--   * Los precios de carta INCLUYEN IGV (tasa por defecto 18 %).
--   * Columnas GENERATED (total, base_imponible, igv, subtotal) no se
--     insertan ni se actualizan desde la app (en JPA: insertable=false,
--     updatable=false).
--   * Estados terminales de venta: finalizada, cancelado, perdida.
--   * Los procedimientos NO abren transacción: llámalos dentro de la tuya.
--
-- Para recrear desde cero, descomenta la siguiente línea:
-- DROP DATABASE IF EXISTS restaurante_ventas_v2;
-- =====================================================================

CREATE DATABASE IF NOT EXISTS restaurante_ventas_v2
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE restaurante_ventas_v2;

-- =====================================================================
-- 1. CATÁLOGOS
-- =====================================================================

CREATE TABLE categoria (
  id_categoria INT NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(50) NOT NULL,
  activo       TINYINT(1)  NOT NULL DEFAULT 1,
  PRIMARY KEY (id_categoria),
  UNIQUE KEY uq_categoria_nombre (nombre)
) ENGINE=InnoDB;

CREATE TABLE producto (
  id_producto  INT NOT NULL AUTO_INCREMENT,
  nombre       VARCHAR(100) NOT NULL,
  descripcion  VARCHAR(200) DEFAULT NULL,
  id_categoria INT NOT NULL,
  precio       DECIMAL(10,2) NOT NULL,          -- incluye IGV
  activo       TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_producto),
  KEY idx_producto_categoria (id_categoria),
  CONSTRAINT fk_producto_categoria FOREIGN KEY (id_categoria) REFERENCES categoria (id_categoria),
  CONSTRAINT chk_producto_precio CHECK (precio > 0)
) ENGINE=InnoDB;

-- COMBOS: un combo se vende como una sola línea con su propio precio
-- y se compone de uno o más productos.
CREATE TABLE combo (
  id_combo       INT NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100) NOT NULL,
  descripcion    VARCHAR(200) DEFAULT NULL,
  precio         DECIMAL(10,2) NOT NULL,        -- incluye IGV
  vigente_desde  DATE DEFAULT NULL,
  vigente_hasta  DATE DEFAULT NULL,
  activo         TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_combo),
  UNIQUE KEY uq_combo_nombre (nombre),
  CONSTRAINT chk_combo_precio CHECK (precio > 0),
  CONSTRAINT chk_combo_vigencia CHECK (vigente_desde IS NULL OR vigente_hasta IS NULL OR vigente_hasta >= vigente_desde)
) ENGINE=InnoDB;

CREATE TABLE combo_producto (
  id_combo    INT NOT NULL,
  id_producto INT NOT NULL,
  cantidad    INT NOT NULL DEFAULT 1,
  PRIMARY KEY (id_combo, id_producto),
  KEY idx_combo_producto_prod (id_producto),
  CONSTRAINT fk_combo_producto_combo FOREIGN KEY (id_combo) REFERENCES combo (id_combo) ON DELETE CASCADE,
  CONSTRAINT fk_combo_producto_prod  FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
  CONSTRAINT chk_combo_producto_cant CHECK (cantidad > 0)
) ENGINE=InnoDB;

CREATE TABLE metodo_pago (
  id_metodo   INT NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(30) NOT NULL,
  es_efectivo TINYINT(1) NOT NULL DEFAULT 0,    -- cuenta para el arqueo de caja
  activo      TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_metodo),
  UNIQUE KEY uq_metodo_pago_nombre (nombre)
) ENGINE=InnoDB;

-- Series y correlativos de comprobantes (evita choques de numeración).
CREATE TABLE serie_comprobante (
  id_serie         INT NOT NULL AUTO_INCREMENT,
  tipo_comprobante ENUM('boleta','factura') NOT NULL,
  serie            CHAR(4) NOT NULL,
  ultimo_numero    INT NOT NULL DEFAULT 0,
  activo           TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_serie),
  UNIQUE KEY uq_serie (serie),
  UNIQUE KEY uq_serie_tipo (id_serie, tipo_comprobante),
  CONSTRAINT chk_serie_numero CHECK (ultimo_numero >= 0)
) ENGINE=InnoDB;

-- =====================================================================
-- 2. PERSONAS
-- =====================================================================

-- Cliente: persona NATURAL o EMPRESA. La empresa exige RUC (11 dígitos);
-- la persona natural puede tener DNI, CE, pasaporte o ningún documento.
CREATE TABLE cliente (
  id_cliente        INT NOT NULL AUTO_INCREMENT,
  tipo_cliente      ENUM('natural','empresa') NOT NULL DEFAULT 'natural',
  nombre            VARCHAR(150) NOT NULL,       -- nombre completo o razón social
  tipo_documento    ENUM('DNI','CE','PASAPORTE','RUC') DEFAULT NULL,
  numero_documento  VARCHAR(15) DEFAULT NULL,
  contacto          VARCHAR(100) DEFAULT NULL,   -- persona de contacto (empresas)
  telefono          VARCHAR(15) DEFAULT NULL,
  email             VARCHAR(100) DEFAULT NULL,
  password_hash     VARCHAR(255) DEFAULT NULL,
  direccion_default VARCHAR(200) DEFAULT NULL,   -- dirección de entrega / fiscal
  fecha_registro    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_cliente),
  UNIQUE KEY uq_cliente_email (email),
  UNIQUE KEY uq_cliente_documento (tipo_documento, numero_documento),
  CONSTRAINT chk_cliente_doc_par CHECK ((tipo_documento IS NULL) = (numero_documento IS NULL)),
  CONSTRAINT chk_cliente_natural CHECK (tipo_cliente <> 'natural' OR tipo_documento IS NULL OR tipo_documento IN ('DNI','CE','PASAPORTE')),
  CONSTRAINT chk_cliente_empresa CHECK (tipo_cliente <> 'empresa'
      OR (tipo_documento IS NOT NULL AND tipo_documento = 'RUC' AND numero_documento REGEXP '^[0-9]{11}$')),
  CONSTRAINT chk_cliente_dni CHECK (tipo_documento IS NULL OR tipo_documento <> 'DNI' OR numero_documento REGEXP '^[0-9]{8}$'),
  CONSTRAINT chk_cliente_ruc CHECK (tipo_documento IS NULL OR tipo_documento <> 'RUC' OR numero_documento REGEXP '^[0-9]{11}$')
) ENGINE=InnoDB;

CREATE TABLE empleado (
  id_empleado    INT NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100) NOT NULL,
  rol            ENUM('cajero','mesero','cocina','admin') NOT NULL,
  usuario        VARCHAR(50) NOT NULL,
  password_hash  VARCHAR(255) NOT NULL,
  telefono       VARCHAR(15) DEFAULT NULL,
  activo         TINYINT(1) NOT NULL DEFAULT 1,
  fecha_registro DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_empleado),
  UNIQUE KEY uq_empleado_usuario (usuario)
) ENGINE=InnoDB;

CREATE TABLE repartidor (
  id_repartidor INT NOT NULL AUTO_INCREMENT,
  nombre        VARCHAR(100) NOT NULL,
  telefono      VARCHAR(15) NOT NULL,
  placa         VARCHAR(10) DEFAULT NULL,
  activo        TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id_repartidor)
) ENGINE=InnoDB;

-- =====================================================================
-- 3. SALA: MESAS Y RESERVAS
-- =====================================================================

CREATE TABLE mesa (
  id_mesa   INT NOT NULL AUTO_INCREMENT,
  numero    INT NOT NULL,
  capacidad INT NOT NULL DEFAULT 4,
  estado    ENUM('libre','ocupada','reservada','inactiva') NOT NULL DEFAULT 'libre',
  PRIMARY KEY (id_mesa),
  UNIQUE KEY uq_mesa_numero (numero),
  CONSTRAINT chk_mesa_capacidad CHECK (capacidad > 0)
) ENGINE=InnoDB;

CREATE TABLE reserva (
  id_reserva      INT NOT NULL AUTO_INCREMENT,
  id_cliente      INT DEFAULT NULL,
  nombre_contacto VARCHAR(100) NOT NULL,
  telefono        VARCHAR(15) NOT NULL,
  id_mesa         INT DEFAULT NULL,
  fecha_reserva   DATETIME NOT NULL,
  num_personas    INT NOT NULL,
  estado          ENUM('pendiente','confirmada','cumplida','cancelada','no_show') NOT NULL DEFAULT 'pendiente',
  notas           VARCHAR(200) DEFAULT NULL,
  fecha_creacion  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_reserva),
  KEY idx_reserva_fecha (fecha_reserva),
  KEY fk_reserva_cliente (id_cliente),
  KEY fk_reserva_mesa (id_mesa),
  CONSTRAINT fk_reserva_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente),
  CONSTRAINT fk_reserva_mesa FOREIGN KEY (id_mesa) REFERENCES mesa (id_mesa),
  CONSTRAINT chk_reserva_personas CHECK (num_personas > 0)
) ENGINE=InnoDB;

-- =====================================================================
-- 4. CAJA
-- =====================================================================

-- monto_inicial: fondo al abrir. monto_final: efectivo contado al cerrar.
-- monto_esperado: lo calcula sp_cerrar_caja. diferencia < 0 = faltante.
CREATE TABLE caja (
  id_caja        INT NOT NULL AUTO_INCREMENT,
  id_empleado    INT NOT NULL,
  fecha_apertura DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_cierre   DATETIME DEFAULT NULL,
  monto_inicial  DECIMAL(10,2) NOT NULL,
  monto_esperado DECIMAL(10,2) DEFAULT NULL,
  monto_final    DECIMAL(10,2) DEFAULT NULL,
  diferencia     DECIMAL(10,2) GENERATED ALWAYS AS (monto_final - monto_esperado) STORED,
  estado         ENUM('abierta','cerrada') NOT NULL DEFAULT 'abierta',
  observaciones  VARCHAR(200) DEFAULT NULL,
  -- Truco: un solo valor no nulo por empleado => máximo una caja abierta.
  empleado_caja_abierta INT GENERATED ALWAYS AS (IF(estado = 'abierta', id_empleado, NULL)) STORED,
  PRIMARY KEY (id_caja),
  UNIQUE KEY uq_caja_abierta_empleado (empleado_caja_abierta),
  KEY fk_caja_empleado (id_empleado),
  CONSTRAINT fk_caja_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
  CONSTRAINT chk_caja_monto_inicial CHECK (monto_inicial >= 0),
  CONSTRAINT chk_caja_estado CHECK (
    (estado = 'abierta' AND fecha_cierre IS NULL)
    OR (estado = 'cerrada' AND fecha_cierre IS NOT NULL AND monto_final IS NOT NULL AND monto_esperado IS NOT NULL))
) ENGINE=InnoDB;

-- =====================================================================
-- 5. CARRITO (pedidos web / delivery)
-- =====================================================================

CREATE TABLE carrito_compras (
  id_carrito          INT NOT NULL AUTO_INCREMENT,
  id_cliente          INT NOT NULL,
  fecha_creacion      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  estado              ENUM('activo','abandonado','guardado','convertido') NOT NULL DEFAULT 'activo',
  PRIMARY KEY (id_carrito),
  KEY fk_carrito_cliente (id_cliente),
  CONSTRAINT fk_carrito_cliente FOREIGN KEY (id_cliente) REFERENCES cliente (id_cliente)
) ENGINE=InnoDB;

-- Cada línea es un producto O un combo (exactamente uno de los dos).
CREATE TABLE detalle_carrito (
  id_detalle_carrito INT NOT NULL AUTO_INCREMENT,
  id_carrito         INT NOT NULL,
  id_producto        INT DEFAULT NULL,
  id_combo           INT DEFAULT NULL,
  cantidad           INT NOT NULL,
  precio_unitario    DECIMAL(10,2) NOT NULL,
  item_clave         VARCHAR(12) GENERATED ALWAYS AS (IF(id_producto IS NOT NULL, CONCAT('P', id_producto), CONCAT('C', id_combo))) STORED,
  PRIMARY KEY (id_detalle_carrito),
  UNIQUE KEY uq_carrito_item (id_carrito, item_clave),
  KEY fk_detcarrito_producto (id_producto),
  KEY fk_detcarrito_combo (id_combo),
  CONSTRAINT fk_detcarrito_carrito  FOREIGN KEY (id_carrito) REFERENCES carrito_compras (id_carrito) ON DELETE CASCADE,
  CONSTRAINT fk_detcarrito_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
  CONSTRAINT fk_detcarrito_combo    FOREIGN KEY (id_combo) REFERENCES combo (id_combo),
  CONSTRAINT chk_detcarrito_cantidad CHECK (cantidad > 0),
  CONSTRAINT chk_detcarrito_precio CHECK (precio_unitario > 0),
  CONSTRAINT chk_detcarrito_item CHECK ((id_producto IS NOT NULL) + (id_combo IS NOT NULL) = 1)
) ENGINE=InnoDB;

-- =====================================================================
-- 6. VENTA
-- =====================================================================
-- Flujo de estados:
--   pendiente_pago -> pendiente -> en_proceso -> listo -> entregado -> finalizada
--   (cancelado: anulada antes de cobrar | perdida: robo / no pagó / no entregado)
-- Montos: monto_items lo mantiene un trigger a partir del detalle;
--   total, base_imponible e igv se calculan solos (columnas generadas).
CREATE TABLE venta (
  id_venta           INT NOT NULL AUTO_INCREMENT,
  fecha_venta        DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  tipo_venta         ENUM('presencial','delivery') NOT NULL,
  estado             ENUM('pendiente_pago','pendiente','en_proceso','listo','entregado','finalizada','cancelado','perdida') NOT NULL DEFAULT 'pendiente',
  id_cliente         INT DEFAULT NULL,
  id_empleado        INT DEFAULT NULL,
  id_mesa            INT DEFAULT NULL,
  id_reserva         INT DEFAULT NULL,
  id_caja            INT DEFAULT NULL,
  id_carrito         INT DEFAULT NULL,
  hora_listo         DATETIME DEFAULT NULL,
  monto_items        DECIMAL(10,2) NOT NULL DEFAULT 0.00,   -- suma del detalle (con IGV)
  descuento          DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  motivo_descuento   VARCHAR(100) DEFAULT NULL,
  costo_delivery     DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tasa_igv           DECIMAL(5,2) NOT NULL DEFAULT 18.00,
  total              DECIMAL(10,2) GENERATED ALWAYS AS (GREATEST(monto_items - descuento, 0) + costo_delivery) STORED,
  base_imponible     DECIMAL(10,2) GENERATED ALWAYS AS (ROUND(total / (1 + tasa_igv / 100), 2)) STORED,
  igv                DECIMAL(10,2) GENERATED ALWAYS AS (total - base_imponible) STORED,
  motivo_cancelacion VARCHAR(150) DEFAULT NULL,
  PRIMARY KEY (id_venta),
  UNIQUE KEY uq_venta_carrito (id_carrito),
  KEY idx_venta_fecha (fecha_venta),
  KEY idx_venta_estado (estado, fecha_venta),
  KEY fk_venta_cliente (id_cliente),
  KEY fk_venta_empleado (id_empleado),
  KEY fk_venta_mesa (id_mesa),
  KEY fk_venta_reserva (id_reserva),
  KEY fk_venta_caja (id_caja),
  CONSTRAINT fk_venta_cliente  FOREIGN KEY (id_cliente)  REFERENCES cliente (id_cliente),
  CONSTRAINT fk_venta_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
  CONSTRAINT fk_venta_mesa     FOREIGN KEY (id_mesa)     REFERENCES mesa (id_mesa),
  CONSTRAINT fk_venta_reserva  FOREIGN KEY (id_reserva)  REFERENCES reserva (id_reserva),
  CONSTRAINT fk_venta_caja     FOREIGN KEY (id_caja)     REFERENCES caja (id_caja),
  CONSTRAINT fk_venta_carrito  FOREIGN KEY (id_carrito)  REFERENCES carrito_compras (id_carrito),
  CONSTRAINT chk_venta_tipo CHECK (
    (tipo_venta = 'presencial' AND id_mesa IS NOT NULL AND id_empleado IS NOT NULL AND id_caja IS NOT NULL
       AND id_carrito IS NULL AND costo_delivery = 0)
    OR (tipo_venta = 'delivery' AND id_mesa IS NULL AND id_cliente IS NOT NULL)),
  CONSTRAINT chk_venta_montos CHECK (monto_items >= 0 AND descuento >= 0 AND descuento <= monto_items
       AND costo_delivery >= 0 AND tasa_igv BETWEEN 0 AND 100),
  CONSTRAINT chk_venta_descuento CHECK (descuento = 0 OR motivo_descuento IS NOT NULL),
  CONSTRAINT chk_venta_cancelacion CHECK (estado <> 'cancelado' OR motivo_cancelacion IS NOT NULL)
) ENGINE=InnoDB;

CREATE TABLE detalle_venta (
  id_detalle      INT NOT NULL AUTO_INCREMENT,
  id_venta        INT NOT NULL,
  id_producto     INT DEFAULT NULL,
  id_combo        INT DEFAULT NULL,
  cantidad        INT NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,                 -- precio vigente al vender
  subtotal        DECIMAL(10,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED,
  observaciones   VARCHAR(150) DEFAULT NULL,              -- "sin ají", "bien cocido"...
  PRIMARY KEY (id_detalle),
  KEY fk_detventa_venta (id_venta),
  KEY fk_detventa_producto (id_producto),
  KEY fk_detventa_combo (id_combo),
  CONSTRAINT fk_detventa_venta    FOREIGN KEY (id_venta)    REFERENCES venta (id_venta),
  CONSTRAINT fk_detventa_producto FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
  CONSTRAINT fk_detventa_combo    FOREIGN KEY (id_combo)    REFERENCES combo (id_combo),
  CONSTRAINT chk_detventa_cantidad CHECK (cantidad > 0),
  CONSTRAINT chk_detventa_precio CHECK (precio_unitario > 0),
  CONSTRAINT chk_detventa_item CHECK ((id_producto IS NOT NULL) + (id_combo IS NOT NULL) = 1)
) ENGINE=InnoDB;

-- DELIVERY: la fecha de entrega programada vive SOLO aquí (la venta
-- solo tiene fecha_venta). Permite pedidos para otro día.
CREATE TABLE delivery (
  id_delivery              INT NOT NULL AUTO_INCREMENT,
  id_venta                 INT NOT NULL,
  id_repartidor            INT DEFAULT NULL,
  direccion_entrega        VARCHAR(200) NOT NULL,
  referencia               VARCHAR(150) DEFAULT NULL,
  telefono_contacto        VARCHAR(15) NOT NULL,
  fecha_entrega_programada DATE NOT NULL,
  hora_estimada_entrega    TIME DEFAULT NULL,
  hora_salida              DATETIME DEFAULT NULL,
  hora_entrega_real        DATETIME DEFAULT NULL,
  estado_delivery          ENUM('programado','asignado','en_ruta','entregado','fallido') NOT NULL DEFAULT 'programado',
  motivo_fallo             VARCHAR(150) DEFAULT NULL,
  PRIMARY KEY (id_delivery),
  UNIQUE KEY uq_delivery_venta (id_venta),
  KEY idx_delivery_fecha (fecha_entrega_programada),
  KEY fk_delivery_repartidor (id_repartidor),
  CONSTRAINT fk_delivery_venta      FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
  CONSTRAINT fk_delivery_repartidor FOREIGN KEY (id_repartidor) REFERENCES repartidor (id_repartidor),
  CONSTRAINT chk_delivery_repartidor CHECK (estado_delivery IN ('programado','fallido') OR id_repartidor IS NOT NULL),
  CONSTRAINT chk_delivery_entregado CHECK (estado_delivery <> 'entregado' OR hora_entrega_real IS NOT NULL),
  CONSTRAINT chk_delivery_fallo CHECK (estado_delivery <> 'fallido' OR motivo_fallo IS NOT NULL)
) ENGINE=InnoDB;

-- =====================================================================
-- 7. PAGOS Y COMPROBANTES
-- =====================================================================

-- Una venta puede tener varios pagos (cuenta dividida, pago mixto).
-- id_caja: caja donde entró el dinero (NULL en pagos online).
CREATE TABLE pago (
  id_pago          INT NOT NULL AUTO_INCREMENT,
  id_venta         INT NOT NULL,
  id_metodo        INT NOT NULL,
  id_caja          INT DEFAULT NULL,
  monto            DECIMAL(10,2) NOT NULL,
  monto_recibido   DECIMAL(10,2) DEFAULT NULL,           -- efectivo entregado (vuelto = recibido - monto)
  estado           ENUM('pendiente','confirmado','rechazado','reembolsado') NOT NULL DEFAULT 'pendiente',
  codigo_operacion VARCHAR(30) DEFAULT NULL,             -- Yape/Plin/tarjeta
  motivo_rechazo   VARCHAR(100) DEFAULT NULL,
  id_empleado      INT DEFAULT NULL,
  fecha_pago       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_revision   DATETIME DEFAULT NULL,
  PRIMARY KEY (id_pago),
  UNIQUE KEY uq_pago_operacion (id_metodo, codigo_operacion),   -- impide reutilizar un mismo voucher
  KEY idx_pago_estado (estado),
  KEY fk_pago_venta (id_venta),
  KEY fk_pago_caja (id_caja),
  KEY fk_pago_empleado (id_empleado),
  CONSTRAINT fk_pago_venta    FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
  CONSTRAINT fk_pago_metodo   FOREIGN KEY (id_metodo) REFERENCES metodo_pago (id_metodo),
  CONSTRAINT fk_pago_caja     FOREIGN KEY (id_caja) REFERENCES caja (id_caja),
  CONSTRAINT fk_pago_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
  CONSTRAINT chk_pago_monto CHECK (monto > 0),
  CONSTRAINT chk_pago_recibido CHECK (monto_recibido IS NULL OR monto_recibido >= monto),
  CONSTRAINT chk_pago_rechazo CHECK (estado <> 'rechazado' OR motivo_rechazo IS NOT NULL),
  CONSTRAINT chk_pago_revision CHECK (estado = 'pendiente' OR (id_empleado IS NOT NULL AND fecha_revision IS NOT NULL))
) ENGINE=InnoDB;

-- Comprobante = foto fiscal de la venta (los datos del receptor y los
-- montos se copian y no cambian aunque luego se edite el cliente).
-- Se emite con sp_emitir_comprobante.
CREATE TABLE comprobante (
  id_comprobante    INT NOT NULL AUTO_INCREMENT,
  id_venta          INT NOT NULL,
  tipo_comprobante  ENUM('boleta','factura') NOT NULL,
  id_serie          INT NOT NULL,
  numero            INT NOT NULL,
  fecha_emision     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  receptor_documento VARCHAR(15) DEFAULT NULL,
  receptor_nombre   VARCHAR(150) DEFAULT NULL,
  tasa_igv          DECIMAL(5,2) NOT NULL,
  base_imponible    DECIMAL(10,2) NOT NULL,
  igv               DECIMAL(10,2) NOT NULL,
  total             DECIMAL(10,2) NOT NULL,
  estado            ENUM('emitido','anulado') NOT NULL DEFAULT 'emitido',
  motivo_anulacion  VARCHAR(150) DEFAULT NULL,
  id_empleado       INT NOT NULL,
  PRIMARY KEY (id_comprobante),
  UNIQUE KEY uq_comprobante_venta (id_venta),
  UNIQUE KEY uq_comprobante_serie_numero (id_serie, numero),
  KEY fk_comprobante_empleado (id_empleado),
  CONSTRAINT fk_comprobante_venta    FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
  CONSTRAINT fk_comprobante_serie    FOREIGN KEY (id_serie, tipo_comprobante) REFERENCES serie_comprobante (id_serie, tipo_comprobante),
  CONSTRAINT fk_comprobante_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
  CONSTRAINT chk_comprobante_total CHECK (total = base_imponible + igv),
  CONSTRAINT chk_comprobante_factura CHECK (tipo_comprobante = 'boleta'
      OR (receptor_documento IS NOT NULL AND receptor_documento REGEXP '^[0-9]{11}$' AND receptor_nombre IS NOT NULL)),
  CONSTRAINT chk_comprobante_anulacion CHECK (estado <> 'anulado' OR motivo_anulacion IS NOT NULL)
) ENGINE=InnoDB;

-- =====================================================================
-- 8. INCIDENTES: ROBOS Y PÉRDIDAS
-- =====================================================================
-- Cubre: faltante de caja, robo de efectivo o de producto, cliente que se
-- va sin pagar, delivery no entregado / repartidor que no rinde, mermas.
-- Un incidente de 'cliente_sin_pago' o 'delivery_no_entregado' marca la
-- venta como 'perdida' (trigger).
CREATE TABLE incidente (
  id_incidente            INT NOT NULL AUTO_INCREMENT,
  tipo                    ENUM('robo_efectivo','robo_producto','cliente_sin_pago','delivery_no_entregado','faltante_caja','merma','otro') NOT NULL,
  id_venta                INT DEFAULT NULL,
  id_caja                 INT DEFAULT NULL,
  id_producto             INT DEFAULT NULL,
  cantidad                INT DEFAULT NULL,
  id_empleado_reporta     INT NOT NULL,
  id_empleado_involucrado INT DEFAULT NULL,
  id_repartidor           INT DEFAULT NULL,
  monto_perdida           DECIMAL(10,2) NOT NULL,
  monto_recuperado        DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  descripcion             VARCHAR(255) NOT NULL,
  fecha_incidente         DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  estado                  ENUM('reportado','en_investigacion','confirmado','descartado','recuperado') NOT NULL DEFAULT 'reportado',
  id_empleado_resuelve    INT DEFAULT NULL,
  fecha_resolucion        DATETIME DEFAULT NULL,
  resolucion              VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id_incidente),
  KEY idx_incidente_estado (estado),
  KEY idx_incidente_fecha (fecha_incidente),
  KEY fk_inc_venta (id_venta),
  KEY fk_inc_caja (id_caja),
  KEY fk_inc_producto (id_producto),
  KEY fk_inc_reporta (id_empleado_reporta),
  KEY fk_inc_involucrado (id_empleado_involucrado),
  KEY fk_inc_repartidor (id_repartidor),
  KEY fk_inc_resuelve (id_empleado_resuelve),
  CONSTRAINT fk_inc_venta       FOREIGN KEY (id_venta) REFERENCES venta (id_venta),
  CONSTRAINT fk_inc_caja        FOREIGN KEY (id_caja) REFERENCES caja (id_caja),
  CONSTRAINT fk_inc_producto    FOREIGN KEY (id_producto) REFERENCES producto (id_producto),
  CONSTRAINT fk_inc_reporta     FOREIGN KEY (id_empleado_reporta) REFERENCES empleado (id_empleado),
  CONSTRAINT fk_inc_involucrado FOREIGN KEY (id_empleado_involucrado) REFERENCES empleado (id_empleado),
  CONSTRAINT fk_inc_repartidor  FOREIGN KEY (id_repartidor) REFERENCES repartidor (id_repartidor),
  CONSTRAINT fk_inc_resuelve    FOREIGN KEY (id_empleado_resuelve) REFERENCES empleado (id_empleado),
  CONSTRAINT chk_inc_montos CHECK (monto_perdida >= 0 AND monto_recuperado >= 0 AND monto_recuperado <= monto_perdida),
  CONSTRAINT chk_inc_cantidad CHECK (cantidad IS NULL OR cantidad > 0),
  CONSTRAINT chk_inc_venta CHECK (tipo NOT IN ('cliente_sin_pago','delivery_no_entregado') OR id_venta IS NOT NULL),
  CONSTRAINT chk_inc_caja CHECK (tipo <> 'faltante_caja' OR id_caja IS NOT NULL),
  CONSTRAINT chk_inc_resolucion CHECK (estado IN ('reportado','en_investigacion')
      OR (id_empleado_resuelve IS NOT NULL AND fecha_resolucion IS NOT NULL))
) ENGINE=InnoDB;

-- =====================================================================
-- 9. BITÁCORA (auditoría)
-- =====================================================================

CREATE TABLE bitacora (
  id_bitacora INT NOT NULL AUTO_INCREMENT,
  id_empleado INT NOT NULL,
  id_venta    INT DEFAULT NULL,
  tipo_accion ENUM('venta','cancelacion','descuento','apertura_caja','cierre_caja','cambio_precio','pedido_listo','entrega',
                   'pago_confirmado','pago_rechazado','reembolso','emision_comprobante','anulacion_comprobante',
                   'incidente','reserva','otro') NOT NULL,
  descripcion VARCHAR(255) DEFAULT NULL,
  fecha       DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id_bitacora),
  KEY idx_bitacora_fecha (fecha),
  KEY fk_bitacora_empleado (id_empleado),
  KEY fk_bitacora_venta (id_venta),
  CONSTRAINT fk_bitacora_empleado FOREIGN KEY (id_empleado) REFERENCES empleado (id_empleado),
  CONSTRAINT fk_bitacora_venta FOREIGN KEY (id_venta) REFERENCES venta (id_venta)
) ENGINE=InnoDB;

-- =====================================================================
-- 10. DATOS INICIALES
-- =====================================================================

INSERT INTO metodo_pago (nombre, es_efectivo) VALUES
  ('Efectivo', 1), ('Yape', 0), ('Plin', 0), ('Tarjeta', 0);

INSERT INTO serie_comprobante (tipo_comprobante, serie) VALUES
  ('boleta', 'B001'), ('factura', 'F001');

-- =====================================================================
-- 11. VISTAS
-- =====================================================================

CREATE VIEW v_mesas_libres AS
SELECT id_mesa, numero, capacidad
FROM mesa
WHERE estado = 'libre';

-- Cocina: pedidos por preparar. Los combos se expanden con su contenido
-- y los deliveries programados para otro día no aparecen hasta su fecha.
CREATE VIEW v_pedidos_cocina AS
SELECT v.id_venta, v.tipo_venta, m.numero AS mesa, v.estado, v.fecha_venta AS fecha,
       GROUP_CONCAT(
         CONCAT(dv.cantidad, ' x ',
                COALESCE(p.nombre,
                         CONCAT(c.nombre, ' [',
                                (SELECT GROUP_CONCAT(CONCAT(cp.cantidad, ' x ', pp.nombre) ORDER BY pp.nombre SEPARATOR ', ')
                                   FROM combo_producto cp
                                   JOIN producto pp ON pp.id_producto = cp.id_producto
                                  WHERE cp.id_combo = c.id_combo), ']')),
                IF(dv.observaciones IS NULL, '', CONCAT(' (', dv.observaciones, ')')))
         ORDER BY dv.id_detalle SEPARATOR ' | ') AS pedido
FROM venta v
JOIN detalle_venta dv ON dv.id_venta = v.id_venta
LEFT JOIN producto p ON p.id_producto = dv.id_producto
LEFT JOIN combo c ON c.id_combo = dv.id_combo
LEFT JOIN mesa m ON m.id_mesa = v.id_mesa
LEFT JOIN delivery d ON d.id_venta = v.id_venta
WHERE v.estado IN ('pendiente','en_proceso')
  AND (d.id_delivery IS NULL OR d.fecha_entrega_programada <= CURRENT_DATE)
GROUP BY v.id_venta, v.tipo_venta, m.numero, v.estado, v.fecha_venta;

CREATE VIEW v_pedidos_listos AS
SELECT v.id_venta, v.tipo_venta, m.numero AS mesa, e.nombre AS mesero, v.hora_listo
FROM venta v
LEFT JOIN mesa m ON m.id_mesa = v.id_mesa
LEFT JOIN empleado e ON e.id_empleado = v.id_empleado
WHERE v.estado = 'listo';

-- Reporte de ventas cerradas por día, con IGV desglosado.
CREATE VIEW v_ventas_diarias AS
SELECT DATE(fecha_venta) AS dia, tipo_venta,
       COUNT(*) AS num_ventas,
       SUM(base_imponible) AS base_imponible,
       SUM(igv) AS igv,
       SUM(total) AS total
FROM venta
WHERE estado = 'finalizada'
GROUP BY DATE(fecha_venta), tipo_venta;

-- Estado de cada caja: efectivo cobrado y diferencia al cierre.
CREATE VIEW v_resumen_caja AS
SELECT c.id_caja, e.nombre AS cajero, c.estado, c.fecha_apertura, c.fecha_cierre,
       c.monto_inicial,
       COALESCE((SELECT SUM(p.monto)
                   FROM pago p
                   JOIN metodo_pago mp ON mp.id_metodo = p.id_metodo
                  WHERE p.id_caja = c.id_caja AND p.estado = 'confirmado' AND mp.es_efectivo = 1), 0) AS efectivo_cobrado,
       c.monto_esperado, c.monto_final, c.diferencia
FROM caja c
JOIN empleado e ON e.id_empleado = c.id_empleado;

CREATE VIEW v_incidentes_abiertos AS
SELECT i.id_incidente, i.tipo, i.fecha_incidente, i.monto_perdida, i.estado,
       r.nombre AS reportado_por, inv.nombre AS empleado_involucrado,
       i.id_venta, i.id_caja, i.descripcion
FROM incidente i
JOIN empleado r ON r.id_empleado = i.id_empleado_reporta
LEFT JOIN empleado inv ON inv.id_empleado = i.id_empleado_involucrado
WHERE i.estado IN ('reportado','en_investigacion');

-- =====================================================================
-- 12. TRIGGERS
-- =====================================================================

DELIMITER $$

-- Mantiene venta.monto_items = suma del detalle.
CREATE TRIGGER trg_detalle_venta_ai AFTER INSERT ON detalle_venta FOR EACH ROW
BEGIN
  UPDATE venta
     SET monto_items = (SELECT COALESCE(SUM(subtotal), 0) FROM detalle_venta WHERE id_venta = NEW.id_venta)
   WHERE id_venta = NEW.id_venta;
END$$

CREATE TRIGGER trg_detalle_venta_au AFTER UPDATE ON detalle_venta FOR EACH ROW
BEGIN
  UPDATE venta
     SET monto_items = (SELECT COALESCE(SUM(subtotal), 0) FROM detalle_venta WHERE id_venta = NEW.id_venta)
   WHERE id_venta = NEW.id_venta;
  IF OLD.id_venta <> NEW.id_venta THEN
    UPDATE venta
       SET monto_items = (SELECT COALESCE(SUM(subtotal), 0) FROM detalle_venta WHERE id_venta = OLD.id_venta)
     WHERE id_venta = OLD.id_venta;
  END IF;
END$$

CREATE TRIGGER trg_detalle_venta_ad AFTER DELETE ON detalle_venta FOR EACH ROW
BEGIN
  UPDATE venta
     SET monto_items = (SELECT COALESCE(SUM(subtotal), 0) FROM detalle_venta WHERE id_venta = OLD.id_venta)
   WHERE id_venta = OLD.id_venta;
END$$

-- La mesa se ocupa al abrir una venta presencial y se libera cuando la
-- venta llega a un estado terminal (finalizada, cancelado, perdida).
CREATE TRIGGER trg_venta_ai AFTER INSERT ON venta FOR EACH ROW
BEGIN
  IF NEW.id_mesa IS NOT NULL AND NEW.estado NOT IN ('finalizada','cancelado','perdida') THEN
    UPDATE mesa SET estado = 'ocupada' WHERE id_mesa = NEW.id_mesa AND estado IN ('libre','reservada');
  END IF;
END$$

CREATE TRIGGER trg_venta_au AFTER UPDATE ON venta FOR EACH ROW
BEGIN
  IF NEW.id_mesa IS NOT NULL
     AND OLD.estado <> NEW.estado
     AND NEW.estado IN ('finalizada','cancelado','perdida') THEN
    UPDATE mesa
       SET estado = 'libre'
     WHERE id_mesa = NEW.id_mesa
       AND estado = 'ocupada'
       AND NOT EXISTS (SELECT 1 FROM venta
                        WHERE id_mesa = NEW.id_mesa
                          AND id_venta <> NEW.id_venta
                          AND estado NOT IN ('finalizada','cancelado','perdida'));
  END IF;
END$$

-- Cliente que no pagó o delivery no entregado => la venta queda 'perdida'.
CREATE TRIGGER trg_incidente_ai AFTER INSERT ON incidente FOR EACH ROW
BEGIN
  IF NEW.tipo IN ('cliente_sin_pago','delivery_no_entregado') AND NEW.id_venta IS NOT NULL THEN
    UPDATE venta SET estado = 'perdida'
     WHERE id_venta = NEW.id_venta AND estado NOT IN ('finalizada','cancelado','perdida');
  END IF;
  INSERT INTO bitacora (id_empleado, id_venta, tipo_accion, descripcion)
  VALUES (NEW.id_empleado_reporta, NEW.id_venta, 'incidente',
          CONCAT('Incidente #', NEW.id_incidente, ' (', NEW.tipo, '), pérdida S/ ', NEW.monto_perdida));
END$$

-- =====================================================================
-- 13. PROCEDIMIENTOS
-- =====================================================================

-- Emite boleta o factura para una venta: asigna el correlativo con la serie
-- bloqueada, copia montos y datos del receptor y deja registro en bitácora.
-- La FACTURA exige un cliente EMPRESA con RUC.
CREATE PROCEDURE sp_emitir_comprobante(
  IN  p_id_venta    INT,
  IN  p_tipo        VARCHAR(10),
  IN  p_id_empleado INT,
  OUT p_id_comprobante INT)
BEGIN
  DECLARE v_estado       VARCHAR(20) DEFAULT NULL;
  DECLARE v_id_cliente   INT DEFAULT NULL;
  DECLARE v_tasa         DECIMAL(5,2) DEFAULT NULL;
  DECLARE v_base         DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_igv          DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_total        DECIMAL(10,2) DEFAULT NULL;
  DECLARE v_tipo_cliente VARCHAR(10) DEFAULT NULL;
  DECLARE v_documento    VARCHAR(15) DEFAULT NULL;
  DECLARE v_nombre       VARCHAR(150) DEFAULT NULL;
  DECLARE v_id_serie     INT DEFAULT NULL;
  DECLARE v_numero       INT DEFAULT NULL;

  IF p_tipo NOT IN ('boleta','factura') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de comprobante inválido (boleta o factura)';
  END IF;

  SELECT estado, id_cliente, tasa_igv, base_imponible, igv, total
    INTO v_estado, v_id_cliente, v_tasa, v_base, v_igv, v_total
    FROM venta WHERE id_venta = p_id_venta FOR UPDATE;

  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no existe';
  END IF;
  IF v_estado IN ('cancelado','perdida') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se emite comprobante para una venta cancelada o perdida';
  END IF;
  IF v_total <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La venta no tiene monto para facturar';
  END IF;

  IF v_id_cliente IS NOT NULL THEN
    SELECT tipo_cliente, numero_documento, nombre
      INTO v_tipo_cliente, v_documento, v_nombre
      FROM cliente WHERE id_cliente = v_id_cliente;
  END IF;

  IF p_tipo = 'factura' AND (v_tipo_cliente IS NULL OR v_tipo_cliente <> 'empresa') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La factura requiere un cliente de tipo empresa con RUC';
  END IF;

  SELECT id_serie INTO v_id_serie
    FROM serie_comprobante
   WHERE tipo_comprobante = p_tipo AND activo = 1
   ORDER BY id_serie LIMIT 1 FOR UPDATE;

  IF v_id_serie IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay una serie activa para ese tipo de comprobante';
  END IF;

  UPDATE serie_comprobante SET ultimo_numero = ultimo_numero + 1 WHERE id_serie = v_id_serie;
  SELECT ultimo_numero INTO v_numero FROM serie_comprobante WHERE id_serie = v_id_serie;

  INSERT INTO comprobante (id_venta, tipo_comprobante, id_serie, numero, receptor_documento, receptor_nombre,
                           tasa_igv, base_imponible, igv, total, id_empleado)
  VALUES (p_id_venta, p_tipo, v_id_serie, v_numero, v_documento, v_nombre,
          v_tasa, v_base, v_igv, v_total, p_id_empleado);

  SET p_id_comprobante = LAST_INSERT_ID();

  INSERT INTO bitacora (id_empleado, id_venta, tipo_accion, descripcion)
  VALUES (p_id_empleado, p_id_venta, 'emision_comprobante', CONCAT(p_tipo, ' emitida, correlativo ', v_numero));
END$$

-- Cierra una caja: calcula el efectivo esperado (fondo + cobros en efectivo
-- confirmados) y lo compara con lo contado. Si falta dinero, registra
-- automáticamente un incidente 'faltante_caja'.
CREATE PROCEDURE sp_cerrar_caja(
  IN p_id_caja        INT,
  IN p_monto_contado  DECIMAL(10,2),
  IN p_id_empleado    INT)
BEGIN
  DECLARE v_estado   VARCHAR(10) DEFAULT NULL;
  DECLARE v_inicial  DECIMAL(10,2) DEFAULT 0;
  DECLARE v_dueno    INT DEFAULT NULL;
  DECLARE v_efectivo DECIMAL(10,2) DEFAULT 0;
  DECLARE v_esperado DECIMAL(10,2) DEFAULT 0;

  SELECT estado, monto_inicial, id_empleado INTO v_estado, v_inicial, v_dueno
    FROM caja WHERE id_caja = p_id_caja FOR UPDATE;

  IF v_estado IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La caja no existe';
  END IF;
  IF v_estado <> 'abierta' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La caja ya está cerrada';
  END IF;
  IF p_monto_contado < 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El monto contado no puede ser negativo';
  END IF;

  SELECT COALESCE(SUM(p.monto), 0) INTO v_efectivo
    FROM pago p
    JOIN metodo_pago mp ON mp.id_metodo = p.id_metodo
   WHERE p.id_caja = p_id_caja AND p.estado = 'confirmado' AND mp.es_efectivo = 1;

  SET v_esperado = v_inicial + v_efectivo;

  UPDATE caja
     SET estado = 'cerrada', fecha_cierre = NOW(),
         monto_esperado = v_esperado, monto_final = p_monto_contado
   WHERE id_caja = p_id_caja;

  INSERT INTO bitacora (id_empleado, tipo_accion, descripcion)
  VALUES (p_id_empleado, 'cierre_caja',
          CONCAT('Caja #', p_id_caja, ': esperado S/ ', v_esperado, ', contado S/ ', p_monto_contado));

  IF p_monto_contado < v_esperado THEN
    INSERT INTO incidente (tipo, id_caja, id_empleado_reporta, id_empleado_involucrado, monto_perdida, descripcion)
    VALUES ('faltante_caja', p_id_caja, p_id_empleado, v_dueno, v_esperado - p_monto_contado,
            CONCAT('Faltante detectado al cerrar la caja #', p_id_caja));
  END IF;
END$$

DELIMITER ;
