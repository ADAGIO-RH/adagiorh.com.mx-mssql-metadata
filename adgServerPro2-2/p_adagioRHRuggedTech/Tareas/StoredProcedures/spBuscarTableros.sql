USE [p_adagioRHRuggedTech]
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
CREATE proc [Tareas].[spBuscarTableros](    	
    @IDTablero int ,
    @ValidarPermisoUsuario bit ,
	@IDUsuario int
) as
begin

    SELECT distinct t.IDTablero ,t.Descripcion,t.Titulo,t.FechaRegistro,t.Style  from Tareas.tblTablero t
    INNER JOIN  Tareas.tblTableroUsuarios tu on tu.IDReferencia=t.IDTablero and ( (@ValidarPermisoUsuario =1 and tu.IDUsuario=@IDUsuario) or (@ValidarPermisoUsuario=0) ) and tu.IDTipoTablero=1
    WHERE isnull(@IDTablero,0) =0 or T.IDTablero=@IDTablero
     
end
GO
