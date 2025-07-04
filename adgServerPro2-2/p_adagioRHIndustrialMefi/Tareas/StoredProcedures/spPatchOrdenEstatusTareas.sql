USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de actualizar el orden de los 'estatus tareas'.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:      
    @IDEstatusTarea
        IDEstatusTarea de la tarea que se ha movido.
    @NuevoOrden
        Este es el orden asignado al 'estatus tarea'.
    @IDReferencia y @IDTipoTablero
        Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.
        @IDTipoTablero hace se relaciona con '[Tareas].[tblCatTipoTablero]'             
    @IDUsuario
        Usuarios que ejecuto la acción.    
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spPatchOrdenEstatusTareas](    
    @IDEstatusTarea int ,    
    @NuevoOrden int,
    @IDTipoTablero int ,        
    @IDReferencia int ,        
    @IDUsuario int
) as
begin    
            
        
    declare @OrdenActual int 
    DECLARE @TablaTemporal TABLE (IDEstatusTarea INT, Orden INT);
                    
    SELECT @OrdenActual=Orden from Tareas.tblCatEstatusTareas where IDEstatusTarea=@IDEstatusTarea     
    
    IF( @NuevoOrden>@OrdenActual  )
    BEGIN
        
        UPDATE Tareas.tblCatEstatusTareas 
            SET Orden = Orden -1
        WHERE Orden >=@OrdenActual  AND orden <= @NuevoOrden   
            and IDTipoTablero= @IDTipoTablero and IDReferencia=@IDReferencia;
    END ELSE
    BEGIN        
        UPDATE Tareas.tblCatEstatusTareas 
            SET Orden = Orden +1 
        WHERE  orden >= @NuevoOrden   AND  Orden <=@OrdenActual     
            and IDTipoTablero= @IDTipoTablero and IDReferencia=@IDReferencia;
    END
    
    UPDATE Tareas.tblCatEstatusTareas 
    SET Orden = @NuevoOrden     
    WHERE IDEstatusTarea = @IDEstatusTarea;

     

    SELECT IDEstatusTarea,Orden FROM @TablaTemporal;
end
GO
