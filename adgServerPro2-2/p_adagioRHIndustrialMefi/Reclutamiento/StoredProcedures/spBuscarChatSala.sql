USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--set a default new query template with the command QE Boost: Set New Query Template


/**************************************************************************************************** 
** Descripción		: <Descripción,varchar,Descripción>
** Autor			: Jose Vargas
** Email			: Jvargas@adagio.com.mx
** FechaCreacion	: 2023-09-10
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spBuscarChatSala] (     
    @IDUsuario int, 
    @IDTipoUsuario int,
    @IDReferencia int =0,
    @IDTipoSala int =0,
    @IDSala int =0
)  AS  
BEGIN  
    SELECT sala.IDSala,sala.IDTipoSala,sala.IDReferencia,
        @IDUsuario IDUsuario,
        @IDTipoUsuario IDTipoUsuario,
       isnull((SELECT MAX(IDChatMensaje) FROM [Reclutamiento].[tblChatMensajes] where IDSala=sala.IDSala group by IDSala),0) AS Sala_UltimoChatIDMensaje,       
       ISNULL(ultimoVisto.UltimoIDChatMensaje, 0) AS Usuario_UltimoIDChatMensajeVisto,
       isnull((SELECT count(IDChatMensaje) FROM [Reclutamiento].[tblChatMensajes] where IDSala=sala.IDSala group by IDSala),0) AS TotalMensajes,
       CASE WHEN (SELECT MAX(IDChatMensaje) FROM [Reclutamiento].[tblChatMensajes] where IDSala=sala.IDSala group by IDSala) > ISNULL(ultimoVisto.UltimoIDChatMensaje, 0) THEN 1 ELSE 0 END AS TieneMensajesNuevos
    FROM Reclutamiento.tblChatSala sala
    LEFT JOIN [Reclutamiento].[tblChatUltimoVisto] ultimoVisto ON ultimoVisto.IDSala = sala.IDSala and ultimoVisto.IDUsuario=@IDUsuario and ultimoVisto.IDTipoUsuario=@IDTipoUsuario
    WHERE  (sala.IDTipoSala=@IDTipoSala and sala.IDReferencia=@IDReferencia) or sala.IDSala=@IDSala
END
GO
