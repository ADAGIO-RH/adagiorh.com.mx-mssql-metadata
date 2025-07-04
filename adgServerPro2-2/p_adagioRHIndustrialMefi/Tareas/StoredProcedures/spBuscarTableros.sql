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
CREATE proc [Tareas].[spBuscarTableros](    	
    @IDTablero int ,
    @ValidarPermisoUsuario bit ,
	@IDUsuario int
) as
begin

    SELECT distinct t.IDTablero ,t.Descripcion,t.Titulo,t.FechaRegistro,t.IDStyleBackground,back.Value as Style  from Tareas.tblTablero t
    left JOIN  Tareas.tblTableroUsuarios tu on tu.IDReferencia=t.IDTablero  and tu.IDTipoTablero=1
    INNER JOIN Tareas.tblCatStylesBackground back on back.IDStyleBackground=t.IDStyleBackground
    WHERE (isnull(@IDTablero,0) =0 or T.IDTablero=@IDTablero) and ((tu.IDUsuario=@IDUsuario and @ValidarPermisoUsuario=1) or (@ValidarPermisoUsuario=0))
     
end
GO
