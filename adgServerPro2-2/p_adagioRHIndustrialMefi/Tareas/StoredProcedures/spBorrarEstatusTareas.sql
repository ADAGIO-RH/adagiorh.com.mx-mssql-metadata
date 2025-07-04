USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de eliminar 'Estatus Tarea' junto con sus dependencias como tareas.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:           
    @IDEstatusTarea
        IDEstatusTarea que se va a eliminar.
    @IDUsuario 
        IDUsuario que ejecuto la acción
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBorrarEstatusTareas](
    @IDEstatusTarea int,
    @IDUsuario int
) as
begin   
    declare @totalTareas int 
    select @totalTareas=count(*)  from Tareas.tblTareas where IDEstatusTarea=@IDEstatusTarea
    if(@totalTareas > 0 )
    begin
        delete from Tareas.tblTareas where IDEstatusTarea=@IDEstatusTarea
    end 
    DELETE FROM Tareas.tblCatEstatusTareas  where IDEstatusTarea=@IDEstatusTarea

end
GO
