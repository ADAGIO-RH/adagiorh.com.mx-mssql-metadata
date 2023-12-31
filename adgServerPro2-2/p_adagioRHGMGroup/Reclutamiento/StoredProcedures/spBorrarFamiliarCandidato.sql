USE [p_adagioRHGMGroup]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/**************************************************************************************************** 
** Descripción		: <Procedure para Borrar el Catálogo de Expedientes Digitales>
** Autor			: 
** Email			: 
** FechaCreacion	: 
** Paremetros		:              
****************************************************************************************************
HISTORIAL DE CAMBIOS
Fecha(yyyy-mm-dd)	Autor				    Comentario
------------------- -------------------     ------------------------------------------------------------
0000-00-00		    NombreCompleto		    ¿Qué cambió?
***************************************************************************************************/

CREATE PROCEDURE [Reclutamiento].[spBorrarFamiliarCandidato]
(
	@IDFamiliarCandidato int
	,@IDUsuario int
)
AS
BEGIN

    declare @IDUsuarioAdmin int ,
        @Message varchar(max),
        @IDCandidato VARCHAR(max);

    select @IDUsuarioAdmin=cast(Valor as int)  from App.tblConfiguracionesGenerales where IDConfiguracion='IDUsuarioAdmin'

	SELECT [IDFamiliarCandidato]
      ,[IDCandidato]
      ,Parentescos.IDParentesco
      ,[NombreFamiliar]
      ,[FechaNacimientoFamiliar]
      ,[Vivo]
	  ,Parentescos.Descripcion as [NombreParentesco]
	  ,ROW_NUMBER()over(ORDER BY [IDFamiliarCandidato])as ROWNUMBER
	  FROM [Reclutamiento].[tblFamiliaresCandidato] candidato
	  inner join [RH].[TblCatParentescos] Parentescos on  Candidato.IDParentesco = Parentescos.IDParentesco
  	  WHERE ([IDFamiliarCandidato] = @IDFamiliarCandidato OR isnull(@IDFamiliarCandidato,0) = 0)



    if(@IDUsuario = 0)
    BEGIN
        select @IDCandidato=IDCandidato from Reclutamiento.tblFamiliaresCandidato where IDFamiliarCandidato=@IDFamiliarCandidato;
        SET @IDUsuario=@IDUsuarioAdmin;
        SET @Message = '{"IDCandidato":'+cast(@IDCandidato as varchar(5))+', "Carrers": 1 }';            
    END		

    DECLARE @OldJSON Varchar(Max)    

    select @OldJSON = a.JSON from [Reclutamiento].[tblFamiliaresCandidato] b
        Cross Apply (Select JSON=[Utilerias].[fnStrJSON](0,1,(Select b.* For XML Raw)) ) a
        WHERE b.IDFamiliarCandidato = @IDFamiliarCandidato
    
    EXEC [Auditoria].[spIAuditoria] @IDUsuario,'[Reclutamiento].[tblFamiliaresCandidato]','[Reclutamiento].[Reclutamiento].[spBorrarFamiliarCandidato]','DELETE','',@OldJSON,@Message;

    DELETE FROM [Reclutamiento].[tblFamiliaresCandidato]
    WHERE [IDFamiliarCandidato] = @IDFamiliarCandidato

END
GO
