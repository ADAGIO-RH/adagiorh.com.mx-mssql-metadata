USE [p_adagioRHMotiDigital]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: Este sp se encarga de buscar los 'estatus tareas'.
** Autor			: Jose Vargas
** Email			: jvargas@adagio.com.mx
** FechaCreacion	: 2024-01-30
** Paremetros		:      
    Este sp puede realizar busqueda por los siguientes filtros:
        * @IDEstatusTarea (Tareas.tblCatEstatusTareas)        
        * @IDReferencia y @IDTipoTablero (Estos datos juntos hacen referencia a un 'Tablero'. La función del `Tablero` es agrupar todo un conjunto de tareas.)

    @IDUsuario
        Usuarios que ejecuto la acción.            
** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
        ?                   ?               ?               
***************************************************************************************************/
CREATE proc [Tareas].[spBuscarEstatusTareas](    	
    @IDTipoTablero int ,
    @IDReferencia int ,
    @IDEstatusTarea int =null,
	@IDUsuario int
) as
begin

    select [IDEstatusTarea],
        [IDTipoTablero],
        [IDReferencia],
        [Icon],
        [Titulo],
        [Descripcion],
        Orden,
        isnull(IsEnd,0) as IsEnd,
        isnull(isDefault,0) as IsDefault
        
     from Tareas.tblCatEstatusTareas
    where 
     ((IDTipoTablero=@IDTipoTablero and IDReferencia=@IDReferencia ) or ( isnull(@IDReferencia,0)=0  and isnull(@IDTipoTablero,0)=0 ))   and
     (IDEstatusTarea=@IDEstatusTarea or isnull(@IDEstatusTarea,0)=0 ) 

    order by Orden
end
GO
