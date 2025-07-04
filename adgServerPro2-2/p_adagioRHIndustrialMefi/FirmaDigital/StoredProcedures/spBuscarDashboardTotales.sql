USE [p_adagioRHIndustrialMefi]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [FirmaDigital].[spBuscarDashboardTotales](
	@IDUsuario	int    
)
AS
BEGIN
	DECLARE  @Email Varchar(255) = null;
	SELECT @Email = Email from Seguridad.tblUsuarios with(nolock) where IDUsuario = @IDUsuario

	  DECLARE @ResultPendientesReqMiFirma AS TABLE(
			Id  Varchar(255)
			,IDTipoDocumento int
			,TipoDocumento  Varchar(255)
			,Nombre  Varchar(255)			
			,ExternalId  Varchar(255)
			,MessageForSigners  Varchar(MAX)
			,RemindEvery int
			,RemindEveryLabel  Varchar(255)
			,OriginalHash  Varchar(255)
			,FileName  Varchar(MAX)
			,SignedByAll bit
			,Signed bit
			,SignedAt datetime
			,DaysToExpire int
            ,[ExpiresAt]  DATETIME
            ,[CreatedAt]          DATETIME            
			,IDUsuario int
			,Usuario  Varchar(255)
            ,UsuarioEmail Varchar(255)
			,CallbackUrl  Varchar(max)
			,SignCallbackUrl   Varchar(max)
			,[File]   Varchar(max)
			,FileDownload   Varchar(max)
			,FileSigned  Varchar(max)
			,FileSignedDownload  Varchar(max)
			,FileZipped  Varchar(max)
			,ManualClose bit
			,SendMail bit
			,State Varchar(255)
            ,StateLabel Varchar(255)
            ,StateLabelVariant Varchar(255)
			,TotalPaginas int
			,TotalRegistros int
     )
	  DECLARE @ResultCompletadosFirmadosPorMI AS TABLE(
			Id  Varchar(255)
			,IDTipoDocumento int
			,TipoDocumento  Varchar(255)
			,Nombre  Varchar(255)			
			,ExternalId  Varchar(255)
			,MessageForSigners  Varchar(MAX)
			,RemindEvery int
			,RemindEveryLabel  Varchar(255)
			,OriginalHash  Varchar(255)
			,FileName  Varchar(MAX)
			,SignedByAll bit
			,Signed bit
			,SignedAt datetime
			,DaysToExpire int
            ,[ExpiresAt]  DATETIME
            ,[CreatedAt]          DATETIME            
			,IDUsuario int
			,Usuario  Varchar(255)
            ,UsuarioEmail Varchar(255)
			,CallbackUrl  Varchar(max)
			,SignCallbackUrl   Varchar(max)
			,[File]   Varchar(max)
			,FileDownload   Varchar(max)
			,FileSigned  Varchar(max)
			,FileSignedDownload  Varchar(max)
			,FileZipped  Varchar(max)
			,ManualClose bit
			,SendMail bit
			,State Varchar(255)
            ,StateLabel Varchar(255)
            ,StateLabelVariant Varchar(255)
			,TotalPaginas int
			,TotalRegistros int
     )
	  DECLARE @ResultPendientesCreadosPorMI AS TABLE(
			Id  Varchar(255)
			,IDTipoDocumento int
			,TipoDocumento  Varchar(255)
			,Nombre  Varchar(255)			
			,ExternalId  Varchar(255)
			,MessageForSigners  Varchar(MAX)
			,RemindEvery int
			,RemindEveryLabel  Varchar(255)
			,OriginalHash  Varchar(255)
			,FileName  Varchar(MAX)
			,SignedByAll bit
			,Signed bit
			,SignedAt datetime
			,DaysToExpire int
            ,[ExpiresAt]  DATETIME
            ,[CreatedAt]          DATETIME            
			,IDUsuario int
			,Usuario  Varchar(255)
            ,UsuarioEmail Varchar(255)
			,CallbackUrl  Varchar(max)
			,SignCallbackUrl   Varchar(max)
			,[File]   Varchar(max)
			,FileDownload   Varchar(max)
			,FileSigned  Varchar(max)
			,FileSignedDownload  Varchar(max)
			,FileZipped  Varchar(max)
			,ManualClose bit
			,SendMail bit
			,State Varchar(255)
            ,StateLabel Varchar(255)
            ,StateLabelVariant Varchar(255)
			,TotalPaginas int
			,TotalRegistros int
     )
	  DECLARE @ResultCompletadosCreadosPorMI AS TABLE(
			Id  Varchar(255)
			,IDTipoDocumento int
			,TipoDocumento  Varchar(255)
			,Nombre  Varchar(255)			
			,ExternalId  Varchar(255)
			,MessageForSigners  Varchar(MAX)
			,RemindEvery int
			,RemindEveryLabel  Varchar(255)
			,OriginalHash  Varchar(255)
			,FileName  Varchar(MAX)
			,SignedByAll bit
			,Signed bit
			,SignedAt datetime
			,DaysToExpire int
            ,[ExpiresAt]  DATETIME
            ,[CreatedAt]          DATETIME            
			,IDUsuario int
			,Usuario  Varchar(255)
            ,UsuarioEmail Varchar(255)
			,CallbackUrl  Varchar(max)
			,SignCallbackUrl   Varchar(max)
			,[File]   Varchar(max)
			,FileDownload   Varchar(max)
			,FileSigned  Varchar(max)
			,FileSignedDownload  Varchar(max)
			,FileZipped  Varchar(max)
			,ManualClose bit
			,SendMail bit
			,State Varchar(255)
            ,StateLabel Varchar(255)
            ,StateLabelVariant Varchar(255)
			,TotalPaginas int
			,TotalRegistros int
     )

	 INSERT INTO @ResultPendientesReqMiFirma
	 EXEC [FirmaDigital].[spBuscarDocumentos] @Tipo = 0, @IDUsuario = @IDUsuario

	 INSERT INTO @ResultCompletadosFirmadosPorMI
	 EXEC [FirmaDigital].[spBuscarDocumentos] @Tipo = 1, @IDUsuario = @IDUsuario

	 INSERT INTO @ResultPendientesCreadosPorMI
	 EXEC [FirmaDigital].[spBuscarDocumentos] @Tipo = 2, @IDUsuario = @IDUsuario

	 INSERT INTO @ResultCompletadosCreadosPorMI
	 EXEC [FirmaDigital].[spBuscarDocumentos] @Tipo = 3, @IDUsuario = @IDUsuario

	 SELECT 
			(
			SELECT COUNT(*) FROM @ResultPendientesReqMiFirma
		   ) AS PendientesReqMiFirma,
		   (
			SELECT COUNT(*) FROM @ResultCompletadosFirmadosPorMI
		   ) AS CompletadosFirmadosPorMI,
		   (
			SELECT COUNT(*) FROM @ResultPendientesCreadosPorMI
		   ) AS PendientesCreadosPorMI,
		    (
			SELECT COUNT(*) FROM @ResultCompletadosCreadosPorMI
		   ) AS CompletadosCreadosPorMI
END
GO
