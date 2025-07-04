USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: ?
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:              
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBorrarTareas](    
    @IDTarea int ,     	
    @IDUsuario int
) as
begin    
    
    
    DECLARE @IDTipoTablero INT 
    DECLARE @IDReferencia int 
    DECLARE @IDEstatusTarea int 
    DECLARE @Orden int 

    select 
        @IDTipoTablero=IDTipoTablero ,
        @IDReferencia=IDReferencia,
        @IDEstatusTarea=IDEstatusTarea,
        @Orden =Orden 
    from Tareas.tblTareas
    where IDTarea =@IDTarea

    --     select 
    --      @IDTipoTablero,
    --      @IDReferencia,
    --      @IDEstatusTarea,
    --      @Orden

    -- select * from Tareas.tblTareas 
    --  where  IDTipoTablero=@IDTipoTablero
    --     AND IDReferencia=@IDReferencia
    --     and IDEstatusTarea=@IDEstatusTarea
    --     AND Orden>@Orden

    UPDATE Tareas.tblTareas 
    set Orden= (Orden-1)
    where  IDTipoTablero=@IDTipoTablero
        AND IDReferencia=@IDReferencia
        and IDEstatusTarea=@IDEstatusTarea
        AND Orden>@Orden
    

    Delete from Tareas.tblTareas where IDTarea=@IDTarea

end
GO
