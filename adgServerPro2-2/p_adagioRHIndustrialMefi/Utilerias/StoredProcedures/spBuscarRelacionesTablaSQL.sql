USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Busca Relaciones de tablas sql
** Autor			: Javier Peña
** Email			: jpena@adagio.com.mx
** FechaCreacion	: 2023-12-06
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor			Comentario
------------------- ------------------- ------------------------------------------------------------

***************************************************************************************************/
CREATE proc [Utilerias].[spBuscarRelacionesTablaSQL](
	@Schema varchar(50)
   ,@Tabla varchar(200)
	
    
) as

    SELECT 
        fk.name AS constraint_name,
        CONCAT(SCHEMA_NAME(tp.schema_id), '.',  tp.name) AS [table],        
        col.name AS column_name,
        CONCAT(SCHEMA_NAME(ref.schema_id), '.',  ref.name) AS referenced_table,        
        ref_col.name AS referenced_column_name
    FROM 
        sys.foreign_keys fk
    INNER JOIN 
        sys.tables tp ON fk.parent_object_id = tp.object_id
    INNER JOIN 
        sys.foreign_key_columns fkc ON fkc.constraint_object_id = fk.object_id
    INNER JOIN 
        sys.columns col ON col.column_id = fkc.parent_column_id AND col.object_id = tp.object_id
    INNER JOIN 
        sys.tables ref ON fk.referenced_object_id = ref.object_id
    INNER JOIN 
        sys.columns ref_col ON ref_col.column_id = fkc.referenced_column_id AND ref_col.object_id = ref.object_id
    WHERE 
        tp.name = @Tabla
        AND SCHEMA_NAME(tp.schema_id) = @Schema;
GO
