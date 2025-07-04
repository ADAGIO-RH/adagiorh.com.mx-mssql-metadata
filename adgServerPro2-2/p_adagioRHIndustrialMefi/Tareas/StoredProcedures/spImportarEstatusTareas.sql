USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/****************************************************************************************************  
** Descripción		: Este sp se encarga de importar masivamente los 'estatus tareas'
** Autor			: Jose Vargas 
** Email			: jvargas@adagio.com.mx 
** FechaCreacion	: 2024-01-30 
** Paremetros		:               
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.
        Nota: @IDTipoTablero se incluye dentro de la variable @dtEstatusTareas. 
** DataTypes Relacionados:  
    [Tareas].[dtCatEstatusTareas]
**************************************************************************************************** 
HISTORIAL DE CAMBIOS 
Fecha(yyyy-mm-dd)	Autor				Comentario 
------------------- ------------------- ------------------------------------------------------------         
?                   ?               ?                
***************************************************************************************************/
CREATE proc [Tareas].[spImportarEstatusTareas](
    @dtEstatusTareas [Tareas].[dtCatEstatusTareas] readonly, 
    @IDReferencia int,   
    @IDUsuario int
)
as
begin
    BEGIN
        BEGIN TRY             
            BEGIN TRAN TranCatEstatusTareas			                                  
            SET IDENTITY_INSERT [Tareas].[tblCatEstatusTareas]  OFF                                                  
            MERGE [Tareas].[tblCatEstatusTareas] AS TARGET                 
                USING @dtEstatusTareas as SOURCE    on TARGET.IDTipoTablero = SOURCE.IDTipoTablero and TARGET.IDReferencia=@IDReferencia and TARGET.IDEstatusTarea= SOURCE.IDEstatusTarea  
            WHEN MATCHED  THEN                     
                UPDATE set TARGET.Icon = SOURCE.Icon,TARGET.Titulo = SOURCE.Titulo,TARGET.Descripcion = SOURCE.Descripcion
            WHEN NOT MATCHED BY TARGET THEN                     
                INSERT(IDTipoTablero,IDReferencia,Icon,Titulo,Descripcion,IsDefault,IsEnd,Orden)   
                VALUES(SOURCE.IDTipoTablero,@IDReferencia,SOURCE.Icon ,SOURCE.Titulo,SOURCE.Descripcion,SOURCE.IsDefault,SOURCE.IsEnd,SOURCE.Orden);                
            --  WHEN NOT MATCHED BY SOURCE AND TARGET.IDTablero = @IDTablero  and TARGET.IDEstatusTarea not in (select IDEstatusTarea from @dtEstatusTareas)   THEN                  
            --  DELETE                 ;                                  
            SET IDENTITY_INSERT [Tareas].[tblCatEstatusTareas]  ON
            COMMIT TRAN TranCatEstatusTareas
        END TRY     
        BEGIN CATCH
            ROLLBACK TRAN TranCatEstatusTareas
            select ERROR_MESSAGE() as Error
        END CATCH     
    END;  
end
GO
