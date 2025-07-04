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
CREATE proc [Tareas].[spBorrarTableroSignalR](    
    @IDReferencia int ,
    @IDTipoTablero int ,
    @IDUsuario int ,
    @Token varchar(200),
    @ConnectionId varchar(100)
) as
begin    
    DELETE FROM Tareas.tblTableroSignalR where  ConnectionId=@ConnectionId and Token=@Token    
end
GO
