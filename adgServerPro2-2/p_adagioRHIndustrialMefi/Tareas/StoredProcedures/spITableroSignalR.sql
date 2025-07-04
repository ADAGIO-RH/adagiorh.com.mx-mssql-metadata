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
CREATE proc [Tareas].[spITableroSignalR](    
    @IDReferencia int ,
    @IDTipoTablero int ,
    @IDUsuario int ,
    @Token varchar(200),
    @ConnectionId varchar(100)
) as
begin    

    IF NOT EXISTS(SELECT TOP 1 1 FROM Tareas.tblTableroSignalR where  ConnectionId=@ConnectionId and Token=@Token)
    BEGIN
        INSERT INTO Tareas.tblTableroSignalR(IDReferencia,IDTipoTablero,IDUsuario,Token,ConnectionId)
        VALUES(@IDReferencia,@IDTipoTablero,@IDUsuario,@Token,@ConnectionId)
    END     

    SELECT COUNT(*) AS UsuariosActivos FROM Tareas.tblTableroSignalR where Token=@Token
end
GO
