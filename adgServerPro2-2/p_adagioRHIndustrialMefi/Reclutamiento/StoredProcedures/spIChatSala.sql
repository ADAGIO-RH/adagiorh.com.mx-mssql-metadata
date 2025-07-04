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
** FechaCreacion	: 2023-10-11
** Paremetros		:              

** DataTypes Relacionados: 
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				Comentario
------------------- ------------------- ------------------------------------------------------------
0000-00-00			NombreCompleto		¿Qué cambió?
***************************************************************************************************/
CREATE PROCEDURE [Reclutamiento].[spIChatSala] (     
    @IDTipoSala int,
    @IDReferencia int,
    @IDUsuario int ,
    @IDTipoUsuario int
    
)  AS  
BEGIN          

    DECLARE @IDSala int 
    SELECT @IDSala=IDSala from reclutamiento.tblchatSala where IDReferencia=@IDReferencia AND IDTipoSala=@IDTipoSala
    

    IF(  isnull(@IDSala,0)=0)
    BEGIN
        insert into Reclutamiento.tblChatSala(IDReferencia,IDTipoSala)
        values (@IDReferencia,@IDTipoSala)   
         set  @IDSala = @@IDENTITY
    END    
    
    EXEC [Reclutamiento].[spBuscarChatSala]  @IDUsuario=@IDUsuario, @IDTipoUsuario=@IDTipoUsuario , @IDSala=@IDSala
    

END
GO
