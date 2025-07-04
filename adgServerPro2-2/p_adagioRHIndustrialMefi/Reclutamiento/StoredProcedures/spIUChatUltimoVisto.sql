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
CREATE PROCEDURE [Reclutamiento].[spIUChatUltimoVisto] (     
    @IDSala int,
    @IDUsuario int,
    @IDTipoUsuario int,
    @UltimoIDChatMensaje int    
)  AS  
BEGIN          

    declare @IDChatUltimoVisto int 
    select @IDChatUltimoVisto = IDChatUltimoVisto  from Reclutamiento.tblChatUltimoVisto where IDSala=@IDSala and  IDTipoUsuario=@IDTipoUsuario AND IDUsuario=@IDUsuario

    IF(  isnull(@IDChatUltimoVisto,0)=0)
    BEGIN
        insert into Reclutamiento.tblChatUltimoVisto(IDSala,IDUsuario,IDTipoUsuario,ultimoIDChatMensaje)        
        values (@IDSala,@IDUsuario,@IDTipoUsuario,@UltimoIDChatMensaje)            
    END ELSE
    BEGIN
        update Reclutamiento.tblChatUltimoVisto set ultimoIDChatMensaje=@UltimoIDChatMensaje where IDChatUltimoVisto=@IDChatUltimoVisto
    END
    
    EXEC [Reclutamiento].[spBuscarChatSala]  @IDUsuario=@IDUsuario, @IDTipoUsuario=@IDTipoUsuario , @IDSala=@IDSala
END
GO
