USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: Jose Vargas
** Email			: Jvargas@adagio.com.mx
** FechaCreacion	: 2023-10-11
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spIChatMensajes] ( 
    @IDUsuario int, 
    @IDTipoUsuario int,
    @Mensaje nvarchar(max),
    -- @IDReferencia int ,
    -- @IDTipoSala int ,
    @IDSala int
)  AS  
BEGIN          

    declare @IDChatMensaje int ;

    insert into Reclutamiento.tblChatMensajes (IDSala,IDUsuario,IDTipoUsuario,Mensaje)
    values (@IDSala,@IDUsuario,@IDTipoUsuario,@Mensaje)

    set @IDChatMensaje= @@IDENTITY 

    EXEC [Reclutamiento].[spBuscarChatMensajes]  @IDSala= @IDSala,@PageNumber = 1,@PageSize =1,@IDChatMensaje=@IDChatMensaje
    EXEC [Reclutamiento].[spIUChatUltimoVisto]  @IDSala=@IDSala,@IDUsuario=@IDUsuario,@IDTipoUsuario=@IDTipoUsuario,@UltimoIDChatMensaje=@IDChatMensaje

END
GO
