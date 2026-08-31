-- =====================================================================
-- Projeto DimDim - DDL do banco de dados
-- Banco: MySQL 8.0
-- =====================================================================

CREATE DATABASE IF NOT EXISTS dimdim
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE dimdim;

-- ---------------------------------------------------------------------
-- Tabela: cliente
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS cliente (

    id_cliente  BIGINT          NOT NULL AUTO_INCREMENT,
    nm_cliente  VARCHAR(100)    NOT NULL,
    nr_cpf      VARCHAR(11)     NOT NULL,
    ds_email    VARCHAR(120)    NOT NULL,
    vl_saldo    DECIMAL(12,2)   NOT NULL DEFAULT 0.00,

    CONSTRAINT pk_cliente        PRIMARY KEY (id_cliente),
    CONSTRAINT uk_cliente_cpf    UNIQUE (nr_cpf),
    CONSTRAINT ck_cliente_saldo  CHECK (vl_saldo >= 0)

) ENGINE = InnoDB;

-- ---------------------------------------------------------------------
-- Carga inicial (para o SELECT do video ja mostrar dados)
-- ---------------------------------------------------------------------
INSERT INTO cliente (nm_cliente, nr_cpf, ds_email, vl_saldo) VALUES
    ('Steves Jobs',       '11122233344', 'steves@dimdim.com.br',  15000.00),
    ('Maria Fernandes',   '55566677788', 'maria@dimdim.com.br',    2350.75);
