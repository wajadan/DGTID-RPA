CREATE TABLE TAB_CONSOLIDADO_MACRO (
    ID NUMBER GENERATED ALWAYS AS IDENTITY, -- Genera un ID único para cada fila automáticamente
    INDICADOR VARCHAR2(50) NOT NULL,        -- 'PRECIO_PETROLEO_WTI', 'RIESGO_PAIS', etc.
    FECHA_EXTRACCION DATE NOT NULL,         -- Cuándo operó el robot (Trazabilidad)
    ESTADO VARCHAR2(15) NOT NULL,           -- 'COMPLETO' o 'INCOMPLETO'
    NECESITA_RESPALDO NUMBER(1) NOT NULL,   -- 0 = False, 1 = True
    DETALLE_ERROR VARCHAR2(4000),           -- Mensaje si algo falla
    DATOS_JSON JSON,                        -- Documento NoSQL nativo de Oracle 26ai
    CONSTRAINT PK_CONSOLIDADO_MACRO PRIMARY KEY (ID)
);

-- 1. Agregamos la columna de la fecha macroeconómica al nivel raíz
ALTER TABLE TAB_CONSOLIDADO_MACRO ADD FECHA_FISCAL VARCHAR2(50);

-- 2. Creamos el escudo de unicidad absoluto: No se puede repetir el mismo indicador en la misma fecha fiscal
ALTER TABLE TAB_CONSOLIDADO_MACRO ADD CONSTRAINT UQ_INDICADOR_FECHA_FISCAL UNIQUE (INDICADOR, FECHA_FISCAL);

/*******************************************************************************
   DICCIONARIO DE TRAZABILIDAD - REPOSITORIO DE INDICADORES MACROECONÓMICOS BCE
   PROYECTO: AUTOMATIZACIÓN DE EXTRACTORES (DIARIO, MENSUAL, ANUAL)
********************************************************************************

1. FLUJO: SECTOR EXTERNO (DIARIO)
   - INDICADOR: 'PRECIO_PETROLEO_WTI'
   - RUTA LÓGICA VIRTUAL: "BCE/SECTOR_EXTERNO/PETROLEO_WTI"
   - ESQUEMA DATOS_JSON: {"fecha_fiscal", "valor", "fuente", "ruta_logica"}

2. FLUJO: PUBLICACIONES (DIARIO)
   - INDICADOR: 'RIESGO_PAIS'
   - RUTA LÓGICA VIRTUAL: "BCE/PUBLICACIONES_GENERALES/RIESGO_PAIS"
   - ESQUEMA DATOS_JSON: {"fecha_fiscal", "valor", "indicador_limpio", "medida", "fuente", "ruta_logica"}

3. FLUJO: SECTOR REAL (MENSUAL)
   - INDICADOR: 'EXPECTATIVAS_EMPRESARIALES'
   - RUTA LÓGICA VIRTUAL: "BCE/SECTOR_REAL/EXPECTATIVAS_EMPRESARIALES"
   - ESQUEMA DATOS_JSON: {"fecha_fiscal", "iee_global", "comercio", "construccion", "manufactura", "servicios", "fuente", "ruta_logica"}

4. FLUJO: CUENTAS NACIONALES (ANUAL)
   - INDICADORES DISPONIBLES:
     * 'PIB_REAL_PER_CAPITA'     ➔ Ruta: "BCE/CUENTAS_NACIONALES/PIB_PC_REAL"
     * 'PIB_NOMINAL_PER_CAPITA'  ➔ Ruta: "BCE/CUENTAS_NACIONALES/PIB_PC_NOMINAL"
     * 'MEI_EMPLEO_SECTORIAL'    ➔ Ruta: "BCE/CUENTAS_NACIONALES/MEI_TOTAL_EMPLEO"
     * 'MEI_TOTAL_EMPLEO_NUR'    ➔ Ruta: "BCE/CUENTAS_NACIONALES/MEI_TOTAL_EMPLEO" (Registro de Cierre)
     * 'MEI_VAB_SECTORIAL'       ➔ Ruta: "BCE/CUENTAS_NACIONALES/MEI_VAB"
     * 'MEI_VAB_TOTAL'           ➔ Ruta: "BCE/CUENTAS_NACIONALES/MEI_VAB" (Registro de Cierre)
   - ESQUEMA DATOS_JSON GENERAL: {"fecha_fiscal", "valores_anuales": {...}, "fuente", "ruta_logica"}

*******************************************************************************/